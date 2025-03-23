import 'package:flutter/material.dart';
import '../utils/widgets_util.dart';

class RecommendationFooter extends StatelessWidget {
  final List<String> notes;

  const RecommendationFooter({
    Key? key,
    required this.notes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              WidgetsUtil.buildTooltipText(
                text: 'Overall Recommendation',
                style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WidgetsUtil.buildTooltipText(
            text: notes.join(' '),
            style: theme.textTheme.bodyLarge!.copyWith(height: 1.6),
            maxLines: 8,
          ),
        ],
      ),
    );
  }
} 