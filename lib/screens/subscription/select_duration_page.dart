import 'package:flutter/material.dart';
import 'subscription_summary_page.dart';
import '../../utils/meal_pricing.dart';

class SelectDurationPage extends StatefulWidget {
  final String planType;
  final String dietType;
  final List<String> selectedMeals;
  final Map<String, String>? dinnerCustomization;
  final double basePrice;

  const SelectDurationPage({
    super.key,
    required this.planType,
    required this.dietType,
    required this.selectedMeals,
    this.dinnerCustomization,
    required this.basePrice,
  });

  @override
  State<SelectDurationPage> createState() => _SelectDurationPageState();
}

class _SelectDurationPageState extends State<SelectDurationPage> {
  String? selectedDuration;
  Map<String, Map<String, dynamic>> durationData = {
    '1 Month': {
      'total': 3999,
      'perMonth': 3999,
      'save': 0,
    },
    '3 Months': {
      'total': 11499,
      'perMonth': 3833,
      'save': 498,
    },
    '6 Months': {
      'total': 21999,
      'perMonth': 3667,
      'save': 1995,
    },
    '1 Year': {
      'total': 41999,
      'perMonth': 3500,
      'save': 5989,
    },
  };

  @override
  void initState() {
    super.initState();
    // Calculate prices based on basePrice
    durationData = MealPricing.getDurationPricing(widget.basePrice);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isSmallScreen),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : isTablet ? 40 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Selected Plan & Diet Summary
                      _buildSelectedSummary(isSmallScreen),
                      const SizedBox(height: 24),
                      // Step 3
                      _buildStepIndicator(3, 'Select Duration', isSmallScreen),
                      const SizedBox(height: 24),
                      // Duration Cards
                      ...durationData.entries.map((entry) {
                        final duration = entry.key;
                        final data = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildDurationCard(
                            duration: duration,
                            total: data['total'] as int,
                            perMonth: data['perMonth'] as int,
                            save: data['save'] as int,
                            isSelected: selectedDuration == duration,
                            onTap: () => setState(() => selectedDuration = duration),
                            isSmallScreen: isSmallScreen,
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Continue Button
            if (selectedDuration != null)
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionSummaryPage(
                              planType: widget.planType,
                              dietType: widget.dietType,
                              duration: selectedDuration!,
                              totalAmount: durationData[selectedDuration!]!['total'] as int,
                              selectedMeals: widget.selectedMeals,
                              dinnerCustomization: widget.dinnerCustomization,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFFF9800),
                              Color(0xFF4CAF50),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
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
          const Text(
            'Choose Your Subscription',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSummary(bool isSmallScreen) {
    final planName = widget.planType == 'hostel' ? 'Hostel Plan' : 'Employee Plan';
    final dietName = widget.dietType == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian';
    final planColor = widget.planType == 'hostel'
        ? const Color(0xFF2196F3)
        : const Color(0xFF9C27B0);
    final dietColor = widget.dietType == 'vegetarian'
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dietColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dietColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: planColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.planType == 'hostel' ? Icons.apartment : Icons.people,
              color: planColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      widget.dietType == 'vegetarian' ? Icons.eco : Icons.set_meal,
                      color: dietColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dietName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: dietColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: BoxDecoration(
            color: const Color(0xFF9E9E9E),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard({
    required String duration,
    required int total,
    required int perMonth,
    required int save,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
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
                const SizedBox(height: 12),
                Text(
                  '₹${total.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${perMonth.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/month',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
            if (save > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Save ₹${save.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

