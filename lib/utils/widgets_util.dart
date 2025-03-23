import 'package:flutter/material.dart';
import '../main.dart';

/// Common widgets used across the app
class WidgetsUtil {

  /// Creates a text widget with tooltip functionality
  static Widget buildTooltipText({
    required String text,
    required TextStyle? style,
    int? maxLines = null,
    TextOverflow overflow = TextOverflow.visible,
    TextAlign textAlign = TextAlign.start,
    bool softWrap = true,
  }) {
    return Tooltip(
      message: text,
      preferBelow: true,
      showDuration: const Duration(seconds: 2),
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
      ),
    );
  }

  /// Builds a common floating action button for all screens
  static FloatingActionButton buildFAB(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      onPressed: () => MyApp.captureAndUploadImage(context),
      backgroundColor: theme.colorScheme.primary,
      child: const Icon(
        Icons.camera_alt,
        color: Color(0xFF181818),
        size: 28,
      ),
    );
  }

  /// Builds a section with icon, title and list items
  static Widget buildSection(
    String title, 
    List<dynamic> items, 
    IconData iconData, 
    Color iconColor,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconData, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: buildTooltipText(
                text: title,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: theme.textTheme.bodyLarge!.copyWith(height: 1.5)),
              Expanded(
                child: buildTooltipText(
                  text: item,
                  style: theme.textTheme.bodyLarge!.copyWith(height: 1.5),
                  maxLines: null,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// Builds a list with icon, title and items
  static Widget buildList(
    String title, 
    List<dynamic> items, 
    IconData iconData, 
    Color iconColor,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconData, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: buildTooltipText(
                text: title,
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: theme.textTheme.bodySmall!.copyWith(height: 1.4)),
              Expanded(
                child: buildTooltipText(
                  text: item,
                  style: theme.textTheme.bodySmall!.copyWith(height: 1.4),
                  maxLines: null,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// Builds a dietary consideration widget
  static Widget buildDietaryConsideration(
    String title, 
    String description, 
    IconData icon, 
    Color color,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTooltipText(
                  text: title,
                  style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                buildTooltipText(
                  text: description,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onBackground,
                    height: 1.4,
                  ),
                  maxLines: null,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a simplified rating indicator (circle with score, without the /10)
  static Widget buildSimpleRatingIndicator(int score, BuildContext context) {
    final theme = Theme.of(context);
    final Color color = _getHealthScoreColor(score);
    
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF222222),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: buildTooltipText(
          text: '$score',
          style: theme.textTheme.displayLarge!.copyWith(
            color: color,
            fontSize: 36,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  /// Builds a rating indicator (circle with score)
  static Widget buildRatingIndicator(int score, BuildContext context) {
    final theme = Theme.of(context);
    final Color color = _getHealthScoreColor(score);
    
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF222222),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTooltipText(
              text: '$score',
              style: theme.textTheme.displayLarge!.copyWith(color: color),
              maxLines: 1,
            ),
            buildTooltipText(
              text: '/10',
              style: theme.textTheme.headlineMedium!.copyWith(color: theme.colorScheme.onBackground),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to get color based on health score
  static Color _getHealthScoreColor(int score) {
    if (score >= 7) return Colors.green;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
} 