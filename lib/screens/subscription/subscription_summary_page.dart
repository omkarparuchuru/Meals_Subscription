import 'package:flutter/material.dart';
import '../payment/payment_page.dart';

class SubscriptionSummaryPage extends StatelessWidget {
  final String planType;
  final String dietType;
  final String duration;

  final int totalAmount;
  final List<String> selectedMeals;
  final Map<String, String>? dinnerCustomization;

  const SubscriptionSummaryPage({
    super.key,
    required this.planType,
    required this.dietType,
    required this.duration,

    required this.totalAmount,
    required this.selectedMeals,
    this.dinnerCustomization,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final gst = (totalAmount * 0.05).round();
    final finalAmount = totalAmount + gst;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Header
          _buildHeader(isSmallScreen, context),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Subscription Summary Card
                    _buildSummaryCard(isSmallScreen, gst, finalAmount),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Continue to Payment Button
          Container(
            padding: EdgeInsets.only(
              left: isSmallScreen ? 16 : 24,
              right: isSmallScreen ? 16 : 24,
              top: isSmallScreen ? 16 : 24,
              bottom: 0, // Handled by SafeArea
            ),
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
              top: false,
              child: Container(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 24),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          planType: planType,
                          dietType: dietType,
                          duration: duration,
                          totalAmount: finalAmount,
                          subtotal: totalAmount,
                          selectedMeals: selectedMeals,
                          dinnerCustomization: dinnerCustomization,
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
                        'Continue to Payment',
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
    );
  }

  Widget _buildHeader(bool isSmallScreen, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: isSmallScreen ? 16 : 24,
        right: isSmallScreen ? 16 : 24,
        top: MediaQuery.of(context).padding.top + (isSmallScreen ? 16 : 20),
        bottom: isSmallScreen ? 16 : 20,
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
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Subscription Summary',
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

  Widget _buildSummaryCard(bool isSmallScreen, int gst, int finalAmount) {
    final planName = planType == 'hostel' ? 'Hostel Plan' : 'Employee Plan';
    final dietName = dietType == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian';

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Summary',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Plan Type', planName, isSmallScreen),
          const SizedBox(height: 12),
          _buildSummaryRow('Diet', dietName, isSmallScreen),
          const SizedBox(height: 12),
          _buildSummaryRow('Duration', duration, isSmallScreen),
          const SizedBox(height: 12),
          _buildSummaryRow('Meals Included', selectedMeals.join(', '), isSmallScreen),
          if (dinnerCustomization != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 24),
            Text(
              'Dinner Customization',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Base',
              _formatCustomization(dinnerCustomization!['base'] ?? ''),
              isSmallScreen,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Curry',
              _formatCustomization(dinnerCustomization!['curry'] ?? ''),
              isSmallScreen,
            ),
          ],
          const Divider(height: 32),
          _buildSummaryRow('Subtotal', 'â‚¹${totalAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isSmallScreen),
          const SizedBox(height: 8),
          _buildSummaryRow('GST (5%)', 'â‚¹${gst.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isSmallScreen),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              Text(
                'â‚¹${finalAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: const Color(0xFF757575),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  String _formatCustomization(String value) {
    switch (value.toLowerCase()) {
      case 'rice':
        return 'Rice';
      case 'chapathi':
        return 'Chapathi';
      case 'pulka':
        return 'Pulka';
      case 'curry':
        return 'Curry';
      case 'dal':
        return 'Dal';
      case 'sabzi':
        return 'Sabzi';
      default:
        return value;
    }
  }
}


