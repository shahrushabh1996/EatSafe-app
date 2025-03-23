import 'package:flutter/material.dart';
import '../models/nutritional_data.dart';
import '../utils/widgets_util.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final List<String> allergens;

  const IngredientCard({
    Key? key,
    required this.ingredient,
    required this.allergens,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int healthScore = ingredient.healthScore;
    final theme = Theme.of(context);
    
    // Print debug info
    print('Rendering IngredientCard for: ${ingredient.name}');

    // Determine card background color based on health score
    Color cardColor;
    Color textColor;
    if (healthScore >= 7) {
      cardColor = const Color(0xFF21FF5F);
      textColor = const Color(0xFF181818);
    } else if (healthScore >= 4) {
      cardColor = const Color(0xFFFF5C01);
      textColor = const Color(0xFFE1E1E1);
    } else {
      cardColor = const Color(0xFFFF3B30);
      textColor = Colors.white;
    }

    final bool isAllergen = allergens
        .any((allergen) => allergen.toLowerCase().contains(ingredient.name.toLowerCase()));

    // Create a title-cased version of the name
    final String titleCasedName = _toTitleCase(ingredient.name);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ingredient name and health score in separate rows for long names
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ingredient name in a flexible container
                        Expanded(
                          child: WidgetsUtil.buildTooltipText(
                            text: titleCasedName,
                            style: theme.textTheme.headlineMedium!.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,  // Allow 2 lines for long names
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Health score badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WidgetsUtil.buildTooltipText(
                                text: '$healthScore',
                                style: theme.textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFF181818),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFEE4A),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Allergen badge in a separate row if needed
                    if (isAllergen)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEE4A),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFF181818),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              WidgetsUtil.buildTooltipText(
                                text: 'Allergen',
                                style: theme.textTheme.labelSmall!.copyWith(
                                  color: const Color(0xFF181818),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: WidgetsUtil.buildList(
                              'Advantages',
                              ingredient.advantages,
                              Icons.check_circle_outline,
                              theme.colorScheme.primary,
                              context,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: WidgetsUtil.buildList(
                              'Disadvantages',
                              ingredient.disadvantages,
                              Icons.cancel_outlined,
                              const Color(0xFFFF3B30),
                              context,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (ingredient.notes.isNotEmpty)
                        _buildNotesSection(context, ingredient.notes),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, List<String> notes) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEE4A).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEE4A).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFFFEE4A),
                size: 20,
              ),
              const SizedBox(width: 8),
              WidgetsUtil.buildTooltipText(
                text: 'Notes:',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notes.map<Widget>((note) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyMedium!.copyWith(height: 1.4)),
                Expanded(
                  child: WidgetsUtil.buildTooltipText(
                    text: note,
                    style: theme.textTheme.bodyMedium!.copyWith(height: 1.4),
                    maxLines: null,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  // Helper method to convert a string to Title Case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 