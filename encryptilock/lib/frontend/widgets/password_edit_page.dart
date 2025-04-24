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
  final Map<String, dynamic> _decryptedValues = {};

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
    _decryptInitialFields();
    _passwordController.text = '••••••••••';
  }

  void _populateFields() {
    // Initially fill controllers with either encrypted or empty placeholders.
    // We'll overwrite them with decrypted text if needed, below.

    _originalValues['service'] = widget.existingRecord['service'];
    _originalValues['username'] = widget.existingRecord['username'];
    _originalValues['servicetype'] = widget.existingRecord['servicetype'];
    _originalValues['url'] = widget.existingRecord['url'];
    _originalValues['notes'] = widget.existingRecord['notes'];
    _isActive = widget.existingRecord['isactive'] == 1;
  }

  Future<void> _decryptInitialFields() async {
    // You decide which fields to decrypt immediately:
    // e.g., 'service', 'username', 'servicetype', 'url', 'notes'.
    // If they are stored encrypted in the DB, decrypt them now.
    final passwordProvider = context.read<PasswordProvider>();

    await _maybeDecryptField('service', _serviceController);
    await _maybeDecryptField('username', _usernameController);
    await _maybeDecryptField('servicetype', _serviceTypeController);
    await _maybeDecryptField('url', _urlController);
    await _maybeDecryptField('notes', _noteController);

    setState(() {});
  }

  /// Decrypts the controller's current text if it's non-empty.
  /// This ensures the user never sees ciphertext in the UI.
  Future<void> _maybeDecryptField(String fieldKey, TextEditingController ctrl) async {
    final rawValue = _originalValues[fieldKey]?.trim();
    if (rawValue == null || rawValue.isEmpty) return;
    if ({
      'service',
      'servicetype'
    }.contains(fieldKey)) {
      // Directly set text if it's plaintext
      ctrl.text = rawValue;
      return;
    }
    try {
      final passwordProvider = context.read<PasswordProvider>();
      final decrypted = await passwordProvider.decryptField(fieldKey, rawValue);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ctrl.text = decrypted;
      });
    } catch (_) {
      // Optional: fallback or notify user
    }
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

  Future<void> _togglePasswordVisibility() async {
    final passwordProv = context.read<PasswordProvider>();
    final encrypted = widget.existingRecord['password'];

    if (_passwordVisible) {
      // Hide immediately
      _hidePasswordTimer?.cancel();
      setState(() {
        _passwordVisible = false;
        _obscurePassword = true;
        _passwordController.text = '••••••••••'; // Restore masked string
      });
    } else {
      setState(() {
        _isDecrypting = true;
        _passwordController.text = '••••••••••'; // show mask while decrypting
      });

      try {
        final decrypted = await passwordProv.decryptPassword(encrypted);
        setState(() {
          _passwordVisible = true;
          _obscurePassword = false;
          _passwordController.text = decrypted;
        });

        _hidePasswordTimer?.cancel();
        _hidePasswordTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _passwordVisible = false;
              _obscurePassword = true;
              _passwordController.text = '••••••••••'; // hide again
            });
          }
        });
      } catch (e) {
        context.read<SnackBarProvider>().showMessage('Failed to decrypt password.');
      } finally {
        if (mounted) setState(() => _isDecrypting = false);
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
    final passwordProvider = context.read<PasswordProvider>();
    final snackbarProvider = context.read<SnackBarProvider>();

    // Handle password masking logic first (unchanged from your code)
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

    // -----------------------------------------------------------
    //  1) Compare new vs. old for non-password fields
    // -----------------------------------------------------------
    final original = widget.existingRecord;
    final newService = _serviceController.text.trim();
    final newUsername = _usernameController.text.trim();
    final newServiceType = _serviceTypeController.text.trim();
    final newUrl = _urlController.text.trim();
    final newNotes = _noteController.text.trim();
    final newIsActive = _isActive ? 1 : 0;

    bool serviceChanged = newService != (original['service'] ?? '');
    bool usernameChanged = newUsername != (original['username'] ?? '');
    bool serviceTypeChanged = newServiceType != (original['servicetype'] ?? '');
    bool urlChanged = newUrl != (original['url'] ?? '');
    bool notesChanged = newNotes != (original['notes'] ?? '');
    bool isActiveChanged = newIsActive != (original['isactive'] ?? 1);

    //  2) Build the changedFields map
    Map<String, bool> changedFields = {
      'service': serviceChanged,
      'username': usernameChanged,
      'servicetype': serviceTypeChanged,
      'url': urlChanged,
      'notes': notesChanged,
      'isactive': isActiveChanged,
      // 'updatedt' or others as needed if you're encrypting them, too
    };
    // -----------------------------------------------------------
    //  3) Build new data to save
    // -----------------------------------------------------------
    final updatedData = {
      'id': original['id'],
      'service': newService,
      'username': newUsername,
      'password': passwordToSave.trim(),
      'servicetype': newServiceType,
      'url': newUrl,
      'notes': newNotes,
      'isactive': newIsActive,
    };

    // -----------------------------------------------------------
    //  4) Make the upsert call
    // -----------------------------------------------------------
    try {
      snackbarProvider.showMessage("Updating password");
      await passwordProvider.addOrUpdatePassword(
        updatedData,
        passwordChanged: passwordChanged,
        changedFields: changedFields,
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

  // @ove
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Sticky Title
              Text('Edit Password', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Scrollable inputs
              Expanded(
                child: SingleChildScrollView(
                  child: FocusTraversalGroup(
                    child: Column(
                      children: [
                        _buildSmartField('Title', _serviceController, 'service'),
                        _buildSmartField('Username', _usernameController, 'username', required: false, decryptFlag: true),
                        _isDecrypting ? const CircularProgressIndicator() : _buildPasswordField(context),
                        _buildSmartField('Category', _serviceTypeController, 'serviceType', required: false),
                        _buildSmartField('URL', _urlController, 'url', required: false, decryptFlag: true),
                        _buildSmartField('Note', _noteController, 'note', required: false, maxLines: 3, decryptFlag: true),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Toggle + Action Bar
              Column(
                children: [
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Show Record'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  BottomActionBar(
                    isEditMode: true,
                    showDeleteButton: true,
                    onSave: _save,
                    onDelete: _delete,
                    onCancel: widget.onCancel,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartField(
    String label,
    TextEditingController controller,
    String key, {
    bool required = false,
    int maxLines = 1,
    bool decryptFlag = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FocusTraversalOrder(
        order: NumericFocusOrder(maxLines.toDouble()),
        child: Focus(
          onFocusChange: (hasFocus) {
            // If user leaves the field and it's empty, revert to original
            if (!hasFocus && _clearedFields.contains(key) && controller.text.trim().isEmpty) {
              controller.text = _originalValues[key] ?? '';
            }
          },
          child: TextFormField(
            controller: controller,
            onTap: () async {
              // Check if we've never "cleared" this field before
              if (!_clearedFields.contains(key)) {
                // Store the original text, then clear it
                _originalValues[key] = controller.text;
                controller.clear();
                _clearedFields.add(key);

                // If we need to decrypt the existing text
                if (decryptFlag && (_originalValues[key]?.isNotEmpty ?? false)) {
                  try {
                    final passwordProvider = context.read<PasswordProvider>();
                    final decrypted = await passwordProvider.decryptField(
                      key,
                      _originalValues[key]!,
                    );
                    if (mounted) {
                      setState(() {
                        controller.text = decrypted;
                        _originalValues[key] = decrypted;
                      });
                    }
                  } catch (e) {
                    // If decryption fails, optionally show a snackbar, etc.
                    // context.read<SnackBarProvider>().showMessage('Failed to decrypt $label.');
                  }
                }
              }
            },
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
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
