import 'package:Encryptilock/backend/helpers/password_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:Encryptilock/frontend/providers/settings_provider.dart';

class ComplexPasswordGeneratorDialog extends StatefulWidget {
  final void Function(String password)? onPasswordGenerated;

  const ComplexPasswordGeneratorDialog({Key? key, this.onPasswordGenerated}) : super(key: key);

  @override
  State<ComplexPasswordGeneratorDialog> createState() => _ComplexPasswordGeneratorDialogState();
}

class _ComplexPasswordGeneratorDialogState extends State<ComplexPasswordGeneratorDialog> {
  final _minLengthController = TextEditingController(text: '8');
  final _maxLengthController = TextEditingController(text: '16');
  final _excludeCharsController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // After the first frame, read SettingsProvider to possibly override defaults
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      // Only override if the user has "Define Password Generator Parameters" toggled on
      if (settings.definePasswordGeneratorParams) {
        _minLengthController.text = settings.minLength.toString();
        _maxLengthController.text = settings.maxLength.toString();
        _excludeCharsController.text = settings.excludeChars;
      }
    });
  }

  /// Generate a password using the provided parameters
  void _generatePassword() {
    try {
      final minLength = int.tryParse(_minLengthController.text) ?? 0;
      final maxLength = int.tryParse(_maxLengthController.text) ?? 0;

      if (minLength <= 0 || maxLength <= 0 || minLength > maxLength) {
        throw Exception('Invalid length parameters.');
      }

      final excludeChars = _excludeCharsController.text;

      final password = PasswordFactory.generatePassword(
        minLength: minLength,
        maxLength: maxLength,
        excludeChars: excludeChars.isNotEmpty ? excludeChars : null,
      );

      setState(() {
        _passwordController.text = password;
      });
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  /// Copy the password to clipboard and show confirmation
  void _copyToClipboard() {
    if (_passwordController.text.isEmpty) {
      _showSnackBar('No password to copy!');
      return;
    }

    Clipboard.setData(ClipboardData(text: _passwordController.text));
    _showSnackBar('Password copied to clipboard!');
  }

  /// Validate inputs and return the password
  void _confirmPassword() {
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please generate a password before confirming.');
      return;
    }

    widget.onPasswordGenerated?.call(_passwordController.text);
    Navigator.of(context).pop(_passwordController.text);
  }

  /// Show a SnackBar with the given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Generate Password'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minimum Length
            TextFormField(
              controller: _minLengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Length',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Maximum Length
            TextFormField(
              controller: _maxLengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maximum Length',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Exclude Characters
            TextFormField(
              controller: _excludeCharsController,
              decoration: const InputDecoration(
                labelText: 'Exclude Characters',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Generated Password Field
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    readOnly: false,
                    decoration: const InputDecoration(
                      labelText: 'Generated Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyToClipboard,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Generate Button
            ElevatedButton(
              onPressed: _generatePassword,
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirmPassword, // Confirm and return password
          child: const Text('OK'),
        ),
      ],
    );
  }
}
