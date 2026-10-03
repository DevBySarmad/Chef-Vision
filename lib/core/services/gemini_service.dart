// ignore_for_file: prefer_single_quotes

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../features/recipe_scan/domain/entities/recipe_scan_result.dart';

class GeminiService {
  GeminiService({this.httpClient, String? apiKey})
    : _groqApiKey = apiKey ?? ApiConstants.groqApiKey;

  final http.Client? httpClient;
  final String _groqApiKey;
  static const String _groqEndpoint = ApiConstants.groqEndpoint;

  // Primary model with higher OTPM rate limits
  final List<String> _modelsToTry = const [
    'llama-3.2-11b-vision-preview',
    'llama-3.2-90b-vision-preview',
    'qwen/qwen3.8-27b',
  ];

  Future<RecipeScanResult> createRecipeSuggestions({
    required List<int> imageBytes,
    required String mimeType,
  }) async {
    if (_groqApiKey.trim().isEmpty) {
      throw StateError(
        'Missing GROQ_API_KEY. Set it with --dart-define or .vscode/launch.json.',
      );
    }

    const promptText = '''
You are ChefVision. Inspect the attached image and return ONLY a single valid JSON object.

Exact JSON structure:
{"detectedIngredients":["..."],"recipes":[{"title":"...","preparationTime":"...","cookingTime":"...","ingredients":["..."],"steps":["..."]}]}

Rules:
1. Identify visible ingredients or dishes.
2. Provide minimum 1 dish and maximum 3 distinct dishes.
3. Keep preparation steps, ingredients, and descriptions extremely short and concise to fit token limits.
4. If not food, return an empty recipes array.
''';

    final base64Image = base64Encode(imageBytes);
    Object? lastError;

    for (final modelName in _modelsToTry) {
      try {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        };
        final body = jsonEncode({
          "model": modelName,
          "max_tokens": 500,
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": promptText},
                {
                  "type": "image_url",
                  "image_url": {"url": "data:$mimeType;base64,$base64Image"},
                },
              ],
            },
          ],
          "response_format": {"type": "json_object"},
        });
        final uri = Uri.parse(_groqEndpoint);
        final response =
            await (httpClient?.post(uri, headers: headers, body: body) ??
                http.post(uri, headers: headers, body: body));

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final text = resData['choices']?[0]?['message']?['content']
              ?.toString()
              .trim();

          if (text == null || text.isEmpty) continue;

          final decoded = jsonDecode(text);
          if (decoded is! Map<String, dynamic>) continue;

          final rawRecipes = decoded['recipes'];
          if (rawRecipes is! List) {
            return RecipeScanResult(
              detectedIngredients: _readStringList(
                decoded['detectedIngredients'],
              ),
              recipes: const [],
            );
          }

          final recipes = rawRecipes
              .map(_recipeFromJson)
              .whereType<RecipeSuggestion>()
              .take(3)
              .toList(growable: false);

          return RecipeScanResult(
            detectedIngredients: _readStringList(
              decoded['detectedIngredients'],
            ),
            recipes: recipes,
          );
        } else if (response.statusCode == 401) {
          lastError = 'Groq rejected GROQ_API_KEY (HTTP 401).';
          break;
        } else {
          lastError =
              'Model $modelName HTTP ${response.statusCode}: ${response.body}';
        }
      } catch (e) {
        lastError = 'Model $modelName Exception: $e';
      }
    }

    throw StateError('Recipe scan failed. Details: $lastError');
  }

  RecipeSuggestion? _recipeFromJson(Object? value) {
    if (value is! Map) return null;
    final recipe = Map<String, dynamic>.from(value);
    final title = recipe['title']?.toString().trim() ?? '';
    if (title.isEmpty) return null;

    return RecipeSuggestion(
      title: title,
      preparationTime: recipe['preparationTime']?.toString().trim() ?? '',
      cookingTime: recipe['cookingTime']?.toString().trim() ?? '',
      ingredients: _readStringList(recipe['ingredients']),
      steps: _readStringList(recipe['steps']),
    );
  }

  List<String> _readStringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
