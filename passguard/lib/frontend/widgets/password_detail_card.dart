// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../providers/password_provider.dart';

// /// A card that displays details for the *currently selected* password in PasswordProvider.
// ///
// /// * All record data (serviceName, username, password, etc.) is loaded from `selectedPassword`.
// /// * If no password is selected, displays "No password selected" instead.
// class PasswordDetailCard extends StatefulWidget {
//   final VoidCallback onEdit;
//   final VoidCallback onClose;

//   const PasswordDetailCard({
//     Key? key,
//     required this.onEdit,
//     required this.onClose,
//   }) : super(key: key);

//   @override
//   State<PasswordDetailCard> createState() => _PasswordDetailCardState();
// }

// class _PasswordDetailCardState extends State<PasswordDetailCard> {
//   bool _showPlaintext = false; // whether we show the password in decrypted form
//   Future<String?>? _decryptFuture; // the Future for decryption
//   Timer? _hideTimer; // auto-hide timer for 2.5s

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     super.dispose();
//   }

//   void _togglePasswordVisibility(String encryptedPassword) {
//     // If currently visible, hide immediately
//     if (_showPlaintext) {
//       _hideTimer?.cancel();
//       setState(() {
//         _showPlaintext = false;
//         _decryptFuture = null;
//       });
//       return;
//     }

//     // Otherwise, show (decrypt)
//     setState(() {
//       _showPlaintext = true;
//       final provider = Provider.of<PasswordProvider>(context, listen: false);
//       _decryptFuture = provider.decryptPassword(encryptedPassword);
//     });

//     // Hide again after 2.5s
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(milliseconds: 2500), () {
//       if (mounted) {
//         setState(() {
//           _showPlaintext = false;
//           _decryptFuture = null;
//         });
//       }
//     });
//   }

//   /// Copy to clipboard and show confirmation
//   void _copyToClipboard(BuildContext context, String text, String label) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$label copied to clipboard!')),
//     );
//   }

//   /// Open the given URL in a browser
//   void _openUrl(BuildContext context, String url) async {
//     if (url.isEmpty) return;
//     final uri = Uri.tryParse(url);
//     if (uri == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid URL: $url')),
//       );
//       return;
//     }
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not open URL: $url')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Consumer<PasswordProvider>(
//       builder: (ctx, passwordProv, _) {
//         final selected = passwordProv.selectedPassword;
//         if (selected == null) {
//           // No password is selected
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "No password selected",
//                 style: theme.textTheme.bodyMedium,
//               ),
//             ),
//           );
//         }

//         // Pull fields from the selected record
//         final serviceName = selected['service'] ?? '';
//         final username = selected['username'] ?? '';
//         final encryptedPassword = selected['password'] ?? '';
//         final url = selected['url'] ?? '';
//         final creationDate = selected['createdt'] ?? '';
//         final serviceType = selected['servicetype'] ?? '';

//         // Helper for a read-only field (non-password)
//         Widget _buildNormalField({
//           required String label,
//           required String value,
//           bool copyable = false,
//           VoidCallback? onSuffixTap,
//           IconData? suffixIconData,
//           String? suffixTooltip,
//         }) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: TextFormField(
//               initialValue: value,
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: label,
//                 suffixIcon: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (copyable)
//                       IconButton(
//                         tooltip: 'Copy $label',
//                         icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                         onPressed: () => _copyToClipboard(context, value, label),
//                       ),
//                     if (onSuffixTap != null && suffixIconData != null)
//                       IconButton(
//                         tooltip: suffixTooltip,
//                         icon: Icon(suffixIconData, color: theme.colorScheme.primary),
//                         onPressed: onSuffixTap,
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }

//         Widget _buildPasswordField() {
//           // If user does NOT want plaintext, show masked
//           if (!_showPlaintext) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: TextFormField(
//                 // Requirement #10: "Use initialValue: null for password field"
//                 initialValue: null,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   labelText: '•••••••••',
//                   suffixIcon: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         tooltip: 'Copy Password',
//                         icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                         onPressed: () => _copyToClipboard(context, encryptedPassword, 'Password'),
//                       ),
//                       IconButton(
//                         tooltip: 'Show Password',
//                         icon: Icon(Icons.visibility, color: theme.colorScheme.primary),
//                         onPressed: () => _togglePasswordVisibility(encryptedPassword),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }

//           // If the user wants plaintext, use a FutureBuilder
//           return FutureBuilder<String?>(
//             future: _decryptFuture,
//             builder: (context, snapshot) {
//               String labelText = '•••••••••';
//               Widget copyButton = IconButton(
//                 icon: const Icon(Icons.copy),
//                 onPressed: null, // disabled by default
//               );
//               IconData visibilityIcon = Icons.visibility_off;
//               String visibilityTooltip = 'Hide Password';

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 // Decrypting
//                 labelText = '';
//               } else if (snapshot.hasError) {
//                 // Decryption failed
//                 labelText = 'Error decrypting password';
//                 final decrypted = snapshot.data ?? '';
//                 labelText = decrypted.isNotEmpty ? decrypted : 'No password';
//                 copyButton = IconButton(
//                   tooltip: 'Copy Password',
//                   icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                   onPressed: () => _copyToClipboard(context, decrypted, 'Password'),
//                 );
//               } else if (snapshot.hasData) {
//                 // Success
//                 final decrypted = snapshot.data ?? '';
//                 labelText = decrypted.isNotEmpty ? decrypted : 'No password';
//                 copyButton = IconButton(
//                   tooltip: 'Copy Password',
//                   icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                   onPressed: () => _copyToClipboard(context, decrypted, 'Password'),
//                 );
//               }

//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: TextFormField(
//                   initialValue: null,
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     labelText: labelText,
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         copyButton,
//                         IconButton(
//                           tooltip: visibilityTooltip,
//                           icon: Icon(visibilityIcon, color: theme.colorScheme.primary),
//                           onPressed: () => _togglePasswordVisibility(encryptedPassword),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }

//         return Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           elevation: 6,
//           margin: const EdgeInsets.all(16.0),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       serviceName,
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit, color: theme.colorScheme.primary),
//                           tooltip: 'Edit',
//                           onPressed: widget.onEdit,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close, color: theme.colorScheme.error),
//                           tooltip: 'Close',
//                           onPressed: widget.onClose,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 24.0),

//                 // Username
//                 _buildNormalField(
//                   label: 'Username',
//                   value: username,
//                   copyable: true,
//                 ),

//                 // Password
//                 _buildPasswordField(),

//                 // URL if present
//                 if (url.isNotEmpty)
//                   _buildNormalField(
//                     label: 'URL',
//                     value: url,
//                     onSuffixTap: () => _openUrl(context, url),
//                     suffixIconData: Icons.open_in_browser,
//                     suffixTooltip: 'Open URL',
//                   ),

//                 const SizedBox(height: 24.0),

//                 // Service Type + Creation date
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Service Type: $serviceType',
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                     Text(
//                       'Created: $creationDate',
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// --------------------------------------------------------------------------------------------------------
// ------------------ ABOVE IS BETTER, ALMOST THERE --------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Import the provider that can decrypt
import 'package:url_launcher/url_launcher.dart';
import '../providers/password_provider.dart';

/// A card for displaying password details.
///
/// Key points:
/// - Non-password fields (username, URL) show their actual values by default (`initialValue: ...`).
/// - The password field uses `initialValue: null` and a masked `hintText: "•••••••••"` by default.
/// - When "Show" is tapped, we decrypt via FutureBuilder, display the result for 2.5s,
///   and then revert to masked mode.
/// - If decryption fails, shows an error message instead of the password text.
class PasswordDetailCard extends StatefulWidget {
  final String serviceName;
  final String username;
  final String password; // Encrypted password from DB
  final String? url;
  final String creationDate;
  final String serviceType;
  final VoidCallback onEdit;
  final VoidCallback onClose;

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
  // Whether the user wants to see the decrypted password right now
  bool _showPlaintext = false;

  // The Future for decrypting the password (used by FutureBuilder)
  Future<String?>? _decryptFuture;

  // A timer that hides the password after 2.5 seconds
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Called when user taps the "eye" icon
  void _togglePasswordVisibility() {
    // If we're currently showing the plaintext, hide it immediately
    if (_showPlaintext) {
      _hideTimer?.cancel();
      setState(() {
        _showPlaintext = false;
        _decryptFuture = null;
      });
      return;
    }

    // Otherwise, show the password (decrypt it)
    setState(() {
      _showPlaintext = true;
      final provider = Provider.of<PasswordProvider>(context, listen: false);
      _decryptFuture = provider.decryptPassword(widget.password);
    });

    // Hide again after 2.5 seconds
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

  /// Copy `text` to the clipboard and show a snackbar with confirmation
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard!')),
    );
  }

  /// Attempt to open the URL in a browser
  void _openUrl(BuildContext context) async {
    if (widget.url == null || widget.url!.isEmpty) return;
    final uri = Uri.tryParse(widget.url!);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL: ${widget.url}')),
      );
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open URL: ${widget.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Helper to build read-only fields for non-password items
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
          // For non-password fields, show the actual value by default
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (copyable)
                  IconButton(
                    tooltip: 'Copy $label',
                    icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
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

    // Helper to build the password field
    Widget _buildPasswordField() {
      // If user does NOT want the plaintext shown, just display masked
      if (!_showPlaintext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            // Requirement #10: For the password, set `initialValue: null`.
            initialValue: null,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '•••••••••',
              // We'll use hintText so the user sees some text by default
              // hintText: '•••••••••',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Copy -> copies encrypted password if hidden
                  IconButton(
                    tooltip: 'Copy Password',
                    icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
                    onPressed: () => _copyToClipboard(context, widget.password, 'Password'),
                  ),
                  IconButton(
                    tooltip: 'Show Password',
                    icon: Icon(Icons.visibility, color: theme.colorScheme.primary),
                    onPressed: _togglePasswordVisibility,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // If the user wants plaintext, use a FutureBuilder to decrypt
      return FutureBuilder<String?>(
        future: _decryptFuture,
        builder: (context, snapshot) {
          String hintText = '•••••••••'; // fallback
          Widget copyButton = IconButton(
            tooltip: 'Copy Password',
            icon: Icon(Icons.copy, color: theme.disabledColor),
            onPressed: null,
          );

          IconData visibilityIcon = Icons.visibility_off;
          String visibilityTooltip = 'Hide Password';

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Decryption in progress
            hintText = '';
          } else if (snapshot.hasError) {
            // Decryption failed
            hintText = 'Error decrypting password';
            // We can still let them copy the *encrypted* version if desired
            copyButton = IconButton(
              tooltip: 'Copy Password',
              icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
              onPressed: () => _copyToClipboard(context, widget.password, 'Password'),
            );
          } else if (snapshot.hasData) {
            // Decryption successful
            final decrypted = snapshot.data ?? '';
            hintText = decrypted.isNotEmpty ? decrypted : 'No password';
            // Let them copy the plaintext
            copyButton = IconButton(
              tooltip: 'Copy Password',
              icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
              onPressed: () => _copyToClipboard(context, decrypted, 'Password'),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              initialValue: null, // required per requirement #10
              readOnly: true,
              decoration: InputDecoration(
                // labelText: 'Password',
                labelText: hintText,
                // hintText: hintText,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    copyButton,
                    IconButton(
                      tooltip: visibilityTooltip,
                      icon: Icon(visibilityIcon, color: theme.colorScheme.primary),
                      onPressed: _togglePasswordVisibility,
                    ),
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
            // Header Row: Service Name + Action Buttons
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

            // Username Field (shows actual value)
            _buildNormalField(
              label: 'Username',
              value: widget.username,
              copyable: true,
            ),

            // Password Field (masked by default; decrypted on demand)
            _buildPasswordField(),

            // URL Field if provided
            if (widget.url != null && widget.url!.isNotEmpty)
              _buildNormalField(
                label: 'URL',
                value: widget.url!,
                onSuffixTap: () => _openUrl(context),
                suffixIconData: Icons.open_in_browser,
                suffixTooltip: 'Open URL',
              ),

            const SizedBox(height: 24.0),

            // Service Type + Creation Date
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
          ],
        ),
      ),
    );
  }
}


// --------------------------------------------------ABOVE WORKING NICELY-----------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// // Import the provider that can decrypt
// // import '../providers/password_provider.dart';
// import 'package:passguard/frontend/providers/password_provider.dart';

// /// A card for displaying password details.
// ///
// /// Requirements met:
// /// 1. Displays serviceName, username, creationDate, serviceType, etc.
// /// 2. Shows a masked password by default (•••••••••).
// /// 3. Tapping "Show Password" uses FutureBuilder to decrypt asynchronously.
// /// 4. Reveals the password for 2.5s, then hides again.
// /// 5. Copy buttons for username and password (copies decrypted if showing).
// /// 6. If decryption fails, shows an error instead of the password.
// /// 7. The decrypted password is not shared across widget instances.
// /// 8. The TextFormField uses `initialValue: null` for the password field.
// class PasswordDetailCard extends StatefulWidget {
//   final String serviceName;
//   final String username;
//   final String password; // This is *encrypted* from the database
//   final String? url;
//   final String creationDate;
//   final String serviceType;
//   final VoidCallback onEdit;
//   final VoidCallback onClose;

//   const PasswordDetailCard({
//     Key? key,
//     required this.serviceName,
//     required this.username,
//     required this.password,
//     this.url,
//     required this.creationDate,
//     required this.serviceType,
//     required this.onEdit,
//     required this.onClose,
//   }) : super(key: key);

//   @override
//   State<PasswordDetailCard> createState() => _PasswordDetailCardState();
// }

// class _PasswordDetailCardState extends State<PasswordDetailCard> {
//   // Whether the user wants to see the decrypted password
//   bool _showPlaintext = false;

//   // We store a Future so the FutureBuilder can display "Decrypting..." or an error
//   Future<String?>? _decryptFuture;

//   // We keep a timer to hide the password after 2.5s
//   Timer? _hideTimer;

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     super.dispose();
//   }

//   /// Called when the user taps the "eye" icon
//   void _togglePasswordVisibility() {
//     // If we're already showing the password, hide it immediately
//     if (_showPlaintext) {
//       _hideTimer?.cancel();
//       setState(() {
//         _showPlaintext = false;
//         _decryptFuture = null;
//       });
//       return;
//     }

//     // Otherwise, show the password (by starting a decrypt future)
//     final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//     setState(() {
//       _showPlaintext = true;
//       // Kick off the asynchronous decryption
//       _decryptFuture = passwordProvider.decryptPassword(widget.password);
//     });

//     // Hide again after 2.5 seconds
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(milliseconds: 2500), () {
//       if (mounted) {
//         setState(() {
//           _showPlaintext = false;
//           _decryptFuture = null;
//         });
//       }
//     });
//   }

//   /// Copy text to clipboard and show a simple confirmation
//   void _copyToClipboard(BuildContext context, String text, String label) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$label copied to clipboard!')),
//     );
//   }

//   /// Attempt to launch the URL in a browser
//   void _openUrl(BuildContext context) async {
//     if (widget.url == null || widget.url!.isEmpty) return;
//     final uri = Uri.tryParse(widget.url!);
//     if (uri == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid URL: ${widget.url}')),
//       );
//       return;
//     }
//     // If you have url_launcher: ^6.1.9 or later
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not open URL: ${widget.url}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Helper for building read-only fields
//     Widget _buildDisabledField({
//       required String label,
//       required Widget suffixIcon,
//       String? textToShow,
//     }) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: TextFormField(
//           // Requirement #10: "The TextFormField used to display the password
//           // should have its initialValue set to null when it contains a password."
//           //
//           // For password fields, we do `initialValue: null` and supply
//           // the actual text via a controller or decoration.
//           // However, we can also simply do `initialValue: null` and put the text
//           // in the hint or prefix.
//           // For clarity, let's do this:
//           initialValue: null,
//           readOnly: true,
//           decoration: InputDecoration(
//             labelText: label,
//             hintText: textToShow,
//             suffixIcon: suffixIcon,
//           ),
//         ),
//       );
//     }

//     // Build the password field with a FutureBuilder (since we must handle decryption and possible error).
//     Widget _buildPasswordField() {
//       // If user has not chosen to show plaintext, display masked
//       if (!_showPlaintext) {
//         // Masked display
//         return _buildDisabledField(
//           label: 'Password',
//           textToShow: '•••••••••',
//           suffixIcon: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Copy -> copies the encrypted password if hidden
//               IconButton(
//                 tooltip: 'Copy Password',
//                 icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                 onPressed: () => _copyToClipboard(context, widget.password, 'Password'),
//               ),
//               IconButton(
//                 tooltip: 'Show Password',
//                 icon: Icon(Icons.visibility, color: theme.colorScheme.primary),
//                 onPressed: _togglePasswordVisibility,
//               ),
//             ],
//           ),
//         );
//       }

//       // If user chose to show plaintext, we use a FutureBuilder to decrypt
//       return FutureBuilder<String?>(
//         future: _decryptFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Decryption in progress
//             return _buildDisabledField(
//               label: 'Password',
//               textToShow: 'Decrypting...',
//               suffixIcon: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // "Copy" is disabled or copies the encrypted if we like
//                   IconButton(
//                     tooltip: 'Copy Password',
//                     icon: Icon(Icons.copy, color: theme.disabledColor),
//                     onPressed: null,
//                   ),
//                   IconButton(
//                     tooltip: 'Hide Password',
//                     icon: Icon(Icons.visibility_off, color: theme.colorScheme.primary),
//                     onPressed: _togglePasswordVisibility,
//                   ),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             // If decryption fails
//             return _buildDisabledField(
//               label: 'Password',
//               textToShow: 'Error decrypting password',
//               suffixIcon: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Copy button might copy the encrypted password anyway
//                   IconButton(
//                     tooltip: 'Copy Password',
//                     icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                     onPressed: () => _copyToClipboard(context, widget.password, 'Password'),
//                   ),
//                   IconButton(
//                     tooltip: 'Hide Password',
//                     icon: Icon(Icons.visibility_off, color: theme.colorScheme.primary),
//                     onPressed: _togglePasswordVisibility,
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             // Successfully decrypted
//             final decrypted = snapshot.data ?? '';
//             return _buildDisabledField(
//               label: 'Password',
//               textToShow: decrypted.isEmpty ? 'No password' : decrypted,
//               suffixIcon: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Copy -> copies the *decrypted* password since visible
//                   IconButton(
//                     tooltip: 'Copy Password',
//                     icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                     onPressed: () => _copyToClipboard(context, decrypted, 'Password'),
//                   ),
//                   IconButton(
//                     tooltip: 'Hide Password',
//                     icon: Icon(Icons.visibility_off, color: theme.colorScheme.primary),
//                     onPressed: _togglePasswordVisibility,
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       );
//     }

//     // -- BUILD UI --
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       elevation: 6,
//       margin: const EdgeInsets.all(16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Row: Service Name + Edit / Close
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   widget.serviceName,
//                   style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: theme.colorScheme.primary),
//                       tooltip: 'Edit',
//                       onPressed: widget.onEdit,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, color: theme.colorScheme.error),
//                       tooltip: 'Close',
//                       onPressed: widget.onClose,
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24.0),

//             // Username Field
//             _buildDisabledField(
//               label: 'Username',
//               textToShow: widget.username,
//               suffixIcon: IconButton(
//                 tooltip: 'Copy Username',
//                 icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                 onPressed: () => _copyToClipboard(context, widget.username, 'Username'),
//               ),
//             ),

//             // Password Field (uses FutureBuilder to decrypt)
//             _buildPasswordField(),

//             // URL (if provided)
//             if (widget.url != null && widget.url!.isNotEmpty)
//               _buildDisabledField(
//                 label: 'URL',
//                 textToShow: widget.url,
//                 suffixIcon: IconButton(
//                   tooltip: 'Open URL',
//                   icon: Icon(Icons.open_in_browser, color: theme.colorScheme.primary),
//                   onPressed: () => _openUrl(context),
//                 ),
//               ),

//             const SizedBox(height: 24.0),

//             // Service Type + Creation Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Service Type: ${widget.serviceType}',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 Text(
//                   'Created: ${widget.creationDate}',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ------------------------------------------------------------------------------------
// --------------------------------------------- BEFORE TOGGLE PW LOGIC ---------------
// ------------------------------------------------------------------------------------

// import 'dart:async'; // For Timer
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';

// class PasswordDetailCard extends StatefulWidget {
//   final String serviceName;
//   final String username;
//   final String password;
//   final String? url;
//   final String creationDate;
//   final String serviceType;
//   final VoidCallback onEdit;
//   final VoidCallback onClose; // New callback for closing the detail view

//   const PasswordDetailCard({
//     Key? key,
//     required this.serviceName,
//     required this.username,
//     required this.password,
//     this.url,
//     required this.creationDate,
//     required this.serviceType,
//     required this.onEdit,
//     required this.onClose,
//   }) : super(key: key);

//   @override
//   State<PasswordDetailCard> createState() => _PasswordDetailCardState();
// }

// class _PasswordDetailCardState extends State<PasswordDetailCard> {
//   bool _isPasswordVisible = false;
//   Timer? _visibilityTimer;

//   @override
//   void dispose() {
//     _visibilityTimer?.cancel();
//     super.dispose();
//   }

//   void _togglePasswordVisibility() {
//     setState(() {
//       _isPasswordVisible = true;
//     });

//     // Start a timer to hide the password after 2.5 seconds
//     _visibilityTimer?.cancel(); // Cancel any existing timer
//     _visibilityTimer = Timer(const Duration(milliseconds: 2500), () {
//       setState(() {
//         _isPasswordVisible = false;
//       });
//     });
//   }

//   void _copyToClipboard(BuildContext context, String text, String label) {
//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     Clipboard.setData(ClipboardData(text: text));
//     snackbarProvider.showMessage('$label copied to clipboard!');
//   }

//   void _openUrl(BuildContext context) async {
//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     if (widget.url != null && widget.url!.isNotEmpty) {
//       final uri = Uri.tryParse(widget.url!);
//       if (uri != null && await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       } else {
//         snackbarProvider.showMessage('Invalid URL: ${widget.url}');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Helper method to build disabled TextFormFields
//     Widget _buildDisabledField(String label, String value, {bool isPassword = false, bool isUrl = false, bool copyable = false}) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: TextFormField(
//           initialValue: isPassword ? (_isPasswordVisible ? widget.password : '•' * 15) : value,
//           readOnly: true,
//           obscureText: isPassword && !_isPasswordVisible,
//           decoration: InputDecoration(
//             labelText: label,
//             suffixIcon: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (copyable)
//                   IconButton(
//                     onPressed: () => _copyToClipboard(context, value, label),
//                     icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
//                     tooltip: 'Copy $label',
//                   ),
//                 if (isPassword)
//                   IconButton(
//                     onPressed: _togglePasswordVisibility,
//                     icon: Icon(
//                       _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
//                       color: theme.colorScheme.primary,
//                     ),
//                     tooltip: _isPasswordVisible ? 'Hide Password' : 'Show Password',
//                   ),
//                 if (isUrl)
//                   IconButton(
//                     onPressed: widget.url!.isNotEmpty ? () => _openUrl(context) : null,
//                     icon: Icon(
//                       Icons.open_in_browser,
//                       color: widget.url!.isNotEmpty ? theme.colorScheme.primary : theme.disabledColor,
//                     ),
//                     tooltip: widget.url!.isNotEmpty ? 'Open URL' : 'No URL Available',
//                   ),
//               ],
//             ),
//           ),
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: isUrl && widget.url!.isNotEmpty ? theme.colorScheme.primary : null,
//           ),
//         ),
//       );
//     }

//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0), // Rounded corners for Material 3
//       ),
//       elevation: 6,
//       margin: const EdgeInsets.all(16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0), // Increased padding for better spacing
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Row with Service Name and Action Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   widget.serviceName,
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: widget.onEdit,
//                       icon: Icon(Icons.edit, color: theme.colorScheme.primary),
//                       tooltip: 'Edit',
//                     ),
//                     IconButton(
//                       onPressed: widget.onClose,
//                       icon: Icon(Icons.close, color: theme.colorScheme.error),
//                       tooltip: 'Close',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24.0),

//             // Username Field
//             _buildDisabledField('Username', widget.username, copyable: true),

//             // Password Field with Masking and Visibility Toggle
//             _buildDisabledField('Password', widget.password, isPassword: true, copyable: true),

//             // URL Field with Conditional Button
//             if (widget.url != null && widget.url!.isNotEmpty) _buildDisabledField('URL', widget.url!, isUrl: true),

//             const SizedBox(height: 24.0),

//             // Service Type and Creation Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Service Type: ${widget.serviceType}',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 Text(
//                   'Created: ${widget.creationDate}',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24.0),

//             // Action Buttons: Copy Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 // Copy Username
//                 ElevatedButton.icon(
//                   onPressed: () => _copyToClipboard(context, widget.username, 'Username'),
//                   icon: const Icon(Icons.copy),
//                   label: const Text('Copy Username'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.secondaryContainer,
//                     foregroundColor: theme.colorScheme.onSecondaryContainer,
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 // Copy Password
//                 ElevatedButton.icon(
//                   onPressed: () => _copyToClipboard(context, widget.password, 'Password'),
//                   icon: const Icon(Icons.copy),
//                   label: const Text('Copy Password'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.secondaryContainer,
//                     foregroundColor: theme.colorScheme.onSecondaryContainer,
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
