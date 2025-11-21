import 'package:flutter/material.dart';
import '../../utils/upgrade_preferences.dart';
import '../../utils/meal_upgrade_manager.dart';

class WeeklyMenuPage extends StatefulWidget {
  final bool isFromManage;
  final String? userDietType; // 'vegetarian' or 'non-vegetarian'
  final Map<String, String>? dinnerCustomization; // {'base': 'rice'/'chapathi'/'pulka', 'curry': 'curry'/'dal'/'sabzi'}
  final List<String>? selectedMeals;

  const WeeklyMenuPage({
    super.key,
    this.isFromManage = false,
    this.userDietType,
    this.dinnerCustomization,
    this.selectedMeals,
  });

  @override
  State<WeeklyMenuPage> createState() => _WeeklyMenuPageState();
}

class _WeeklyMenuPageState extends State<WeeklyMenuPage> {
  Set<String> _upgradedMealKeys = {}; // Normalized "DAY|MEAL"
  Set<String> _upgradedDays = {};
  bool _upgradedWeek = false;
  bool _upgradedMonth = false;

  Map<String, List<String>> _daySpecificMeals = {};

  @override
  void initState() {
    super.initState();
    _loadUpgradeState();
  }

  Future<void> _loadUpgradeState() async {
    final mealSet = await UpgradePreferences.getMealUpgrades();
    final daySet = await UpgradePreferences.getDayUpgrades();
    final week = await UpgradePreferences.isWeekUpgraded();
    final month = await UpgradePreferences.isMonthUpgraded();
    
    // Load day-specific meals
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final baseMeals = widget.selectedMeals ?? ['Tiffin', 'Lunch', 'Dinner'];
    final Map<String, List<String>> dayMeals = {};
    
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final day = days[(now.weekday + i - 1) % 7];
      dayMeals[day] = await MealUpgradeManager.getMealsForDate(date, baseMeals);
    }

    if (!mounted) return;
    setState(() {
      _upgradedMealKeys = mealSet;
      _upgradedDays = daySet;
      _upgradedWeek = week;
      _upgradedMonth = month;
      _daySpecificMeals = dayMeals;
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
            if (!widget.isFromManage) _buildHeader(isSmallScreen, context),
            // Upgrade Banner removed - use dedicated Upgrade page instead
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : (isTablet ? 40 : 24),
                  ),
                  child: Column(
                    children: [
                      if (!widget.isFromManage) const SizedBox(height: 24),
                      // Weekly Menu - Show current week and next week from Friday
                      _buildWeeklyMenuWithNextWeek(isSmallScreen),
                      const SizedBox(height: 40),
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
  
  Widget _buildUpgradeBanner(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF9800),
            Color(0xFF4CAF50),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.upgrade, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Non-Vegetarian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enjoy premium non-veg meals. Upgrade for a day, week, or specific meal.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen, BuildContext context) {
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
              'Back to Home',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Weekly Menu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'View our delicious meal varieties for the week',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Removed _buildSubscriptionCard - no longer needed


  Widget _buildWeeklyMenuWithNextWeek(bool isSmallScreen) {
    final now = DateTime.now();
    final isFridayOrLater = now.weekday >= DateTime.friday;

    final bool basePlanIsVegetarian = widget.userDietType != 'non-vegetarian';
    final bool hasGlobalUpgrade =
        _upgradedWeek || _upgradedMonth || !basePlanIsVegetarian;

    final vegCurrentMenu = _getFullWeekMenu(true);
    final nonVegCurrentMenu = _getFullWeekMenu(false);
    final vegNextMenu = _getNextWeekMenu(true);
    final nonVegNextMenu = _getNextWeekMenu(false);

    final currentBaseMenu =
        hasGlobalUpgrade ? nonVegCurrentMenu : vegCurrentMenu;
    final currentAltMenu =
        hasGlobalUpgrade ? vegCurrentMenu : nonVegCurrentMenu;
    final nextBaseMenu = hasGlobalUpgrade ? nonVegNextMenu : vegNextMenu;
    final nextAltMenu = hasGlobalUpgrade ? vegNextMenu : nonVegNextMenu;

    final bool canUpgradeMeals = widget.isFromManage &&
        basePlanIsVegetarian &&
        !_upgradedWeek &&
        !_upgradedMonth;

    if (isFridayOrLater) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Week Menu (Effective from today)',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'It’s Friday! We have refreshed your entire menu for the upcoming week.',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(nextBaseMenu.length, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDayMenu(
                  baseDay: nextBaseMenu[index],
                  altDay: nextAltMenu[index],
                  isSmallScreen: isSmallScreen,
                ),
              )),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Week',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(currentBaseMenu.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDayMenu(
                baseDay: currentBaseMenu[index],
                altDay: currentAltMenu[index],
                isSmallScreen: isSmallScreen,
                showUpgradeActions: canUpgradeMeals,
              ),
            )),
        const SizedBox(height: 32),
        Text(
          'Next Week Preview (Unlocks Friday)',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Here’s a sneak peek of the upcoming menu. It automatically replaces the current menu this Friday.',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            color: const Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(nextBaseMenu.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDayMenu(
                baseDay: nextBaseMenu[index],
                altDay: nextAltMenu[index],
                isSmallScreen: isSmallScreen,
              ),
            )),
      ],
    );
  }

  List<Map<String, dynamic>> _getFullWeekMenu(bool isVegetarian) {
    final dinnerBase = widget.dinnerCustomization?['base'] ?? 'rice';
    final dinnerCurry = widget.dinnerCustomization?['curry'] ?? 'curry';
    
    // Helper to get dinner dish based on customization
    String getDinnerDish(String base, String curry, bool isVeg) {
      String baseText = '';
      if (base == 'rice') {
        baseText = 'Rice';
      } else if (base == 'chapathi') {
        baseText = 'Chapathi';
      } else if (base == 'pulka') {
        baseText = 'Pulka';
      }
      
      String curryText = '';
      if (curry == 'curry') {
        curryText = isVeg ? 'Paneer Butter Masala' : 'Butter Chicken';
      } else if (curry == 'dal') {
        curryText = 'Dal Tadka';
      } else if (curry == 'sabzi') {
        curryText = isVeg ? 'Aloo Gobi' : 'Chicken Curry';
      }
      
      return '$baseText, $curryText, Raita';
    }
    
    // Return all meals without filtering - filtering happens in _buildDayMenu
    if (isVegetarian) {
      return [
        {'day': 'Monday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Idli & Coconut Chutney', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Dal Tadka, Aloo Gobi', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Samosa & Tea', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Tuesday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Dosa & Sambar', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Kadhi Pakora, Aloo Fry', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Biscuits & Tea', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Wednesday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Upma & Tea', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Dal, Mixed Veg', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Pakora & Tea', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Thursday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Poha & Tea', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Sambar, Beans Fry', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Sandwich & Coffee', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Friday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Paratha & Curd', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Rajma, Aloo Sabzi', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Bajji & Tea', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Saturday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Aloo Paratha & Pickle', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Dal Fry, Mix Veg', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Vada Pav & Tea', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Sunday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Uttapam & Chutney', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Sambar, Papad', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Cake & Coffee', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
        ]},
      ];
    } else {
      return [
        {'day': 'Monday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Egg Bhurji & Toast', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Dal Tadka, Chicken Curry', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Puff & Tea', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Tuesday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Chicken Sandwich', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Fish Curry, Aloo Fry', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Egg Roll', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Wednesday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Omelette & Bread', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Prawn Curry, Mixed Veg', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Nuggets', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Thursday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Egg Paratha', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Chicken Curry, Aloo Fry', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Momos', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Friday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Chicken Paratha', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Mutton Curry, Mix Veg', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Fish Finger', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Saturday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Egg Bhurji Paratha', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Chicken Biryani, Raita', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Popcorn', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
        {'day': 'Sunday', 'meals': [
          {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Omelette & Toast', 'time': '7:00 - 9:00 AM'},
          {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Rice, Fish Curry, Papad', 'time': '12:00 - 2:00 PM'},
          {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Burger', 'time': '4:00 - 5:00 PM'},
          {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
        ]},
      ];
    }
  }

  List<Map<String, dynamic>> _getNextWeekMenu(bool isVegetarian) {
    final dinnerBase = widget.dinnerCustomization?['base'] ?? 'rice';
    final dinnerCurry = widget.dinnerCustomization?['curry'] ?? 'curry';

    String getDinnerDish(String base, String curry, bool isVeg) {
      final baseText = base == 'chapathi'
          ? 'Chapathi'
          : base == 'pulka'
              ? 'Pulka'
              : 'Rice';
      String curryText;
      if (curry == 'dal') {
        curryText = isVeg ? 'Dal Fry' : 'Dal Gosht';
      } else if (curry == 'sabzi') {
        curryText = isVeg ? 'Mixed Veg Sabzi' : 'Pepper Chicken';
      } else {
        curryText = isVeg ? 'Paneer Tikka Masala' : 'Butter Chicken Masala';
      }
      return '$baseText, $curryText, Salad';
    }

    // Return all meals without filtering
    if (isVegetarian) {
      return [
        {
          'day': 'Monday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Ragi Dosa & Peanut Chutney', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Jeera Rice, Dal Makhani, Stir-fried Veggies', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Dhokla', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Tuesday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Moong Dal Chilla & Mint Chutney', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Veg Pulao, Raita, Aloo Capsicum', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Kachori', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Wednesday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Sabudana Khichdi & Curd', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Veg Biryani, Mirchi Salan, Salad', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Pani Puri', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Thursday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Aloo Puri & Pickle', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Curd Rice, Veg Fryums, Tomato Dal', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Samosa', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Friday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Masala Idli Bowl', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Veg Thali: Rice, Dal, Paneer Curry, Veg Fry', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Bhel Puri', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Saturday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Paneer Stuffed Paratha', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Lemon Rice, Veg Kurma, Salad', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Aloo Tikki', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Sunday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Mini Uttapam Platter', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Veg Fried Rice, Manchurian, Kimchi Salad', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Pav Bhaji', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, true), 'time': '7:00 - 9:00 PM'},
          ]
        },
      ];
    } else {
      return [
        {
          'day': 'Monday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Chicken Keema Sandwich', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Chicken Pulao, Raita, Salad', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Cutlet', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Tuesday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Egg Wrap & Mint Dip', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Mutton Curry, Steamed Rice, Aloo Fry', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Roll', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Wednesday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Chicken Poha', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Fish Curry, Brown Rice, Veg Poriyal', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Wings', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Thursday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Egg White Omelette', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Prawn Masala, Rice, Veg Salad', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Sandwich', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Friday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Chicken Sausage Roll', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Hyderabadi Chicken Biryani, Raita, Mirchi Ka Salan', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Fish Fry', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Saturday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Grilled Chicken Sandwich', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Lemon Rice, Pepper Chicken, Veg Stir Fry', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken 65', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
        {
          'day': 'Sunday',
          'meals': [
            {'type': 'Tiffin', 'icon': Icons.wb_sunny, 'dish': 'Chicken Waffles & Maple Syrup', 'time': '7:00 - 9:00 AM'},
            {'type': 'Lunch', 'icon': Icons.wb_cloudy, 'dish': 'Seafood Platter: Rice, Fish Curry, Prawn Fry', 'time': '12:00 - 2:00 PM'},
            {'type': 'Snacks', 'icon': Icons.bakery_dining, 'dish': 'Chicken Burger', 'time': '4:00 - 5:00 PM'},
            {'type': 'Dinner', 'icon': Icons.nightlight_round, 'dish': getDinnerDish(dinnerBase, dinnerCurry, false), 'time': '7:00 - 9:00 PM'},
          ]
        },
      ];
    }
  }

  Widget _buildDayMenu({
    required Map<String, dynamic> baseDay,
    required Map<String, dynamic> altDay,
    required bool isSmallScreen,
    bool showUpgradeActions = false,
  }) {
    final day = baseDay['day'] as String;
    final baseMeals =
        List<Map<String, dynamic>>.from(baseDay['meals'] as List);
    final altMeals = List<Map<String, dynamic>>.from(altDay['meals'] as List);
    final dayKey = _normalizeDay(day);
    final bool globalUpgrade =
        _upgradedWeek || _upgradedMonth || widget.userDietType == 'non-vegetarian';
    final bool dayUpgraded = globalUpgrade || _upgradedDays.contains(dayKey);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? 18
                      : (MediaQuery.of(context).size.width > 600 ? 24 : 22),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              if (showUpgradeActions && !dayUpgraded)
                TextButton.icon(
                  onPressed: () =>
                      _showUpgradeOptions(context, isSmallScreen, day: day),
                  icon: const Icon(Icons.upgrade, size: 14),
                  label: Text(
                    'Upgrade Day (+₹50)',
                    style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF9800),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          ...List.generate(baseMeals.length, (index) {
            final baseMeal = baseMeals[index];
            final altMeal = altMeals[index];
            final mealType = baseMeal['type'] as String;
            
            // Check visibility based on day-specific meals
            bool isVisible = false;
            if (_daySpecificMeals.isNotEmpty) {
              // Use loaded day-specific meals
              isVisible = _daySpecificMeals[day]?.contains(mealType) ?? false;
            } else {
              // Fallback to global selection if day-specific not loaded yet
              isVisible = widget.selectedMeals?.contains(mealType) ?? false;
            }
            
            if (!isVisible) return const SizedBox.shrink();

            final mealKey = _mealPreferenceKey(day, mealType);
            final bool mealUpgraded =
                dayUpgraded || _upgradedMealKeys.contains(mealKey);
            final mealData = mealUpgraded ? altMeal : baseMeal;
            final bool canUpgradeMeal =
                showUpgradeActions && !dayUpgraded && !mealUpgraded;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        mealData['icon'] as IconData,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  mealType,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                if (mealUpgraded) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF9800)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Upgraded',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 9 : 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFF9800),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mealData['dish'] as String,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: const Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mealData['time'] as String,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (canUpgradeMeal) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 32 : 36,
                      child: OutlinedButton.icon(
                        onPressed: () => _showUpgradeOptions(
                          context,
                          isSmallScreen,
                          day: day,
                          meal: mealType,
                        ),
                        icon: Icon(Icons.upgrade, size: isSmallScreen ? 12 : 14),
                        label: Text(
                          'Upgrade $mealType (+₹20)',
                          style:
                              TextStyle(fontSize: isSmallScreen ? 10 : 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF9800),
                          side: const BorderSide(color: Color(0xFFFF9800)),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 4 : 6,
                            horizontal: isSmallScreen ? 8 : 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  
  String _normalizeDay(String day) => day.trim().toUpperCase();

  String _mealPreferenceKey(String day, String meal) =>
      '${_normalizeDay(day)}|${meal.trim().toUpperCase()}';

  void _showUpgradeOptions(BuildContext context, bool isSmallScreen, {String? day, String? meal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _UpgradeOptionsSheet(
        day: day,
        meal: meal,
        onUpgrade: (type, amount) => _processUpgrade(context, type, amount, day: day, meal: meal),
      ),
    );
  }
  
  Future<void> _processUpgrade(BuildContext context, String upgradeType, int amount, {String? day, String? meal}) async {
    Navigator.pop(context); // Close bottom sheet
    
    // Show payment dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upgrade, color: Color(0xFFFF9800)),
            SizedBox(width: 8),
            Text('Confirm Upgrade'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade Type: $upgradeType'),
                  if (day != null) Text('Day: $day'),
                  if (meal != null) Text('Meal: $meal'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount to Pay:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a one-time payment for the upgrade.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay & Upgrade'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing payment...'),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (upgradeType == 'Week') {
          await UpgradePreferences.setWeekUpgrade(true);
        } else if (upgradeType == 'Month') {
          await UpgradePreferences.setMonthUpgrade(true);
        } else if (upgradeType == 'Day' && day != null) {
          await UpgradePreferences.addDayUpgrade(day);
        } else if (upgradeType == 'Single Meal' && day != null && meal != null) {
          await UpgradePreferences.addMealUpgrade(day, meal);
        }

        if (mounted) {
          await _loadUpgradeState();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upgrade successful! $upgradeType upgraded to Non-Vegetarian.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _UpgradeOptionsSheet extends StatelessWidget {
  final String? day;
  final String? meal;
  final Function(String, int) onUpgrade;

  const _UpgradeOptionsSheet({
    required this.day,
    required this.meal,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Pricing
    final singleMealPrice = 20; // Per meal
    final dayPrice = 50; // All 3 meals for a day
    final weekPrice = 300; // All meals for a week
    final monthPrice = 950; // Full month upgrade

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upgrade to Non-Vegetarian',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (meal != null)
            Text(
              'Upgrade $meal for ${day ?? "selected day"}',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: const Color(0xFF757575),
              ),
            )
          else if (day != null)
            Text(
              'Upgrade all meals for $day',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: const Color(0xFF757575),
              ),
            )
          else
            Text(
              'Choose your upgrade option',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: const Color(0xFF757575),
              ),
            ),
          const SizedBox(height: 24),
          // Single Meal Upgrade
          if (meal != null)
            _buildUpgradeOption(
              context: context,
              title: 'Single Meal',
              description: 'Upgrade this $meal to non-vegetarian',
              price: singleMealPrice,
              icon: Icons.restaurant,
              onTap: () => onUpgrade('Single Meal', singleMealPrice),
              isSmallScreen: isSmallScreen,
            ),
          // Day Upgrade
          if (day != null && meal == null)
            _buildUpgradeOption(
              context: context,
              title: 'Full Day',
              description: 'Upgrade all meals (Tiffin, Lunch, Dinner) for $day',
              price: dayPrice,
              icon: Icons.calendar_today,
              onTap: () => onUpgrade('Day', dayPrice),
              isSmallScreen: isSmallScreen,
            ),
          // Week Upgrade
          _buildUpgradeOption(
            context: context,
            title: 'Full Week',
            description: 'Upgrade all meals for the entire week',
            price: weekPrice,
            icon: Icons.date_range,
            onTap: () => onUpgrade('Week', weekPrice),
            isSmallScreen: isSmallScreen,
            isRecommended: true,
          ),
          const SizedBox(height: 16),
          _buildUpgradeOption(
            context: context,
            title: 'Full Month',
            description: 'Upgrade all meals for the entire month',
            price: monthPrice,
            icon: Icons.workspace_premium,
            onTap: () => onUpgrade('Month', monthPrice),
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUpgradeOption({
    required BuildContext context,
    required String title,
    required String description,
    required int price,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
    bool isRecommended = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRecommended ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE0E0E0),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF9800)),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            if (isRecommended) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Best Value',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Upgrade'),
        ),
        isThreeLine: true,
      ),
    );
  }
}

