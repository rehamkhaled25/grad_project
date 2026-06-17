import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final List<String> _apiKeys = [];
  static int _currentKeyIndex = 0;

  static void initialize() {
    _apiKeys.clear();
    
    // 1. Try to read comma-separated keys from GEMINI_API_KEY
    final rawKey = dotenv.env['GEMINI_API_KEY'];
    if (rawKey != null && rawKey.isNotEmpty) {
      final keys = rawKey
          .split(',')
          .map((k) => k.trim())
          .where((k) => k.isNotEmpty && k != 'your_api_key_here');
      _apiKeys.addAll(keys);
    }
    
    // 2. Try to read from GEMINI_API_KEY_2, GEMINI_API_KEY_3, etc.
    int i = 2;
    while (true) {
      final key = dotenv.env['GEMINI_API_KEY_$i'];
      if (key == null || key.isEmpty) break;
      final trimmed = key.trim();
      if (trimmed.isNotEmpty && trimmed != 'your_api_key_here' && !_apiKeys.contains(trimmed)) {
        _apiKeys.add(trimmed);
      }
      i++;
    }

    _currentKeyIndex = 0;
    debugPrint("GeminiService initialized with ${_apiKeys.length} API keys.");
  }

  static List<String> get apiKeys => _apiKeys;

  static String? get activeKey {
    if (_apiKeys.isEmpty) return null;
    return _apiKeys[_currentKeyIndex];
  }

  static void rotateKey() {
    if (_apiKeys.length <= 1) return;
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    debugPrint("Rotated Gemini API key to index $_currentKeyIndex.");
  }

  static GenerativeModel? getModel({
    required String modelName,
    Content? systemInstruction,
    GenerationConfig? generationConfig,
  }) {
    final key = activeKey;
    if (key == null || key.isEmpty) return null;

    return GenerativeModel(
      model: modelName,
      apiKey: key,
      systemInstruction: systemInstruction,
      generationConfig: generationConfig,
    );
  }
}
