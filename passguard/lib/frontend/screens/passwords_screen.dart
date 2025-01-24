import 'package:flutter/material.dart';
import 'package:passguard/frontend/widgets/password_list_view.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';

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
                TextField()
              ],
            ),
          ),
          Expanded(
            child: Center(child: Text('Select a password to view details')),
          ),
        ],
      );
    } else {
      List<PasswordEntry> passwordEntries = [
        PasswordEntry(
          id: "1293A",
          service: "Chase",
          serviceType: "Banking",
          username: "Encrypto",
          creationDate: "2025-01-02",
        ),
        PasswordEntry(
          id: "12395G",
          service: "Qualstar",
          serviceType: "Banking",
          username: "Encrypto",
          creationDate: "2025-01-01",
        ),
        PasswordEntry(
          id: "030903MJ",
          service: "Extra Gum",
          serviceType: "Leisure",
          username: "GumOnMyFace",
          creationDate: "2003-06-29",
        ),
        PasswordEntry(
          id: "203902MHD",
          service: "Facebook",
          serviceType: "Leisure",
          username: "CharlieBitMe",
          creationDate: "2010-12-03",
        ),
        PasswordEntry(
          id: "2938JD1",
          service: "Federal Union",
          serviceType: "Banking",
          username: "Bankzilla991",
          creationDate: "2022-05-17",
        ),
      ];
      // MOBILE: just show a single list with search bar
      return PasswordListView(passwordEntries: passwordEntries, onEntryTap: _onPasswordTap);
      // return Column(
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: TextField(
      //         decoration: const InputDecoration(
      //           labelText: 'Search Passwords',
      //           border: OutlineInputBorder(),
      //           suffixIcon: Icon(Icons.search),
      //         ),
      //         onChanged: (value) {
      //           // handle searching
      //         },
      //       ),
      //     ),
      //     Expanded(
      //       child: ListView.builder(
      //         itemCount: 10,
      //         itemBuilder: (context, index) {
      //           return ListTile(
      //             title: Text('Password #$index'),
      //             onTap: () {},
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // );
    }
  }

  void _onPasswordTap(PasswordEntry entry) {
    print("Received entry: ${entry.service}");
  }
}
