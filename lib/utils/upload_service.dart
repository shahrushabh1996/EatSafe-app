import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // For min function
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/nutritional_data.dart';
import '../screens/nutritional_insights_screen.dart';
import 'dialog_service.dart';

/// Service class for handling image uploads and API responses
class UploadService {
  /// Function to upload image to server
  static Future<void> uploadImage(File imageFile, BuildContext context) async {
    print('======= UPLOAD PROCESS STARTED =======');
    print('Platform: Android=${Platform.isAndroid}, iOS=${Platform.isIOS}, Web=$kIsWeb');
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
      // ANDROID SPECIFIC IMPLEMENTATION
      if (Platform.isAndroid) {
        print('Using direct Android implementation');

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
            filename: 'android_image.jpg',
          );
          request.files.add(multipartFile);
          
          print('Sending Android MultipartRequest to $uri');
          
          // Make the API call with a timeout
          final response = await request.send().timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );
          
          print('Android response status: ${response.statusCode}');
          
          // Read the response
          final responseBody = await response.stream.bytesToString();
          print('Android response received: ${responseBody.substring(0, min(100, responseBody.length))}...');
          
          // Process the response if context is still valid
          if (context.mounted) {
            // Handle the response
            _handleAndroidResponse(response.statusCode, responseBody, context);
          }
        } catch (e) {
          print('Android upload error: $e');
          
          // Try an alternative approach
          if (context.mounted) {
            try {
              print('Trying alternative approach for Android...');
              
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
                _handleAndroidResponse(response.statusCode, response.body, context);
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
                    'filename': 'android_image.jpg',
                    'is_fallback': true,
                  }),
                ).timeout(const Duration(seconds: 60));
                
                print('Base64 fallback response: ${response.statusCode}');
                
                // Process the response
                if (context.mounted) {
                  // Handle the response
                  _handleAndroidResponse(response.statusCode, response.body, context);
                }
              } catch (finalError) {
                print('All approaches failed: $finalError');
                
                // Show error dialog
                if (context.mounted) {
                  // Show error dialog
                  _showAndroidErrorDialog(context, 'Failed to upload image after multiple attempts.');
                }
              }
            }
          }
        }
      } else {
        // For web and iOS, use existing implementations
        var uri = Uri.parse('http://65.1.134.235:3003');
        
        if (kIsWeb) {
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
        } else {
          // For iOS, use the original approach
          print('Using iOS standard upload approach');
          var request = http.MultipartRequest('POST', uri);
          
          // Add file to request
          request.files.add(await http.MultipartFile.fromPath(
            'file', 
            imageFile.path,
          ));
          
          print('Sending iOS request to ${uri.toString()}');
          final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );
          
          print('Response received with status: ${streamedResponse.statusCode}');
          final respStr = await streamedResponse.stream.bytesToString();
          print('Response body: $respStr');
          
          // Process response
          _handleApiResponse(streamedResponse.statusCode, respStr, context);
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
        if (Platform.isAndroid) {
          _showAndroidErrorDialog(context, e.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload error: ${e.toString()}')),
          );
        }
      }
    }
    
    print('======= UPLOAD PROCESS COMPLETED =======');
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
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Uploading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This may take a moment',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    print('Loading dialog shown for upload');
  }
  
  /// Helper function to hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        print('Loading dialog closed');
      }
    } catch (e) {
      print('Error hiding dialog: $e');
    }
  }
  
  /// Android-specific error dialog
  static void _showAndroidErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Upload Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to upload the image. Please try again.'),
              SizedBox(height: 10),
              Text(
                errorMessage.length > 150 ? '${errorMessage.substring(0, 150)}...' : errorMessage,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  /// Android-specific response handler
  static void _handleAndroidResponse(int statusCode, String responseBody, BuildContext context) {
    print('Processing Android API response');
    
    // Close loading dialog if open
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error closing Android dialog: $e');
    }
    
    if (statusCode == 200) {
      try {
        // Parse JSON response
        final data = json.decode(responseBody);
        print('Android: Successfully parsed JSON');
        
        if (data.containsKey('result')) {
          if (data['result'] is Map && 
              data['result'].containsKey('success') && 
              data['result']['success'] == false) {
            // No ingredients found
            _showNoIngredientsDialog(context);
          } else {
            // Success - navigate to results
            final nutritionalData = NutritionalData.fromJson(data);
            print('Navigating to results screen');
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NutritionalInsightsScreen(
                  nutritionalData: nutritionalData,
                  productName: 'Analyzed Product',
                ),
              ),
            );
          }
        } else {
          // Invalid response format
          _showAndroidErrorDialog(context, 'Unexpected response format from server');
        }
      } catch (e) {
        print('Android response processing error: $e');
        _showAndroidErrorDialog(context, 'Error processing server response: $e');
      }
    } else {
      // Non-200 status code
      _showAndroidErrorDialog(context, 'Server returned error code: $statusCode');
    }
  }
  
  /// Show no ingredients dialog
  static void _showNoIngredientsDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('No Ingredients Found'),
            content: Text('We could not identify any ingredients in this image. Please try again with a clearer image.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  
  /// Show web-specific error message
  static void _showWebSpecificError(BuildContext context, dynamic error) {
    if (!context.mounted) return;
    
    // If this is a CORS error or network error, provide a helpful message
    if (error.toString().contains('XMLHttpRequest') || 
        error.toString().contains('network') || 
        error.toString().contains('CORS')) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Connection Issue', 
              style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
            content: const Text(
              'The app cannot connect to the image analysis server from a web browser due to security restrictions. '
              'For the best experience, please use the mobile app.\n\n'
              'If you need to use the web version, try uploading a smaller image.'
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
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading: ${error.toString()}')),
      );
    }
  }
  
  /// Helper method to handle API response for iOS and Web
  static void _handleApiResponse(int statusCode, String responseBody, BuildContext context) {
    print('Processing API response. Status code: $statusCode');
    print('Response body sample: ${responseBody.length > 100 ? '${responseBody.substring(0, 100)}...' : responseBody}');
    
    // Close loading dialog if still open
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error closing dialog: $e');
    }
    
    if (statusCode == 200 && context.mounted) {
      try {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(responseBody);
        print('Successfully parsed JSON response');
        
        // Check if the response indicates no ingredients found
        if (data.containsKey('result') && 
            data['result'] is Map && 
            data['result'].containsKey('success') && 
            data['result']['success'] == false) {
          
          print('API response indicates no ingredients found');
          
          // Show "No ingredients found" message
          _showNoIngredientsDialog(context);
        } else if (data.containsKey('result')) {
          print('API response contains nutritional data');
          
          // Create nutritional data from response
          final nutritionalData = NutritionalData.fromJson(data);
          
          // Navigate to the nutritional insights screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NutritionalInsightsScreen(
                nutritionalData: nutritionalData,
                productName: 'Analyzed Product', // We don't have a URL to extract name from
              ),
            ),
          );
        } else {
          print('Unexpected API response format');
          
          // Handle unexpected response format
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Received unexpected response format')),
            );
          }
        }
      } catch (e) {
        print('Error processing response: $e');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing response: ${e.toString()}')),
          );
        }
      }
    } else if (context.mounted) {
      print('API request failed with status code: $statusCode');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed with status: $statusCode')),
      );
    }
  }
} 