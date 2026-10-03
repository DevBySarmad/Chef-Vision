import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/gemini_service.dart';
import '../../features/recipe_scan/domain/entities/recipe_scan_result.dart';
import '../../features/recipe_scan/data/repositories/gemini_recipe_scan_repository.dart';
import '../../features/recipe_scan/domain/use_cases/scan_ingredients_use_case.dart';
import '../../features/saved_recipes/data/services/firestore_saved_recipes_service.dart';
import '../../features/saved_recipes/presentation/screens/saved_recipes_screen.dart';
import '../common_widgets/action_card.dart';
import '../common_widgets/custom_button.dart';
import '../common_widgets/recipe_card.dart';
import '../common_widgets/scan_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final FirestoreSavedRecipesService _savedRecipesService =
      FirestoreSavedRecipesService();
  late final ScanIngredientsUseCase _scanIngredients;
  XFile? _image;
  Uint8List? _imageBytes;
  RecipeScanResult? _scanResult;
  String? _errorMessage;
  bool _isLoading = false;
  final Set<String> _savingRecipes = {};
  final Set<String> _savedRecipeTitles = {};

  @override
  void initState() {
    super.initState();
    _scanIngredients = ScanIngredientsUseCase(
      GeminiRecipeScanRepository(GeminiService()),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (!mounted || image == null) return;
      final imageBytes = await image.readAsBytes();
      setState(() {
        _image = image;
        _imageBytes = imageBytes;
        _scanResult = null;
        _savedRecipeTitles.clear();
        _errorMessage = null;
      });
    } catch (error) {
      _showError('Could not open the selected image: $error');
    }
  }

  Future<void> _scanImage() async {
    final image = _image;
    if (image == null || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _scanResult = null;
      _savedRecipeTitles.clear();
    });
    try {
      final result = await _scanIngredients(
        imageBytes: _imageBytes!,
        mimeType: _mimeType(image.name),
      );
      if (mounted) setState(() => _scanResult = result);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRecipe(RecipeSuggestion recipe) async {
    if (_scanResult == null || _savingRecipes.contains(recipe.title)) return;
    setState(() => _savingRecipes.add(recipe.title));
    try {
      await _savedRecipesService.saveRecipe(
        scanResult: _scanResult!,
        recipe: recipe,
      );
      if (!mounted) return;
      setState(() => _savedRecipeTitles.add(recipe.title));
      _showError('Saved ${recipe.title} to your recipes.');
    } catch (error) {
      _showError('Could not save recipe: $error');
    } finally {
      if (mounted) setState(() => _savingRecipes.remove(recipe.title));
    }
  }

  Future<void> _openSavedRecipes() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SavedRecipesScreen(service: _savedRecipesService),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      _showError('Could not sign out: $error');
    }
  }

  String _mimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }

  String _friendlyError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return 'Recipe scan failed. $message';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionCard(
                title: 'Take a photo',
                subtitle: 'Scan what is on your counter',
                icon: Icons.photo_camera_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ActionCard(
                title: 'Choose from gallery',
                subtitle: 'Use a photo already on your device',
                icon: Icons.photo_library_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, size: 23),
            SizedBox(width: 9),
            Text('Chef Vision', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved recipes',
            onPressed: _openSavedRecipes,
            icon: const Icon(Icons.bookmarks_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Make something\ndelicious.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF284C3B),
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show us what you have. We’ll find the meal in it.',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: const Color(0xFF676C65)),
            ),
            const SizedBox(height: 22),
            if (_image == null) _imagePlaceholder() else _imagePreview(),
            const SizedBox(height: 14),
            if (_image == null)
              ActionCard(
                title: 'Add an ingredient photo',
                subtitle: 'Camera or photo library',
                icon: Icons.add_a_photo_outlined,
                onTap: _showImageSourcePicker,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: _scanResult == null
                          ? 'Find My Recipe'
                          : 'Scan Again',
                      onPressed: _scanImage,
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Choose a different image',
                    onPressed: _isLoading ? null : _showImageSourcePicker,
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ],
              ),
            if (_isLoading) const ScanLoader(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 18),
              _ErrorNotice(message: _errorMessage!),
            ],
            if (_scanResult != null) ...[
              const SizedBox(height: 26),
              const Text(
                'Your recipe ideas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF284C3B),
                ),
              ),
              const SizedBox(height: 10),
              if (_scanResult!.detectedIngredients.isNotEmpty) ...[
                const Text(
                  'Detected ingredients',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 7,
                  runSpacing: 4,
                  children: [
                    for (final ingredient in _scanResult!.detectedIngredients)
                      Chip(label: Text(ingredient)),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              if (_scanResult!.recipes.isEmpty)
                const _ErrorNotice(
                  message:
                      'No recipe suggestions were returned for this image.',
                )
              else
                for (final recipe in _scanResult!.recipes) ...[
                  RecipeCard(
                    recipe: recipe,
                    isSaved: _savedRecipeTitles.contains(recipe.title),
                    isSaving: _savingRecipes.contains(recipe.title),
                    onSave: () => _saveRecipe(recipe),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE3D8)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_back_outlined,
              size: 42,
              color: Color(0xFF52705C),
            ),
            SizedBox(height: 10),
            Text(
              'Your ingredients, in one frame',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Produce, pantry staples, leftovers',
              style: TextStyle(color: Color(0xFF72766F)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        _imageBytes!,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          color: const Color(0xFFECEFE7),
          alignment: Alignment.center,
          child: const Text('Image preview unavailable'),
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDEA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF9A3D2A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF713426)),
            ),
          ),
        ],
      ),
    );
  }
}
