import 'package:flutter/material.dart';
import '../utils/widgets_util.dart';

class AdditionalInsights extends StatelessWidget {
  final List<String> additionalInsights;

  const AdditionalInsights({
    Key? key,
    required this.additionalInsights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
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
          WidgetsUtil.buildTooltipText(
            text: 'Additional Insights',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 24),

          // Sugar Content Comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetsUtil.buildTooltipText(
                      text: 'Sugar Content',
                      style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    WidgetsUtil.buildTooltipText(
                      text: additionalInsights[0],
                      style: theme.textTheme.bodyMedium!.copyWith(height: 1.5),
                      maxLines: null,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.5)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF3B30),
                          border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.7), width: 2),
                        ),
                        child: Center(
                          child: WidgetsUtil.buildTooltipText(
                            text: 'High',
                            style: theme.textTheme.labelLarge!.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      WidgetsUtil.buildTooltipText(
                        text: 'Sugar Level',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Divider(
            height: 40,
            thickness: 1,
            color: theme.colorScheme.onBackground.withOpacity(0.1),
          ),

          // Dietary Considerations
          WidgetsUtil.buildTooltipText(
            text: 'Dietary Considerations',
            style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          
          // For lactose intolerance warning
          WidgetsUtil.buildDietaryConsideration(
            'Lactose Intolerance',
            _extractLactoseIntolerance(additionalInsights),
            Icons.no_food,
            const Color(0xFFFF3B30),
            context,
          ),
          
          // For nut allergies
          WidgetsUtil.buildDietaryConsideration(
            'Nut Allergies',
            'Contains pistachios - Avoid if allergic to tree nuts',
            Icons.dangerous,
            const Color(0xFFFF3B30),
            context,
          ),
          
          // For added sugar check
          WidgetsUtil.buildDietaryConsideration(
            'Added Sugar Check',
            additionalInsights.length > 1 ? additionalInsights[1] : "Check product label for added sugar information",
            Icons.warning_amber,
            theme.colorScheme.tertiary,
            context,
          ),
        ],
      ),
    );
  }

  // Helper method to extract lactose intolerance information
  String _extractLactoseIntolerance(List<String> insights) {
    if (insights.length > 2) {
      final String item = insights[2];
      if (item.contains(',')) {
        return item.split(', and ')[0];
      }
      return item;
    }
    return 'May cause issues for lactose-intolerant individuals';
  }
} 