import 'package:flutter/material.dart';

import '../../features/recipe_scan/domain/entities/recipe_scan_result.dart';
import '../../features/recipe_scan/presentation/screens/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    required this.recipe,
    required this.onSave,
    this.isSaved = false,
    this.isSaving = false,
    super.key,
  });

  final RecipeSuggestion recipe;
  final VoidCallback onSave;
  final bool isSaved;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final summary = recipe.summary.trim().isNotEmpty
        ? recipe.summary.trim()
        : recipe.ingredients.take(3).join(' · ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF284C3B),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _RecipeMeta(
                    icon: Icons.schedule_outlined,
                    label: 'Prep ${recipe.preparationTime}',
                  ),
                  _RecipeMeta(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Cook ${recipe.cookingTime}',
                  ),
                ],
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF686E67)),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: isSaved || isSaving ? null : onSave,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_added
                          : Icons.bookmark_add_outlined,
                    ),
                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : isSaved
                          ? 'Saved'
                          : 'Save Recipe',
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeMeta extends StatelessWidget {
  const _RecipeMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFBE6B3F)),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
