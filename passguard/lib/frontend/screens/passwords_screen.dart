import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:passguard/frontend/providers/snackbar_provider.dart';
import 'package:passguard/frontend/providers/password_provider.dart';

import 'package:passguard/frontend/widgets/password_detail_card.dart';
import 'package:passguard/frontend/widgets/password_create_edit_page.dart';
import 'package:passguard/frontend/widgets/password_list_view.dart';

class PasswordsScreen extends StatelessWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordProvider>(
      builder: (context, passwordProv, child) {
        final selected = passwordProv.selectedPassword;

        if (selected == null) {
          // No password selected => Show “Create New” button
          return Center(
            child: ElevatedButton(
              child: const Text('Create New Password'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PasswordCreationEditPage(),
                  ),
                );
              },
            ),
          );
        } else {
          // We have a selected password => Show detail
          return PasswordDetailCard(
            serviceName: selected['service'] ?? '',
            username: selected['username'] ?? '',
            password: '(encrypted)', // or decrypt on demand
            url: selected['url'],
            creationDate: selected['createdt'] ?? '',
            serviceType: selected['servicetype'] ?? '',
            onEdit: () {
              // Open the edit page with the existing record
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PasswordCreationEditPage(
                    existingRecord: selected,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

// class PasswordsScreen extends StatelessWidget {
//   const PasswordsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     // DESKTOP: show a two-pane layout with search bar at top-left
//     if (isDesktop) {
//       return Row(
//         children: [
//           SizedBox(
//             width: 300,
//             child: Column(
//               children: [
//                 TextField()
//               ],
//             ),
//           ),
//           Expanded(
//             child: Center(child: Text('Select a password to view details')),
//           ),
//         ],
//       );
//     } else {
//       List<PasswordEntry> passwordEntries = [
//         PasswordEntry(
//           id: "1293A",
//           service: "Chase",
//           serviceType: "Banking",
//           username: "Encrypto",
//           creationDate: "2025-01-02",
//         ),
//         PasswordEntry(
//           id: "12395G",
//           service: "Qualstar",
//           serviceType: "Banking",
//           username: "Encrypto",
//           creationDate: "2025-01-01",
//         ),
//         PasswordEntry(
//           id: "030903MJ",
//           service: "Extra Gum",
//           serviceType: "Leisure",
//           username: "GumOnMyFace",
//           creationDate: "2003-06-29",
//         ),
//         PasswordEntry(
//           id: "203902MHD",
//           service: "Facebook",
//           serviceType: "Leisure",
//           username: "CharlieBitMe",
//           creationDate: "2010-12-03",
//         ),
//         PasswordEntry(
//           id: "2938JD1",
//           service: "Federal Union",
//           serviceType: "Banking",
//           username: "Bankzilla991",
//           creationDate: "2022-05-17",
//         ),
//       ];
//       // MOBILE: just shows the PasswordListView until clicked.
//       return PasswordListView(passwordEntries: passwordEntries, onEntryTap: _onPasswordTap);
//     }
//   }

//   void _onPasswordTap(PasswordEntry entry) {
//     print("Received entry: ${entry.service}");
//   }
// }
