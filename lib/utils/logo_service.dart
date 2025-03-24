import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoService {
  // EatSafe logo using Roboto font
  static Widget buildEatSafeLogo(BuildContext context, {double? height, Color? color}) {
    final theme = Theme.of(context);
    return Text(
      'EatSafe',
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: height != null ? height * 0.6 : 28,
          fontWeight: FontWeight.bold,
          color: color ?? theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Delivery service logos
  static Widget buildSwiggyInstamartLogo(BuildContext context, {double size = 80}) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/swiggy_instamart_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // If the standard logo fails, try the new one
            return Image.asset(
              'assets/images/swiggy.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // If both fail, show an error placeholder
                return Container(
                  color: Colors.orange,
                  child: const Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static Widget buildBlinkitLogo(BuildContext context, {double size = 80}) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/blinkit_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // If the standard logo fails, try the new one
            return Image.asset(
              'assets/images/blinkit.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // If both fail, show an error placeholder
                return Container(
                  color: Colors.yellow,
                  child: const Icon(Icons.shopping_basket, color: Colors.black, size: 40),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static Widget buildZeptoLogo(BuildContext context, {double size = 80}) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/zepto_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // If the standard logo fails, try the new one
            return Image.asset(
              'assets/images/zepto.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // If both fail, show an error placeholder
                return Container(
                  color: Colors.purple,
                  child: const Icon(Icons.delivery_dining, color: Colors.white, size: 40),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 