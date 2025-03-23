import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;
import 'dart:html' as html;
import 'dart:ui';
import 'dart:async';
import 'dart:math'; // For min function
import 'package:flutter/foundation.dart' show kIsWeb;
import 'permission_service.dart';
import 'upload_service.dart';
import 'dialog_service.dart';

// Create a cross-platform File class wrapper
class File {
  final io.File? _ioFile;
  final String _path;
  final List<int>? _bytes;

  File(String path) : 
    _path = path,
    _ioFile = kIsWeb ? null : io.File(path),
    _bytes = null;

  File.fromBytes(this._bytes, this._path) : 
    _ioFile = null;

  String get path => _path;

  Future<bool> exists() async {
    if (kIsWeb) {
      return _bytes != null || _path.isNotEmpty;
    } else {
      return await _ioFile!.exists();
    }
  }

  Future<int> length() async {
    if (kIsWeb) {
      return _bytes?.length ?? 0;
    } else {
      return await _ioFile!.length();
    }
  }

  Future<List<int>> readAsBytes() async {
    if (kIsWeb) {
      return _bytes ?? [];
    } else {
      return await _ioFile!.readAsBytes();
    }
  }

  io.File get absolute {
    if (kIsWeb) {
      throw UnsupportedError('absolute path not supported on web');
    } else {
      return _ioFile!.absolute;
    }
  }

  Future<File> writeAsBytes(List<int> bytes) async {
    if (kIsWeb) {
      return File.fromBytes(bytes, _path);
    } else {
      await _ioFile!.writeAsBytes(bytes);
      return this;
    }
  }
}

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
    
    // Web-specific handling to prevent platform errors
    if (kIsWeb && source == ImageSource.camera) {
      print('Web platform detected with camera source');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera capture is not fully supported in web browsers. Please use gallery upload instead.')),
        );
        
        // Automatically switch to gallery on web for better compatibility
        print('Switching to gallery upload for web compatibility');
        source = ImageSource.gallery;
      }
    }
    
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
    // Create a context variable for loading dialog
    BuildContext loadingContext = context;
    
    try {
      print('Starting image capture process from ${source == ImageSource.camera ? "camera" : "gallery"}');
      print('Platform information: Web=$kIsWeb');
      
      // Set image quality and dimensions based on platform
      final int imageQuality = kIsWeb ? 50 : 70; 
      final double maxDimension = kIsWeb ? 800.0 : 1200.0;
      
      print('Using image quality: $imageQuality and max dimension: $maxDimension');
      
      // Set up a pre-loading dialog for mobile (non-web) platforms
      if (!kIsWeb && context.mounted) {
        try {
          print('Showing preparation dialog');
          DialogService.showLoadingDialog(context, message: 'Preparing Camera...');
          dialogContext = context; // Store context for later dismissal
          print('Preparation dialog shown');
        } catch (e) {
          print('Failed to show preparation dialog: $e');
        }
      }
      
      print('About to call image picker...');
      // Convert from DialogService.ImageSource to image_picker.ImageSource
      final image_picker_source = source == ImageSource.camera ? 
               image_picker.ImageSource.camera : 
               image_picker.ImageSource.gallery;
               
      try {
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
        
        // Close the initial loading dialog if it's still open
        if (!kIsWeb) {
          try {
            print('Attempting to close preparation dialog');
            DialogService.hideDialog(dialogContext);
            print('Successfully closed preparation dialog');
          } catch (e) {
            print('Error closing dialog: $e');
          }
        }
        
        if (photo != null) {
          print('Image captured successfully. Path: ${photo.path}');
          
          // Create a new loading context for the next dialog
          if (context.mounted) {
            loadingContext = context;
          }
          
          try {
            // Web requires special handling for XFile
            if (kIsWeb) {
              print('Processing web image');
              if (context.mounted) {
                print('Showing processing dialog for web upload');
                DialogService.showLoadingDialog(context, message: 'Processing Web Image...');
                loadingContext = context;
              }
              
              // For web, we need to read the bytes directly from XFile
              final bytes = await photo.readAsBytes();
              print('Read web image: ${bytes.length} bytes');
              
              // Upload file using the web-specific flow
              if (context.mounted) {
                await UploadService.uploadImageForWeb(bytes, photo.name, loadingContext);
              }
            } else {
              // Create the File instance from the captured XFile
              File originalImageFile = File(photo.path);
              
              // On non-web platforms, verify the file exists and is readable
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
              
              // Upload the image using the loading context to ensure the dialog can be closed
              if (context.mounted) {
                print('Starting upload process with valid file...');
                await UploadService.uploadImage(processedImage, loadingContext);
                print('Upload process completed');
              } else {
                print('Context not mounted, cannot start upload');
              }
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
              if (source == ImageSource.camera && !kIsWeb) {
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
        print('Image picker error: $e');
        
        // Close loading dialog if open
        try {
          print('Attempting to close loading dialog after error');
          DialogService.hideDialog(dialogContext);
          print('Successfully closed loading dialog');
        } catch (dialogError) {
          print('Error closing dialog: $dialogError');
        }
        
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image picker error: ${e.toString()}')),
          );
        } else {
          print('Context not mounted, cannot show error message');
        }
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
      
      // Convert to JPEG and compress
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
    } catch (e) {
      print('Image compression error: $e');
      // Return original file as fallback
      return file;
    }
  }
} 