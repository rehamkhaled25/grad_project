import os
import json
import time
import sys
import google.generativeai as genai
import PIL.Image
import typing_extensions as typing
from flask import current_app


class FoodItem(typing.TypedDict):
    name: str
    weight_g: int
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float
    item_gi: int
    item_gl: float


class HiddenIngredientReport(typing.TypedDict):
    name: str
    impact_calories: int
    impact_protein_g: float
    impact_carbs_g: float
    impact_fat_g: float
    impact_explanation: str
    general_info: str


class NutritionReport(typing.TypedDict):
    meal_name: str
    total_calories: int
    total_protein: float
    total_carbs: float
    total_fat: float
    protein_dv_percent: int
    carbs_dv_percent: int
    fat_dv_percent: int
    fiber_g: float
    sugar_g: float
    sodium_mg: float
    magnesium_mg: float
    calcium_mg: float
    vitamin_c_mg: float
    vitamins_others: list[str]
    minerals_others: list[str]
    total_gl: float
    gl_category: str
    glycemic_index: int
    glycemic_index_rating: str
    health_score: int
    is_processed_estimate: bool
    metabolic_warning: str
    health_tip: str
    user_summary: str
    missing_nutrients: list[str]
    items: list[FoodItem]
    hidden_ingredients: list[HiddenIngredientReport]


MASTER_PROMPT = """Act as a Clinical Nutrition Scientist. Analyze this image with high precision.
Context provided by user: {context}
Calculate Macros vs DV%, Micros (Magnesium, Calcium, Sodium, Vit C), and Glycemic Index and Glycemic Load.
Identify and list other vitamins present in the food inside the `vitamins_others` field (e.g., ["Vitamin A", "Vitamin B6", "Vitamin D"]), and other minerals inside `minerals_others`.
Ensure mathematical consistency across the report.
Return health_score as an integer from 0 to 10 only, not as a percentage.

If the user mentions any hidden ingredients in the context:
1. Populate the `hidden_ingredients` list with an entry for each identified hidden ingredient.
2. Estimate its specific impact (calories, protein, carbs, fat) and how much it increases/changes the meal's overall intake.
3. Write a clear, concise impact_explanation (e.g. "Adds 120 kcal of fat") and provide a general_info string explaining general facts/health impacts of that ingredient.
4. If no hidden ingredients are specified, return an empty list for `hidden_ingredients`."""


def get_api_keys():
    keys = []
    # 1. Try GEMINI_API_KEY (might be comma-separated list of keys)
    primary = None
    try:
        primary = current_app.config.get("GEMINI_API_KEY")
    except Exception:
        pass
    if not primary:
        primary = os.getenv("GEMINI_API_KEY")
        
    if primary:
        for k in primary.split(','):
            k = k.strip()
            if k and k != "your_api_key_here" and k not in keys:
                keys.append(k)

    # 2. Try GEMINI_API_KEY_2, GEMINI_API_KEY_3, etc.
    i = 2
    while True:
        key = os.getenv(f"GEMINI_API_KEY_{i}")
        if not key:
            break
        k = key.strip()
        if k and k != "your_api_key_here" and k not in keys:
            keys.append(k)
        i += 1
        
    return keys


def _generate_with_key_rotation(model_creator, content_generator):
    keys = get_api_keys()
    if not keys:
        raise ValueError("No GEMINI_API_KEY found in config or environment variables")

    last_error = None
    for attempt in range(max(3, len(keys))):
        key = keys[attempt % len(keys)]
        try:
            model = model_creator(key)
            return content_generator(model)
        except Exception as e:
            err_str = str(e).lower()
            is_quota_or_auth = (
                "429" in err_str or
                "quota" in err_str or
                "limit" in err_str or
                "invalid" in err_str or
                "400" in err_str or
                "403" in err_str
            )
            if is_quota_or_auth and len(keys) > 1:
                sys.stdout.write(
                    f"\nGemini API call failed with key index {attempt % len(keys)}. Rotating key... Error: {e}\n"
                )
                sys.stdout.flush()
                time.sleep(1)
                last_error = e
                continue
            else:
                raise e

    if last_error:
        raise last_error
    raise RuntimeError("Failed to generate content after exhausting keys")


def analyze_meal(image_path, context=""):
    image = PIL.Image.open(image_path)
    image.thumbnail((600, 600))
    prompt = MASTER_PROMPT.format(context=context or "")

    def model_creator(api_key):
        genai.configure(api_key=api_key, transport="rest")
        return genai.GenerativeModel(
            model_name="gemini-2.5-flash",
            generation_config={
                "response_mime_type": "application/json",
                "response_schema": NutritionReport,
            },
        )

    def content_generator(model):
        response = model.generate_content([prompt, image])
        if response is None or not response.text:
            raise RuntimeError("Gemini API returned an empty response")
        return json.loads(response.text)

    return _generate_with_key_rotation(model_creator, content_generator)


def analyze_food_name(food_name, serving_size="", context=""):
    prompt = f"""Act as a Clinical Nutrition Scientist.

Analyze this food entry based on the user's text only.

Food name: {food_name}
Serving size or quantity: {serving_size}
Extra context: {context}

Estimate the nutrition values as accurately as possible.
Calculate calories, macros, daily value percentages, fiber, sugar, sodium, key micronutrients, glycemic index, glycemic load, and health score.
Identify and list other vitamins present in the food inside the `vitamins_others` field (e.g., ["Vitamin A", "Vitamin B6", "Vitamin D"]), and other minerals inside `minerals_others`.

Important rules:
- Return valid JSON only.
- health_score must be an integer from 0 to 10 only, not a percentage.
- If the quantity is unclear, estimate a common serving size and mention that in user_summary.
- Be realistic and conservative with estimates.

If the user mentions any hidden ingredients in the extra context:
1. Populate the `hidden_ingredients` list with an entry for each identified hidden ingredient.
2. Estimate its specific impact (calories, protein, carbs, fat) and how much it increases/changes the meal's overall intake.
3. Write a clear, concise impact_explanation (e.g. "Adds 120 kcal of fat") and provide a general_info string explaining general facts/health impacts of that ingredient.
4. If no hidden ingredients are specified, return an empty list for `hidden_ingredients`.
"""

    def model_creator(api_key):
        genai.configure(api_key=api_key, transport="rest")
        return genai.GenerativeModel(
            model_name="gemini-2.5-flash",
            generation_config={
                "response_mime_type": "application/json",
                "response_schema": NutritionReport,
            },
        )

    def content_generator(model):
        response = model.generate_content([prompt])
        if response is None or not response.text:
            raise RuntimeError("Gemini API returned an empty response")
        data = json.loads(response.text)
        health_score = data.get("health_score")
        try:
            health_score = float(health_score)
            if health_score > 10:
                health_score = round(health_score / 10)
            health_score = max(0, min(10, int(health_score)))
        except Exception:
            health_score = None
        data["health_score"] = health_score
        return data

    return _generate_with_key_rotation(model_creator, content_generator)
