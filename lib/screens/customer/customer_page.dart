import 'package:flutter/material.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Customer Support'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Contact Options
              _buildContactCard(
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: '+91 1800-123-4567',
                color: const Color(0xFF4CAF50),
                onTap: () => _showCallDialog(context),
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.email,
                title: 'Email Us',
                subtitle: 'support@finalmeals.com',
                color: const Color(0xFF2196F3),
                onTap: () => _showEmailDialog(context),
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Available 24/7',
                color: const Color(0xFFFF9800),
                onTap: () => _showChatDialog(context),
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 32),
              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 16),
              _buildFaqItem(
                question: 'How do I cancel my subscription?',
                answer: 'You can cancel your subscription anytime from the Subscription Details page. Changes will take effect at the end of your current billing cycle.',
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'Can I change my meal preferences?',
                answer: 'Yes, you can modify your meal preferences from the Manage Meals page. Changes can be made before 8:00 PM for the next day.',
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'What if I don\'t receive my meal?',
                answer: 'You can report a missing meal from the Order Status page. Our team will contact you within 2 hours to resolve the issue.',
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                question: 'How do I change my delivery address?',
                answer: 'Go to Manage Meals > Delivery tab and click on "Change Address" to update your delivery location.',
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF757575), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: const Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Support'),
        content: const Text('Would you like to call our support team at +91 1800-123-4567?'),
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
                  content: Text('Opening phone dialer...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Support'),
        content: const Text('Send us an email at support@finalmeals.com and we\'ll get back to you within 24 hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening email client...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Our support team is available 24/7. Start a chat session now?'),
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
                  content: Text('Connecting to live chat...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}


