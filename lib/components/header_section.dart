import 'package:flutter/material.dart';
import '../utils/widgets_util.dart';

class HeaderSection extends StatelessWidget {
  final String productName;
  final int overallScore;
  final List<String> keyAdvantages;
  final List<String> keyDisadvantages;
  final List<String> allergens;

  const HeaderSection({
    Key? key,
    required this.productName,
    required this.overallScore,
    required this.keyAdvantages,
    required this.keyDisadvantages,
    required this.allergens,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and rating in a row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product name
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetsUtil.buildTooltipText(
                      text: productName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall Health Score',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Health Rating (with proper display)
              Expanded(
                flex: 3,
                child: WidgetsUtil.buildRatingIndicator(overallScore, context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Allergen Alert if present
          if (allergens.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF3B30)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3B30), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WidgetsUtil.buildTooltipText(
                          text: 'Allergen Alert',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: const Color(0xFFFF3B30),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        WidgetsUtil.buildTooltipText(
                          text: 'Contains: ${allergens.join(', ')}',
                          style: theme.textTheme.bodyMedium,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Key Advantages Section - Full width
          WidgetsUtil.buildSection(
            'Key Advantages',
            keyAdvantages,
            Icons.check_circle,
            theme.colorScheme.primary,
            context,
          ),
          
          const SizedBox(height: 20),
          
          // Key Disadvantages Section - Full width
          WidgetsUtil.buildSection(
            'Key Disadvantages',
            keyDisadvantages,
            Icons.warning,
            const Color(0xFFFF3B30),
            context,
          ),
        ],
      ),
    );
  }
}