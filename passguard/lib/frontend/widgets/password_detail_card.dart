import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async'; // For Timer

class PasswordDetailCard extends StatefulWidget {
  final String serviceName;
  final String username;
  final String password;
  final String? url;
  final String creationDate;
  final String serviceType;
  final VoidCallback onEdit;
  final VoidCallback onClose; // New callback for closing the detail view

  const PasswordDetailCard({
    Key? key,
    required this.serviceName,
    required this.username,
    required this.password,
    this.url,
    required this.creationDate,
    required this.serviceType,
    required this.onEdit,
    required this.onClose,
  }) : super(key: key);

  @override
  State<PasswordDetailCard> createState() => _PasswordDetailCardState();
}

class _PasswordDetailCardState extends State<PasswordDetailCard> {
  bool _isPasswordVisible = false;
  Timer? _visibilityTimer;

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = true;
    });

    // Start a timer to hide the password after 2.5 seconds
    _visibilityTimer?.cancel(); // Cancel any existing timer
    _visibilityTimer = Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        _isPasswordVisible = false;
      });
    });
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard!')),
    );
  }

  void _openUrl(BuildContext context) async {
    if (widget.url != null && widget.url!.isNotEmpty) {
      final uri = Uri.tryParse(widget.url!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL: ${widget.url}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Helper method to build disabled TextFormFields
    Widget _buildDisabledField(String label, String value, {bool isPassword = false, bool isUrl = false, bool copyable = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: isPassword ? (_isPasswordVisible ? widget.password : '•' * 15) : value,
          readOnly: true,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (copyable)
                  IconButton(
                    onPressed: () => _copyToClipboard(context, value, label),
                    icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
                    tooltip: 'Copy $label',
                  ),
                if (isPassword)
                  IconButton(
                    onPressed: _togglePasswordVisibility,
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: _isPasswordVisible ? 'Hide Password' : 'Show Password',
                  ),
                if (isUrl)
                  IconButton(
                    onPressed: widget.url!.isNotEmpty ? () => _openUrl(context) : null,
                    icon: Icon(
                      Icons.open_in_browser,
                      color: widget.url!.isNotEmpty ? theme.colorScheme.primary : theme.disabledColor,
                    ),
                    tooltip: widget.url!.isNotEmpty ? 'Open URL' : 'No URL Available',
                  ),
              ],
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUrl && widget.url!.isNotEmpty ? theme.colorScheme.primary : null,
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for Material 3
      ),
      elevation: 6,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Increased padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Service Name and Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.serviceName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onEdit,
                      icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(Icons.close, color: theme.colorScheme.error),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Username Field
            _buildDisabledField('Username', widget.username, copyable: true),

            // Password Field with Masking and Visibility Toggle
            _buildDisabledField('Password', widget.password, isPassword: true, copyable: true),

            // URL Field with Conditional Button
            if (widget.url != null && widget.url!.isNotEmpty) _buildDisabledField('URL', widget.url!, isUrl: true),

            const SizedBox(height: 24.0),

            // Service Type and Creation Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Type: ${widget.serviceType}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Created: ${widget.creationDate}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // Action Buttons: Copy Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Copy Username
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context, widget.username, 'Username'),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Username'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Copy Password
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context, widget.password, 'Password'),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PasswordDetailCard extends StatelessWidget {
//   final String serviceName;
//   final String username;
//   final String password;
//   final String? url;
//   final String creationDate;
//   final String serviceType;
//   final VoidCallback onEdit;

//   const PasswordDetailCard({
//     Key? key,
//     required this.serviceName,
//     required this.username,
//     required this.password,
//     this.url,
//     required this.creationDate,
//     required this.serviceType,
//     required this.onEdit,
//   }) : super(key: key);

//   void _copyToClipboard(BuildContext context, String text, String label) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$label copied to clipboard!')),
//     );
//   }

//   void _openUrl(BuildContext context) async {
//     if (url != null && url!.isNotEmpty) {
//       final uri = Uri.tryParse(url!);
//       if (uri != null && await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid URL: $url')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       elevation: 4,
//       margin: const EdgeInsets.all(16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   serviceName,
//                   style: theme.textTheme.titleLarge,
//                 ),
//                 IconButton(
//                   onPressed: onEdit,
//                   icon: Icon(Icons.edit, color: theme.colorScheme.primary),
//                   tooltip: 'Edit',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             _buildDetailRow(
//               context,
//               label: 'Username',
//               value: username,
//               copyable: true,
//             ),
//             const SizedBox(height: 8.0),
//             _buildDetailRow(
//               context,
//               label: 'Password',
//               value: password,
//               copyable: true,
//               obscurable: true,
//             ),
//             const SizedBox(height: 8.0),
//             if (url != null && url!.isNotEmpty)
//               _buildDetailRow(
//                 context,
//                 label: 'URL',
//                 value: url!,
//                 copyable: false,
//                 clickable: true,
//               ),
//             const SizedBox(height: 16.0),
//             Text(
//               'Service Type: $serviceType',
//               style: theme.textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 4.0),
//             Text(
//               'Created: $creationDate',
//               style: theme.textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     BuildContext context, {
//     required String label,
//     required String value,
//     bool copyable = false,
//     bool obscurable = false,
//     bool clickable = false,
//   }) {
//     final theme = Theme.of(context);
//     bool isObscured = obscurable;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: clickable ? () => _openUrl(context) : null,
//             child: Text(
//               value,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: clickable ? theme.colorScheme.primary : null,
//                 decoration: clickable ? TextDecoration.underline : null,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//         if (copyable || obscurable)
//           Row(
//             children: [
//               if (copyable)
//                 IconButton(
//                   onPressed: () => _copyToClipboard(context, value, label),
//                   icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                   tooltip: 'Copy $label',
//                 ),
//               if (obscurable)
//                 StatefulBuilder(
//                   builder: (context, setState) {
//                     return IconButton(
//                       onPressed: () => setState(() => isObscured = !isObscured),
//                       icon: Icon(
//                         isObscured ? Icons.visibility : Icons.visibility_off,
//                         color: theme.colorScheme.secondary,
//                       ),
//                       tooltip: isObscured ? 'Show $label' : 'Hide $label',
//                     );
//                   },
//                 ),
//             ],
//           ),
//       ],
//     );
//   }
// }
