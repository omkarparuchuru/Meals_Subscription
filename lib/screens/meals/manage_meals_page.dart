import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/meal_upgrade_manager.dart';
import '../meals/weekly_menu_page.dart';
import '../settings/delivery_settings_page.dart';

class ManageMealsPage extends StatefulWidget {
  final String? userDietType;
  final Map<String, String>? dinnerCustomization;
  final List<String>? selectedMeals;

  const ManageMealsPage({
    super.key,
    this.userDietType,
    this.dinnerCustomization,
    this.selectedMeals,
  });

  @override
  State<ManageMealsPage> createState() => _ManageMealsPageState();
}

class _ManageMealsPageState extends State<ManageMealsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Store meal states per day: {day: {meal: {enabled: bool, time: String, address: String}}}
  final Map<String, Map<String, Map<String, dynamic>>> _mealStates = {};

  // Track current meals and diet type
  List<String> _currentMeals = [];
  String? _currentDietType;
  Map<String, String>? _currentDinnerCustomization;
  
  // Default times and address
  final Map<String, String> _defaultTimes = {
    'Tiffin': '8:00 AM',
    'Lunch': '1:00 PM',
    'Dinner': '8:00 PM',
  };
  
  String _defaultAddress = '123 Main Street, Apartment 4B, Near Central Park';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMealData();
  }

  Future<void> _loadMealData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (mounted) {
      // Load current base meals from SharedPreferences
      final baseMeals = prefs.getStringList('selectedMeals') ?? widget.selectedMeals ?? ['Tiffin', 'Lunch', 'Dinner'];
      
      setState(() {
        _currentMeals = baseMeals;
        _currentDietType = widget.userDietType;
        _currentDinnerCustomization = widget.dinnerCustomization;
        
        // Load dinner customization if available
        final dinnerBase = prefs.getString('dinnerBase');
        final dinnerCurry = prefs.getString('dinnerCurry');
        if (dinnerBase != null && dinnerCurry != null) {
          _currentDinnerCustomization = {'base': dinnerBase, 'curry': dinnerCurry};
        }
      });
      
      await _initializeMealStates(baseMeals);
    }
  }
  
  Future<void> _initializeMealStates(List<String> baseMeals) async {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final day = days[(now.weekday + i - 1) % 7];
      
      // Get meals for this specific date (base + added)
      final mealsForDay = await MealUpgradeManager.getMealsForDate(date, baseMeals);
      
      setState(() {
        _mealStates[day] = {};
        
        for (final meal in mealsForDay) {
          _mealStates[day]![meal] = {
            'enabled': true,
            'time': _defaultTimes[meal] ?? '12:00 PM',
            'address': _defaultAddress
          };
        }
      });
    }
  }
  
  bool _getMealState(String day, String meal) {
    return _mealStates[day]?[meal]?['enabled'] ?? true;
  }
  
  String _getMealTime(String day, String meal) {
    return _mealStates[day]?[meal]?['time'] ?? _defaultTimes[meal] ?? '';
  }
  
  String _getMealAddress(String day, String meal) {
    return _mealStates[day]?[meal]?['address'] ?? _defaultAddress;
  }
  
  void _setMealState(String day, String meal, bool enabled) {
    setState(() {
      if (_mealStates[day] == null) {
        _mealStates[day] = {};
      }
      if (_mealStates[day]![meal] == null) {
        _mealStates[day]![meal] = {
          'enabled': enabled,
          'time': _defaultTimes[meal] ?? '',
          'address': _defaultAddress,
        };
      } else {
        _mealStates[day]![meal]!['enabled'] = enabled;
      }
    });
  }
  
  void _setMealTime(String day, String meal, String time) {
    setState(() {
      if (_mealStates[day] == null) {
        _mealStates[day] = {};
      }
      if (_mealStates[day]![meal] == null) {
        _mealStates[day]![meal] = {
          'enabled': true,
          'time': time,
          'address': _defaultAddress,
        };
      } else {
        _mealStates[day]![meal]!['time'] = time;
      }
    });
  }
  
  void _setMealAddress(String day, String meal, String address) {
    setState(() {
      if (_mealStates[day] == null) {
        _mealStates[day] = {};
      }
      if (_mealStates[day]![meal] == null) {
        _mealStates[day]![meal] = {
          'enabled': true,
          'time': _defaultTimes[meal] ?? '',
          'address': address,
        };
      } else {
        _mealStates[day]![meal]!['address'] = address;
      }
    });
  }
  
  void _pauseAllMealsForDay(String day) {
    setState(() {
      if (_mealStates[day] != null) {
        for (var meal in _mealStates[day]!.keys) {
           _mealStates[day]![meal]?['enabled'] = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isSmallScreen),
            // Policy Alert
            _buildPolicyAlert(isSmallScreen),
            // Tabs
            _buildTabs(),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildScheduleTab(isSmallScreen),
                  WeeklyMenuPage(
                    isFromManage: true,
                    userDietType: _currentDietType ?? 'vegetarian',
                    dinnerCustomization: _currentDinnerCustomization,
                    selectedMeals: _currentMeals,
                  ),
                  DeliverySettingsPage(
                    selectedMeals: _currentMeals,
                    userDietType: _currentDietType,
                    dinnerCustomization: _currentDinnerCustomization,
                  ),
                ],
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
        horizontal: isSmallScreen ? 16 : MediaQuery.of(context).size.width > 600 ? 40 : 24,
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
            'Manage Your Meals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'View menu, pause meals, and manage delivery preferences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '12h 30m until cutoff',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyAlert(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal Modification Policy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can only pause or modify tomorrow\'s meals before 8:00 PM today. After 8 PM, changes will apply to the day after tomorrow.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: const Color(0xFF2C2C2C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF4CAF50),
        labelColor: const Color(0xFF4CAF50),
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Schedule'),
          Tab(text: 'Weekly Menu'),
          Tab(text: 'Delivery'),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(bool isSmallScreen) {
    final now = DateTime.now();
    final today = now.weekday;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          for (int i = 0; i < 7; i++) ...[
            _buildDaySchedule(
              day: days[(today + i - 1) % 7],
              isToday: i == 0,
              canModify: i > 0,
              isSmallScreen: isSmallScreen,
            ),
            if (i < 6) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySchedule({
    required String day,
    required bool isToday,
    required bool canModify,
    required bool isSmallScreen,
  }) {
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
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF757575), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
              if (canModify)
                TextButton.icon(
                  onPressed: () => _pauseAllMeals(day),
                  icon: const Icon(Icons.pause, size: 18),
                  label: const Text('Pause All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isToday
                ? 'Today - Cannot modify'
                : canModify
                    ? 'Tomorrow - Can modify'
                    : 'Can modify',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: isToday
                  ? Colors.blue
                  : canModify
                      ? Colors.green
                      : const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 16),
          ...((_mealStates[day]?.keys.toList() ?? [])
                ..sort((a, b) {
                  final order = {'Tiffin': 0, 'Lunch': 1, 'Snacks': 2, 'Dinner': 3};
                  return (order[a] ?? 99).compareTo(order[b] ?? 99);
                }))
              .map((meal) {
            return Column(
              children: [
                _buildMealToggle(day, meal, !isToday && canModify, isSmallScreen),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMealToggle(String day, String meal, bool enabled, bool isSmallScreen) {
    final isOn = _getMealState(day, meal);
    final time = _getMealTime(day, meal);
    final address = _getMealAddress(day, meal);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOn ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOn ? const Color(0xFF4CAF50).withOpacity(0.3) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meal,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        if (!isOn) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Paused',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: const Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: const Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: const Color(0xFF757575),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: enabled
                    ? (value) {
                        _setMealState(day, meal, value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? '$meal enabled for delivery'
                                  : '$meal paused',
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor: value ? Colors.green : Colors.orange,
                          ),
                        );
                      }
                    : null,
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            // Single line buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: isSmallScreen ? 32 : 36,
                    child: OutlinedButton.icon(
                      onPressed: () => _changeMealTime(day, meal, time),
                      icon: Icon(Icons.access_time, size: isSmallScreen ? 12 : 14),
                      label: Text(
                        'Time',
                        style: TextStyle(fontSize: isSmallScreen ? 10 : 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 4 : 6,
                          horizontal: isSmallScreen ? 6 : 8,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Expanded(
                  child: SizedBox(
                    height: isSmallScreen ? 32 : 36,
                    child: OutlinedButton.icon(
                      onPressed: () => _changeMealAddress(day, meal, address),
                      icon: Icon(Icons.location_on, size: isSmallScreen ? 12 : 14),
                      label: Text(
                        'Address',
                        style: TextStyle(fontSize: isSmallScreen ? 10 : 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 4 : 6,
                          horizontal: isSmallScreen ? 6 : 8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  void _changeMealTime(String day, String meal, String currentTime) {
    final timeController = TextEditingController(text: currentTime);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change $meal Time for $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Delivery Time',
                hintText: 'e.g., 8:00 AM',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Times:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTimeChip('7:00 AM', timeController),
                _buildTimeChip('8:00 AM', timeController),
                _buildTimeChip('9:00 AM', timeController),
                _buildTimeChip('12:00 PM', timeController),
                _buildTimeChip('1:00 PM', timeController),
                _buildTimeChip('2:00 PM', timeController),
                _buildTimeChip('7:00 PM', timeController),
                _buildTimeChip('8:00 PM', timeController),
                _buildTimeChip('9:00 PM', timeController),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              timeController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTime = timeController.text.trim();
              if (newTime.isNotEmpty) {
                _setMealTime(day, meal, newTime);
                timeController.dispose();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$meal time updated to $newTime for $day'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeChip(String time, TextEditingController controller) {
    return ActionChip(
      label: Text(time),
      onPressed: () {
        controller.text = time;
      },
      backgroundColor: const Color(0xFFE3F2FD),
    );
  }
  
  void _changeMealAddress(String day, String meal, String currentAddress) {
    final addressController = TextEditingController(text: currentAddress);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change $meal Address for $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter complete address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate getting current location
                addressController.text = '123 Main Street, Apartment 4B, Near Central Park';
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location fetched successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              addressController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAddress = addressController.text.trim();
              if (newAddress.isNotEmpty) {
                _setMealAddress(day, meal, newAddress);
                addressController.dispose();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$meal address updated for $day'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pauseAllMeals(String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause All Meals'),
        content: Text('Are you sure you want to pause all meals for $day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _pauseAllMealsForDay(day);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All meals paused for $day'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Pause All'),
          ),
        ],
      ),
    );
  }
}

