import 'package:flutter/material.dart';
import 'customize_dinner_page.dart';

class SelectDietPage extends StatefulWidget {
  final String planType;
  final Map<String, String>? dinnerCustomization;

  const SelectDietPage({
    super.key,
    required this.planType,
    this.dinnerCustomization,
  });

  @override
  State<SelectDietPage> createState() => _SelectDietPageState();
}

class _SelectDietPageState extends State<SelectDietPage> {
  String? selectedDiet;

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
            // Header with Gradient
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
                      // Step 1 - Completed
                      _buildStepIndicator(1, 'Select Subscription Type', true, isSmallScreen),
                      const SizedBox(height: 8),
                      _buildPlanSummary(isSmallScreen),
                      const SizedBox(height: 24),
                      // Step 2 - Current
                      _buildStepIndicator(2, 'Choose Diet Preference', false, isSmallScreen),
                      const SizedBox(height: 24),
                      // Diet Preference Cards
                      _buildDietCard(
                        icon: Icons.eco,
                        title: 'Vegetarian',
                        description: '100% plant-based meals.',
                        isSelected: selectedDiet == 'vegetarian',
                        onTap: () => setState(() => selectedDiet = 'vegetarian'),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 16),
                      _buildDietCard(
                        icon: Icons.set_meal,
                        title: 'Non-Vegetarian',
                        description: 'Includes chicken, fish & eggs.',
                        isSelected: selectedDiet == 'non-vegetarian',
                        onTap: () => setState(() => selectedDiet = 'non-vegetarian'),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Continue Button
            if (selectedDiet != null)
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
                            builder: (context) => CustomizeDinnerPage(
                              planType: widget.planType,
                              dietType: selectedDiet!,
                              duration: null,
                              totalAmount: null,
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
          const SizedBox(height: 4),
          const Text(
            'Select subscription type, diet preference, and duration',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isCompleted, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9E9E9E),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Center(
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

  Widget _buildPlanSummary(bool isSmallScreen) {
    final planName = widget.planType == 'hostel' ? 'Hostel Plan' : 'Employee Plan';
    final planColor = widget.planType == 'hostel'
        ? const Color(0xFF2196F3)
        : const Color(0xFF9C27B0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: planColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: planColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: planColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected: $planName',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietCard({
    required IconData icon,
    required String title,
    required String description,
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
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFE0E0E0).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

