import '../repositories/recipe_scan_repository.dart';
import '../entities/recipe_scan_result.dart';

class ScanIngredientsUseCase {
  const ScanIngredientsUseCase(this._repository);

  final RecipeScanRepository _repository;

  Future<RecipeScanResult> call({
    required List<int> imageBytes,
    required String mimeType,
  }) {
    return _repository.suggestRecipes(
      imageBytes: imageBytes,
      mimeType: mimeType,
    );
  }
}
