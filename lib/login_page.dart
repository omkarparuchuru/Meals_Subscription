import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Mobile number must start with 6-9';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP sent successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate to OTP page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(
            phoneNumber: '+91 ${_mobileController.text.trim()}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  // Logo Section
                  _buildLogo(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // Welcome Text
                  Text(
                    'Welcome to Final Meals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your daily meal subscription service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 40),
                  // Login Card
                  _buildLoginCard(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 40 : 60),
                  // Features Section
                  _buildFeaturesSection(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 20 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 70 : 80,
      height: isSmallScreen ? 70 : 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF9800), // Orange
            Color(0xFF4CAF50), // Green
          ],
        ),
      ),
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: Color(0xFF9C27B0), // Purple
      ),
    );
  }

  Widget _buildLoginCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login to Continue',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 24),
          // Mobile Number Input
          const Text(
            'Mobile Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: _validateMobileNumber,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.phone,
                  color: Color(0xFF9E9E9E),
                ),
                hintText: 'Enter 10-digit mobile number',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                errorStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "We'll send you an OTP to verify your number",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 24),
          // Send OTP Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
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
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFFF9800), // Orange
                            Color(0xFF4CAF50), // Green
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  color: _isLoading ? Colors.grey : null,
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send OTP',
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
          const SizedBox(height: 16),
          // Terms and Privacy Policy
          GestureDetector(
            onTap: () {
              _showTermsDialog();
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isSmallScreen) {
    return Wrap(
      spacing: isSmallScreen ? 16 : 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureItem(
          icon: Icons.restaurant_menu,
          label: 'Fresh Meals',
          color: const Color(0xFF4CAF50),
          isSmallScreen: isSmallScreen,
        ),
        _buildFeatureItem(
          icon: Icons.access_time,
          label: 'On Time',
          color: const Color(0xFFE91E63),
          isSmallScreen: isSmallScreen,
        ),
        _buildFeatureItem(
          icon: Icons.account_balance_wallet,
          label: 'Affordable',
          color: const Color(0xFFFFC107),
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 50 : 60,
          height: isSmallScreen ? 50 : 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 24 : 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service & Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'By using Final Meals, you agree to our Terms of Service and Privacy Policy. '
            'We collect your mobile number and address information to provide meal delivery services. '
            'Your data is secure and will not be shared with third parties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}

