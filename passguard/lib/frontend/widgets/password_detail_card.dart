import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Encryptilock/frontend/providers/password_provider.dart';
import 'package:Encryptilock/frontend/providers/settings_provider.dart';
import 'package:Encryptilock/frontend/providers/snackbar_provider.dart';

/// A card displaying the *currently selected* password from PasswordProvider.
/// If a new password is selected while this is open, the fields update and
/// any old state (like the decrypted result) is reset.
class PasswordDetailCard extends StatefulWidget {
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const PasswordDetailCard({
    Key? key,
    required this.onEdit,
    required this.onClose,
  }) : super(key: key);

  @override
  State<PasswordDetailCard> createState() => _PasswordDetailCardState();
}

class _PasswordDetailCardState extends State<PasswordDetailCard> {
  bool _showPlaintext = false; // Whether we display the decrypted password
  Future<String?>? _decryptFuture; // Tracks the ongoing decryption
  Timer? _hideTimer; // Hides the password after 2.5s
  String? _lastSelectedId; // To detect if the user changed to a new record

  Future<void> _decryptPasswordToClipboard(BuildContext context, String encryptedPass) async {
    final snackbarProv = Provider.of<SnackBarProvider>(context, listen: false);
    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      final decryptedPassword = await passwordProvider.decryptPassword(encryptedPass);

      if (decryptedPassword.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: decryptedPassword));
        snackbarProv.showMessage('Password copied to clipboard');
      } else {
        snackbarProv.showMessage('Failed to copy to clipboard');
      }
    } catch (e) {
      snackbarProv.showMessage('Failed to copy to clipboard');
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// If a new password is selected while this card is still mounted,
  /// reset the local state so we don't see old decrypt results.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final passwordProv = Provider.of<PasswordProvider>(context);
    final currentId = passwordProv.selectedPassword?['id'];

    // If the user has changed the selection
    if (currentId != _lastSelectedId) {
      // Reset everything
      _hideTimer?.cancel();
      _showPlaintext = false;
      _decryptFuture = null;
      _lastSelectedId = currentId;
    }
  }

  void _togglePasswordVisibility(String encryptedPassword) {
    if (_showPlaintext) {
      // Hide immediately
      _hideTimer?.cancel();
      setState(() {
        _showPlaintext = false;
        _decryptFuture = null;
      });
      return;
    }

    // Otherwise, decrypt and show
    final passwordProv = Provider.of<PasswordProvider>(context, listen: false);
    setState(() {
      _showPlaintext = true;
      _decryptFuture = passwordProv.decryptPassword(encryptedPassword);
    });

    // Auto-hide after 2.5s
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showPlaintext = false;
          _decryptFuture = null;
        });
      }
    });
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    final snackbarProv = Provider.of<SnackBarProvider>(context, listen: false);
    Clipboard.setData(ClipboardData(text: text));
    snackbarProv.showMessage('$label copied to clipboard');
  }

  void _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;

    // Normalize the URL
    String normalizedUrl = _normalizeUrl(url);

    // Try parsing the normalized URL
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL: $url')),
      );
      return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open URL: $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: ${e.toString()}')),
      );
    }
  }

  // Helper function to normalize URLs
  String _normalizeUrl(String url) {
    // Trim whitespace
    url = url.trim();

    // If no scheme is present, add https://
    if (!url.contains('://')) {
      // Check if it starts with www.
      if (url.startsWith('www.')) {
        url = 'https://$url';
      }
      // If it doesn't start with www., add https://
      else {
        url = 'https://$url';
      }
    }

    return url;
  }
  // void _openUrl(BuildContext context, String url) async {
  //   if (url.isEmpty) return;
  //   final uri = Uri.tryParse(url);
  //   if (uri == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Invalid URL: $url')),
  //     );
  //     return;
  //   }
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not open URL: $url')),
  //     );
  //   }
  // }

  /// Handles the delete action. If "Do Not Ask Before Deleting" is true,
  /// it deletes immediately. Otherwise, shows a small confirmation prompt.
  void _onDeletePassword(BuildContext context, String passwordId) async {
    final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
    final skipConfirm = settingsProv.skipDeleteConfirmation;
    final passwordProv = Provider.of<PasswordProvider>(context, listen: false);
    final snackBarProv = Provider.of<SnackBarProvider>(context, listen: false);

    // Delete immediately if skipConfirm is on
    if (skipConfirm) {
      await passwordProv.deletePassword(passwordId);
      snackBarProv.showMessage('Password deleted');
      widget.onClose(); // Close detail card automatically if desired
    } else {
      // Ask for confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this password?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await passwordProv.deletePassword(passwordId);
        snackBarProv.showMessage('Password deleted');
        widget.onClose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // return Consumer<PasswordProvider>(
    //   builder: (ctx, passwordProv, _) {
    //     final selected = passwordProv.selectedPassword;

    //     // If no password is selected, show a simple placeholder
    //     if (selected == null) {
    //       return Center(
    //         child: Padding(
    //           padding: const EdgeInsets.all(16.0),
    //           child: Text(
    //             "No password selected",
    //             style: theme.textTheme.bodyMedium,
    //           ),
    //         ),
    //       );
    //     }
    return Consumer3<PasswordProvider, SettingsProvider, SnackBarProvider>(
      builder: (ctx, passwordProv, settingsProv, snackbarProv, _) {
        final selected = passwordProv.selectedPassword;

        // If no password is selected, show a simple placeholder
        if (selected == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No password selected",
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        // Extract all fields
        final serviceName = selected['service'] ?? '';
        final username = selected['username'] ?? '';
        final encryptedPass = selected['password'] ?? '';
        final url = selected['url'] ?? '';
        final creationDate = selected['createdt'] ?? '';
        final serviceType = selected['servicetype'] ?? '';
        final passwordId = selected['id'];

        DateTime createDateParsed = DateTime.parse(creationDate);
        String formattedDate = '${createDateParsed.year}-${createDateParsed.month.toString().padLeft(2, '0')}-${createDateParsed.day.toString().padLeft(2, '0')}';

        // Reusable read-only field for non-password data
        Widget _buildNormalField({
          required String label,
          required String value,
          bool copyable = false,
          VoidCallback? onSuffixTap,
          IconData? suffixIconData,
          String? suffixTooltip,
        }) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              initialValue: value,
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (copyable)
                      IconButton(
                        tooltip: 'Copy $label',
                        icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                        onPressed: () => _copyToClipboard(context, value, label),
                      ),
                    if (onSuffixTap != null && suffixIconData != null)
                      IconButton(
                        tooltip: suffixTooltip,
                        icon: Icon(suffixIconData, color: theme.colorScheme.primary),
                        onPressed: onSuffixTap,
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        // Password field
        Widget _buildPasswordField() {
          if (!_showPlaintext) {
            // Masked by default
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                initialValue: '•••••••••',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Show Password',
                        icon: Icon(Icons.visibility, color: theme.colorScheme.primary),
                        onPressed: () => _togglePasswordVisibility(encryptedPass),
                      ),
                      // Copy -> copies encrypted password
                      IconButton(
                        tooltip: 'Copy Password',
                        icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                        onPressed: () => _decryptPasswordToClipboard(context, encryptedPass),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // If showing plaintext, show a FutureBuilder that decrypts
          return FutureBuilder<String?>(
            future: _decryptFuture,
            builder: (context, snapshot) {
              String labelText = '•••••••••';
              Widget copyButton = IconButton(
                icon: const Icon(Icons.copy),
                onPressed: null,
              );
              IconData visibilityIcon = Icons.visibility_off;
              String visibilityTooltip = 'Hide Password';

              if (snapshot.connectionState == ConnectionState.waiting) {
                labelText = '';
              } else if (snapshot.hasData) {
                final decrypted = snapshot.data ?? '';
                labelText = decrypted.isNotEmpty ? decrypted : 'No password';
                // Copy plaintext
                copyButton = IconButton(
                  tooltip: 'Copy Password',
                  icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                  onPressed: () => _decryptPasswordToClipboard(context, encryptedPass),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: labelText,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: labelText,
                    border: OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: visibilityTooltip,
                          icon: Icon(visibilityIcon, color: theme.colorScheme.primary),
                          onPressed: () => _togglePasswordVisibility(encryptedPass),
                        ),
                        copyButton,
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Service name + Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        serviceName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Ensures the text truncates with "..."
                        maxLines: 1, // Prevents wrapping to a new line
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min, // Ensures buttons only take the space they need
                      children: [
                        if (settingsProv.showDeleteButtonMainView)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: theme.colorScheme.error,
                            tooltip: 'Delete',
                            onPressed: () {
                              _onDeletePassword(context, passwordId);
                            },
                          ),
                        const SizedBox(width: 32.0),
                        IconButton(
                          icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                          tooltip: 'Edit',
                          onPressed: widget.onEdit,
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.colorScheme.error),
                          tooltip: 'Close',
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24.0),

                // Username
                _buildNormalField(
                  label: 'Username',
                  value: username,
                  copyable: true,
                ),

                // Password
                _buildPasswordField(),

                // URL if present
                _buildNormalField(
                  label: 'URL',
                  value: url,
                  onSuffixTap: () => _openUrl(context, url),
                  suffixIconData: Icons.open_in_browser,
                  suffixTooltip: 'Open URL',
                ),

                const SizedBox(height: 24.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Service Type: $serviceType',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.0), // Add spacing between the texts if needed
                    Flexible(
                      child: Text(
                        'Created: $formattedDate',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
