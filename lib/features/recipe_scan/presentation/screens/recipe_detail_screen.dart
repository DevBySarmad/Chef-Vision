import 'package:flutter/material.dart';

import '../../domain/entities/recipe_scan_result.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({required this.recipe, super.key});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF284C3B);
    const orange = Color(0xFFBE6B3F);
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              recipe.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: forest, fontWeight: FontWeight.w800),
            ),
            if (recipe.summary.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                recipe.summary.trim(),
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: const Color(0xFF686E67)),
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _TimeBadge(
                  icon: Icons.schedule_outlined,
                  title: 'Preparation',
                  value: recipe.preparationTime,
                ),
                _TimeBadge(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Cooking',
                  value: recipe.cookingTime,
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: forest, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (recipe.ingredients.isEmpty)
              const Text('No ingredient list was provided.')
            else
              for (final ingredient in recipe.ingredients)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 19,
                          color: orange,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(child: Text(ingredient)),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            Text(
              'Step-by-step method',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: forest, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (recipe.steps.isEmpty)
              const Text('No cooking instructions were provided.')
            else
              for (var index = 0; index < recipe.steps.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EFE8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: forest,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(recipe.steps[index]),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E6DD)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFBE6B3F)),
          const SizedBox(width: 7),
          Text('$title: $value'),
        ],
      ),
    );
  }
}
