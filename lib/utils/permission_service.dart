import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Service class for handling permission-related functionality
class PermissionService {
  /// Function to request camera permissions
  static Future<bool> requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    
    if (status == PermissionStatus.denied) {
      status = await Permission.camera.request();
    }
    
    if (status == PermissionStatus.permanentlyDenied) {
      // Show dialog to direct user to app settings
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Camera Permission Required', 
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            content: const Text('Camera permission is required to use this feature. Please grant camera access in app settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: Text('Open Settings', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          );
        }
      );
      return false;
    }
    
    return status == PermissionStatus.granted;
  }

  /// Function to request storage permissions
  static Future<bool> requestStoragePermission(BuildContext context) async {
    var status;
    
    // Handle permissions differently based on platform
    if (Platform.isAndroid) {
      // Try photos permission first (for newer Android versions)
      status = await Permission.photos.request();
      
      // If photos permission didn't work, fall back to storage
      if (status != PermissionStatus.granted && status != PermissionStatus.permanentlyDenied) {
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      // iOS photo library permission
      status = await Permission.photos.request();
    } else {
      // Fallback for other platforms
      status = await Permission.storage.request();
    }
    
    if (status == PermissionStatus.permanentlyDenied) {
      // Show dialog to direct user to app settings
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Storage Permission Required', 
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              content: const Text('Storage permission is required to access photos. Please grant access in app settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                  child: Text('Open Settings', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            );
          }
        );
      }
      return false;
    }
    
    return status == PermissionStatus.granted;
  }
} 