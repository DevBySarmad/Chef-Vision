import '../entities/recipe_scan_result.dart';

abstract interface class RecipeScanRepository {
  Future<RecipeScanResult> suggestRecipes({
    required List<int> imageBytes,
    required String mimeType,
  });
}
