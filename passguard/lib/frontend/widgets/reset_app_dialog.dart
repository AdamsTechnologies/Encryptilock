import 'dart:io';
import 'package:flutter/material.dart';

import 'package:encryptilock/backend/controllers/config_settings_controller.dart';
import 'package:encryptilock/frontend/services/app_reset_service.dart';

class ResetAppDialog extends StatefulWidget {
  final ConfigSettingsController configManager;

  const ResetAppDialog({required this.configManager, super.key});

  @override
  State<ResetAppDialog> createState() => _ResetAppDialogState();
}

class _ResetAppDialogState extends State<ResetAppDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final confirmText = _confirmController.text.trim();
    final isReady = confirmText.toUpperCase() == 'DELETE' && !_isDeleting;

    return AlertDialog(
      title: const Text('Factory Reset Encryptilock'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              "This will permanently delete your vault and all settings.\n\n"
              "⚠️ Your data cannot be recovered.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "To confirm, type DELETE below:",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(
                hintText: 'Type DELETE to confirm',
                errorText: _error,
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: isReady
              ? () async {
                  setState(() => _isDeleting = true);
                  await AppResetService.resetToRegister(
                    context: context,
                    configManager: widget.configManager,
                  );
                }
              : null,
          child: _isDeleting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Delete and Restart'),
        ),
      ],
    );
  }
}
