abstract final class ApiConstants {
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static const String groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';
}
