class SavedRecipe {
  const SavedRecipe({
    required this.id,
    required this.title,
    required this.detectedIngredients,
    required this.ingredients,
    required this.steps,
    required this.preparationTime,
    required this.cookingTime,
    required this.savedAt,
  });

  final String id;
  final String title;
  final List<String> detectedIngredients;
  final List<String> ingredients;
  final List<String> steps;
  final String preparationTime;
  final String cookingTime;
  final DateTime? savedAt;
}
