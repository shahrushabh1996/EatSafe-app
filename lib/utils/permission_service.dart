import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for handling permission-related functionality
class PermissionService {
  static const String _cameraPermissionKey = 'camera_permission_requested';
  static const String _storagePermissionKey = 'storage_permission_requested';
  
  /// Function to check if permission was already requested in this session
  static Future<bool> _wasPermissionRequested(String key) async {
    if (kIsWeb) return false; // Don't track for web
    
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('Error checking permission status: $e');
      return false;
    }
  }
  
  /// Function to mark permission as requested
  static Future<void> _markPermissionAsRequested(String key) async {
    if (kIsWeb) return; // Don't track for web
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (e) {
      print('Error marking permission as requested: $e');
    }
  }

  /// Function to request camera permissions
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // Skip permission check on web
    if (kIsWeb) {
      return true;
    }
    
    // Check if we already have permission
    var status = await Permission.camera.status;
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    // Check if we already requested in this session to avoid double dialogs
    bool alreadyRequested = await _wasPermissionRequested(_cameraPermissionKey);
    
    if (status == PermissionStatus.denied && !alreadyRequested) {
      await _markPermissionAsRequested(_cameraPermissionKey);
      status = await Permission.camera.request();
    }
    
    if (status == PermissionStatus.permanentlyDenied) {
      // Only show dialog if we haven't shown it before in this session
      if (!alreadyRequested && context.mounted) {
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
      }
      return false;
    }
    
    return status == PermissionStatus.granted;
  }

  /// Function to request storage permissions
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // Skip permission check on web
    if (kIsWeb) {
      return true;
    }
    
    // Check if we already requested in this session to avoid double dialogs
    bool alreadyRequested = await _wasPermissionRequested(_storagePermissionKey);
    if (alreadyRequested) {
      // If already requested in this session, check current status
      if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
        return true;
      }
      
      // If permanently denied, don't show dialog again
      if (await Permission.photos.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied) {
        return false;
      }
    }
    
    await _markPermissionAsRequested(_storagePermissionKey);
    var status;
    
    // Handle permissions differently based on platform
    if (!kIsWeb) {
      // For non-web platforms
      bool isAndroid = false;
      bool isIOS = false;
      
      try {
        isAndroid = io.Platform.isAndroid;
        isIOS = io.Platform.isIOS;
      } catch (e) {
        print('Error checking platform: $e');
      }
      
      if (isAndroid) {
        // Try photos permission first (for newer Android versions)
        status = await Permission.photos.request();
        
        // If photos permission didn't work, fall back to storage
        if (status != PermissionStatus.granted && status != PermissionStatus.permanentlyDenied) {
          status = await Permission.storage.request();
        }
      } else if (isIOS) {
        // iOS photo library permission
        status = await Permission.photos.request();
      } else {
        // Fallback for other platforms
        status = await Permission.storage.request();
      }
    } else {
      // For web, permissions are handled differently
      status = PermissionStatus.granted;
    }
    
    if (status == PermissionStatus.permanentlyDenied) {
      // Show dialog to direct user to app settings
      if (context.mounted && !alreadyRequested) {
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