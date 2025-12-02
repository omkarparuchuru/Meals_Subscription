import 'package:flutter/material.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Removed Upcoming tab
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
            // Tabs
            _buildTabs(isSmallScreen),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(isSmallScreen),
                  _buildPastTab(isSmallScreen),
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
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 16 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF2196F3),
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
            'Order Status',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your meal deliveries',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isSmallScreen) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2196F3),
        labelColor: const Color(0xFF2196F3),
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Today'),
          Tab(text: 'Past'),
        ],
      ),
    );
  }

  Widget _buildTodayTab(bool isSmallScreen) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : isTablet ? 40 : 24),
      child: Column(
        children: [
          _buildOrderCard(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            mealType: 'Tiffin',
            description: 'Idli & Coconut Chutney',
            status: 'Delivered',
            statusColor: Colors.green,
            deliveryTime: 'Delivered at: 8:30 AM',
            showAction: true,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            icon: Icons.wb_cloudy,
            iconColor: Colors.orange,
            mealType: 'Lunch',
            description: 'Rice, Dal Tadka, Aloo Gobi',
            status: 'Out for Delivery',
            statusColor: Colors.orange,
            deliveryTime: null,
            showAction: false,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            icon: Icons.nightlight_round,
            iconColor: Colors.amber,
            mealType: 'Dinner',
            description: 'Roti, Paneer Butter Masala',
            status: 'Preparing',
            statusColor: Colors.blue,
            deliveryTime: null,
            showAction: false,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These orders will be prepared and delivered on the scheduled date',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Removed _buildUpcomingTab - no longer used (upcoming tab was removed)

  Widget _buildPastTab(bool isSmallScreen) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : isTablet ? 40 : 24),
      child: Column(
        children: [
          _buildOrderCard(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            mealType: 'Tiffin',
            description: 'Poha & Tea',
            status: 'Delivered',
            statusColor: Colors.green,
            deliveryTime: 'Delivered at: 8:15 AM',
            showAction: false,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            icon: Icons.wb_cloudy,
            iconColor: Colors.orange,
            mealType: 'Lunch',
            description: 'Rice, Sambar, Cabbage Fry',
            status: 'Delivered',
            statusColor: Colors.green,
            deliveryTime: 'Delivered at: 1:00 PM',
            showAction: false,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required IconData icon,
    required Color iconColor,
    required String mealType,
    required String description,
    required String status,
    required Color statusColor,
    String? deliveryTime,
    required bool showAction,
    required bool isSmallScreen,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == 'Delivered'
                          ? Icons.check_circle
                          : status == 'Out for Delivery'
                              ? Icons.local_shipping
                              : Icons.access_time,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (deliveryTime != null) ...[
            const SizedBox(height: 12),
            Text(
              deliveryTime,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
          if (showAction && status == 'Delivered') ...[
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showReportDialog(mealType);
                },
                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                label: const Text(
                  'Mark as Not Received',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportDialog(String mealType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Text('Are you sure you did not receive your $mealType? Our team will contact you shortly.'),
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
                      Text('Issue reported. Our team will contact you shortly.'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}


