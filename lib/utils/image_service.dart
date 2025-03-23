import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:math'; // For min function
import 'package:flutter/foundation.dart' show kIsWeb;
import 'permission_service.dart';
import 'upload_service.dart';
import 'dialog_service.dart';

/// Service class for handling image operations like capturing and processing
class ImageService {
  /// Function to capture image and upload
  static Future<void> captureAndUploadImage(BuildContext context) async {
    // For web, show a note about limitations first
    if (kIsWeb) {
      DialogService.showWebVersionNotice(context, () {
        DialogService.showImageSourceDialog(context, (source) {
          processImageCapture(context, source);
        });
      });
    } else {
      // On mobile, proceed directly
      DialogService.showImageSourceDialog(context, (source) {
        processImageCapture(context, source);
      });
    }
  }

  /// Handles image capture from either camera or gallery
  static Future<void> processImageCapture(BuildContext context, ImageSource source) async {
    print('===== STARTING IMAGE CAPTURE PROCESS =====');
    print('Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');
    
    // Skip permission request on web
    bool hasPermission = true;
    if (!kIsWeb) {
      // Request appropriate permission based on source
      if (source == ImageSource.camera) {
        hasPermission = await PermissionService.requestCameraPermission(context);
      } else {
        hasPermission = await PermissionService.requestStoragePermission(context);
      }
      
      if (!hasPermission) {
        print('Permission denied, aborting image capture');
        return; // Exit if permission not granted
      }
    }
    
    final image_picker.ImagePicker picker = image_picker.ImagePicker();
    // Store a global variable for dialog context to avoid referencing a deactivated context
    BuildContext dialogContext = context;
    
    try {
      print('Starting image capture process from ${source == ImageSource.camera ? "camera" : "gallery"}');
      print('Platform information: Android=${Platform.isAndroid}, iOS=${Platform.isIOS}, Web=$kIsWeb');
      
      // Set image quality and dimensions based on platform
      final int imageQuality = kIsWeb ? 50 : (Platform.isAndroid ? 40 : 70); // Increased quality for Android
      final double maxDimension = kIsWeb ? 800.0 : (Platform.isAndroid ? 800.0 : 1200.0); // Increased size for Android
      
      print('Using image quality: $imageQuality and max dimension: $maxDimension');
      
      // Set up a pre-loading dialog on Android
      if (Platform.isAndroid && context.mounted) {
        try {
          print('ANDROID: Showing preparation dialog');
          DialogService.showLoadingDialog(context, message: 'Preparing Camera...');
          dialogContext = context; // Store context for later dismissal
          print('ANDROID: Preparation dialog shown');
        } catch (e) {
          print('Failed to show preparation dialog: $e');
        }
      }
      
      print('About to call image picker...');
      // Convert from DialogService.ImageSource to image_picker.ImageSource
      final image_picker_source = source == ImageSource.camera ? 
               image_picker.ImageSource.camera : 
               image_picker.ImageSource.gallery;
               
      // Use imageQuality parameter to reduce the image size and prevent decoding issues
      final image_picker.XFile? photo = await picker.pickImage(
        source: image_picker_source,
        imageQuality: imageQuality,
        maxWidth: maxDimension,
        maxHeight: maxDimension,
        requestFullMetadata: false, // Skip full metadata to reduce processing
        preferredCameraDevice: image_picker.CameraDevice.rear,
      );
      print('Image picker returned: ${photo != null ? "success" : "null"}');
      
      // Close the initial loading dialog on Android if it's still open
      if (Platform.isAndroid) {
        try {
          print('ANDROID: Attempting to close preparation dialog');
          DialogService.hideDialog(dialogContext);
          print('ANDROID: Successfully closed preparation dialog');
        } catch (e) {
          print('Error closing dialog: $e');
        }
      }
      
      if (photo != null) {
        print('Image captured successfully. Path: ${photo.path}');
        
        // Create a new loading context for the next dialog
        BuildContext loadingContext = context;
        
        try {
          // Create the File instance from the captured XFile
          File originalImageFile = File(photo.path);
          
          // On Android, verify the file exists and is readable
          if (Platform.isAndroid) {
            try {
              final bool fileExists = await originalImageFile.exists();
              final int fileSize = await originalImageFile.length();
              print('Image file check - Exists: $fileExists, Size: $fileSize bytes');
              
              if (!fileExists || fileSize <= 0) {
                throw Exception('Invalid image file: File exists = $fileExists, Size = $fileSize');
              }
            } catch (e) {
              print('File verification error: $e');
              
              // Try to read the bytes directly from XFile as a fallback
              final bytes = await photo.readAsBytes();
              print('Read image directly from XFile: ${bytes.length} bytes');
              
              // Save to a temporary file that we know will be accessible
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
              await tempFile.writeAsBytes(bytes);
              originalImageFile = tempFile;
              print('Created temporary file at: ${originalImageFile.path}');
              
              // Verify the temporary file
              final bool tempFileExists = await originalImageFile.exists();
              final int tempFileSize = await originalImageFile.length();
              print('Temp file check - Exists: $tempFileExists, Size: $tempFileSize bytes');
              
              if (!tempFileExists || tempFileSize <= 0) {
                throw Exception('Invalid temporary image file');
              }
            }
          }
          
          // Show full-screen loading overlay for the processing and upload
          // Use a fresh context reference that we know is valid
          if (context.mounted) {
            print('Showing processing dialog before upload');
            // Close any previous dialogs to avoid stacking
            try {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                print('Closed previous dialog before showing processing dialog');
              }
            } catch (e) {
              print('Error closing previous dialog: $e');
            }
            
            // Show new processing dialog
            DialogService.showLoadingDialog(
              context, 
              message: 'Processing Image...'
            );
            loadingContext = context; // Update context for later dismissal
            print('Processing dialog shown successfully');
          } else {
            print('Context not mounted, cannot show processing dialog');
          }
          
          // Compress the image to avoid decoding issues
          print('Starting image compression...');
          File? processedImage = await compressImage(originalImageFile);
          
          if (processedImage == null) {
            // If compression fails, try with original file
            processedImage = originalImageFile;
            print('Compression failed, using original image: ${processedImage.path}');
          } else {
            print('Image compressed successfully: ${processedImage.path}');
          }
          
          // Check that the processed image exists and is valid
          if (Platform.isAndroid) {
            try {
              final bool fileExists = await processedImage.exists();
              final int fileSize = await processedImage.length();
              print('Final image check - Exists: $fileExists, Size: $fileSize bytes');
              
              if (!fileExists || fileSize <= 0) {
                throw Exception('Invalid processed image file');
              }
            } catch (e) {
              print('Final file verification error: $e');
              throw Exception('Failed to verify final image file: $e');
            }
          }
          
          // Upload the image using the loading context to ensure the dialog can be closed
          if (context.mounted) {
            print('Starting upload process with valid file...');
            await UploadService.uploadImage(processedImage, loadingContext);
            print('Upload process completed');
          } else {
            print('Context not mounted, cannot start upload');
          }
        } catch (e) {
          print('Image processing error: $e');
          
          // Close loading dialog if open
          try {
            print('Attempting to close loading dialog after error');
            DialogService.hideDialog(loadingContext);
            print('Successfully closed loading dialog');
          } catch (dialogError) {
            print('Error closing dialog: $dialogError');
          }
          
          // Show error with option to try gallery if camera failed
          if (context.mounted) {
            if (source == ImageSource.camera && (e.toString().contains('decode') || e.toString().contains('ImageDecoder'))) {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: Text('Camera Error', 
                      style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
                    content: const Text('There was an issue processing the camera image. Would you like to try selecting an image from your gallery instead?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          processImageCapture(context, ImageSource.gallery);
                        },
                        child: Text('Use Gallery', style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
                      ),
                    ],
                  );
                }
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image processing error: ${e.toString()}')),
              );
            }
          } else {
            print('Context not mounted, cannot show error dialog');
          }
        }
      } else {
        print('Image capture cancelled or failed');
      }
    } catch (e) {
      print('General image capture error: $e');
      
      // Close loading dialog if open
      try {
        print('Attempting to close dialog after general error');
        DialogService.hideDialog(dialogContext);
        print('Successfully closed dialog');
      } catch (dialogError) {
        print('Error closing dialog: $dialogError');
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image capture error: ${e.toString()}')),
        );
      } else {
        print('Context not mounted, cannot show error message');
      }
    }
    
    print('===== COMPLETED IMAGE CAPTURE PROCESS =====');
  }

  /// Function to compress an image to prevent decoding issues
  static Future<File?> compressImage(File file) async {
    // Skip compression on web platform since it's not supported
    if (kIsWeb) {
      return file;
    }
    
    try {
      print('Starting image compression for file: ${file.path}');
      
      // Create a directory for the compressed image
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // For Android, implement special handling to ensure compression works
      if (Platform.isAndroid) {
        try {
          print('Using Android-specific compression settings');
          
          // Check if file exists and is readable
          if (!(await file.exists())) {
            print('File does not exist, cannot compress');
            return file;
          }
          
          // First try to read the image as bytes
          final bytes = await file.readAsBytes();
          print('Successfully read ${bytes.length} bytes from original file');
          
          // For very large images, use a lower quality setting
          final int quality = bytes.length > 5 * 1024 * 1024 ? 15 : 30;
          
          // Convert to JPEG and compress heavily for Android compatibility
          final result = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: quality,
            format: CompressFormat.jpeg,
            minWidth: 800, // Increased from 480 for better quality
            minHeight: 800,
            keepExif: false, // Remove EXIF data to reduce size
          );
          
          if (result != null) {
            final File resultFile = File(result.path);
            final int originalSize = await file.length();
            final int compressedSize = await resultFile.length();
            
            print('Compression successful. Original: $originalSize bytes, Compressed: $compressedSize bytes, Ratio: ${(compressedSize / originalSize * 100).toStringAsFixed(1)}%');
            
            return resultFile;
          } else {
            print('Compression returned null, falling back to original file');
            return file;
          }
        } catch (androidError) {
          // If FlutterImageCompress fails on Android, try an alternative approach
          print('Android image compression error: $androidError');
          print('Trying alternate compression method');
          
          try {
            // Read the file as bytes
            final bytes = await file.readAsBytes();
            
            // Create a new file to write compressed data
            final File compressedFile = File(targetPath);
            await compressedFile.writeAsBytes(bytes, flush: true);
            
            print('Created copy of image, optimized for Android: ${compressedFile.path}');
            return compressedFile;
          } catch (fallbackError) {
            print('Fallback compression also failed: $fallbackError');
            return file;
          }
        }
      } else {
        // For iOS and other platforms, use the standard approach
        print('Using standard compression for non-Android platform');
        
        // Convert to JPEG and compress
        final result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: Platform.isIOS ? 60 : 50,
          format: CompressFormat.jpeg,
          minWidth: 800,
          minHeight: 800,
        );
        
        return result != null ? File(result.path) : null;
      }
    } catch (e) {
      print('Image compression error: $e');
      // Return original file as fallback
      return file;
    }
  }
} 