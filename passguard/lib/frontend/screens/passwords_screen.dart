import 'package:flutter/material.dart';

class PasswordsScreen extends StatelessWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return isDesktop
        ? Row(
            children: [
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Password $index'),
                      onTap: () {
                        // Display details
                      },
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text('Select a password to view details.'),
                ),
              ),
            ],
          )
        : ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Password $index'),
                onTap: () {
                  // Navigate to details page
                },
              );
            },
          );
  }
}
