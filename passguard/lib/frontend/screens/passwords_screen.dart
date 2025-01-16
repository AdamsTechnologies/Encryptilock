
import 'package:flutter/material.dart';
/*
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
*/
class PasswordsScreen extends StatelessWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    // DESKTOP: show a two-pane layout with search bar at top-left
    if (isDesktop) {
      return Row(
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: [
                // The search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Passwords',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // handle searching
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Password #$index'),
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(child: Text('Select a password to view details')),
          ),
        ],
      );
    } else {
      // MOBILE: just show a single list with search bar
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Passwords',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // handle searching
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Password #$index'),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      );
    }
  }
}