import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service class for handling dialog-related functionality
class DialogService {
  /// Show a dialog to select image source (camera or gallery)
  static void showImageSourceDialog(BuildContext context, Function(ImageSource) onSourceSelected) {
    print('DialogService: Showing image source dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source', 
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Select the source for your image'),
                const SizedBox(height: 20),
                // Only show camera option if not on web or explicitly note the limitations
                if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Camera'),
                  onTap: () {
                    print('DialogService: Camera option selected');
                    Navigator.of(context).pop();
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                if (kIsWeb)
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Camera (Limited support in browsers)'),
                  onTap: () {
                    print('DialogService: Web Camera option selected');
                    Navigator.of(context).pop();
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Gallery'),
                  onTap: () {
                    print('DialogService: Gallery option selected');
                    Navigator.of(context).pop();
                    onSourceSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show a web version notice dialog
  static void showWebVersionNotice(BuildContext context, VoidCallback onContinue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Web Version Notice', 
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          content: const Text(
            'The image upload feature may have limitations in the web version due to browser security restrictions.\n\n'
            'For the best experience, we recommend using the mobile app. '
            'You can still try using this feature, but gallery upload is more reliable than camera in web browsers.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onContinue();
              },
              child: Text('Continue', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      }
    );
  }

  /// Show a loading dialog with a message
  static void showLoadingDialog(BuildContext context, {String message = 'Processing...'}) {
    print('DialogService: Showing loading dialog with message: $message');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show an error dialog with a message
  static void showErrorDialog(BuildContext context, String errorMessage, {String title = 'Error'}) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  /// Hide any currently showing dialog
  static void hideDialog(BuildContext context) {
    print('DialogService: Attempting to hide dialog');
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      print('DialogService: Dialog hidden successfully');
    } else {
      print('DialogService: No dialog to hide');
    }
  }
}

/// Enum to represent image sources
enum ImageSource {
  camera,
  gallery
} 