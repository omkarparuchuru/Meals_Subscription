import 'package:flutter/material.dart';
import 'subscription_summary_page.dart';
import 'select_duration_page.dart';

class CustomizeDinnerPage extends StatefulWidget {
  final String? planType;
  final String? dietType;
  final String? duration;
  final int? totalAmount;
  final List<String>? selectedMeals;
  final Map<String, String>? dinnerCustomization; // For when coming from later in flow
  final double basePrice;

  const CustomizeDinnerPage({
    super.key,
    this.planType,
    this.dietType,
    this.duration,
    this.totalAmount,
    this.selectedMeals,
    this.dinnerCustomization,
    required this.basePrice,
  });

  @override
  State<CustomizeDinnerPage> createState() => _CustomizeDinnerPageState();
}

class _CustomizeDinnerPageState extends State<CustomizeDinnerPage> {
  String? selectedRiceOption; // 'rice' or 'chapathi' or 'pulka'
  String? selectedCurryOption; // 'curry' or 'dal' or 'sabzi'
  
  @override
  void initState() {
    super.initState();
    // If coming from later in flow, restore selections
    if (widget.dinnerCustomization != null) {
      selectedRiceOption = widget.dinnerCustomization!['base'];
      selectedCurryOption = widget.dinnerCustomization!['curry'];
    }
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Selected Summary (only if coming from later in flow)
                      if (widget.planType != null) ...[
                        _buildSelectedSummary(isSmallScreen),
                        const SizedBox(height: 24),
                      ],
                      // Step 3 (after diet selection)
                      _buildStepIndicator(3, 'Customize Dinner', isSmallScreen),
                      const SizedBox(height: 24),
                      // Info Card
                      _buildInfoCard(isSmallScreen),
                      const SizedBox(height: 24),
                      // Rice/Chapathi/Pulka Selection
                      Text(
                        'Choose Your Base:',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBaseOptionCard(
                        title: 'Rice',
                        description: 'Steamed basmati rice (No curry needed)',
                        icon: Icons.rice_bowl,
                        value: 'rice',
                        isSelected: selectedRiceOption == 'rice',
                        onTap: () => setState(() {
                          selectedRiceOption = 'rice';
                          selectedCurryOption = null; // Rice doesn't need curry
                        }),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 12),
                      _buildBaseOptionCard(
                        title: 'Chapathi',
                        description: 'Whole wheat flatbread',
                        icon: Icons.flatware,
                        value: 'chapathi',
                        isSelected: selectedRiceOption == 'chapathi',
                        onTap: () => setState(() => selectedRiceOption = 'chapathi'),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 12),
                      _buildBaseOptionCard(
                        title: 'Pulka',
                        description: 'Soft roti without oil',
                        icon: Icons.restaurant,
                        value: 'pulka',
                        isSelected: selectedRiceOption == 'pulka',
                        onTap: () => setState(() => selectedRiceOption = 'pulka'),
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 32),
                      // Curry Selection - Only show if chapathi or pulka selected
                      if (selectedRiceOption != null && selectedRiceOption != 'rice') ...[
                        Text(
                          'Choose Your Curry:',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCurryOptionCard(
                          title: 'Curry',
                          description: widget.dietType == 'vegetarian'
                              ? 'Mixed vegetable curry'
                              : 'Chicken/Vegetable curry',
                          icon: Icons.soup_kitchen,
                          value: 'curry',
                          isSelected: selectedCurryOption == 'curry',
                          onTap: () => setState(() => selectedCurryOption = 'curry'),
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: 12),
                        _buildCurryOptionCard(
                          title: 'Dal',
                          description: 'Lentil curry (Dal Tadka/Masoor Dal)',
                          icon: Icons.restaurant_menu,
                          value: 'dal',
                          isSelected: selectedCurryOption == 'dal',
                          onTap: () => setState(() => selectedCurryOption = 'dal'),
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: 12),
                        _buildCurryOptionCard(
                          title: 'Sabzi',
                          description: 'Dry vegetable preparation',
                          icon: Icons.local_dining,
                          value: 'sabzi',
                          isSelected: selectedCurryOption == 'sabzi',
                          onTap: () => setState(() => selectedCurryOption = 'sabzi'),
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Continue Button - Show if rice selected OR if chapathi/pulka with curry selected
            if (selectedRiceOption == 'rice' || (selectedRiceOption != null && selectedCurryOption != null))
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final customization = {
                          'base': selectedRiceOption!,
                          if (selectedCurryOption != null) 'curry': selectedCurryOption!,
                        };
                        
                        if (widget.duration == null) {
                          // After diet selection - go to duration selection
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectDurationPage(
                                planType: widget.planType!,
                                dietType: widget.dietType!,
                                dinnerCustomization: customization,
                                selectedMeals: widget.selectedMeals!,
                                basePrice: widget.basePrice,
                              ),
                            ),
                          );
                        } else {
                          // Later step - go to summary
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubscriptionSummaryPage(
                                planType: widget.planType!,
                                dietType: widget.dietType!,
                                duration: widget.duration!,
                                totalAmount: widget.totalAmount!,
                                dinnerCustomization: customization,
                                selectedMeals: widget.selectedMeals!,
                              ),
                            ),
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
                          child: Text(
                            'Continue',
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
            'Customize Your Dinner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Personalize your dinner preferences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSummary(bool isSmallScreen) {
    if (widget.planType == null) return const SizedBox.shrink();
    
    final planName = widget.planType == 'hostel' ? 'Hostel Plan' : 'Employee Plan';
    final dietName = widget.dietType == 'vegetarian' ? 'Vegetarian' : 'Non-Vegetarian';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
              const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
              const SizedBox(width: 8),
              Text(
                'Selected Plan',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Plan Type', planName, isSmallScreen),
          const SizedBox(height: 8),
          _buildSummaryRow('Diet', dietName, isSmallScreen),
          const SizedBox(height: 8),
          _buildSummaryRow('Duration', widget.duration ?? '', isSmallScreen),
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
            fontSize: isSmallScreen ? 13 : 14,
            color: const Color(0xFF757575),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: const BoxDecoration(
            color: Color(0xFF9E9E9E),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF2196F3), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can customize your dinner base and curry. This preference will be applied to all dinners during your subscription period.',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
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
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurryOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9800)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
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
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF9800).withValues(alpha: 0.1)
                    : const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF757575),
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFF9800),
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


