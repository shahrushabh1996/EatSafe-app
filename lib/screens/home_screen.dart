import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/nutritional_data.dart';
import '../utils/api_service.dart';
import '../utils/logo_service.dart';
import 'nutritional_insights_screen.dart';
import '../utils/widgets_util.dart';
import 'package:flutter/rendering.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Function to fetch nutritional data
  Future<void> _fetchNutritionalData() async {
    final url = _urlController.text.trim();
    
    if (!ApiService.isValidProductUrl(url)) {
      setState(() {
        _errorMessage = 'Please enter a valid URL from Swiggy Instamart, Blinkit, or Zepto';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final nutritionalData = await ApiService.fetchNutritionalData(url);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionalInsightsScreen(
              nutritionalData: nutritionalData,
              productName: ApiService.extractProductName(url),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Check if the error is "No ingredients found"
          if (e.toString().contains('No ingredients found')) {
            _errorMessage = 'No ingredients found for this product';
          } else {
            _errorMessage = 'Failed to fetch data: ${e.toString()}';
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: LogoService.buildEatSafeLogo(context),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => MyApp.captureAndUploadImage(context),
                tooltip: 'Capture Image',
                elevation: 8, // Increased elevation for more depth
                child: const Icon(Icons.camera_alt),
              ),
            ),
          );
        },
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo or Title
                  Text(
                    'Discover Nutritional Insights',
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info text
                  Text(
                    'Enter a product URL from the supported stores to get detailed nutritional analysis',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Search Bar
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'Enter Product URL',
                      hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: theme.colorScheme.primary),
                        onPressed: _isLoading ? null : _fetchNutritionalData,
                      ),
                    ),
                    onSubmitted: (_) => _isLoading ? null : _fetchNutritionalData(),
                    style: theme.textTheme.bodyLarge,
                  ),
                  
                  // Error message
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _errorMessage != null ? 40 : 0,
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.secondary),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Supported Platforms Text
                  Text(
                    'Supported Platforms',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Brand Logos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Swiggy Instamart Logo
                      _buildBrandLogoWidget('Swiggy\nInstamart', 'swiggy'),
                      
                      // Blinkit Logo
                      _buildBrandLogoWidget('Blinkit', 'blinkit'),
                      
                      // Zepto Logo
                      _buildBrandLogoWidget('Zepto', 'zepto'),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Analyzing Product...',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'This may take a few moments while we fetch and analyze the nutritional data.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper method to build a brand logo with appropriate branding
  Widget _buildBrandLogoWidget(String name, String brand) {
    Widget logoWidget;
    String exampleUrl = '';
    
    if (brand == 'swiggy') {
      logoWidget = LogoService.buildSwiggyInstamartLogo(context);
      exampleUrl = 'https://www.swiggy.com/instamart/p/amul-rasmalai-GL9VB55RAI';
    } else if (brand == 'blinkit') {
      logoWidget = LogoService.buildBlinkitLogo(context);
      exampleUrl = 'https://blinkit.com/prn/ras-malai-by-amul/prid/349695';
    } else {
      logoWidget = LogoService.buildZeptoLogo(context);
      exampleUrl = 'https://www.zeptonow.com/pn/amul-frozen-rasmalai/pvid/de1de754-4137-4474-8398-cffd7c8c0190';
    }
    
    return InkWell(
      onTap: () {
        _urlController.text = exampleUrl;
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          logoWidget,
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 