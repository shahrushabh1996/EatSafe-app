import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/nutritional_data.dart';
import 'utils/logo_service.dart';
import 'screens/home_screen.dart';
import 'screens/nutritional_insights_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:math'; // For min function
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/image_service.dart';
import 'utils/permission_service.dart';
import 'utils/upload_service.dart';
import 'utils/dialog_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to request camera permissions
  static Future<bool> _requestCameraPermission(BuildContext context) async {
    return await PermissionService.requestCameraPermission(context);
  }

  // Function to capture image and upload
  static Future<void> captureAndUploadImage(BuildContext context) async {
    print('MyApp: Starting captureAndUploadImage...');
    try {
      // Add more detailed logging
      print('MyApp: Calling ImageService.captureAndUploadImage...');
      await ImageService.captureAndUploadImage(context);
      print('MyApp: ImageService.captureAndUploadImage completed');
    } catch (e) {
      print('MyApp: Error in captureAndUploadImage: $e');
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EatSafe',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
