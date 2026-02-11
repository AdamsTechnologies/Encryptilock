import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/widgets/password_detail_card.dart';
import 'package:encryptilock/frontend/widgets/password_create_page.dart';
import 'package:encryptilock/frontend/widgets/password_edit_page.dart';
import 'package:encryptilock/frontend/widgets/password_list_view.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  _PasswordsScreenState createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  late PasswordProvider _passwordProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _passwordProvider = context.read<PasswordProvider>();
  }

  @override
  void dispose() {
    // Delay until after widget tree is stable again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordProvider.selectPasswordId(null);
      _passwordProvider.setMode('list');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 750;

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
          onCancel: () => passwordProv.setMode('list'),
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
            passwordProv.setMode('detail');
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
            passwordProv.setMode('detail');
          },
          onDeleteComplete: (deletedId) {
            passwordProv.setMode('list');
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
