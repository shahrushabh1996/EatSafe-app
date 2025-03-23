import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/nutritional_data.dart';

class ApiService {
  static const String baseUrl = 'http://65.1.134.235:3003';
  
  /// Fetches nutritional data for a product URL
  static Future<NutritionalData> fetchNutritionalData(String url) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check for error message in the response
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          debugPrint('API returned error: ${data['error']}');
          
          // For "No ingredients found" error, throw a specific error that can be caught in the UI
          if (data['error'] == 'No ingredients found') {
            throw Exception('No ingredients found');
          }
          
          // Create an empty nutritional data object with error info for other errors
          return NutritionalData(
            result: Result(
              ingredients: [], // Empty ingredients list to trigger error UI
              overallRating: 0,
              keyAdvantages: ['Unable to analyze this product'],
              keyDisadvantages: ['${data['error']}'],
              additionalInsights: ['Please try with a different product or contact support if the issue persists.'],
              potentialAllergens: [],
              notes: ['The analysis could not be completed due to missing ingredient information.'],
            ),
          );
        }
        
        return NutritionalData.fromJson(data);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }
  
  /// Validates if the URL is from a supported platform
  static bool isValidProductUrl(String url) {
    if (url.isEmpty) return false;
    
    // Check if it's a valid URL from one of the supported platforms
    final RegExp urlRegExp = RegExp(
      r'^https?://(www\.)?(zepto\.com|zeptonow\.com|blinkit\.com|swiggy\.com).*$',
      caseSensitive: false,
    );
    
    return urlRegExp.hasMatch(url);
  }
  
  /// Extracts a product name from a product URL
  static String extractProductName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Most product URLs have the product name as part of the path
      if (pathSegments.length >= 2) {
        // Assuming the product name is the second-to-last segment in most URLs
        String segment = pathSegments[pathSegments.length - 2];
        
        // Clean up the segment to create a readable product name
        return segment
            .replaceAll('-', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
      }
    } catch (e) {
      debugPrint('Error extracting product name: $e');
    }
    
    return 'Product';
  }
} 