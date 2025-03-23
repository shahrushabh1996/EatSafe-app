import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // For min function
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/nutritional_data.dart';
import '../screens/nutritional_insights_screen.dart';
import 'dialog_service.dart';
import 'image_service.dart'; // Import the image_service.dart which now has our File wrapper class

/// Service class for handling image uploads and API responses
class UploadService {
  /// Function to upload image to server
  static Future<void> uploadImage(File imageFile, BuildContext context) async {
    print('======= UPLOAD PROCESS STARTED =======');
    print('Platform: Web=$kIsWeb');
    print('Image path: ${imageFile.path}');
    print('Image size: ${await imageFile.length()} bytes');
    print('API endpoint being used: http://65.1.134.235:3003');
    
    // Check if we have a valid context
    if (!context.mounted) {
      print('Context is not mounted, cannot proceed with upload');
      return;
    }
    
    // Check if the file exists and is valid
    try {
      bool fileExists = await imageFile.exists();
      int fileSize = await imageFile.length();
      print('Upload file check - Exists: $fileExists, Size: $fileSize bytes');
      
      if (!fileExists || fileSize <= 0) {
        print('Invalid upload file! Exists=$fileExists, Size=$fileSize');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Invalid image file for upload')),
          );
        }
        return;
      }
    } catch (e) {
      print('File validation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error validating image file: ${e.toString()}')),
        );
      }
      return;
    }
    
    try {
      // For mobile platforms
      if (!kIsWeb) {
        print('Using mobile implementation');

        // Make sure a loading dialog is showing
        bool isDialogShowing = false;
        try {
          // Check if a dialog is already showing
          if (Navigator.canPop(context)) {
            isDialogShowing = true;
            print('Loading dialog is already showing');
          } else {
            print('No dialog is currently showing, will show new loading dialog');
          }
        } catch (e) {
          print('Dialog check error: $e');
        }
        
        // Ensure a loading dialog is shown
        if (!isDialogShowing && context.mounted) {
          print('Showing new loading dialog for API upload');
          DialogService.showLoadingDialog(context, message: 'Uploading image to server...');
        }
        
        // Upload logic in try-catch
        try {
          // Read the image file
          print('Reading image file bytes...');
          final bytes = await imageFile.readAsBytes();
          print('Successfully read ${bytes.length} bytes from image');
          
          // Create the API request
          final uri = Uri.parse('http://65.1.134.235:3003');
          print('API endpoint: $uri');
          
          // First approach: MultipartRequest
          final request = http.MultipartRequest('POST', uri);
          
          // Add the file to the request
          final multipartFile = http.MultipartFile.fromBytes(
            'file', 
            bytes,
            filename: 'mobile_image.jpg',
          );
          request.files.add(multipartFile);
          
          print('Sending mobile MultipartRequest to $uri');
          
          // Make the API call with a timeout
          final response = await request.send().timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );
          
          print('Mobile response status: ${response.statusCode}');
          
          // Read the response
          final responseBody = await response.stream.bytesToString();
          print('Mobile response received: ${responseBody.substring(0, min(100, responseBody.length))}...');
          
          // Process the response if context is still valid
          if (context.mounted) {
            // Handle the response
            _handleApiResponse(response.statusCode, responseBody, context);
          }
        } catch (e) {
          print('Mobile upload error: $e');
          
          // Try an alternative approach
          if (context.mounted) {
            try {
              print('Trying alternative approach for mobile...');
              
              // Read image as bytes
              final bytes = await imageFile.readAsBytes();
              print('Read ${bytes.length} bytes for alternative approach');
              
              // Create a direct POST request
              final uri = Uri.parse('http://65.1.134.235:3003');
              final response = await http.post(
                uri,
                headers: {'Content-Type': 'multipart/form-data'},
                body: bytes,
              ).timeout(const Duration(seconds: 60));
              
              print('Alternative response status: ${response.statusCode}');
              
              // Process the response
              if (context.mounted) {
                // Handle the response
                _handleApiResponse(response.statusCode, response.body, context);
              }
            } catch (altError) {
              print('Alternative approach also failed: $altError');
              
              // One final fallback with base64 encoding
              try {
                print('Trying final fallback with base64 encoding');
                
                // Read image and convert to base64
                final bytes = await imageFile.readAsBytes();
                final base64Image = base64Encode(bytes);
                
                // Create a JSON POST request
                final uri = Uri.parse('http://65.1.134.235:3003');
                final response = await http.post(
                  uri,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'image_data': base64Image,
                    'filename': 'mobile_image.jpg',
                    'is_fallback': true,
                  }),
                ).timeout(const Duration(seconds: 60));
                
                print('Base64 fallback response: ${response.statusCode}');
                
                // Process the response
                if (context.mounted) {
                  // Handle the response
                  _handleApiResponse(response.statusCode, response.body, context);
                }
              } catch (finalError) {
                print('All approaches failed: $finalError');
                
                // Show error dialog
                if (context.mounted) {
                  // Show error dialog
                  _showErrorDialog(context, 'Failed to upload image after multiple attempts.');
                }
              }
            }
          }
        }
      } else {
        // For web, use existing implementations
        var uri = Uri.parse('http://65.1.134.235:3003');
        
        // Web-specific implementation
        print('Using web-specific upload approach');
        
        try {
          // Create a FormData-based request for web
          final bytes = await imageFile.readAsBytes();
          print('Image read as bytes: ${bytes.length} bytes');
          
          // For web, try a simpler POST approach first
          try {
            // Create a boundary string for multipart form data
            final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
            final headers = {
              'Content-Type': 'multipart/form-data; boundary=$boundary',
            };
            
            // Create the multipart request body manually
            final requestBody = <int>[];
            
            // Add the file part header
            requestBody.addAll(utf8.encode('--$boundary\r\n'));
            requestBody.addAll(utf8.encode('Content-Disposition: form-data; name="file"; filename="image.jpg"\r\n'));
            requestBody.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
            
            // Add the file data
            requestBody.addAll(bytes);
            requestBody.addAll(utf8.encode('\r\n'));
            
            // Add the closing boundary
            requestBody.addAll(utf8.encode('--$boundary--\r\n'));
            
            // Send the request
            print('Sending direct web request to ${uri.toString()}');
            final response = await http.post(
              uri,
              headers: headers,
              body: requestBody,
            ).timeout(
              const Duration(seconds: 45),
              onTimeout: () => throw TimeoutException('Request timed out'),
            );
            
            print('Response received with status: ${response.statusCode}');
            print('Response body: ${response.body}');
            
            // Process response
            _handleApiResponse(response.statusCode, response.body, context);
            
          } catch (directError) {
            // If the direct approach fails, fall back to MultipartRequest
            print('Direct web request failed: $directError');
            print('Falling back to MultipartRequest approach');
            
            var request = http.MultipartRequest('POST', uri);
            
            request.files.add(
              http.MultipartFile.fromBytes(
                'file',
                bytes,
                filename: 'image.jpg',
              ),
            );
            
            final streamedResponse = await request.send().timeout(
              const Duration(seconds: 45),
              onTimeout: () => throw TimeoutException('Request timed out'),
            );
            
            print('Response received with status: ${streamedResponse.statusCode}');
            final respStr = await streamedResponse.stream.bytesToString();
            print('Response body: $respStr');
            
            // Process response
            _handleApiResponse(streamedResponse.statusCode, respStr, context);
          }
          
        } catch (e) {
          print('Web upload error: $e');
          // For web, show a more specific error message
          _showWebSpecificError(context, e);
          throw e;
        }
      }
    } catch (e) {
      print('General upload error: $e');
      
      // Close any loading dialogs
      try {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } catch (dialogError) {
        print('Error closing dialog: $dialogError');
      }
      
      // Show error message if context is valid
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
    
    print('======= UPLOAD PROCESS COMPLETED =======');
  }
  
  /// Function specifically for uploading web images
  static Future<void> uploadImageForWeb(List<int> imageBytes, String fileName, BuildContext context) async {
    print('======= WEB UPLOAD PROCESS STARTED =======');
    print('Web image size: ${imageBytes.length} bytes');
    print('API endpoint being used: http://65.1.134.235:3003');
    
    // Check if we have a valid context
    if (!context.mounted) {
      print('Context is not mounted, cannot proceed with web upload');
      return;
    }
    
    try {
      var uri = Uri.parse('http://65.1.134.235:3003');
      print('Using web-specific upload approach');
      
      try {
        // Create a boundary string for multipart form data
        final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
        final headers = {
          'Content-Type': 'multipart/form-data; boundary=$boundary',
        };
        
        // Create the multipart request body manually
        final requestBody = <int>[];
        
        // Add the file part header
        requestBody.addAll(utf8.encode('--$boundary\r\n'));
        requestBody.addAll(utf8.encode('Content-Disposition: form-data; name="file"; filename="$fileName"\r\n'));
        requestBody.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
        
        // Add the file data
        requestBody.addAll(imageBytes);
        requestBody.addAll(utf8.encode('\r\n'));
        
        // Add the closing boundary
        requestBody.addAll(utf8.encode('--$boundary--\r\n'));
        
        // Send the request
        print('Sending direct web request to ${uri.toString()}');
        final response = await http.post(
          uri,
          headers: headers,
          body: requestBody,
        ).timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw TimeoutException('Request timed out'),
        );
        
        print('Web response received with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        // Process response
        _handleApiResponse(response.statusCode, response.body, context);
      } catch (webError) {
        print('Web upload error: $webError');
        
        // Try fallback with base64 encoding
        try {
          print('Trying fallback with base64 encoding for web');
          
          // Convert image bytes to base64
          final base64Image = base64Encode(imageBytes);
          
          // Create a JSON POST request
          final uri = Uri.parse('http://65.1.134.235:3003');
          final response = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image_data': base64Image,
              'filename': fileName,
              'platform': 'web',
            }),
          ).timeout(const Duration(seconds: 45));
          
          print('Base64 web response: ${response.statusCode}');
          
          // Process the response
          if (context.mounted) {
            _handleApiResponse(response.statusCode, response.body, context);
          }
        } catch (fallbackError) {
          print('All web upload approaches failed: $fallbackError');
          _showWebSpecificError(context, fallbackError);
        }
      }
    } catch (e) {
      print('General web upload error: $e');
      
      // Close any loading dialogs
      try {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } catch (dialogError) {
        print('Error closing dialog: $dialogError');
      }
      
      // Show error message
      if (context.mounted) {
        _showWebSpecificError(context, e);
      }
    }
    
    print('======= WEB UPLOAD PROCESS COMPLETED =======');
  }
  
  /// Helper function to show and hide loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.black87,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Processing...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
  
  /// Process API response
  static void _handleApiResponse(int statusCode, String responseStr, BuildContext context) {
    print('Processing API response with status: $statusCode');
    
    // Close any loading dialogs
    try {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
        print('Closed loading dialog');
      }
    } catch (e) {
      print('Error closing dialog: $e');
    }
    
    // Handle response based on status code
    if (statusCode == 200) {
      print('Successful API response');
      
      try {
        // Parse the JSON response
        final jsonResponse = json.decode(responseStr);
        print('Parsed JSON response');
        
        // Create a NutritionalData object from the response
        NutritionalData nutritionalData = NutritionalData.fromJson(jsonResponse);
        print('Created NutritionalData object');
        
        // Navigate to the NutritionalInsightsScreen with the data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionalInsightsScreen(nutritionalData: nutritionalData),
          ),
        );
        
        print('Navigated to NutritionalInsightsScreen');
      } catch (e) {
        print('Error parsing response: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing server response: ${e.toString()}')),
        );
      }
    } else if (statusCode == 422) {
      // Unprocessable Entity - likely image quality issue
      print('Server could not process the image (422)');
      
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Image Not Clear', 
              style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
            content: const Text(
              'The server could not process this image clearly. Please try:\n\n'
              '• Taking a clearer photo\n'
              '• Better lighting\n'
              '• Different angle\n'
              '• Using a different image'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK', style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
              ),
            ],
          );
        }
      );
    } else {
      // Handle other status codes
      print('Unexpected status code: $statusCode');
      
      String errorMessage = 'Server error (Code: $statusCode). Please try again later.';
      if (statusCode == 413) {
        errorMessage = 'Image is too large. Please try a smaller image.';
      } else if (statusCode >= 500) {
        errorMessage = 'Server error. Our team has been notified. Please try again later.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
  
  /// Show error dialog for Android
  static void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Upload Error', 
            style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('There was an error uploading your image:'),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Please try:'),
              const SizedBox(height: 8),
              const Text('• Checking your internet connection'),
              const Text('• Using a smaller or clearer image'),
              const Text('• Trying again in a few minutes'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }
  
  /// Show web-specific error dialog
  static void _showWebSpecificError(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Web Upload Error', 
            style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('There was an error uploading your image in the web version:'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Web limitations:'),
              const SizedBox(height: 8),
              const Text('• Browsers have stricter security policies'),
              const Text('• Some operations may not be fully supported'),
              const Text('• Consider using the mobile app for full features'),
              const SizedBox(height: 16),
              const Text('You can try:'),
              const SizedBox(height: 8),
              const Text('• Using a smaller image'),
              const Text('• Using a different file format (jpg/png)'),
              const Text('• Using a different browser'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }
} 