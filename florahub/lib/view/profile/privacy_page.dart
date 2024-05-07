import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: Text('Privacy Page'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.green[100],
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to our Privacy Settings. Your privacy is important to us,'
                'and we want to ensure that you have control over how your '
                'information is handled. In this section, you can customize your '
                'privacy preferences according to your comfort level. You can '
                'choose what data you want to share and with whom. By adjusting '
                'these settings, you can tailor your experience with our app to '
                'suit your privacy needs.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Data Collection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Our app collects certain data to provide you with a personalized'
                ' and seamless experience. This data may include information about'
                ' your interactions with the app, such as the features you use, '
                'the content you view, and how often you use the app. We also collect '
                'device information, such as your device model, operating system, and '
                'unique device identifiers. Additionally, if you enable location '
                'services, we may collect your location data to offer location-based '
                'services. Rest assured, we handle your data with the utmost care and'
                ' only use it to improve your experience with our app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Your Rights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'At [App Name], we believe in transparency and respect for your '
                'privacy rights. You have the right to control your personal data '
                'and understand how it is used. In this section,'
                ' you'
                'll find information about your rights regarding your data.'
                ' This includes the right to access the personal information we '
                'hold about you, the right to correct inaccuracies, and the right'
                ' to request deletion of your data. We are committed to protecting'
                ' your privacy and ensuring that your data is handled responsibly '
                'and in accordance with applicable laws and regulations.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
