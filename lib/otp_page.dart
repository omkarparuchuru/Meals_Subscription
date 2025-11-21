import 'package:flutter/material.dart';
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

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 30;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter complete OTP'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Validate OTP (demo mode: 123456)
    if (otp == '123456') {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP verified successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      // Navigate to profile page
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Invalid OTP. Please try again'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _resendOtp() {
    if (!_isTimerActive) {
      setState(() {
        _resendTimer = 30;
        _isTimerActive = true;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP resent successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
            ),
            child: Column(
              children: [
                SizedBox(height: isSmallScreen ? 10 : 20),
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2C2C2C),
                      size: 20,
                    ),
                    label: Text(
                      'Back',
                      style: TextStyle(
                        color: const Color(0xFF2C2C2C),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 40),
                // Main Card - More Attractive
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Icon - More Attractive
                      Container(
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 80 : 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9C27B0),
                              Color(0xFFE91E63),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9C27B0).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      // Title - More Attractive
                      Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      // Instruction Text - Enhanced
                      Column(
                        children: [
                          Text(
                            "We've sent a 6-digit code to",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: const Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF9C27B0).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.phoneNumber,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF9C27B0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 32 : 40),
                      // OTP Input Fields - Attractive and Clear with Overflow Protection
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final spacing = isSmallScreen ? 6.0 : 8.0;
                          final maxFieldWidth = isSmallScreen ? 50.0 : 60.0;
                          final fieldWidth = ((availableWidth - (5 * spacing)) / 6).clamp(40.0, maxFieldWidth);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(6, (index) {
                              final isFocused = _focusNodes[index].hasFocus;
                              final hasValue = _otpControllers[index].text.isNotEmpty;
                              return Flexible(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: fieldWidth,
                                    height: isSmallScreen ? 56 : 64,
                                    decoration: BoxDecoration(
                                      color: isFocused
                                          ? const Color(0xFFE8F5E9)
                                          : hasValue
                                              ? const Color(0xFFF1F8E9)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isFocused
                                            ? const Color(0xFF4CAF50)
                                            : hasValue
                                                ? const Color(0xFF8BC34A)
                                                : const Color(0xFFE0E0E0),
                                        width: isFocused ? 2.5 : hasValue ? 2 : 1.5,
                                      ),
                                      boxShadow: isFocused
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : hasValue
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF8BC34A).withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                              : [],
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: _otpControllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 24 : 28,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2C2C2C),
                                          letterSpacing: 0,
                                          height: 1.2,
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          _onOtpChanged(index, value);
                                          setState(() {}); // Update UI when value changes
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Demo Mode Box - Enhanced
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFE3F2FD),
                              const Color(0xFFBBDEFB),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1976D2),
                                ),
                                children: [
                                  TextSpan(text: 'Demo Mode: Use OTP '),
                                  TextSpan(
                                    text: '123456',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Even-ending mobile = Existing User | Odd-ending = New User',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Verify OTP Button - Enhanced
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 52 : 56,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF9C27B0),
                                  Color(0xFFE91E63),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9C27B0).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Resend OTP Timer
                      GestureDetector(
                        onTap: _isTimerActive ? null : _resendOtp,
                        child: Text(
                          _isTimerActive
                              ? 'Resend OTP in ${_resendTimer}s'
                              : 'Resend OTP',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: _isTimerActive
                                ? const Color(0xFF9E9E9E)
                                : const Color(0xFF4CAF50),
                            fontWeight: _isTimerActive
                                ? FontWeight.normal
                                : FontWeight.w500,
                            decoration: _isTimerActive
                                ? null
                                : TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

