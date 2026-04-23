import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';

class Allergies extends StatefulWidget {
  const Allergies({super.key});

  @override
  State<Allergies> createState() => _AllergiesState();
}

class _AllergiesState extends State<Allergies> {
  // Use a List instead of a Set to maintain selection order for consistent numbering
  List<String> selectedAllergies = [];
  List<String> customAllergies = [];
  final TextEditingController _customController = TextEditingController();

  void _showAddCustomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: Material(
          color: Colors.transparent,
          child: Popup(
            controller: _customController,
            onCancel: () {
              _customController.clear();
              Navigator.pop(context);
            },
            onAdd: () {
              if (_customController.text.isNotEmpty) {
                setState(() {
                  customAllergies.add(_customController.text);
                });
                _customController.clear();
              }
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
      
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomAppbar(currentStep: 1, totalSteps: 8),
                SizedBox(height: height * 0.02),
                const Center(
                  child: Text(
                    "Got any allergies?",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
                const SizedBox(height: 5),
                const Center(
                  child: Text(
                    "Add them here and we'll keep an \n eye out while you track your meals.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0XFF706B6B)),
                  ),
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFoodContainer('Peanuts', 'assets/images/peanut.png', width, height),
                    _buildFoodContainer('Gluten', 'assets/images/gluten.png', width, height),
                    _buildFoodContainer('Eggs', 'assets/images/egg.png', width, height),
                  ],
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFoodContainer('Milk', 'assets/images/milk.png', width, height),
                    _buildFoodContainer('Fish', 'assets/images/fish.png', width, height),
                    _buildFoodContainer('Soy', 'assets/images/soysauce.png', width, height),
                  ],
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFoodContainer('Shellfish', 'assets/images/lobster.png', width, height),
                    _buildFoodContainer('Strawberry', 'assets/images/strawberry.png', width, height),
                    _buildFoodContainer('Lactose', 'assets/images/cheese.png', width, height),
                  ],
                ),
                SizedBox(height: height * 0.07),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.042),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...customAllergies.map((allergy) => _buildCustomChip(allergy)),
                      GestureDetector(
                        onTap: _showAddCustomDialog,
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(radius: Radius.circular(40),
                          color:  const Color(0xffD9D9D9),),
                         
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Color(0xff605A5A), size: 20),
                                SizedBox(width: 4),
                                Text(
                                  "Add custom allergy",
                                  style: TextStyle(fontSize: 12, color: Color(0xff706B6B)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.1), // Spacer space before button
                ContinueButton(txt: "Continue", onPressed: () {}),
                SizedBox(height: height * 0.051),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodContainer(String text, String image, double width, double height) {
   
    int selectionIndex = selectedAllergies.indexOf(text);
    bool isSelected = selectionIndex != -1;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAllergies.remove(text);
          } else {
            selectedAllergies.add(text);
          }
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width * 0.252,
            height: height * 0.099,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? const Color(0xffD90C0C) : const Color(0xffD9D9D9),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(image, height: 30),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -5,
              right: -5,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black,
                child: Text(
                  "${selectionIndex + 1}", 
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomChip(String text) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xffD90C0C)),
          ),
          child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xff706B6B))),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                customAllergies.remove(text);
              });
            },
            child: const CloseWidget(),
          ),
        ),
      ],
    );
  }
}

class Popup extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const Popup({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add a custom allergy",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: "e.g, Strawberries, apples",
                hintStyle: TextStyle(color: Color(0xffBBBABA), fontSize: 10, fontWeight: FontWeight.w500),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffD90C0C))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffD90C0C))),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    width: 80, height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xffD9D9D9), borderRadius: BorderRadius.circular(10)),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black, fontSize: 10)),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 80, height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                    child: const Text("Add", style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CloseWidget extends StatelessWidget {
  const CloseWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 10,
      backgroundColor: Colors.black,
      child: Icon(Icons.close, color: Colors.white, size: 12),
    );
  }
}