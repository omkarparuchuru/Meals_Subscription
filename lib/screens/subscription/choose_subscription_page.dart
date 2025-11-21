import 'package:flutter/material.dart';
import 'select_diet_page.dart';
import '../../utils/meal_pricing.dart';

class ChooseSubscriptionPage extends StatefulWidget {
  final List<String> selectedMeals;
  final Map<String, String>? dinnerCustomization;

  const ChooseSubscriptionPage({
    super.key,
    required this.selectedMeals,
    this.dinnerCustomization,
  });

  @override
  State<ChooseSubscriptionPage> createState() => _ChooseSubscriptionPageState();
}

class _ChooseSubscriptionPageState extends State<ChooseSubscriptionPage> {
  String? selectedPlan;

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
                      // Step Indicator
                      _buildStepIndicator(1, 'Select Subscription Type', isSmallScreen),
                      const SizedBox(height: 24),
                      // Subscription Plan Cards
                      _buildSubscriptionCard(
                        icon: Icons.apartment,
                        iconColor: const Color(0xFF2196F3),
                        title: 'Hostel Plan',
                        description:
                            'Perfect for students living in hostels. Includes balanced nutrition.',
                        price: '₹${MealPricing.calculateBasePrice(selectedMeals: widget.selectedMeals, planType: 'hostel').toInt()}/month',
                        isSelected: selectedPlan == 'hostel',
                        onTap: () => setState(() => selectedPlan = 'hostel'),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 16),
                      _buildSubscriptionCard(
                        icon: Icons.people,
                        iconColor: const Color(0xFF9C27B0),
                        title: 'Employee Plan',
                        description:
                            'Designed for working professionals. Premium meals with varied menu.',
                        price: '₹${MealPricing.calculateBasePrice(selectedMeals: widget.selectedMeals, planType: 'employee').toInt()}/month',
                        isSelected: selectedPlan == 'employee',
                        onTap: () => setState(() => selectedPlan = 'employee'),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Continue Button
            if (selectedPlan != null)
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
                            builder: (context) => SelectDietPage(
                              planType: selectedPlan!,
                              selectedMeals: widget.selectedMeals,
                              dinnerCustomization: widget.dinnerCustomization,
                              basePrice: MealPricing.calculateBasePrice(
                                selectedMeals: widget.selectedMeals,
                                planType: selectedPlan!,
                              ),
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

  Widget _buildStepIndicator(int step, String label, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
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

  Widget _buildSubscriptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String price,
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
                ? iconColor
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
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 60 : 70,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: isSmallScreen ? 30 : 35),
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
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: const Color(0xFF757575),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
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
