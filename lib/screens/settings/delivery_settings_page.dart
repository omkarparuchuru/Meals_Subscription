import 'package:flutter/material.dart';
import '../upgrade/upgrade_meal_page.dart';

class DeliverySettingsPage extends StatelessWidget {
  final List<String>? selectedMeals;
  final String? userDietType;
  final Map<String, String>? dinnerCustomization;

  const DeliverySettingsPage({
    super.key,
    this.selectedMeals,
    this.userDietType,
    this.dinnerCustomization,
  });


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // Use selected meals or fallback to all
    final meals = selectedMeals ?? ['Tiffin', 'Lunch', 'Dinner'];
    final defaultTimes = {
      'Tiffin': '8:00 AM',
      'Lunch': '1:00 PM',
      'Dinner': '8:00 PM',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : (isTablet ? 40 : 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Delivery Timings Card (dynamic based on selected meals)
            _buildDeliveryTimingsCard(isSmallScreen, meals, defaultTimes),
            const SizedBox(height: 24),
            // Upgrade options for veg meals (if user is vegetarian)
            if (userDietType == 'vegetarian') ..._buildUpgradeOptions(context, isSmallScreen, meals),
            const SizedBox(height: 24),
            // Add Meal options for meals not yet subscribed
            ..._buildAddMealOptions(context, isSmallScreen, meals),
            const SizedBox(height: 24),
            // Delivery Address Card (unchanged)
            _buildDeliveryAddressCard(isSmallScreen, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimingsCard(bool isSmallScreen, List<String> meals, Map<String, String> defaultTimes) {
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
              const Icon(Icons.access_time, color: Color(0xFF757575), size: 20),
              const SizedBox(width: 8),
              Text(
                'Delivery Timings',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Dynamically render each selected meal's timing row
          for (final meal in meals) ...[
            _buildTimingRow(meal, defaultTimes[meal] ?? '---', isSmallScreen),
            const SizedBox(height: 16),
          ],
          const Divider(height: 32),
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF757575), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contact support to change delivery timings',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildTimingRow(String meal, String time, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Current timing',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard(bool isSmallScreen, BuildContext context) {
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
              const Icon(Icons.location_on, color: Color(0xFF757575), size: 20),
              const SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Current Address',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '123 Main Street, Apartment 4B, Near Central Park',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showChangeAddressDialog(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2C2C2C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Change Address',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeAddressDialog(BuildContext context) {
    final addressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Delivery Address'),
        content: TextField(
          controller: addressController,
          decoration: const InputDecoration(
            hintText: 'Enter new address',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Address updated successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  // Build upgrade cards for each subscribed veg meal
  List<Widget> _buildUpgradeOptions(BuildContext context, bool isSmallScreen, List<String> meals) {
    return [
      const Text(
        'Upgrade Meals (Veg → Non‑Veg)',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
      ),
      const SizedBox(height: 12),
      for (final meal in meals) ...[
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: ListTile(
            leading: Icon(_mealIcon(meal), color: const Color(0xFF4CAF50)),
            title: Text('Upgrade $meal to Non‑Veg', style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpgradeMealPage(
                    planType: 'employee',
                    dietType: userDietType ?? 'vegetarian',
                    currentMeals: selectedMeals ?? [],
                    dinnerCustomization: dinnerCustomization,
                    forcedMeal: meal,
                    isUpgrade: true,
                  ),
                ),
              );
              
              // If upgrade was successful, trigger a page refresh
              if (result == true && context.mounted) {
                // Trigger a rebuild of the parent widget
                Navigator.of(context).pop(true); // Return to ManageMealsPage with refresh flag
              }
            },
          ),
        ),
      ],
    ];
  }

  // Build "Add Meal" section for meals not yet subscribed
  List<Widget> _buildAddMealOptions(BuildContext context, bool isSmallScreen, List<String> currentMeals) {
    final allMeals = ['Tiffin', 'Lunch', 'Snacks', 'Dinner'];
    final mealsToAdd = allMeals.where((m) => !currentMeals.contains(m)).toList();
    
    if (mealsToAdd.isEmpty) return [];

    return [
      const Text(
        'Add More Meals',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
      ),
      const SizedBox(height: 12),
      for (final meal in mealsToAdd) ...[
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: Icon(_mealIcon(meal), color: const Color(0xFF4CAF50)),
            title: Text('Add $meal', style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.add, color: Color(0xFF4CAF50)),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpgradeMealPage(
                    planType: 'employee',
                    dietType: userDietType ?? 'vegetarian',
                    currentMeals: selectedMeals ?? [],
                    dinnerCustomization: dinnerCustomization,
                    forcedMeal: meal,
                    isUpgrade: false,
                  ),
                ),
              );
              
              // If meal was added successfully, trigger a page refresh
              if (result == true && context.mounted) {
                Navigator.of(context).pop(true); // Return to ManageMealsPage with refresh flag
              }
            },
          ),
        ),
      ],
    ];
  }

  IconData _mealIcon(String meal) {
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
}

