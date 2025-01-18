import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';            // For Clipboard support
import 'package:url_launcher/url_launcher.dart';   // For URL launching
import 'package:passguard/frontend/widgets/password_detail_card.dart'; // Adjust import as needed
void main() {
  runApp(const TestPasswordDetailCardApp());
}

class TestPasswordDetailCardApp extends StatelessWidget {
  const TestPasswordDetailCardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test PasswordDetailCard',
      home: Scaffold(
        appBar: AppBar(title: const Text('Password Detail Card Test')),
        body: Center(
          child: PasswordDetailCard(
            serviceName: 'Example Service',
            username: 'exampleUser',
            password: 'decrypted-encrypted-test123',
            url: 'https://example.com',
            creationDate: '2023-06-20',
            serviceType: 'ExampleType',
            onEdit: () {
              // Simple callback for edit action
              print('Edit button pressed');
            },
          ),
        ),
      ),
    );
  }
}
