import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'profile_page.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _resendTimer = 30;
  bool _isTimerActive = true;
  bool _isVerifying = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes[0].requestFocus();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isTimerActive) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startTimer();
          } else {
            _isTimerActive = false;
          }
        });
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      _otpControllers[index].text = value;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-verify when all digits entered
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() async {
    String otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      return;
    }

    setState(() => _isVerifying = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Validate OTP (demo mode: 123456)
    if (otp == '123456') {
      _showSuccessSnackBar('OTP verified successfully!');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber),
        ),
      );
    } else {
      setState(() => _isVerifying = false);
      _showErrorSnackBar('Invalid OTP. Please try again');
      _clearOtp();
    }
  }

  void _resendOtp() {
    setState(() {
      _resendTimer = 30;
      _isTimerActive = true;
    });
    _startTimer();
    _showSuccessSnackBar('OTP resent successfully!');
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : isTablet ? 48 : 24,
                      vertical: isSmallScreen ? 16 : 24,
                    ),
                    child: Column(
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios),
                            color: const Color(0xFF2C2C2C),
                            tooltip: 'Go back',
                          ),
                        ),
                        
                        if (isMobile) const SizedBox(height: 20),
                        
                        Expanded(
                          child: Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: isTablet ? 500 : double.infinity,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Animated Icon
                                      _buildAnimatedIcon(isSmallScreen),
                                      
                                      SizedBox(height: isSmallScreen ? 24 : 32),
                                      
                                      // Title
                                      Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 28 : isTablet ? 36 : 32,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2C2C2C),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 8 : 12),
                                      
                                      // Subtitle
                                      Text(
                                        'Enter the 6-digit code sent to',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: const Color(0xFF757575),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 4),
                                      
                                      // Phone Number
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '+91 ${widget.phoneNumber}',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 15 : 17,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 32 : 40),
                                      
                                      // OTP Input Fields
                                      _buildOtpFields(isSmallScreen, isTablet),
                                      
                                      SizedBox(height: isSmallScreen ? 24 : 32),
                                      
                                      // Demo Mode Hint
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: isSmallScreen ? 13 : 14,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                  children: const [
                                                    TextSpan(text: 'Demo Mode: Use OTP '),
                                                    TextSpan(
                                                      text: '123456',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 24 : 32),
                                      
                                      // Verify Button
                                      _buildVerifyButton(isSmallScreen, isTablet),
                                      
                                      SizedBox(height: isSmallScreen ? 20 : 24),
                                      
                                      // Resend OTP
                                      _buildResendSection(isSmallScreen),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF66BB6A),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.lock_outline,
              size: isSmallScreen ? 40 : 50,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpFields(bool isSmallScreen, bool isTablet) {
    final fieldSize = isSmallScreen ? 45.0 : isTablet ? 65.0 : 55.0;
    final fontSize = isSmallScreen ? 20.0 : isTablet ? 28.0 : 24.0;
    final spacing = isSmallScreen ? 8.0 : isTablet ? 16.0 : 12.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _buildOtpField(index, fieldSize, fontSize),
        );
      }),
    );
  }

  Widget _buildOtpField(int index, double size, double fontSize) {
    final hasValue = _otpControllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasValue
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF4CAF50)
              : hasValue
                  ? const Color(0xFF4CAF50).withOpacity(0.5)
                  : const Color(0xFFE0E0E0),
          width: isFocused ? 2 : 1.5,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C2C2C),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onOtpChanged(index, value),
      ),
    );
  }

  Widget _buildVerifyButton(bool isSmallScreen, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 50 : isTablet ? 60 : 55,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isVerifying
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : [
                      const Color(0xFF4CAF50),
                      const Color(0xFF66BB6A),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isVerifying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Verify OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 15,
            color: const Color(0xFF757575),
          ),
        ),
        if (_isTimerActive)
          Text(
            '($_resendTimer s)',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
            ),
          )
        else
          GestureDetector(
            onTap: _resendOtp,
            child: Text(
              'Resend',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
