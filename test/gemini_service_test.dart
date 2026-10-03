import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:chef_vision/core/services/gemini_service.dart';

void main() {
  test('sends the configured key and parses a Groq recipe response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url,
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      );
      expect(
        request.headers['authorization'] ?? request.headers['Authorization'],
        'Bearer test-groq-key',
      );

      final requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      expect(requestBody['model'], 'llama-3.2-11b-vision-preview');

      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'detectedIngredients': ['tomato', 'egg'],
                  'recipes': [
                    {
                      'title': 'Tomato eggs',
                      'preparationTime': '3 minutes',
                      'cookingTime': '7 minutes',
                      'ingredients': ['2 eggs', '1 tomato'],
                      'steps': ['Chop the tomato.', 'Cook with the eggs.'],
                    },
                  ],
                }),
              },
            },
          ],
        }),
        200,
      );
    });

    final result = await GeminiService(
      httpClient: client,
      apiKey: 'test-groq-key',
    ).createRecipeSuggestions(imageBytes: [1, 2, 3], mimeType: 'image/png');

    expect(result.detectedIngredients, ['tomato', 'egg']);
    expect(result.recipes, hasLength(1));
    expect(result.recipes.single.title, 'Tomato eggs');
    expect(result.recipes.single.ingredients, ['2 eggs', '1 tomato']);
    expect(result.recipes.single.steps, [
      'Chop the tomato.',
      'Cook with the eggs.',
    ]);
  });

  test('stops model fallback after an unauthorized response', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return http.Response('Unauthorized', 401);
    });

    await expectLater(
      GeminiService(
        httpClient: client,
        apiKey: 'invalid-test-key',
      ).createRecipeSuggestions(imageBytes: [1, 2, 3], mimeType: 'image/png'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('HTTP 401'),
        ),
      ),
    );
    expect(requestCount, 1);
  });
}
