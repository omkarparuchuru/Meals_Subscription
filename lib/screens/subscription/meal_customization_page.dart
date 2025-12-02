import 'package:flutter/material.dart';
import 'choose_subscription_page.dart';

class MealCustomizationPage extends StatefulWidget {
  const MealCustomizationPage({super.key});

  @override
  State<MealCustomizationPage> createState() => _MealCustomizationPageState();
}

class _MealCustomizationPageState extends State<MealCustomizationPage> {
  // Default all selected
  final Set<String> selectedMeals = {'Tiffin', 'Lunch', 'Snacks', 'Dinner'};

  final List<Map<String, dynamic>> mealOptions = [
    {
      'id': 'Tiffin',
      'title': 'Morning Tiffin',
      'time': '7:30 AM - 9:00 AM',
      'icon': Icons.breakfast_dining,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'Lunch',
      'title': 'Wholesome Lunch',
      'time': '12:30 PM - 2:00 PM',
      'icon': Icons.lunch_dining,
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'Snacks',
      'title': 'Evening Snacks',
      'time': '4:30 PM - 5:30 PM',
      'icon': Icons.bakery_dining,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'Dinner',
      'title': 'Light Dinner',
      'time': '7:30 PM - 9:00 PM',
      'icon': Icons.dinner_dining,
      'color': const Color(0xFF2196F3),
    },
  ];

  void _toggleMeal(String mealId) {
    setState(() {
      if (selectedMeals.contains(mealId)) {
        if (selectedMeals.length > 1) {
          selectedMeals.remove(mealId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must select at least one meal'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        selectedMeals.add(mealId);
      }
    });
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
                      _buildInfoCard(isSmallScreen),
                      const SizedBox(height: 24),
                      Text(
                        'Select Your Meals',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mealOptions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final option = mealOptions[index];
                          return _buildMealOptionCard(
                            id: option['id'],
                            title: option['title'],
                            time: option['time'],
                            icon: option['icon'],
                            color: option['color'],
                            isSelected: selectedMeals.contains(option['id']),
                            isSmallScreen: isSmallScreen,
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Bottom padding for button
                    ],
                  ),
                ),
              ),
            ),

            // Continue Button
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                          builder: (context) => ChooseSubscriptionPage(
                            selectedMeals: selectedMeals.toList(),
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
            'Customize Your Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the meals you want to include in your daily plan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can choose any combination of meals. Pricing will be adjusted based on your selection.',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealOptionCard({
    required String id,
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: () => _toggleMeal(id),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : const Color(0xFF9E9E9E),
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
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF2C2C2C) : const Color(0xFF9E9E9E),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: color,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
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

