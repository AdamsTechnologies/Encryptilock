import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';
import 'package:encryptilock/backend/helpers/path_utils.dart';
import 'package:encryptilock/frontend/screens/login_screen.dart';

class ResetAppDialog extends StatefulWidget {
  final ConfigSettingsController configManager;

  const ResetAppDialog({required this.configManager});

  @override
  _ResetAppDialogState createState() => _ResetAppDialogState();
}

class _ResetAppDialogState extends State<ResetAppDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  Future<void> _resetApp() async {
    setState(() => _isDeleting = true);
    try {
      widget.configManager.close();

      final configFile = File(await getLocalPath('s1.db'));
      final vaultFile = File(await getLocalPath('s2.db'));

      if (await vaultFile.exists()) await vaultFile.delete();
      if (await configFile.exists()) await configFile.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print(e);
      setState(() {
        _error = '$e';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmText = _confirmController.text.trim();
    final isReady = confirmText.toUpperCase() == 'DELETE' && !_isDeleting;

    return AlertDialog(
      title: Text('Reset Encryptilock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("This will permanently delete your vault and all settings. Your data cannot be recovered."),
          SizedBox(height: 16),
          Text("To confirm, type DELETE below:"),
          TextField(
            controller: _confirmController,
            decoration: InputDecoration(
              hintText: 'Type DELETE to confirm',
              errorText: _error,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: isReady ? _resetApp : null,
          child: _isDeleting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Delete Everything'),
        ),
      ],
    );
  }
}
