import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/widgets/password_detail_card.dart';
import 'package:encryptilock/frontend/widgets/password_create_page.dart';
import 'package:encryptilock/frontend/widgets/password_edit_page.dart';
import 'package:encryptilock/frontend/widgets/password_list_view.dart';

class PasswordsScreen extends StatelessWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 750; // Adjust breakpoint as needed

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
        return PasswordCreatePage(
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
        return PasswordEditPage(
          existingRecord: selected,
          onCancel: () => passwordProv.setMode('list'), //passwordProv.setMode('detail'), TODO feel this out, might want to return to detail mode maybe not.
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
        return PasswordCreatePage(
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
        return PasswordEditPage(
          existingRecord: selected,
          onCancel: () => passwordProv.setMode('list'),
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
