class MealPricing {
  // Base monthly prices for each meal type
  static const double _tiffinPrice = 800;
  static const double _lunchPrice = 1200;
  static const double _snacksPrice = 400;
  static const double _dinnerPrice = 1000;

  // Plan multipliers
  static const double _hostelMultiplier = 0.9; // 10% discount for hostel plan
  static const double _employeeMultiplier = 1.1; // 10% premium for employee plan

  static double calculateBasePrice({
    required List<String> selectedMeals,
    required String planType, // 'hostel' or 'employee'
  }) {
    double total = 0;

    if (selectedMeals.contains('Tiffin')) total += _tiffinPrice;
    if (selectedMeals.contains('Lunch')) total += _lunchPrice;
    if (selectedMeals.contains('Snacks')) total += _snacksPrice;
    if (selectedMeals.contains('Dinner')) total += _dinnerPrice;

    // Apply plan multiplier
    if (planType == 'hostel') {
      total *= _hostelMultiplier;
    } else if (planType == 'employee') {
      total *= _employeeMultiplier;
    }

    // Round to nearest 10 for cleaner pricing
    return (total / 10).round() * 10.0;
  }

  static Map<String, Map<String, dynamic>> getDurationPricing(double baseMonthlyPrice) {
    return {
      '1 Month': {
        'total': baseMonthlyPrice.toInt(),
        'perMonth': baseMonthlyPrice.toInt(),
        'save': 0,
      },
      '3 Months': {
        'total': (baseMonthlyPrice * 3 * 0.95).toInt(), // 5% discount
        'perMonth': (baseMonthlyPrice * 0.95).toInt(),
        'save': (baseMonthlyPrice * 3 * 0.05).toInt(),
      },
      '6 Months': {
        'total': (baseMonthlyPrice * 6 * 0.90).toInt(), // 10% discount
        'perMonth': (baseMonthlyPrice * 0.90).toInt(),
        'save': (baseMonthlyPrice * 6 * 0.10).toInt(),
      },
      '1 Year': {
        'total': (baseMonthlyPrice * 12 * 0.85).toInt(), // 15% discount
        'perMonth': (baseMonthlyPrice * 0.85).toInt(),
        'save': (baseMonthlyPrice * 12 * 0.15).toInt(),
      },
    };
  }
}
