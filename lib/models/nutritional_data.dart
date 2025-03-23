class NutritionalData {
  final Result result;

  NutritionalData({required this.result});

  factory NutritionalData.fromJson(Map<String, dynamic> json) {
    return NutritionalData(
      result: Result.fromJson(json['result']),
    );
  }

  Map<String, dynamic> toJson() => {
    'result': result.toJson(),
  };
}

class Result {
  final List<Ingredient> ingredients;
  final int overallRating;
  final List<String> keyAdvantages;
  final List<String> keyDisadvantages;
  final List<String> additionalInsights;
  final List<String> potentialAllergens;
  final List<String> notes;

  Result({
    required this.ingredients,
    required this.overallRating,
    required this.keyAdvantages,
    required this.keyDisadvantages,
    required this.additionalInsights,
    required this.potentialAllergens,
    required this.notes,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      ingredients: List<Ingredient>.from(json['ingredients'].map((x) => Ingredient.fromJson(x))),
      overallRating: json['overallrating'],
      keyAdvantages: List<String>.from(json['keyadvantages']),
      keyDisadvantages: List<String>.from(json['keydisadvantages']),
      additionalInsights: List<String>.from(json['additionalinsights']),
      potentialAllergens: List<String>.from(json['potentialallergens']),
      notes: List<String>.from(json['notes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'ingredients': List<dynamic>.from(ingredients.map((x) => x.toJson())),
    'overallrating': overallRating,
    'keyadvantages': List<dynamic>.from(keyAdvantages),
    'keydisadvantages': List<dynamic>.from(keyDisadvantages),
    'additionalinsights': List<dynamic>.from(additionalInsights),
    'potentialallergens': List<dynamic>.from(potentialAllergens),
    'notes': List<dynamic>.from(notes),
  };
}

class Ingredient {
  final String name;
  final List<String> advantages;
  final List<String> disadvantages;
  final int healthScore;
  final List<String> notes;

  Ingredient({
    required this.name,
    required this.advantages,
    required this.disadvantages,
    required this.healthScore,
    required this.notes,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      advantages: List<String>.from(json['advantages']),
      disadvantages: List<String>.from(json['disadvantages']),
      healthScore: json['healthscore'],
      notes: List<String>.from(json['notes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'advantages': List<dynamic>.from(advantages),
    'disadvantages': List<dynamic>.from(disadvantages),
    'healthscore': healthScore,
    'notes': List<dynamic>.from(notes),
  };
}

// Sample data for testing
final Map<String, dynamic> sampleNutritionalData = {
  "result": {
    "ingredients": [
      {
        "name": "Milk Solids",
        "advantages": [
          "Good source of calcium for bone health.",
          "Provides protein for muscle building and repair."
        ],
        "disadvantages": [
          "Can be high in saturated fat, potentially raising cholesterol levels.",
          "May cause digestive issues for lactose-intolerant individuals."
        ],
        "healthscore": 6,
        "notes": [
          "The specific health impact depends on the type of milk used (whole, skim, etc.) and the processing methods.",
          "Individuals with lactose intolerance should exercise caution."
        ]
      },
      {
        "name": "Sugar",
        "advantages": [
          "Provides a quick source of energy."
        ],
        "disadvantages": [
          "Contributes to weight gain and obesity.",
          "Increases the risk of type 2 diabetes.",
          "Can lead to dental cavities."
        ],
        "healthscore": 2,
        "notes": [
          "High sugar intake is generally detrimental to health. Limit consumption.",
          "The amount of sugar is a critical factor in overall health impact."
        ]
      },
      {
        "name": "Pistachio",
        "advantages": [
          "Good source of healthy fats and fiber.",
          "Contains antioxidants that protect against cell damage.",
          "May help lower cholesterol levels."
        ],
        "disadvantages": [
          "Relatively high in calories.",
          "Can trigger allergic reactions in some individuals."
        ],
        "healthscore": 8,
        "notes": [
          "Pistachios are generally a healthy snack option in moderation.",
          "Be mindful of portion sizes due to their calorie density."
        ]
      },
      {
        "name": "Nature Identical Flavouring Substances (Rose Water)",
        "advantages": [
          "Enhances flavor without adding significant calories.",
          "Rose water may have some antioxidant properties (minimal)."
        ],
        "disadvantages": [
          "Potential for undisclosed ingredients or additives.",
          "May trigger sensitivities in some individuals."
        ],
        "healthscore": 5,
        "notes": [
          "The term 'nature identical' does not guarantee complete safety or natural origin; it means the flavoring is chemically the same as a natural flavoring but synthesized.",
          "The benefits are mostly related to flavor enhancement rather than significant nutritional value."
        ]
      }
    ],
    "overallrating": 5,
    "keyadvantages": [
      "Source of calcium and protein from milk solids.",
      "Contains healthy fats and fiber from pistachios."
    ],
    "keydisadvantages": [
      "High sugar content poses significant health risks.",
      "Potential for hidden additives within flavoring substances."
    ],
    "additionalinsights": [
      "The product's healthiness is heavily influenced by the quantity of sugar used. A lower sugar content would significantly improve the overall rating.",
      "Individuals should check if there is a 'added sugar' label to evaluate the quality of the product.",
      "Pay attention to potential lactose intolerance issues from milk solids, and nut allergies from pistachios."
    ],
    "potentialallergens": [
      "Milk",
      "Nuts (pistachios)"
    ],
    "notes": [
      "Overall, the product's health profile is moderate, with notable advantages from pistachios balanced by the disadvantages of high sugar content.",
      "Consider it an occasional treat rather than a regular part of a healthy diet."
    ]
  }
}; 