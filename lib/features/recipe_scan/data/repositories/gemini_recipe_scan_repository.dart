import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/recipe_scan_result.dart';
import '../../domain/repositories/recipe_scan_repository.dart';

class GeminiRecipeScanRepository implements RecipeScanRepository {
  GeminiRecipeScanRepository(this._geminiService);

  final GeminiService _geminiService;

  @override
  Future<RecipeScanResult> suggestRecipes({
    required List<int> imageBytes,
    required String mimeType,
  }) {
    return _geminiService.createRecipeSuggestions(
      imageBytes: imageBytes,
      mimeType: mimeType,
    );
  }
}
