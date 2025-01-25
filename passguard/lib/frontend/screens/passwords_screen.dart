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
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Consumer<PasswordProvider>(
      builder: (context, passwordProv, child) {
        if (isDesktop) {
          // a row with left: list, right: detail/create/edit
          return Row(
            children: [
              Expanded(
                child: _buildDetailAreaDesktop(passwordProv),
              ),
            ],
          );
        } else {
          // on mobile, we either show the list or the detail form inline
          // based on passwordProv.mode
          return _buildMobileLayout(passwordProv);
        }
      },
    );
  }

  Widget _buildDetailAreaDesktop(PasswordProvider passwordProv) {
    switch (passwordProv.mode) {
      case 'create':
        return PasswordCreationEditPage(
          onCancel: () => passwordProv.setMode('list'),
          // if you want to pass a callback on save
          onSaveComplete: (newId) {
            // optionally set selected password, or revert to detail
            passwordProv.selectPasswordId(newId);
          },
        );
      case 'edit':
        final selected = passwordProv.selectedPassword;
        if (selected == null) {
          return const Center(child: Text('No password selected.'));
        }
        return PasswordCreationEditPage(
          existingRecord: selected,
          onCancel: () => passwordProv.setMode('detail'),
          onSaveComplete: (updatedId) {
            passwordProv.selectPasswordId(updatedId);
          },
        );
      case 'detail':
        final selected = passwordProv.selectedPassword;
        if (selected == null) {
          return const Center(child: Text('No password selected.'));
        }
        print("selected password: $selected");
        return PasswordDetailCard(
          serviceName: selected['service'] ?? '',
          username: selected['username'] ?? '',
          password: '(encrypted)',
          url: selected['url'],
          creationDate: selected['createdt'] ?? '',
          serviceType: selected['servicetype'] ?? '',
          onEdit: () => passwordProv.setMode('edit'),
        );
      case 'list':
      default:
        // If user doesn't have anything selected & isn't creating,
        // show some placeholder or instructions
        return const Center(
          child: Text('Select a password or create a new one.'),
        );
    }
  }

  Widget _buildMobileLayout(PasswordProvider passwordProv) {
    switch (passwordProv.mode) {
      case 'list':
        return PasswordListView();
      case 'create':
        return PasswordCreationEditPage(
          onCancel: () => passwordProv.setMode('list'),
          onSaveComplete: (newId) {
            passwordProv.selectPasswordId(newId);
          },
        );
      case 'edit':
        final selected = passwordProv.selectedPassword;
        if (selected == null) {
          return const Center(child: Text('No password selected.'));
        }
        return PasswordCreationEditPage(
          existingRecord: selected,
          onCancel: () => passwordProv.setMode('detail'),
          onSaveComplete: (updatedId) {
            passwordProv.selectPasswordId(updatedId);
          },
        );
      case 'detail':
        final selected = passwordProv.selectedPassword;
        if (selected == null) {
          return const Center(child: Text('No password selected.'));
        }

        return PasswordDetailCard(
          serviceName: selected['service'] ?? '',
          username: selected['username'] ?? '',
          password: '(encrypted)',
          url: selected['url'] ?? '',
          serviceType: selected['serviceType'] ?? '', // TODO
          creationDate: selected['creationDate'] ?? '', // TODO
          onEdit: () => passwordProv.setMode('edit'),
        );
      default:
        return const Center(child: Text('Unrecognized mode.'));
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/providers/password_provider.dart';

// import 'package:passguard/frontend/widgets/password_detail_card.dart';
// import 'package:passguard/frontend/widgets/password_create_edit_page.dart';
// import 'package:passguard/frontend/widgets/password_list_view.dart';

// class PasswordsScreen extends StatelessWidget {
//   const PasswordsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PasswordProvider>(
//       builder: (context, passwordProv, child) {
//         final selected = passwordProv.selectedPassword;

//         if (selected == null) {
//           // No password selected => Show “Create New” button
//           return Center(
//             child: ElevatedButton(
//               child: const Text('Create New Password'),
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const PasswordCreationEditPage(),
//                   ),
//                 );
//               },
//             ),
//           );
//         } else {
//           // We have a selected password => Show detail
//           return PasswordDetailCard(
//             serviceName: selected['service'] ?? '',
//             username: selected['username'] ?? '',
//             password: '(encrypted)', // or decrypt on demand
//             url: selected['url'],
//             creationDate: selected['createdt'] ?? '',
//             serviceType: selected['servicetype'] ?? '',
//             onEdit: () {
//               // Open the edit page with the existing record
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => PasswordCreationEditPage(
//                     existingRecord: selected,
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

// --------------------------------------- OLD BUT NOT READY TO REMOVE COMPLETELY

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
