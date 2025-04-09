import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/widgets/bottom_action_bar.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:encryptilock/frontend/widgets/password_generator_dialog.dart';
import 'package:encryptilock/backend/helpers/password_generator.dart';

class PasswordEditPage extends StatefulWidget {
  final Map<String, dynamic> existingRecord;
  final VoidCallback onCancel;
  final void Function(String updatedId)? onSaveComplete;
  final void Function(String deletedId)? onDeleteComplete;

  const PasswordEditPage({
    Key? key,
    required this.existingRecord,
    required this.onCancel,
    this.onSaveComplete,
    this.onDeleteComplete,
  }) : super(key: key);

  @override
  State<PasswordEditPage> createState() => _PasswordEditPageState();
}

class _PasswordEditPageState extends State<PasswordEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _clearedFields = <String>{};
  final _originalValues = <String, String>{};

  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();

  String? _decryptedPassword;
  bool _passwordVisible = false;
  bool _obscurePassword = true;
  bool _passwordChanged = false;
  bool _isActive = true;
  bool _isDecrypting = false;

  Timer? _hidePasswordTimer;

  @override
  void initState() {
    super.initState();
    _populateFields();
    _decryptPassword();
  }

  void _populateFields() {
    _serviceController.text = widget.existingRecord['service'] ?? '';
    _usernameController.text = widget.existingRecord['username'] ?? '';
    _serviceTypeController.text = widget.existingRecord['servicetype'] ?? '';
    _urlController.text = widget.existingRecord['url'] ?? '';
    _noteController.text = widget.existingRecord['notes'] ?? '';
    _isActive = widget.existingRecord['isactive'] == 1;
  }

  Future<void> _decryptPassword() async {
    setState(() => _isDecrypting = true);
    final passwordProv = context.read<PasswordProvider>();
    final encrypted = widget.existingRecord['password'];

    try {
      final decrypted = await passwordProv.decryptPassword(encrypted);
      setState(() {
        _decryptedPassword = decrypted;
        _passwordController.text = '••••••••••';
      });
    } catch (e) {
      context.read<SnackBarProvider>().showMessage('Failed to decrypt password.');
    } finally {
      setState(() => _isDecrypting = false);
    }
  }

  void _togglePasswordVisibility() {
    if (_passwordVisible) {
      setState(() {
        _obscurePassword = true;
        _passwordVisible = false;
        _passwordController.text = '••••••••••';
      });
      _hidePasswordTimer?.cancel();
    } else {
      if (_decryptedPassword != null) {
        setState(() {
          _obscurePassword = false;
          _passwordVisible = true;
          _passwordController.text = _decryptedPassword!;
        });
        _hidePasswordTimer?.cancel();
        _hidePasswordTimer = Timer(const Duration(seconds: 10), () {
          setState(() {
            _obscurePassword = true;
            _passwordVisible = false;
            _passwordController.text = '••••••••••';
          });
        });
      } else {
        context.read<SnackBarProvider>().showMessage('Password not yet decrypted.');
      }
    }
  }

  void _generatePassword() async {
    final settings = context.read<SettingsProvider>();
    String generated = settings.autoGenerateAndFill
        ? PasswordFactory.generatePassword(
            minLength: settings.minLength,
            maxLength: settings.maxLength,
            excludeChars: settings.excludeChars.isNotEmpty ? settings.excludeChars : null,
          )
        : (await showDialog<String>(
              context: context,
              builder: (_) => const ComplexPasswordGeneratorDialog(),
            )) ??
            '';

    if (generated.isNotEmpty) {
      setState(() {
        _decryptedPassword = generated;
        _passwordController.text = generated;
        _passwordChanged = true;
      });
    }
  }

  Future<void> _save() async {
    // if (!_formKey.currentState!.validate()) return;

    final passwordProvider = context.read<PasswordProvider>();
    final snackbarProvider = context.read<SnackBarProvider>();

    final maskedValue = '••••••••••';
    final controllerText = _passwordController.text.trim();
    final isMasked = controllerText == maskedValue;

    String passwordToSave;
    bool passwordChanged = _passwordChanged;

    if (passwordChanged && _decryptedPassword != null) {
      passwordToSave = _decryptedPassword!;
    } else if (!isMasked && _decryptedPassword != controllerText) {
      // User typed something new manually
      passwordChanged = true;
      passwordToSave = controllerText;
    } else {
      // No change, use existing encrypted password
      passwordToSave = widget.existingRecord['password'];
    }

    final updatedData = {
      'id': widget.existingRecord['id'],
      'service': _serviceController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': passwordToSave.trim(),
      'servicetype': _serviceTypeController.text.trim(),
      'url': _urlController.text.trim(),
      'notes': _noteController.text.trim(),
      'isactive': _isActive ? 1 : 0,
    };

    try {
      snackbarProvider.showMessage("Updating password");
      await passwordProvider.addOrUpdatePassword(
        updatedData,
        passwordChanged: passwordChanged,
      );
      widget.onSaveComplete?.call(updatedData['id']);
    } catch (e) {
      snackbarProvider.showMessage("Error saving password: $e");
    }
  }

  Future<void> _delete() async {
    final settings = context.read<SettingsProvider>();
    final passwordId = widget.existingRecord['id'];

    if (!settings.skipDeleteConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Password'),
          content: Text('Delete password for "${widget.existingRecord['service']}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await context.read<PasswordProvider>().deletePassword(passwordId);
    widget.onDeleteComplete?.call(passwordId);
  }

  @override
  void dispose() {
    _hidePasswordTimer?.cancel();
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _serviceTypeController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: FocusTraversalGroup(
              child: Column(
                children: [
                  Text('Edit Password', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildSmartField('Title', _serviceController, 'service'),
                  _buildSmartField('Username', _usernameController, 'username', required: false),
                  _isDecrypting ? const CircularProgressIndicator() : _buildPasswordField(context),
                  _buildSmartField('Category', _serviceTypeController, 'serviceType', required: false),
                  _buildSmartField('URL', _urlController, 'url', required: false),
                  _buildSmartField('Note', _noteController, 'note', required: false, maxLines: 3),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Show Record'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),
                  BottomActionBar(
                    isEditMode: true,
                    showDeleteButton: true,
                    onSave: _save,
                    onDelete: _delete,
                    onCancel: widget.onCancel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartField(String label, TextEditingController controller, String key, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FocusTraversalOrder(
        order: NumericFocusOrder(maxLines.toDouble()),
        child: Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus && _clearedFields.contains(key) && controller.text.trim().isEmpty) {
              controller.text = _originalValues[key] ?? '';
            }
          },
          child: TextFormField(
            controller: controller,
            onTap: () {
              if (!_clearedFields.contains(key)) {
                _originalValues[key] = controller.text;
                controller.clear();
                _clearedFields.add(key);
              }
            },
            maxLines: maxLines,
            decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
            validator: (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FocusTraversalOrder(
        order: const NumericFocusOrder(3.0),
        child: Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus && _clearedFields.contains('password') && _passwordController.text.trim().isEmpty) {
              _passwordController.text = _originalValues['password'] ?? '••••••••••';
              _obscurePassword = true;
              _passwordVisible = false;
              _clearedFields.remove('password');
            }
          },
          child: TextFormField(
            controller: _passwordController,
            onTap: () {
              if (!_clearedFields.contains('password')) {
                _originalValues['password'] = _passwordController.text;
                _passwordController.clear();
                _clearedFields.add('password');

                setState(() {
                  _obscurePassword = false;
                  _passwordVisible = true;
                });

                _hidePasswordTimer?.cancel();
                _hidePasswordTimer = Timer(const Duration(seconds: 10), () {
                  if (mounted) {
                    setState(() {
                      _obscurePassword = true;
                      _passwordVisible = false;
                      if (_passwordController.text.isNotEmpty) {
                        _passwordController.text = '••••••••••';
                      }
                    });
                  }
                });
              }
            },
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: theme.colorScheme.primary),
                    onPressed: _togglePasswordVisibility,
                  ),
                  IconButton(
                    icon: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
                    onPressed: _generatePassword,
                  ),
                ],
              ),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
          ),
        ),
      ),
    );
  }
}
