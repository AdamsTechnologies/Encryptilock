// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

// import 'package:encryptilock/frontend/widgets/bottom_action_bar.dart';
// import 'package:encryptilock/frontend/providers/password_provider.dart';
// import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
// import 'package:encryptilock/frontend/providers/settings_provider.dart';
// import 'package:encryptilock/frontend/widgets/password_generator_dialog.dart';
// import 'package:encryptilock/backend/helpers/password_generator.dart'; // For PasswordFactory

// class PasswordCreationEditPage extends StatefulWidget {
//   final Map<String, dynamic>? existingRecord; // Null for creation mode
//   final VoidCallback? onCancel;
//   final void Function(String newId)? onSaveComplete;
//   final void Function(String deletedId)? onDeleteComplete;

//   const PasswordCreationEditPage({
//     Key? key,
//     this.existingRecord,
//     this.onCancel,
//     this.onSaveComplete,
//     this.onDeleteComplete,
//   }) : super(key: key);

//   @override
//   State<PasswordCreationEditPage> createState() => _PasswordCreationEditPageState();
// }

// class _PasswordCreationEditPageState extends State<PasswordCreationEditPage> {
//   final _formKey = GlobalKey<FormState>();

//   // Form field controllers
//   final TextEditingController _serviceNameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _serviceTypeController = TextEditingController();
//   final TextEditingController _urlController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//   final Set<String> _clearedFields = {};
//   final Map<String, String> _originalValues = {};
//   Timer? _hidePasswordTimer;
//   bool _passwordVisible = false;
//   bool _isActive = true;
//   bool _obscurePassword = true; // Controls password visibility
//   bool _isDecrypting = false; // Tracks if decryption is in progress

//   String? _decryptedPassword; // Stores the decrypted password securely
//   bool _passwordChanged = false; // Tracks if the password has been changed

//   bool get isEditMode => widget.existingRecord != null;

//   @override
//   void initState() {
//     super.initState();
//     if (isEditMode) {
//       // Initialize form fields with existing data
//       _serviceNameController.text = widget.existingRecord!['service'] ?? '';
//       _usernameController.text = widget.existingRecord!['username'] ?? '';
//       _serviceTypeController.text = widget.existingRecord!['servicetype'] ?? '';
//       _urlController.text = widget.existingRecord!['url'] ?? '';
//       _noteController.text = widget.existingRecord!['notes'] ?? '';
//       _isActive = widget.existingRecord!['isactive'] == 1;

//       // Decrypt the existing password
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _decryptExistingPassword();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _hidePasswordTimer?.cancel();
//     _decryptedPassword = null;
//     _passwordController.clear();

//     _serviceNameController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _serviceTypeController.dispose();
//     _urlController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   /// Decrypts the existing password in edit mode and prepares it for secure display.
//   ///
//   Future<void> _decryptExistingPassword() async {
//     final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//     final encryptedPassword = widget.existingRecord?['password'] ?? '';

//     setState(() => _isDecrypting = true);
//     try {
//       final decrypted = await passwordProvider.decryptPassword(encryptedPassword);
//       if (decrypted.isNotEmpty) {
//         setState(() {
//           _decryptedPassword = decrypted;
//           _passwordChanged = false;
//           if (!_passwordVisible) {
//             _passwordController.text = '••••••••••';
//           }
//         });
//       } else {
//         _showSnackBar('Failed to decrypt the password.');
//       }
//     } catch (e) {
//       _showSnackBar('Error decrypting password: $e');
//     } finally {
//       setState(() => _isDecrypting = false);
//     }
//   }

//   /// If "Auto-Generate & Fill" is OFF, open the password dialog.
//   /// Otherwise, generate a password directly using defaults or user-defined settings.
//   void _generatePassword() async {
//     final settings = Provider.of<SettingsProvider>(context, listen: false);

//     if (settings.autoGenerateAndFill) {
//       // 1) Determine min/max/exclude from settings if definePasswordGeneratorParams is true
//       int minLen = 8;
//       int maxLen = 16;
//       String? exclude;

//       if (settings.definePasswordGeneratorParams) {
//         minLen = settings.minLength;
//         maxLen = settings.maxLength;
//         exclude = settings.excludeChars.isNotEmpty ? settings.excludeChars : null;
//       }

//       // 2) Generate password
//       final generated = PasswordFactory.generatePassword(
//         minLength: minLen,
//         maxLength: maxLen,
//         excludeChars: exclude,
//       );

//       // 3) Fill in the password field
//       setState(() {
//         _decryptedPassword = generated;
//         _passwordController.text = generated;
//         _passwordChanged = true;
//       });
//     } else {
//       // Open the ComplexPasswordGeneratorDialog and wait for the generated password
//       final generatedPassword = await showDialog<String>(
//         context: context,
//         builder: (context) => const ComplexPasswordGeneratorDialog(),
//       );

//       // If a password was generated, populate the password fields
//       if (generatedPassword != null && generatedPassword.isNotEmpty) {
//         setState(() {
//           _decryptedPassword = generatedPassword;
//           _passwordController.text = generatedPassword;
//           _passwordChanged = true;
//         });
//       }
//     }
//   }

//   /// Toggles the visibility of the password field.
//   void _togglePasswordVisibility() {
//     final isCreateMode = _decryptedPassword == null && _passwordController.text.isNotEmpty;

//     if (_passwordVisible) {
//       // HIDE PASSWORD
//       setState(() {
//         _obscurePassword = true;
//         _passwordVisible = false;

//         // Only mask the field text if we’re showing decrypted content
//         if (!isCreateMode) {
//           _passwordController.text = '••••••••••';
//         }
//       });
//       _hidePasswordTimer?.cancel();
//     } else {
//       // SHOW PASSWORD
//       if (_decryptedPassword != null || isCreateMode) {
//         setState(() {
//           _obscurePassword = false;
//           _passwordVisible = true;

//           // Use decrypted password if available, else just use what's already typed
//           if (_decryptedPassword != null) {
//             _passwordController.text = _decryptedPassword!;
//           }
//         });

//         _hidePasswordTimer?.cancel();
//         _hidePasswordTimer = Timer(const Duration(seconds: 10), () {
//           setState(() {
//             _obscurePassword = true;
//             _passwordVisible = false;

//             if (!isCreateMode) {
//               _passwordController.text = '••••••••••';
//             }
//           });
//         });
//       } else {
//         _showSnackBar('Password not yet decrypted.');
//       }
//     }
//   }

//   /// Displays a SnackBar with the provided message.
//   void _showSnackBar(String message) {
//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     snackbarProvider.showMessage(message);
//   }

//   Future<void> _savePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);

//     String passwordToSave;
//     bool passwordChanged = _passwordChanged;

//     final maskedValue = '••••••••••';
//     final controllerText = _passwordController.text.trim();

//     // If the field still contains the masked value, we treat it as "not changed"
//     final isMasked = controllerText == maskedValue;

//     if (isEditMode) {
//       if (passwordChanged && _decryptedPassword != null) {
//         passwordToSave = _decryptedPassword!;
//       } else if (!isMasked && _decryptedPassword != controllerText) {
//         // User typed something new manually
//         passwordChanged = true;
//         passwordToSave = controllerText;
//       } else {
//         // No change, use existing encrypted password
//         passwordToSave = widget.existingRecord!['password'];
//       }
//     } else {
//       // In creation mode
//       passwordToSave = controllerText;
//     }

//     // Build the data map
//     final data = {
//       'id': widget.existingRecord?['id'],
//       'service': _serviceNameController.text,
//       'username': _usernameController.text,
//       'password': passwordToSave,
//       'servicetype': _serviceTypeController.text,
//       'url': _urlController.text,
//       'notes': _noteController.text,
//       'isactive': _isActive ? 1 : 0, // isactive stored as int
//     };

//     try {
//       String newOrUpdatedId;

//       if (isEditMode) {
//         snackbarProvider.showMessage("Updating password");
//         data['id'] = widget.existingRecord!['id'];
//         await passwordProvider.addOrUpdatePassword(
//           data,
//           passwordChanged: passwordChanged,
//         );
//         newOrUpdatedId = data['id'] as String;
//       } else {
//         snackbarProvider.showMessage("Creating password");
//         await passwordProvider.addOrUpdatePassword(
//           data,
//           passwordChanged: true, // Always encrypt on creation
//         );
//         newOrUpdatedId = passwordProvider.passwords.last['id'] as String;
//       }

//       widget.onSaveComplete?.call(newOrUpdatedId);
//       passwordProvider.selectPasswordId(newOrUpdatedId);

//       setState(() {
//         _decryptedPassword = null;
//         _passwordChanged = false;
//         _passwordController.clear();
//       });
//     } catch (e) {
//       snackbarProvider.showMessage("Error saving password: $e");
//     }
//   }

//   /// Handles the delete action. If "Do Not Ask Before Deleting" (skipDeleteConfirmation) is on,
//   /// it deletes immediately; otherwise shows the old confirmation dialog.
//   Future<void> _deletePassword() async {
//     if (!isEditMode) return;

//     final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
//     final record = widget.existingRecord!;
//     final passwordId = record['id'];

//     // If "skipDeleteConfirmation" is true, delete immediately
//     if (settingsProv.skipDeleteConfirmation) {
//       try {
//         final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//         await passwordProvider.deletePassword(passwordId);

//         _showSnackBar("Password deleted successfully");
//         widget.onDeleteComplete?.call(passwordId);
//       } catch (e) {
//         _showSnackBar("Error deleting password: $e");
//       }
//       return;
//     }

//     // Otherwise, show a dialog to confirm
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Password'),
//         content: Text('Are you sure you want to delete the password for "${record['service']}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       await passwordProvider.deletePassword(passwordId);

//       snackbarProvider.showMessage("Password deleted successfully");
//       widget.onDeleteComplete?.call(passwordId);
//     } catch (e) {
//       snackbarProvider.showMessage("Error deleting password: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0), // Rounded corners for Material 3
//       ),
//       elevation: 6,
//       margin: const EdgeInsets.all(16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0), // Outer padding
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//               child: FocusTraversalGroup(
//             child: Column(
//               children: [
//                 Text(
//                   isEditMode ? 'Edit Password' : 'Create Password',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20.0),
//                 FocusTraversalOrder(
//                   order: const NumericFocusOrder(1.0),
//                   child: Focus(
//                     onFocusChange: (hasFocus) {
//                       if (!hasFocus && isEditMode && _clearedFields.contains('serviceName') && _serviceNameController.text.trim().isEmpty) {
//                         _serviceNameController.text = _originalValues['serviceName'] ?? '';
//                       }
//                     },
//                     child: TextFormField(
//                       controller: _serviceNameController,
//                       onTap: () {
//                         if (isEditMode && !_clearedFields.contains('serviceName')) {
//                           _originalValues['serviceName'] = _serviceNameController.text;
//                           _serviceNameController.clear();
//                           _clearedFields.add('serviceName');
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Title',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 FocusTraversalOrder(
//                   order: const NumericFocusOrder(2.0),
//                   child: Focus(
//                     onFocusChange: (hasFocus) {
//                       if (!hasFocus && isEditMode && _clearedFields.contains('username') && _usernameController.text.trim().isEmpty) {
//                         _usernameController.text = _originalValues['username'] ?? '';
//                       }
//                     },
//                     child: TextFormField(
//                       controller: _usernameController,
//                       onTap: () {
//                         if (isEditMode && !_clearedFields.contains('username')) {
//                           _originalValues['username'] = _usernameController.text;
//                           _usernameController.clear();
//                           _clearedFields.add('username');
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Username',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 _isDecrypting
//                     ? Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 12.0),
//                         child: Row(
//                           children: [
//                             CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Theme.of(context).colorScheme.primary,
//                               ),
//                             ),
//                             const SizedBox(width: 16.0),
//                             const Text('Decrypting password...'),
//                           ],
//                         ),
//                       )
//                     : FocusTraversalOrder(
//                         order: const NumericFocusOrder(3.0),
//                         child: Focus(
//                           onFocusChange: (hasFocus) {
//                             if (!hasFocus && isEditMode && _clearedFields.contains('password') && _passwordController.text.trim().isEmpty) {
//                               _passwordController.text = _originalValues['password'] ?? '';
//                             }
//                           },
//                           child: TextFormField(
//                             controller: _passwordController,
//                             onTap: () {
//                               if (isEditMode && !_clearedFields.contains('password')) {
//                                 _originalValues['password'] = _passwordController.text;
//                                 _passwordController.clear();
//                                 _clearedFields.add('password');
//                               }
//                             },
//                             obscureText: _obscurePassword,
//                             decoration: InputDecoration(
//                               labelText: 'Password',
//                               border: const OutlineInputBorder(),
//                               suffixIcon: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     tooltip: _obscurePassword ? 'Show Password' : 'Hide Password',
//                                     icon: Icon(
//                                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                                       color: Theme.of(context).colorScheme.primary,
//                                     ),
//                                     onPressed: _togglePasswordVisibility,
//                                   ),
//                                   IconButton(
//                                     tooltip: 'Generate Password',
//                                     icon: Icon(Icons.vpn_key, color: Theme.of(context).colorScheme.primary),
//                                     onPressed: _generatePassword,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
//                           ),
//                         ),
//                       ),
//                 const SizedBox(height: 12.0),
//                 FocusTraversalOrder(
//                   order: const NumericFocusOrder(4.0),
//                   child: Focus(
//                     onFocusChange: (hasFocus) {
//                       if (!hasFocus && isEditMode && _clearedFields.contains('serviceType') && _serviceTypeController.text.trim().isEmpty) {
//                         _serviceTypeController.text = _originalValues['serviceType'] ?? '';
//                       }
//                     },
//                     child: TextFormField(
//                       controller: _serviceTypeController,
//                       onTap: () {
//                         if (isEditMode && !_clearedFields.contains('serviceType')) {
//                           _originalValues['serviceType'] = _serviceTypeController.text;
//                           _serviceTypeController.clear();
//                           _clearedFields.add('serviceType');
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Category',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 FocusTraversalOrder(
//                   order: const NumericFocusOrder(5.0),
//                   child: Focus(
//                     onFocusChange: (hasFocus) {
//                       if (!hasFocus && isEditMode && _clearedFields.contains('url') && _urlController.text.trim().isEmpty) {
//                         _urlController.text = _originalValues['url'] ?? '';
//                       }
//                     },
//                     child: TextFormField(
//                       controller: _urlController,
//                       onTap: () {
//                         if (isEditMode && !_clearedFields.contains('url')) {
//                           _originalValues['url'] = _urlController.text;
//                           _urlController.clear();
//                           _clearedFields.add('url');
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'URL',
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.url,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 FocusTraversalOrder(
//                   order: const NumericFocusOrder(6.0),
//                   child: Focus(
//                     onFocusChange: (hasFocus) {
//                       if (!hasFocus && isEditMode && _clearedFields.contains('note') && _noteController.text.trim().isEmpty) {
//                         _noteController.text = _originalValues['note'] ?? '';
//                       }
//                     },
//                     child: TextFormField(
//                       controller: _noteController,
//                       onTap: () {
//                         if (isEditMode && !_clearedFields.contains('note')) {
//                           _originalValues['note'] = _noteController.text;
//                           _noteController.clear();
//                           _clearedFields.add('note');
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Note',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLines: 3,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 SwitchListTile(
//                   value: _isActive,
//                   onChanged: (val) => setState(() => _isActive = val),
//                   title: const Text('Show Record'),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//                 const SizedBox(height: 20.0),
//                 BottomActionBar(
//                   isEditMode: isEditMode,
//                   showDeleteButton: isEditMode,
//                   onCancel: () {
//                     _hidePasswordTimer?.cancel();
//                     _passwordController.clear();
//                     _decryptedPassword = null;
//                     widget.onCancel?.call();
//                   },
//                   onDelete: _deletePassword,
//                   onSave: _savePassword,
//                   style: BottomActionBarStyle.iconOnly, // Or iconWithText
//                 ),
//                 const SizedBox(height: 8.0),
//               ],
//             ),
//           )),
//         ),
//       ),
//     );
//   }
// }
