import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Introduction\n\n'
                        'We value your privacy. This Privacy Policy outlines the information we collect, how we use it, and the steps we take to protect your personal data.\n\n'
                        'By using our services, you agree to the collection and use of information in accordance with this policy.\n\n',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Information We Collect\n\n'
                        '• Personal Identification Information: We collect information such as your name, email, and phone number.\n'
                        '• Usage Data: We may collect data on how you access and use our services.\n'
                        '• Location Data: If enabled, we may collect information on your location.\n\n',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'How We Use Your Information\n\n'
                        'We use the collected information to improve our services, respond to inquiries, and provide a better user experience.\n\n',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Data Security\n\n'
                        'We take appropriate security measures to protect your personal information. However, no method of transmission over the Internet is completely secure.\n\n',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Changes to this Privacy Policy\n\n'
                        'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.\n\n',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Contact Us\n\n'
                        'If you have any questions about this Privacy Policy, please contact us at:\n'
                        'email@example.com\n\n',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
