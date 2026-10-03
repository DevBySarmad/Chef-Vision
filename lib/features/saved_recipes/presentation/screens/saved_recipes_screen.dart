import 'package:flutter/material.dart';

import '../../data/services/firestore_saved_recipes_service.dart';
import '../../domain/entities/saved_recipe.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({required this.service, super.key});

  final FirestoreSavedRecipesService service;

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  late final Stream<List<SavedRecipe>> _savedRecipes;

  @override
  void initState() {
    super.initState();
    _savedRecipes = widget.service.watchSavedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Recipes')),
      body: StreamBuilder<List<SavedRecipe>>(
        stream: _savedRecipes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.cloud_off_outlined,
              message: 'Could not load saved recipes. Check your connection.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipes = snapshot.data!;
          if (recipes.isEmpty) {
            return const _MessageState(
              icon: Icons.bookmark_border,
              message: 'Saved recipes will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _SavedRecipeTile(
              recipe: recipes[index],
              onDelete: () => _deleteRecipe(recipes[index]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteRecipe(SavedRecipe recipe) async {
    try {
      await widget.service.deleteRecipe(recipe.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove recipe: $error')),
      );
    }
  }
}

class _SavedRecipeTile extends StatelessWidget {
  const _SavedRecipeTile({required this.recipe, required this.onDelete});

  final SavedRecipe recipe;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final savedDate = recipe.savedAt?.toLocal().toString().split('.').first;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.bookmark, color: Color(0xFF284C3B)),
        title: Text(
          recipe.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            recipe.preparationTime,
            recipe.cookingTime,
          ].where((time) => time.isNotEmpty).join(' prep · '),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          _RecipeSection(
            title: 'Detected ingredients',
            items: recipe.detectedIngredients,
          ),
          _RecipeSection(
            title: 'Recipe ingredients',
            items: recipe.ingredients,
          ),
          _RecipeSection(title: 'Steps', items: recipe.steps, numbered: true),
          if (savedDate != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Saved $savedDate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Remove saved recipe',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({
    required this.title,
    required this.items,
    this.numbered = false,
  });

  final String title;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                numbered
                    ? '${index + 1}. ${items[index]}'
                    : '• ${items[index]}',
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 38, color: const Color(0xFF52705C)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
