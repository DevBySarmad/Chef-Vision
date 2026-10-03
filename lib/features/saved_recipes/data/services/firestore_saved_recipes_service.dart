import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../recipe_scan/domain/entities/recipe_scan_result.dart';
import '../../domain/entities/saved_recipe.dart';

class FirestoreSavedRecipesService {
  FirestoreSavedRecipesService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('saved_recipes');

  Future<void> saveRecipe({
    required RecipeScanResult scanResult,
    required RecipeSuggestion recipe,
  }) {
    return _recipes.add({
      'recipeTitle': recipe.title,
      'detectedIngredients': scanResult.detectedIngredients,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'preparationTime': recipe.preparationTime,
      'cookingTime': recipe.cookingTime,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<SavedRecipe>> watchSavedRecipes() {
    return _recipes
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }

  Future<void> deleteRecipe(String id) => _recipes.doc(id).delete();

  SavedRecipe _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final savedAt = data['savedAt'];
    return SavedRecipe(
      id: document.id,
      title: data['recipeTitle'] as String? ?? 'Untitled recipe',
      detectedIngredients: _readStrings(data['detectedIngredients']),
      ingredients: _readStrings(data['ingredients']),
      steps: _readStrings(data['steps']),
      preparationTime: data['preparationTime'] as String? ?? '',
      cookingTime: data['cookingTime'] as String? ?? '',
      savedAt: savedAt is Timestamp ? savedAt.toDate() : null,
    );
  }

  List<String> _readStrings(Object? value) {
    if (value is! Iterable) return const [];
    return value.whereType<String>().toList(growable: false);
  }
}
