import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:encryptilock/frontend/widgets/bottom_action_bar.dart';
import 'package:encryptilock/frontend/widgets/password_generator_dialog.dart';
import 'package:encryptilock/backend/helpers/password_generator.dart';

class PasswordCreatePage extends StatefulWidget {
  final VoidCallback? onCancel;
  final void Function(String newId)? onSaveComplete;

  const PasswordCreatePage({
    Key? key,
    this.onCancel,
    this.onSaveComplete,
  }) : super(key: key);

  @override
  State<PasswordCreatePage> createState() => _PasswordCreatePageState();
}

class _PasswordCreatePageState extends State<PasswordCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _serviceNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();

  Timer? _hidePasswordTimer;
  bool _passwordVisible = false;
  bool _obscurePassword = true;
  bool _isActive = true;

  @override
  void dispose() {
    _hidePasswordTimer?.cancel();
    _passwordController.clear();

    _serviceNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _serviceTypeController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _generatePassword() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (settings.autoGenerateAndFill) {
      final generated = PasswordFactory.generatePassword(
        minLength: settings.definePasswordGeneratorParams ? settings.minLength : 8,
        maxLength: settings.definePasswordGeneratorParams ? settings.maxLength : 16,
        excludeChars: settings.excludeChars.isNotEmpty ? settings.excludeChars : null,
      );
      setState(() => _passwordController.text = generated);
    } else {
      final generatedPassword = await showDialog<String>(
        context: context,
        builder: (context) => const ComplexPasswordGeneratorDialog(),
      );

      if (generatedPassword != null && generatedPassword.isNotEmpty) {
        setState(() => _passwordController.text = generatedPassword);
      }
    }
  }

  void _togglePasswordVisibility() {
    if (_passwordVisible) {
      setState(() {
        _obscurePassword = true;
        _passwordVisible = false;
      });
      _hidePasswordTimer?.cancel();
    } else {
      setState(() {
        _obscurePassword = false;
        _passwordVisible = true;
      });

      _hidePasswordTimer?.cancel();
      _hidePasswordTimer = Timer(const Duration(seconds: 10), () {
        setState(() {
          _obscurePassword = true;
          _passwordVisible = false;
        });
      });
    }
  }

  void _showSnackBar(String message) {
    final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
    snackbarProvider.showMessage(message);
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    final data = {
      'service': _serviceNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
      'servicetype': _serviceTypeController.text.trim(),
      'url': _urlController.text.trim(),
      'notes': _noteController.text.trim(),
      'isactive': _isActive ? 1 : 0,
    };

    try {
      final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
      snackbarProvider.showMessage("Creating password...");
      await passwordProvider.addOrUpdatePassword(data, passwordChanged: true, changedFields: {
        'service': true,
        'username': true,
        'servicetype': true,
        'url': true,
        'notes': true,
        'isactive': true,
        'createdt': true,
        'updatedt': true,
      });

      final newId = passwordProvider.passwords.last['id'] as String;
      widget.onSaveComplete?.call(newId);
      passwordProvider.selectPasswordId(newId);
    } catch (e) {
      _showSnackBar("Error saving password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      margin: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Sticky Title
              Text('Create Password', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Scrollable Input Fields
              Expanded(
                child: SingleChildScrollView(
                  child: FocusTraversalGroup(
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _serviceNameController,
                          decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (val) {
                            if (_obscurePassword && !_passwordVisible) {
                              setState(() {
                                _obscurePassword = false;
                                _passwordVisible = true;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: _obscurePassword ? 'Show Password' : 'Hide Password',
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                IconButton(
                                  tooltip: 'Generate Password',
                                  icon: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
                                  onPressed: _generatePassword,
                                ),
                              ],
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _serviceTypeController,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(labelText: 'URL', border: OutlineInputBorder()),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder()),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Toggle + Save/Cancel
              Column(
                children: [
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    title: const Text('Show Record'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  BottomActionBar(
                    isEditMode: false,
                    showDeleteButton: false,
                    onCancel: () {
                      _hidePasswordTimer?.cancel();
                      widget.onCancel?.call();
                    },
                    onSave: _savePassword,
                    style: BottomActionBarStyle.iconOnly,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
