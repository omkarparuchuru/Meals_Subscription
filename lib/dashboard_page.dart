import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'screens/subscription/meal_customization_page.dart';
import 'screens/orders/order_status_page.dart';
import 'screens/meals/manage_meals_page.dart';
import 'screens/meals/weekly_menu_page.dart';
import 'screens/customer/customer_page.dart';
import 'screens/profile/edit_profile_page.dart';
import 'screens/upgrade/upgrade_meal_page.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  final String mobileNumber;
  final String address;
  final String? landmark;
  final String? profileImagePath;

  const DashboardPage({
    super.key,
    required this.userName,
    required this.mobileNumber,
    required this.address,
    this.landmark,
    this.profileImagePath,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _hasActiveSubscription = false;
  String? _subscriptionPlanType;
  String? _subscriptionDietType;
  String? _subscriptionDuration;
  DateTime? _subscriptionEndDate;
  int? _daysRemaining;

  final List<Map<String, dynamic>> _todayOrders = [
    {
      'meal': 'Tiffin',
      'status': 'Delivered',
      'time': 'Delivered at 8:30 AM',
      'icon': Icons.wb_sunny,
      'iconColor': Colors.orange,
    },
    {
      'meal': 'Lunch',
      'status': 'Out for Delivery',
      'time': 'Expected: 1:00 PM',
      'icon': Icons.wb_cloudy,
      'iconColor': Colors.orange,
    },
    {
      'meal': 'Dinner',
      'status': 'Preparing',
      'time': 'Expected: 8:00 PM',
      'icon': Icons.nightlight_round,
      'iconColor': Colors.amber,
    },
  ];

  String? _storedUserName;
  String? _storedProfileImagePath;
  String? _storedAddress;
  String? _storedLandmark;
  Map<String, String>? _dinnerCustomization;
  List<String> _selectedMeals = ['Tiffin', 'Lunch', 'Dinner']; // Default to all

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkSubscriptionStatus();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedUserName = prefs.getString('userName') ?? widget.userName;
      _storedProfileImagePath = prefs.getString('profileImagePath') ?? widget.profileImagePath;
      _storedAddress = prefs.getString('address') ?? widget.address;
      _storedLandmark = prefs.getString('landmark') ?? widget.landmark;
    });
  }

  void _checkSubscriptionStatus() {
    // Check if subscription data was passed from payment
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', widget.userName);
        if (widget.profileImagePath != null) {
          await prefs.setString('profileImagePath', widget.profileImagePath!);
        }
        await prefs.setString('address', widget.address);
        if (widget.landmark != null && widget.landmark!.isNotEmpty) {
          await prefs.setString('landmark', widget.landmark!);
        }
        if (args['dinnerCustomization'] != null) {
          _dinnerCustomization = Map<String, String>.from(args['dinnerCustomization']);
          await prefs.setString('dinnerBase', _dinnerCustomization!['base'] ?? 'rice');
          await prefs.setString('dinnerCurry', _dinnerCustomization!['curry'] ?? 'curry');
        }
        if (args['selectedMeals'] != null) {
          _selectedMeals = List<String>.from(args['selectedMeals']);
          await prefs.setStringList('selectedMeals', _selectedMeals);
        }
        _updateSubscriptionData(
          planType: args['planType'] ?? 'employee',
          dietType: args['dietType'] ?? 'non-vegetarian',
          duration: args['duration'] ?? '1 Month',
          days: args['days'] ?? 30,
        );
        setState(() {
          _storedUserName = widget.userName;
          _storedProfileImagePath = widget.profileImagePath;
          _storedAddress = widget.address;
          _storedLandmark = widget.landmark;
        });
      } else {
        // Load from SharedPreferences if available
        final prefs = await SharedPreferences.getInstance();
        final storedName = prefs.getString('userName');
        final storedImage = prefs.getString('profileImagePath');
        final storedAddress = prefs.getString('address');
        final storedLandmark = prefs.getString('landmark');
        final dinnerBase = prefs.getString('dinnerBase');
        final dinnerCurry = prefs.getString('dinnerCurry');
        final storedMeals = prefs.getStringList('selectedMeals');
        
        setState(() {
          _storedUserName = storedName ?? widget.userName;
          _storedProfileImagePath = storedImage ?? widget.profileImagePath;
          _storedAddress = storedAddress ?? widget.address;
          _storedLandmark = storedLandmark ?? widget.landmark;
          if (dinnerBase != null && dinnerCurry != null) {
            _dinnerCustomization = {'base': dinnerBase, 'curry': dinnerCurry};
          }
          if (storedMeals != null) {
            _selectedMeals = storedMeals;
          }
        });
      }
    });
  }

  void _updateSubscriptionData({
    required String planType,
    required String dietType,
    required String duration,
    required int days,
  }) {
    setState(() {
      _hasActiveSubscription = true;
      _subscriptionPlanType = planType;
      _subscriptionDietType = dietType;
      _subscriptionDuration = duration;
      _subscriptionEndDate = DateTime.now().add(Duration(days: days));
      _daysRemaining = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              _buildHeader(isSmallScreen, context),
              const SizedBox(height: 20),
              // Conditional Content Based on Subscription Status
              if (_hasActiveSubscription) ...[
                // After Subscription - Show Subscription Details & Orders
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                  child: _buildActiveSubscriptionCard(isSmallScreen),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                  child: _buildTodayOrdersCard(isSmallScreen),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                  child: _buildNavigationGrid(isSmallScreen, isTablet),
                ),
              ] else ...[
                // Before Subscription - Show Meal Plans List
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                  child: _buildSubscriptionCard(isSmallScreen),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                  child: _buildMealPlansList(isSmallScreen),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: isSmallScreen ? 16 : 24,
        right: isSmallScreen ? 16 : 24,
        top: MediaQuery.of(context).padding.top + (isSmallScreen ? 20 : 24),
        bottom: isSmallScreen ? 20 : 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        // Profile Image or Initial - Always show
                        GestureDetector(
                          onTap: () => _showProfileDialog(context, isSmallScreen),
                          child: (_storedProfileImagePath ?? widget.profileImagePath) != null
                              ? Container(
                                  width: isSmallScreen ? 36 : 44,
                                  height: isSmallScreen ? 36 : 44,
                                  margin: EdgeInsets.only(right: isSmallScreen ? 10 : 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: FileImage(File(_storedProfileImagePath ?? widget.profileImagePath!)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : (_storedUserName ?? widget.userName).isNotEmpty
                                  ? Container(
                                      width: isSmallScreen ? 36 : 44,
                                      height: isSmallScreen ? 36 : 44,
                                      margin: EdgeInsets.only(right: isSmallScreen ? 10 : 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (_storedUserName ?? widget.userName)[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 16 : 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Text(
                            'Hello, ${_storedUserName ?? widget.userName}!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text('ðŸ‘‹', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        // Logout Button
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => _showLogoutDialog(context),
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome to your meal dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'No active subscription',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _handleSubscribe();
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
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Subscribe Now',
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
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(bool isSmallScreen) {
    final planName = _subscriptionPlanType == 'hostel' ? 'Hostel Plan' : 'Employee Plan';
    final planColor = _subscriptionPlanType == 'hostel'
        ? Colors.blue[700]!
        : Colors.purple[700]!;
    final dietColor = _subscriptionDietType == 'vegetarian'
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Active Subscription',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: planColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    planName,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: planColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: dietColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _subscriptionDietType == 'vegetarian'
                          ? Icons.eco
                          : Icons.set_meal,
                      color: dietColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _subscriptionDietType == 'vegetarian'
                          ? 'Vegetarian'
                          : 'Non-Veg',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: dietColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Valid for',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$_daysRemaining',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'days',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subscriptionDuration ?? '1 Month',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Expires',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subscriptionEndDate != null
                        ? '${_subscriptionEndDate!.day}/${_subscriptionEndDate!.month}/${_subscriptionEndDate!.year}'
                        : '12/20/2025',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildTodayOrdersCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Orders",
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._todayOrders.where((order) => _selectedMeals.contains(order['meal'])).map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderItem(
                  meal: order['meal'] as String,
                  status: order['status'] as String,
                  time: order['time'] as String,
                  icon: order['icon'] as IconData,
                  iconColor: order['iconColor'] as Color,
                  isSmallScreen: isSmallScreen,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String meal,
    required String status,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isSmallScreen,
  }) {
    final isDelivered = status == 'Delivered';
    final statusColor = isDelivered
        ? Colors.green
        : status == 'Out for Delivery'
            ? Colors.orange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDelivered
                          ? Icons.check_circle
                          : status == 'Out for Delivery'
                              ? Icons.local_shipping
                              : Icons.access_time,
                      color: statusColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDelivered) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _reportOrder(meal),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Report',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlansList(bool isSmallScreen) {
    final plans = [
      {
        'name': 'Hostel Plan',
        'price': 'â‚¹2,999/month',
        'description': 'Perfect for students. 3 meals daily.',
        'icon': Icons.apartment,
        'color': Colors.blue[700]!,
      },
      {
        'name': 'Employee Plan',
        'price': 'â‚¹3,499/month',
        'description': 'For working professionals. Premium meals.',
        'icon': Icons.people,
        'color': Colors.purple[700]!,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        ...plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPlanCard(
                name: plan['name'] as String,
                price: plan['price'] as String,
                description: plan['description'] as String,
                icon: plan['icon'] as IconData,
                color: plan['color'] as Color,
                isSmallScreen: isSmallScreen,
              ),
            )),
      ],
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: () => _handleSubscribe(),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 60 : 70,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 30 : 35),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF757575), size: 20),
          ],
        ),
      ),
    );
  }

  void _reportOrder(String meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Text('Did you not receive your $meal? Our team will contact you shortly to resolve this.'),
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
                      Expanded(
                        child: Text('Issue reported. Our team will contact you within 2 hours.'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(bool isSmallScreen, bool isTablet) {
    final crossAxisCount = isTablet ? 4 : 2;
    final childAspectRatio = isTablet ? 1.2 : 1.1;

    final navCards = <Widget>[
      _buildNavCard(
        icon: Icons.inventory_2_outlined,
        label: 'Order Status',
        color: const Color(0xFF2196F3),
        onTap: () => _handleOrderStatus(),
        isSmallScreen: isSmallScreen,
      ),
      _buildNavCard(
        icon: Icons.restaurant_menu,
        label: 'Manage Meals',
        color: const Color(0xFFFF9800),
        onTap: () => _handleViewMenu(),
        isSmallScreen: isSmallScreen,
      ),
      _buildNavCard(
        icon: Icons.calendar_today,
        label: 'Weekly Menu',
        color: const Color(0xFF9C27B0),
        onTap: () => _handleWeeklyMenu(),
        isSmallScreen: isSmallScreen,
      ),
    ];

    if (_hasActiveSubscription) {
      navCards.add(
        _buildNavCard(
          icon: Icons.upgrade,
          label: 'Upgrade Meal',
          color: const Color(0xFFFFC107),
          onTap: () => _handleUpgradeNavigation(),
          isSmallScreen: isSmallScreen,
        ),
      );
      navCards.add(
        _buildNavCard(
          icon: Icons.support_agent,
          label: 'Support',
          color: const Color(0xFF4CAF50),
          onTap: () => _handleCustomerSupport(),
          isSmallScreen: isSmallScreen,
        ),
      );
    } else {
      navCards.add(
        _buildNavCard(
          icon: Icons.subscriptions,
          label: 'Subscribe',
          color: Colors.white,
          isGradient: true,
          onTap: () => _handleSubscribe(),
          isSmallScreen: isSmallScreen,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      children: navCards,
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGradient ? null : Colors.white,
          gradient: isGradient
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFF9800), // Orange
                    Color(0xFF4CAF50), // Green
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 32 : 40,
              color: isGradient ? Colors.white : color,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: isGradient ? Colors.white : const Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, bool isSmallScreen) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                        onPressed: () {
                          Navigator.pop(context);
                          _openEditProfilePage();
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF757575)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
                  _buildInfoRow(
                    label: 'Name',
                    value: _storedUserName ?? widget.userName,
                icon: Icons.person,
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                label: 'Mobile Number',
                value: widget.mobileNumber,
                icon: Icons.phone,
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 16),
                  _buildInfoRow(
                    label: 'Delivery Address',
                    value: _storedAddress ?? widget.address,
                icon: Icons.location_on,
                isSmallScreen: isSmallScreen,
              ),
              if ((_storedLandmark ?? widget.landmark)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  label: 'Landmark',
                  value: (_storedLandmark ?? widget.landmark)!,
                  icon: Icons.place,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _openEditProfilePage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _storedUserName ?? widget.userName,
          initialAddress: _storedAddress ?? widget.address,
          initialLandmark: _storedLandmark ?? widget.landmark,
          mobileNumber: widget.mobileNumber,
          initialImagePath: _storedProfileImagePath ?? widget.profileImagePath,
        ),
      ),
    );

    if (result == true) {
      await _loadUserData();
      setState(() {});
    }
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Removed _buildAccountInfoCard - no longer used (moved to profile dialog)

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF757575),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSubscribe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MealCustomizationPage(),
      ),
    );
  }

  void _handleOrderStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderStatusPage(),
      ),
    );
  }

  void _handleViewMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final dinnerBase = prefs.getString('dinnerBase');
    final dinnerCurry = prefs.getString('dinnerCurry');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageMealsPage(
          userDietType: _subscriptionDietType ?? 'vegetarian',
          dinnerCustomization: (dinnerBase != null && dinnerCurry != null)
              ? {'base': dinnerBase, 'curry': dinnerCurry}
              : null,
          selectedMeals: _selectedMeals,
        ),
      ),
    );
  }

  void _handleUpgradeNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final dinnerBase = prefs.getString('dinnerBase');
    final dinnerCurry = prefs.getString('dinnerCurry');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpgradeMealPage(
          planType: _subscriptionPlanType ?? 'employee',
          dietType: _subscriptionDietType ?? 'vegetarian',
          currentMeals: _selectedMeals,
          dinnerCustomization: (dinnerBase != null && dinnerCurry != null)
              ? {'base': dinnerBase, 'curry': dinnerCurry}
              : null,
        ),
      ),
    ).then((upgraded) async {
      if (upgraded == true && mounted) {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _subscriptionDietType =
              prefs.getString('subscriptionDietType') ?? _subscriptionDietType;
        });
      }
    });
  }
  
  void _handleWeeklyMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final dinnerBase = prefs.getString('dinnerBase');
    final dinnerCurry = prefs.getString('dinnerCurry');
    
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyMenuPage(
          isFromManage: false,
          userDietType: _subscriptionDietType ?? 'vegetarian',
          dinnerCustomization: (dinnerBase != null && dinnerCurry != null)
              ? {'base': dinnerBase, 'curry': dinnerCurry}
              : null,
          selectedMeals: _selectedMeals,
        ),
      ),
    );
  }

  void _handleCustomerSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerPage(),
      ),
    );
  }

}


