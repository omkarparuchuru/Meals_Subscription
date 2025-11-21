import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../subscription/customize_dinner_page.dart';
import '../payment/payment_page.dart';

class UpgradeMealPage extends StatefulWidget {
  final String planType;
  final String dietType;
  final List<String> currentMeals;
  final Map<String, String>? dinnerCustomization;
  final String? forcedMeal;
  final bool isUpgrade; // true if upgrading existing meal (Veg->NonVeg), false if adding new meal

  const UpgradeMealPage({
    super.key,
    required this.planType,
    required this.dietType,
    required this.currentMeals,
    this.dinnerCustomization,
    this.forcedMeal,
    this.isUpgrade = false,
  });

  @override
  State<UpgradeMealPage> createState() => _UpgradeMealPageState();
}

class _UpgradeMealPageState extends State<UpgradeMealPage> {
  String _selectedUpgradeType = 'day'; // 'day', 'week', 'month'
  String? _selectedMealToAdd;
  String _selectedDay = 'Monday';
  bool _isProcessing = false;
  Map<String, String>? _dinnerCustomization;
  String _selectedDietType = 'vegetarian'; // 'vegetarian' or 'non-vegetarian'

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  List<String> get _availableMealsToAdd {
    if (widget.forcedMeal != null) {
      return [widget.forcedMeal!];
    }
    
    final allMeals = ['Tiffin', 'Lunch', 'Snacks', 'Dinner'];
    return allMeals.where((meal) => !widget.currentMeals.contains(meal)).toList();
  }

  // Pricing structure: meal -> diet type -> duration -> price
  Map<String, dynamic> get _mealPrices {
    return {
      'Tiffin': {
        'vegetarian': {'day': 30, 'week': 180, 'month': 700},
        'non-vegetarian': {'day': 40, 'week': 240, 'month': 900},
        'upgrade': {'day': 10, 'week': 60, 'month': 200}, // Veg to Non-Veg upgrade cost
      },
      'Lunch': {
        'vegetarian': {'day': 50, 'week': 300, 'month': 1100},
        'non-vegetarian': {'day': 70, 'week': 420, 'month': 1500},
        'upgrade': {'day': 20, 'week': 120, 'month': 400},
      },
      'Snacks': {
        'vegetarian': {'day': 20, 'week': 120, 'month': 450},
        'non-vegetarian': {'day': 30, 'week': 180, 'month': 650},
        'upgrade': {'day': 10, 'week': 60, 'month': 200},
      },
      'Dinner': {
        'vegetarian': {'day': 45, 'week': 270, 'month': 1000},
        'non-vegetarian': {'day': 60, 'week': 360, 'month': 1350},
        'upgrade': {'day': 15, 'week': 90, 'month': 350},
      },
    };
  }

  Map<String, dynamic> get _upgradePrice {
    if (_selectedMealToAdd == null) return {'day': 0, 'week': 0, 'month': 0};
    
    final mealPrice = _mealPrices[_selectedMealToAdd];
    if (mealPrice == null) return {'day': 0, 'week': 0, 'month': 0};
    
    // If upgrading existing meal (Veg to Non-Veg), use upgrade pricing
    if (widget.isUpgrade) {
      return mealPrice['upgrade'] ?? {'day': 0, 'week': 0, 'month': 0};
    }
    
    // If adding new meal, use full pricing based on selected diet type
    return mealPrice[_selectedDietType] ?? {'day': 0, 'week': 0, 'month': 0};
  }

  @override
  void initState() {
    super.initState();
    _dinnerCustomization = widget.dinnerCustomization;
    
    // Set default diet type based on current subscription
    _selectedDietType = widget.dietType;
    
    if (widget.forcedMeal != null) {
      _selectedMealToAdd = widget.forcedMeal;
    } else if (_availableMealsToAdd.isNotEmpty) {
      _selectedMealToAdd = _availableMealsToAdd.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    if (_availableMealsToAdd.isEmpty && !widget.isUpgrade) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isSmallScreen),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'You have all meals!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your subscription already includes all available meals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isSmallScreen),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : isTablet ? 40 : 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentSubscriptionCard(isSmallScreen),
                    const SizedBox(height: 24),
                    if (!widget.isUpgrade) _buildMealSelector(isSmallScreen),
                    if (!widget.isUpgrade) const SizedBox(height: 24),
                    // Show diet type selector only when adding new meal (not upgrading)
                    if (!widget.isUpgrade) _buildDietTypeSelector(isSmallScreen),
                    if (!widget.isUpgrade) const SizedBox(height: 24),
                    _buildUpgradeTypeSelector(isSmallScreen),
                    const SizedBox(height: 24),
                    if (_selectedUpgradeType == 'day') _buildDaySelector(isSmallScreen),
                    const SizedBox(height: 24),
                    _buildPriceSummary(isSmallScreen),
                    const SizedBox(height: 24),
                    _buildProceedButton(isSmallScreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    String title = widget.isUpgrade ? 'Upgrade to Non-Veg' : 'Add More Meals';
    String subtitle = widget.isUpgrade 
        ? 'Upgrade your ${widget.forcedMeal} to non-vegetarian'
        : 'Add more meals to your subscription';
        
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 16 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF9800),
            Color(0xFF4CAF50),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            label: const Text(
              'Back',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              Text(
                'Current Subscription',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.currentMeals.map((meal) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4CAF50)),
                ),
                child: Text(
                  '$meal (${widget.dietType == 'vegetarian' ? 'Veg' : 'Non-Veg'})',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Meal to Add:',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        ..._availableMealsToAdd.map((meal) {
          final isSelected = _selectedMealToAdd == meal;
          return GestureDetector(
            onTap: () => setState(() => _selectedMealToAdd = meal),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMealIcon(meal),
                    color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF757575),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMealDescription(meal),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDietTypeSelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Diet Type:',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDietTypeCard('vegetarian', 'Vegetarian', Icons.eco, Colors.green, isSmallScreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDietTypeCard('non-vegetarian', 'Non-Veg', Icons.restaurant, Colors.orange, isSmallScreen),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDietTypeCard(String type, String label, IconData icon, Color color, bool isSmallScreen) {
    final isSelected = _selectedDietType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedDietType = type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeTypeSelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isUpgrade ? 'Upgrade Duration:' : 'Add for Duration:',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTypeCard('day', 'Day', Icons.today, isSmallScreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildTypeCard('week', 'Week', Icons.date_range, isSmallScreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildTypeCard('month', 'Month', Icons.calendar_month, isSmallScreen)),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard(String type, String label, IconData icon, bool isSmallScreen) {
    final isSelected = _selectedUpgradeType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedUpgradeType = type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Day:',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _days.map((day) {
            final isSelected = _selectedDay == day;
            return GestureDetector(
              onTap: () => setState(() => _selectedDay = day),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  day.substring(0, 3),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF757575),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(bool isSmallScreen) {
    final price = _upgradePrice[_selectedUpgradeType] ?? 0;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFFFF9800).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isUpgrade ? 'Upgrade Cost:' : 'Total Amount:',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              Text(
                '₹$price',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildSummaryRow('Meal:', _selectedMealToAdd ?? 'None', isSmallScreen),
          if (!widget.isUpgrade)
            _buildSummaryRow('Diet Type:', _selectedDietType == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian', isSmallScreen),
          _buildSummaryRow('Duration:', _selectedUpgradeType.toUpperCase(), isSmallScreen),
          if (_selectedUpgradeType == 'day')
            _buildSummaryRow('Day:', _selectedDay, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              color: const Color(0xFF757575),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleProceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Proceed to Payment',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _handleProceed() async {
    if (_selectedMealToAdd == null) return;

    // If adding dinner and diet type is selected, show customization
    if (_selectedMealToAdd == 'Dinner' && _dinnerCustomization == null && !widget.isUpgrade) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomizeDinnerPage(
            planType: widget.planType,
            dietType: _selectedDietType, // Use the selected diet type
            selectedMeals: [...widget.currentMeals, 'Dinner'],
            basePrice: (_upgradePrice[_selectedUpgradeType] as num?)?.toDouble() ?? 0.0,
          ),
        ),
      );

      if (result != null && result is Map<String, String>) {
        setState(() {
          _dinnerCustomization = result;
        });
      } else {
        return; // User cancelled
      }
    }

    setState(() => _isProcessing = true);

    // Save upgrade details to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final upgradeKey = 'upgrade_${_selectedMealToAdd}_${_selectedUpgradeType}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Store upgrade info with diet type
    final upgradeData = '$_selectedMealToAdd|${widget.isUpgrade ? 'upgrade' : _selectedDietType}|$_selectedUpgradeType|$_selectedDay';
    await prefs.setString(upgradeKey, upgradeData);

    if (_dinnerCustomization != null) {
      await prefs.setString('dinnerBase', _dinnerCustomization!['base']!);
      if (_dinnerCustomization!['curry'] != null) {
        await prefs.setString('dinnerCurry', _dinnerCustomization!['curry']!);
      }
    }

    // If upgrading existing meal to non-veg, update the meal list
    if (widget.isUpgrade && widget.forcedMeal != null) {
      final currentMeals = prefs.getStringList('selectedMeals') ?? [];
      // Mark this meal as non-veg upgraded
      await prefs.setString('upgraded_${widget.forcedMeal}_nonveg', 'true');
    }

    // If adding new meal, add it to the subscription
    if (!widget.isUpgrade && _selectedMealToAdd != null) {
      final currentMeals = prefs.getStringList('selectedMeals') ?? [];
      // Don't add to permanent list for temporary additions
      // if (!currentMeals.contains(_selectedMealToAdd!)) {
      //   currentMeals.add(_selectedMealToAdd!);
      //   await prefs.setStringList('selectedMeals', currentMeals);
      // }
      // Store the diet type for this meal
      await prefs.setString('meal_${_selectedMealToAdd}_diet', _selectedDietType);
    }

    setState(() => _isProcessing = false);

    if (!mounted) return;

    // Navigate to Payment Page
    final price = _upgradePrice[_selectedUpgradeType] ?? 0;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          planType: widget.planType,
          dietType: widget.isUpgrade ? 'non-vegetarian' : _selectedDietType,
          duration: _selectedUpgradeType == 'day' ? '1 Day' : _selectedUpgradeType == 'week' ? '1 Week' : '1 Month',
          totalAmount: price,
          subtotal: price,
          selectedMeals: widget.isUpgrade 
              ? widget.currentMeals 
              : [...widget.currentMeals, if (_selectedMealToAdd != null) _selectedMealToAdd!],
          dinnerCustomization: _dinnerCustomization,
        ),
      ),
    );

    // If payment was successful, return true to trigger refresh
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case 'Tiffin':
        return Icons.wb_sunny;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Snacks':
        return Icons.cookie;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  String _getMealDescription(String meal) {
    switch (meal) {
      case 'Tiffin':
        return 'Morning breakfast meal';
      case 'Lunch':
        return 'Afternoon meal';
      case 'Snacks':
        return 'Evening snacks';
      case 'Dinner':
        return 'Night meal';
      default:
        return '';
    }
  }
}
