import 'package:flutter/material.dart';
import '../payment/payment_page.dart';
import '../../utils/upgrade_preferences.dart';

class UpgradeMealPage extends StatefulWidget {
  final String planType;
  final String currentDiet;
  final Map<String, String>? dinnerCustomization;

  const UpgradeMealPage({
    super.key,
    required this.planType,
    required this.currentDiet,
    this.dinnerCustomization,
  });

  @override
  State<UpgradeMealPage> createState() => _UpgradeMealPageState();
}

class _UpgradeMealPageState extends State<UpgradeMealPage> {
  String _selectedUpgradeType = 'meal';
  String _selectedMeal = 'Lunch';
  String _selectedDay = 'Monday';
  int _selectedAmount = 20;
  bool _isProcessing = false;

  final List<String> _mealOptions = ['Tiffin', 'Lunch', 'Dinner'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  final List<Map<String, dynamic>> _upgradeOptions = [
    {
      'type': 'meal',
      'title': 'Single Meal Upgrade',
      'description': 'Upgrade any specific meal to a non-veg premium menu.',
      'price': 20,
      'icon': Icons.restaurant,
      'gradient': [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
    },
    {
      'type': 'day',
      'title': 'Full Day Upgrade',
      'description': 'Upgrade tiffin, lunch, and dinner for the selected day.',
      'price': 50,
      'icon': Icons.calendar_today,
      'gradient': [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    },
    {
      'type': 'week',
      'title': 'Full Week Upgrade',
      'description': 'Upgrade all meals for the next 7 days.',
      'price': 300,
      'icon': Icons.date_range,
      'gradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    },
    {
      'type': 'month',
      'title': 'Full Month Upgrade',
      'description': 'Upgrade every meal for an entire month.',
      'price': 950,
      'icon': Icons.workspace_premium,
      'gradient': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isSmallScreen),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(isSmallScreen),
                    const SizedBox(height: 20),
                    _buildUpgradeOptionsGrid(isSmallScreen),
                    const SizedBox(height: 24),
                    if (_selectedUpgradeType == 'meal') _buildMealSelector(isSmallScreen),
                    if (_selectedUpgradeType == 'day') _buildDaySelector(isSmallScreen),
                    const SizedBox(height: 24),
                    _buildUpgradeDetailsCard(isSmallScreen),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9800),
            Color(0xFFFFC107),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Upgrade Meals',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.upgrade, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Plan',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.planType.toUpperCase()} • ${widget.currentDiet == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian'}',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upgrading allows you to enjoy premium non-veg meals while keeping your existing plan active.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: const Color(0xFF757575),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeOptionsGrid(bool isSmallScreen) {
    final availableWidth =
        MediaQuery.of(context).size.width - (isSmallScreen ? 32 : 48);
    final double baseCardWidth = isSmallScreen
        ? availableWidth
        : (availableWidth / 2) - 12;
    final double cardWidth = baseCardWidth.clamp(160.0, 360.0);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _upgradeOptions.map((option) {
        final bool isSelected = _selectedUpgradeType == option['type'];
        final gradient = option['gradient'] as List<Color>;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedUpgradeType = option['type'] as String;
              _selectedAmount = option['price'] as int;
              if (_selectedUpgradeType != 'meal') {
                _selectedMeal = 'Lunch';
              }
              if (_selectedUpgradeType != 'day') {
                _selectedDay = 'Monday';
              }
            });
          },
          child: SizedBox(
            width: isSmallScreen ? double.infinity : cardWidth,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected ? gradient : [Colors.white, Colors.white],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF9800)
                      : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${option['price']}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    option['title'] as String,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option['description'] as String,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealSelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Meal',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _mealOptions.map((meal) {
            final bool isSelected = _selectedMeal == meal;
            return ChoiceChip(
              label: Text(meal),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedMeal = meal;
                });
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF757575),
              ),
              selectedColor: const Color(0xFFFF9800),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaySelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Day',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButton<String>(
            value: _selectedDay,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: _days
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDay = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeDetailsCard(bool isSmallScreen) {
    String subtitle;
    if (_selectedUpgradeType == 'meal') {
      subtitle = 'Meal: $_selectedMeal';
    } else if (_selectedUpgradeType == 'day') {
      subtitle = 'Day: $_selectedDay';
    } else if (_selectedUpgradeType == 'week') {
      subtitle = 'Covers next 7 days';
    } else {
      subtitle = 'Covers entire month';
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade Summary',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedUpgradeType == 'meal'
                          ? 'Single Meal'
                          : _selectedUpgradeType == 'day'
                              ? 'Full Day'
                              : _selectedUpgradeType == 'week'
                                  ? 'Full Week'
                                  : 'Full Month',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$_selectedAmount',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 50 : 54,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _startUpgradePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF9800),
                Color(0xFFFFC107),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isProcessing
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.payment, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Proceed to Pay ₹$_selectedAmount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _startUpgradePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            planType: widget.planType,
            dietType: 'non-vegetarian',
            duration: 'Upgrade',
            totalAmount: _selectedAmount,
            subtotal: _selectedAmount,
            dinnerCustomization: widget.dinnerCustomization,
          ),
        ),
      );

      if (result == true && mounted) {
        await _persistUpgradeSelection();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upgrade successful! Your meals have been updated.'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _persistUpgradeSelection() async {
    switch (_selectedUpgradeType) {
      case 'meal':
        await UpgradePreferences.addMealUpgrade(_selectedDay, _selectedMeal);
        break;
      case 'day':
        await UpgradePreferences.addDayUpgrade(_selectedDay);
        break;
      case 'week':
        await UpgradePreferences.setWeekUpgrade(true);
        break;
      case 'month':
        await UpgradePreferences.setMonthUpgrade(true);
        break;
    }
  }
}

