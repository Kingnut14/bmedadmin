import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView(
          children: [
            // Frequently Asked Questions
            _buildSectionTitle('Frequently Asked Questions'),
            SizedBox(height: 10),
            _buildCard(
              child: Column(
                children: [
                  _buildFAQTile(
                    'How do I change my password?',
                    'You can change your password from the account settings section.',
                  ),
                  Divider(),
                  _buildFAQTile(
                    'How do I enable notifications?',
                    'You can enable notifications from the general settings section.',
                  ),
                  Divider(),
                  _buildFAQTile(
                    'How do I contact support?',
                    'You can contact support through our help center or email.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Contact Support
            _buildSectionTitle('Contact Support'),
            SizedBox(height: 10),
            _buildCard(
              child: Column(
                children: [
                  _buildContactTile('Email Support', 'support@example.com', () {
                    // Add functionality to send an email or open email app
                  }),
                  Divider(),
                  _buildContactTile('Phone Support', '+123 456 7890', () {
                    // Add functionality to call support
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ListTile(
      title: Text(
        question,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        answer,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Add any extra functionality if necessary
      },
    );
  }

  Widget _buildContactTile(String title, String subtitle, Function() onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
