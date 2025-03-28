import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:passguard/frontend/providers/snackbar_provider.dart';
import 'package:Encryptilock/frontend/providers/password_provider.dart';

import 'package:Encryptilock/frontend/widgets/password_detail_card.dart';
import 'package:Encryptilock/frontend/widgets/password_create_edit_page.dart';
import 'package:Encryptilock/frontend/widgets/password_list_view.dart';

class PasswordsScreen extends StatelessWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600; // Adjust breakpoint as needed

    return Consumer<PasswordProvider>(
      builder: (context, passwordProv, child) {
        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDetailAreaDesktop(passwordProv),
              ),
            ],
          );
        } else {
          // Mobile: Display based on mode
          return _buildMobileLayout(passwordProv);
        }
      },
    );
  }

  Widget _buildDetailAreaDesktop(PasswordProvider passwordProv) {
    switch (passwordProv.mode) {
      case 'create':
        return PasswordCreationEditPage(
          existingRecord: null,
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
          onDeleteComplete: (deletedId) {
            // Handle post-deletion logic if needed
          },
        );
      case 'detail':
        final selected = passwordProv.selectedPassword;
        if (selected == null) {
          return const Center(child: Text('No password selected.'));
        }
        return PasswordDetailCard(
          key: ValueKey(passwordProv.selectedPassword?['id']),
          onEdit: () => passwordProv.setMode('edit'),
          onClose: () => passwordProv.selectPasswordId(null),
        );
      case 'list':
      default:
        return const Center(
          child: Text('Select a password or create a new one.'),
        );
    }
  }

  Widget _buildMobileLayout(PasswordProvider passwordProv) {
    switch (passwordProv.mode) {
      case 'list':
        return PasswordListView(
          onItemSelected: (int itemSelect) {
            if (itemSelect == 0) {
              // Assume PasswordListView handles selection and updates provider
            } else if (itemSelect == 1) {
              passwordProv.setMode('create');
            }
          },
        );
      case 'create':
        return PasswordCreationEditPage(
          existingRecord: null,
          onCancel: () => passwordProv.setMode('list'),
          onSaveComplete: (newId) {
            passwordProv.selectPasswordId(newId);
            passwordProv.setMode('detail'); // Switch to detail view after creation
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
            passwordProv.setMode('detail'); // Remain in detail view after editing
          },
          onDeleteComplete: (deletedId) {
            passwordProv.setMode('list'); // Return to list after deletion
          },
        );
      case 'detail':
        final selected = passwordProv.selectedPassword;
        if (selected == null) {
          return const Center(child: Text('No password selected.'));
        }
        return PasswordDetailCard(
          key: ValueKey(passwordProv.selectedPassword?['id']),
          onEdit: () => passwordProv.setMode('edit'),
          onClose: () => passwordProv.setMode('list'),
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
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Consumer<PasswordProvider>(
//       builder: (context, passwordProv, child) {
//         if (isDesktop) {
//           // a row with left: list, right: detail/create/edit
//           return Row(
//             children: [
//               Expanded(
//                 child: _buildDetailAreaDesktop(passwordProv),
//               ),
//             ],
//           );
//         } else {
//           // on mobile, we either show the list or the detail form inline
//           // based on passwordProv.mode
//           return _buildMobileLayout(passwordProv);
//         }
//       },
//     );
//   }

//   Widget _buildDetailAreaDesktop(PasswordProvider passwordProv) {
//     switch (passwordProv.mode) {
//       case 'create':
//         return PasswordCreationEditPage(
//           onCancel: () => passwordProv.setMode('list'),
//           // if you want to pass a callback on save
//           onSaveComplete: (newId) {
//             // optionally set selected password, or revert to detail
//             passwordProv.selectPasswordId(newId);
//           },
//         );
//       case 'edit':
//         final selected = passwordProv.selectedPassword;
//         if (selected == null) {
//           return const Center(child: Text('No password selected.'));
//         }
//         return PasswordCreationEditPage(
//           existingRecord: selected,
//           onCancel: () => passwordProv.setMode('detail'),
//           onSaveComplete: (updatedId) {
//             passwordProv.selectPasswordId(updatedId);
//           },
//         );
//       case 'detail':
//         final selected = passwordProv.selectedPassword;
//         if (selected == null) {
//           return const Center(child: Text('No password selected.'));
//         }
//         print("selected password: $selected");
//         return PasswordDetailCard(
//           serviceName: selected['service'] ?? '',
//           username: selected['username'] ?? '',
//           password: '(encrypted)',
//           url: selected['url'],
//           creationDate: selected['createdt'] ?? '',
//           serviceType: selected['servicetype'] ?? '',
//           onEdit: () => passwordProv.setMode('edit'),
//         );
//       case 'list':
//       default:
//         // If user doesn't have anything selected & isn't creating,
//         // show some placeholder or instructions
//         return const Center(
//           child: Text('Select a password or create a new one.'),
//         );
//     }
//   }

//   Widget _buildMobileLayout(PasswordProvider passwordProv) {
//     switch (passwordProv.mode) {
//       case 'list':
//         return PasswordListView();
//       case 'create':
//         return PasswordCreationEditPage(
//           onCancel: () => passwordProv.setMode('list'),
//           onSaveComplete: (newId) {
//             passwordProv.selectPasswordId(newId);
//           },
//         );
//       case 'edit':
//         final selected = passwordProv.selectedPassword;
//         if (selected == null) {
//           return const Center(child: Text('No password selected.'));
//         }
//         return PasswordCreationEditPage(
//           existingRecord: selected,
//           onCancel: () => passwordProv.setMode('detail'),
//           onSaveComplete: (updatedId) {
//             passwordProv.selectPasswordId(updatedId);
//           },
//         );
//       case 'detail':
//         final selected = passwordProv.selectedPassword;
//         if (selected == null) {
//           return const Center(child: Text('No password selected.'));
//         }

//         return PasswordDetailCard(
//           serviceName: selected['service'] ?? '',
//           username: selected['username'] ?? '',
//           password: '(encrypted)',
//           url: selected['url'] ?? '',
//           serviceType: selected['serviceType'] ?? '', // TODO
//           creationDate: selected['creationDate'] ?? '', // TODO
//           onEdit: () => passwordProv.setMode('edit'),
//         );
//       default:
//         return const Center(child: Text('Unrecognized mode.'));
//     }
//   }
// }
