import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../models/nutritional_data.dart';
import '../components/header_section.dart';
import '../components/ingredient_card.dart';
import '../components/additional_insights.dart';
import '../components/recommendation_footer.dart';
import '../utils/widgets_util.dart';
import 'dart:async';

class NutritionalInsightsScreen extends StatefulWidget {
  final NutritionalData nutritionalData;
  final String productName;

  const NutritionalInsightsScreen({
    Key? key,
    required this.nutritionalData,
    this.productName = 'Product Name Not Available',
  }) : super(key: key);

  @override
  State<NutritionalInsightsScreen> createState() => _NutritionalInsightsScreenState();
}

class _NutritionalInsightsScreenState extends State<NutritionalInsightsScreen> {
  late int _currentIngredientIndex;
  bool _hasIngredientsError = false;
  bool _showErrorMessage = false;
  Timer? _errorMessageTimer;
  late NutritionalData _formattedData;

  @override
  void initState() {
    super.initState();
    _currentIngredientIndex = 0;
    
    // Format the nutritional data with proper casing
    _formattedData = _formatNutritionalData(widget.nutritionalData);
    
    // Check if there's an ingredients error
    _hasIngredientsError = _formattedData.result.ingredients.isEmpty;
    
    // Show error message for 3 seconds if there is an ingredients error
    if (_hasIngredientsError) {
      _showErrorMessage = true;
      _errorMessageTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showErrorMessage = false;
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _errorMessageTimer?.cancel();
    super.dispose();
  }

  // Helper method to format nutritional data with consistent casing
  NutritionalData _formatNutritionalData(NutritionalData data) {
    // Create a copy of the data with proper casing
    final formattedResult = Result(
      ingredients: data.result.ingredients.map((ingredient) {
        return Ingredient(
          name: _toTitleCase(ingredient.name),
          advantages: ingredient.advantages.map(_toSentenceCase).toList(),
          disadvantages: ingredient.disadvantages.map(_toSentenceCase).toList(),
          healthScore: ingredient.healthScore,
          notes: ingredient.notes.map(_toSentenceCase).toList(),
        );
      }).toList(),
      overallRating: data.result.overallRating,
      keyAdvantages: data.result.keyAdvantages.map(_toSentenceCase).toList(),
      keyDisadvantages: data.result.keyDisadvantages.map(_toSentenceCase).toList(),
      additionalInsights: data.result.additionalInsights.map(_toSentenceCase).toList(),
      potentialAllergens: data.result.potentialAllergens.map(_toTitleCase).toList(),
      notes: data.result.notes.map(_toSentenceCase).toList(),
    );
    
    return NutritionalData(result: formattedResult);
  }
  
  // Convert a string to Title Case (each word capitalized)
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  // Convert a string to Sentence case (first letter capitalized)
  String _toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final result = _formattedData.result;
    final theme = Theme.of(context);
    
    // Debug print to verify number of ingredients
    print('Total ingredients in data: ${result.ingredients.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: WidgetsUtil.buildTooltipText(
          text: 'Product Overview',
          style: theme.textTheme.displaySmall,
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      floatingActionButton: WidgetsUtil.buildFAB(context),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 16.0, bottom: 88.0),
            children: [
              // Header Section
              HeaderSection(
                productName: widget.productName,
                overallScore: result.overallRating,
                keyAdvantages: result.keyAdvantages,
                keyDisadvantages: result.keyDisadvantages,
                allergens: result.potentialAllergens,
              ),

              // Main Content Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ingredients Analysis
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: WidgetsUtil.buildTooltipText(
                              text: 'Ingredients Analysis',
                              style: theme.textTheme.displaySmall,
                            ),
                          ),
                          if (!_hasIngredientsError)
                            TextButton.icon(
                              icon: Icon(
                                Icons.swipe,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              label: WidgetsUtil.buildTooltipText(
                                text: 'Swipe to View',
                                style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary),
                              ),
                              onPressed: () {},
                            ),
                        ],
                      ),
                    ),

                    // Handle "No ingredients found" error
                    if (_hasIngredientsError)
                      _buildIngredientsError(context)
                    else
                      Column(
                        children: [
                          // Simple, reliable vanilla PageView implementation instead of the carousel widget
                          Container(
                            height: 420,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: PageView.builder(
                              itemCount: result.ingredients.length,
                              controller: PageController(
                                viewportFraction: 0.9,
                                initialPage: 0,
                              ),
                              onPageChanged: (index) {
                                print('Page changed to: $index of ${result.ingredients.length}');
                                setState(() {
                                  _currentIngredientIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                print('Building ingredient item: $index, name: ${result.ingredients[index].name}');
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                  child: IngredientCard(
                                    ingredient: result.ingredients[index],
                                    allergens: result.potentialAllergens,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Page indicator dots - only one set
                          if (result.ingredients.length > 1)
                            Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  result.ingredients.length,
                                  (index) {
                                    print('Generating indicator for index: $index');
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentIngredientIndex == index
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onBackground.withOpacity(0.3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 32),

                    // Additional Insights Section
                    AdditionalInsights(
                      additionalInsights: result.additionalInsights,
                    ),

                    const SizedBox(height: 32),

                    // Footer Section - Overall Notes
                    RecommendationFooter(
                      notes: result.notes,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Temporary error message overlay
          if (_showErrorMessage)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildErrorMessageBanner(context),
            ),
        ],
      ),
    );
  }
  
  // Widget to display when no ingredients are found
  Widget _buildIngredientsError(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          WidgetsUtil.buildTooltipText(
            text: 'No ingredients found',
            style: theme.textTheme.headlineMedium!.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          WidgetsUtil.buildTooltipText(
            text: 'We couldn\'t find any ingredients for this product. Please try scanning the product again or manually enter the ingredients.',
            style: theme.textTheme.bodyLarge,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
  
  // Widget for temporary error message banner
  Widget _buildErrorMessageBanner(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No ingredients found',
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 