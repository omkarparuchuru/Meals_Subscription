import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard_page.dart';

class PaymentPage extends StatefulWidget {
  final String planType;
  final String dietType;
  final String duration;
  final int totalAmount;
  final int subtotal;
  final List<String> selectedMeals;
  final Map<String, String>? dinnerCustomization;

  const PaymentPage({
    super.key,
    required this.planType,
    required this.dietType,
    required this.duration,
    required this.totalAmount,

    required this.subtotal,
    required this.selectedMeals,
    this.dinnerCustomization,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'upi';
  final TextEditingController _upiController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
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
                    children: [
                      const SizedBox(height: 24),
                      // Payment Method Selection
                      _buildPaymentMethodCard(isSmallScreen),
                      const SizedBox(height: 24),
                      // UPI Input (if UPI selected)
                      if (selectedPaymentMethod == 'upi')
                        _buildUpiInputCard(isSmallScreen),
                      const SizedBox(height: 24),
                      // Order Summary
                      _buildOrderSummaryCard(isSmallScreen),
                      const SizedBox(height: 24),
                      // Security Message
                      _buildSecurityMessage(isSmallScreen),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            // Pay Button
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
                    onPressed: _isProcessing ? null : _handlePayButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isProcessing
                            ? null
                            : const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFFF9800),
                                  Color(0xFF4CAF50),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        color: _isProcessing ? Colors.grey : null,
                      ),
                      child: Center(
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Pay ₹${widget.totalAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: const TextStyle(
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
            'Complete Payment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Secure payment gateway powered by industry standards',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(bool isSmallScreen) {
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
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isTabletLayout = screenWidth > 600;
              final crossAxisCount = isTabletLayout ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isTabletLayout ? 1.5 : 1.2,
            children: [
              _buildPaymentOption('upi', Icons.phone_android, 'UPI', isSmallScreen),
              _buildPaymentOption('card', Icons.credit_card, 'Card', isSmallScreen),
              _buildPaymentOption('bank', Icons.account_balance, 'Bank', isSmallScreen),
                _buildPaymentOption('wallet', Icons.account_balance_wallet, 'Wallet', isSmallScreen),
              ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon, String label, bool isSmallScreen) {
    final isSelected = selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = method),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF757575),
              size: isSmallScreen ? 28 : 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiInputCard(bool isSmallScreen) {
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
          Text(
            'UPI ID',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _upiController,
              decoration: const InputDecoration(
                hintText: 'yourname@upi',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your UPI ID (Google Pay, PhonePe, Paytm, etc.)',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode: Use any UPI ID format (e.g., demo@upi) to continue',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1976D2),
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

  Widget _buildOrderSummaryCard(bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletLayout = screenWidth > 600;
    final planName = widget.planType == 'hostel' ? 'Hostel Plan' : 'Employee Plan';
    final dietName = widget.dietType == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian';

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : isTabletLayout ? 24 : 20),
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
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Plan Type', planName, isSmallScreen),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Diet Preference',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: const Color(0xFF757575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      widget.dietType == 'vegetarian' ? Icons.eco : Icons.set_meal,
                      size: isSmallScreen ? 14 : 16,
                      color: const Color(0xFF757575),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  dietName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Duration', widget.duration, isSmallScreen),
          const SizedBox(height: 12),
          _buildSummaryRow('Meals Included', widget.selectedMeals.join(', '), isSmallScreen),
          const Divider(height: 24),
          _buildSummaryRow('Subtotal', '₹${widget.subtotal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isSmallScreen),
          const SizedBox(height: 8),
          _buildSummaryRow('GST (5%)', '₹${((widget.subtotal * 0.05).round()).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isSmallScreen),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '₹${widget.totalAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: const Color(0xFF757575),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityMessage(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock,
            color: Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your payment is secured with 256-bit encryption',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayButtonPressed() {
    if (selectedPaymentMethod == 'upi' && _upiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter your UPI ID'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _showConfirmPaymentSheet();
  }

  void _showConfirmPaymentSheet() {
    final methodLabel = _getPaymentMethodLabel(selectedPaymentMethod);
    final methodIcon = _getPaymentMethodIcon(selectedPaymentMethod);
    final methodSubtitle = selectedPaymentMethod == 'upi'
        ? _upiController.text.trim().isNotEmpty
            ? _upiController.text.trim()
            : 'UPI ID not provided'
        : 'Tap confirm to continue with $methodLabel';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(methodIcon, color: const Color(0xFFFF9800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        methodLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        methodSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      Text(
                        '₹${widget.totalAmount.toString().replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.verified, color: Color(0xFF4CAF50), size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'You will receive an instant confirmation after the payment succeeds.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF757575),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _processPayment();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text(
                      'Confirm & Pay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'card':
        return 'Credit or Debit Card';
      case 'bank':
        return 'Net Banking';
      case 'wallet':
        return 'Wallet Payment';
      case 'upi':
      default:
        return 'UPI Payment';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'upi':
      default:
        return Icons.phone_android;
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);

      // Show animated success dialog
      _showPaymentSuccessAnimation(context      );
    }
  }
  
  void _showPaymentSuccessAnimation(BuildContext context) {
    // Calculate days based on duration
    int days = 30; // Default 1 month
    if (widget.duration == '3 Months') days = 90;
    else if (widget.duration == '6 Months') days = 180;
    else if (widget.duration == '1 Year') days = 365;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Success Icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 70,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Animated Title
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: const Text(
                            'Payment Successful!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Animated Content
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              const Text(
                                'Your subscription has been activated successfully!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Color(0xFF4CAF50),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Confirmation email sent',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: const Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Animated Button
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  // Get user data from SharedPreferences
                                  final prefs = await SharedPreferences.getInstance();
                                  final userName = prefs.getString('userName') ?? 'User';
                                  final mobileNumber = prefs.getString('mobileNumber') ?? '+91 6302207891';
                                  final address = prefs.getString('address') ?? '123 Main Street';
                                  final landmark = prefs.getString('landmark');
                                  final profileImagePath = prefs.getString('profileImagePath');
                                  
                                  // Save dinner customization
                                  if (widget.dinnerCustomization != null) {
                                    await prefs.setString('dinnerBase', widget.dinnerCustomization!['base'] ?? 'rice');
                                    await prefs.setString('dinnerCurry', widget.dinnerCustomization!['curry'] ?? 'curry');
                                  }

                                  // Save selected meals
                                  await prefs.setStringList('selectedMeals', widget.selectedMeals);
                                  
                                  // Check if this is an upgrade payment
                                  final isUpgrade = widget.duration == 'Upgrade';
                                  
                                  if (isUpgrade) {
                                    // Return true to indicate successful upgrade payment
                                    Navigator.pop(context, true);
                                  } else {
                                    // Navigate to dashboard with subscription data
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DashboardPage(
                                          userName: userName,
                                          mobileNumber: mobileNumber,
                                          address: address,
                                          landmark: landmark,
                                          profileImagePath: profileImagePath,
                                        ),
                                        settings: RouteSettings(
                                          arguments: {
                                            'planType': widget.planType,
                                            'dietType': widget.dietType,
                                            'duration': widget.duration,
                                            'days': days,
                                            'dinnerCustomization': widget.dinnerCustomization,
                                            'selectedMeals': widget.selectedMeals,
                                          },
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  }
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.home, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Go to Dashboard',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

