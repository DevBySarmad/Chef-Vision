class RecipeScanResult {
  const RecipeScanResult({
    required this.detectedIngredients,
    required this.recipes,
  });

  final List<String> detectedIngredients;
  final List<RecipeSuggestion> recipes;
}

class RecipeSuggestion {
  const RecipeSuggestion({
    required this.title,
    this.summary = '',
    required this.preparationTime,
    required this.cookingTime,
    required this.ingredients,
    required this.steps,
  });

  final String title;
  final String summary;
  final String preparationTime;
  final String cookingTime;
  final List<String> ingredients;
  final List<String> steps;
}
