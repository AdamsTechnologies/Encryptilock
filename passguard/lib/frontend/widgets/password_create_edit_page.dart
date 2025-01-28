import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:passguard/frontend/providers/password_provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';
import 'package:passguard/frontend/widgets/password_generator_dialog.dart'; // Ensure correct import path

class PasswordCreationEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingRecord; // Null for creation mode
  final VoidCallback? onCancel;
  final void Function(String newId)? onSaveComplete;
  final void Function(String deletedId)? onDeleteComplete;

  const PasswordCreationEditPage({
    Key? key,
    this.existingRecord,
    this.onCancel,
    this.onSaveComplete,
    this.onDeleteComplete,
  }) : super(key: key);

  @override
  State<PasswordCreationEditPage> createState() => _PasswordCreationEditPageState();
}

class _PasswordCreationEditPageState extends State<PasswordCreationEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isActive = true;
  bool _obscurePassword = true; // Controls password visibility
  bool _isDecrypting = false; // Tracks if decryption is in progress

  String? _decryptedPassword; // Stores the decrypted password securely

  bool get isEditMode => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Initialize form fields with existing data
      _serviceNameController.text = widget.existingRecord!['service'] ?? '';
      _usernameController.text = widget.existingRecord!['username'] ?? '';
      _serviceTypeController.text = widget.existingRecord!['servicetype'] ?? '';
      _urlController.text = widget.existingRecord!['url'] ?? '';
      _noteController.text = widget.existingRecord!['notes'] ?? '';
      _isActive = widget.existingRecord!['isactive'] == 1;

      // Decrypt the existing password
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _decryptExistingPassword();
      });
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _serviceTypeController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Decrypts the existing password in edit mode and prepares it for secure display.
  Future<void> _decryptExistingPassword() async {
    final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    final encryptedPassword = widget.existingRecord!['password'] ?? '';

    setState(() {
      _isDecrypting = true;
    });

    try {
      final decryptedPassword = await passwordProvider.decryptPassword(encryptedPassword);

      if (decryptedPassword.isNotEmpty) {
        setState(() {
          _decryptedPassword = decryptedPassword;
          _passwordController.text = '•••••••••'; // Fixed masking
        });
      } else {
        _showSnackBar('Failed to decrypt the password.');
      }
    } catch (e) {
      _showSnackBar('Error decrypting password: $e');
    } finally {
      setState(() {
        _isDecrypting = false;
      });
    }
  }

  /// Opens the Password Generator Dialog and populates the password fields with the generated password.
  void _generatePassword() async {
    // Open the ComplexPasswordGeneratorDialog and wait for the generated password
    final generatedPassword = await showDialog<String>(
      context: context,
      builder: (context) => const ComplexPasswordGeneratorDialog(),
    );

    // If a password was generated, populate the password fields
    if (generatedPassword != null && generatedPassword.isNotEmpty) {
      setState(() {
        _decryptedPassword = generatedPassword;
        _passwordController.text = '•••••••••'; // Fixed masking
      });
    }
  }

  /// Toggles the visibility of the password field.
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
      if (!_obscurePassword && _decryptedPassword != null) {
        _passwordController.text = _decryptedPassword!;
      } else if (_obscurePassword && _decryptedPassword != null) {
        _passwordController.text = '•••••••••'; // Fixed masking
      }
    });
  }

  /// Displays a SnackBar with the provided message.
  void _showSnackBar(String message) {
    final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
    snackbarProvider.showMessage(message);
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Build the data map
    final data = {
      'service': _serviceNameController.text,
      'username': _usernameController.text,
      'password': _decryptedPassword ?? _passwordController.text,
      'servicetype': _serviceTypeController.text,
      'url': _urlController.text,
      'notes': _noteController.text,
      'isactive': _isActive ? 1 : 0, // Assuming isactive is stored as integer
    };

    final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      String newOrUpdatedId;
      if (isEditMode) {
        snackbarProvider.showMessage("Updating password");
        data['id'] = widget.existingRecord!['id'];
        await passwordProvider.addOrUpdatePassword(data);
        newOrUpdatedId = data['id'] as String;
      } else {
        // Creation
        snackbarProvider.showMessage("Creating password");
        await passwordProvider.addOrUpdatePassword(data);
        // Assuming the new ID is generated and the last password in the list is the new one
        newOrUpdatedId = passwordProvider.passwords.last['id'] as String;
      }

      // Call the onSaveComplete callback if provided
      widget.onSaveComplete?.call(newOrUpdatedId);

      // Optionally, clear the decrypted password from memory
      setState(() {
        _decryptedPassword = null;
      });
    } catch (e) {
      snackbarProvider.showMessage("Error saving password: $e");
    }
  }

  Future<void> _deletePassword() async {
    if (!isEditMode) return;
    final record = widget.existingRecord!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text('Are you sure you want to delete the password for "${record['service']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      await passwordProvider.deletePassword(record['id']);

      snackbarProvider.showMessage("Password deleted successfully");

      // Call the onDeleteComplete callback if provided
      widget.onDeleteComplete?.call(record['id']);
    } catch (e) {
      snackbarProvider.showMessage("Error deleting password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for Material 3
      ),
      elevation: 6,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Reduced padding for smaller vertical spacing
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Text(
                  isEditMode ? 'Edit Password' : 'Create Password',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0), // Reduced spacing

                // Service Name
                TextFormField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
                ),
                const SizedBox(height: 12.0), // Reduced spacing

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 12.0), // Reduced spacing

                // Password
                _isDecrypting
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 16.0),
                            const Text('Decrypting password...'),
                          ],
                        ),
                      )
                    : TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Show/Hide Password Icon
                              IconButton(
                                tooltip: _obscurePassword ? 'Show Password' : 'Hide Password',
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              // Generate Password Icon
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
                const SizedBox(height: 12.0), // Reduced spacing

                // Service Type
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0), // Reduced spacing

                // URL
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12.0), // Reduced spacing

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12.0), // Reduced spacing

                // Active Switch
                SwitchListTile(
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  title: const Text('Active'),
                  contentPadding: EdgeInsets.zero, // Removes default padding for better alignment
                ),
                const SizedBox(height: 20.0), // Reduced spacing

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        widget.onCancel?.call();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16.0),

                    // Save/Update Button
                    ElevatedButton(
                      onPressed: _savePassword,
                      child: Text(isEditMode ? 'Update' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      ),
                    ),

                    if (isEditMode) ...[
                      const SizedBox(width: 16.0),
                      // Delete Button
                      ElevatedButton.icon(
                        onPressed: _deletePassword,
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Red color for delete action
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------------------------- ^ NEWER
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------- V OLDER

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';

// import 'package:passguard/frontend/providers/password_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/widgets/password_generator_dialog.dart'; // Ensure correct import path

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

//   bool _isActive = true;
//   bool _obscurePassword = true; // Controls password visibility
//   bool _isDecrypting = false; // Tracks if decryption is in progress

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
//     _serviceNameController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _serviceTypeController.dispose();
//     _urlController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   /// Decrypts the existing password in edit mode and populates the password field.
//   Future<void> _decryptExistingPassword() async {
//     final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//     final encryptedPassword = widget.existingRecord!['password'] ?? '';

//     setState(() {
//       _isDecrypting = true;
//     });

//     try {
//       final decryptedPassword = await passwordProvider.decryptPassword(encryptedPassword);

//       if (decryptedPassword.isNotEmpty) {
//         setState(() {
//           _passwordController.text = decryptedPassword;
//         });
//       } else {
//         _showSnackBar('Failed to decrypt the password.');
//       }
//     } catch (e) {
//       _showSnackBar('Error decrypting password: $e');
//     } finally {
//       setState(() {
//         _isDecrypting = false;
//       });
//     }
//   }

//   /// Opens the Password Generator Dialog and populates the password fields with the generated password.
//   void _generatePassword() async {
//     // Open the ComplexPasswordGeneratorDialog and wait for the generated password
//     final generatedPassword = await showDialog<String>(
//       context: context,
//       builder: (context) => const ComplexPasswordGeneratorDialog(),
//     );

//     // If a password was generated, populate the password fields
//     if (generatedPassword != null && generatedPassword.isNotEmpty) {
//       setState(() {
//         _passwordController.text = generatedPassword;
//       });
//     }
//   }

//   /// Toggles the visibility of the password field.
//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscurePassword = !_obscurePassword;
//     });
//   }

//   /// Displays a SnackBar with the provided message.
//   void _showSnackBar(String message) {
//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     snackbarProvider.showMessage(message);
//   }

//   Future<void> _savePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Build the data map
//     final data = {
//       'service': _serviceNameController.text,
//       'username': _usernameController.text,
//       'password': _passwordController.text,
//       'servicetype': _serviceTypeController.text,
//       'url': _urlController.text,
//       'notes': _noteController.text,
//       'isactive': _isActive ? 1 : 0, // Assuming isactive is stored as integer
//     };

//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       String newOrUpdatedId;
//       if (isEditMode) {
//         snackbarProvider.showMessage("Updating password");
//         data['id'] = widget.existingRecord!['id'];
//         await passwordProvider.addOrUpdatePassword(data);
//         newOrUpdatedId = data['id'] as String;
//       } else {
//         // Creation
//         snackbarProvider.showMessage("Creating password");
//         await passwordProvider.addOrUpdatePassword(data);
//         // Assuming the new ID is generated and the last password in the list is the new one
//         newOrUpdatedId = passwordProvider.passwords.last['id'] as String;
//       }

//       // Call the onSaveComplete callback if provided
//       widget.onSaveComplete?.call(newOrUpdatedId);
//     } catch (e) {
//       snackbarProvider.showMessage("Error saving password: $e");
//     }
//   }

//   Future<void> _deletePassword() async {
//     if (!isEditMode) return;
//     final record = widget.existingRecord!;
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
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;

//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       await passwordProvider.deletePassword(record['id']);

//       snackbarProvider.showMessage("Password deleted successfully");

//       // Call the onDeleteComplete callback if provided
//       widget.onDeleteComplete?.call(record['id']);
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
//         padding: const EdgeInsets.all(20.0), // Reduced padding for smaller vertical spacing
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header
//                 Text(
//                   isEditMode ? 'Edit Password' : 'Create Password',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20.0), // Reduced spacing

//                 // Service Name
//                 TextFormField(
//                   controller: _serviceNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Service Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Username
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Password
//                 _isDecrypting
//                     ? Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 12.0),
//                         child: Row(
//                           children: [
//                             CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
//                             ),
//                             const SizedBox(width: 16.0),
//                             const Text('Decrypting password...'),
//                           ],
//                         ),
//                       )
//                     : TextFormField(
//                         controller: _passwordController,
//                         obscureText: _obscurePassword,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           border: OutlineInputBorder(),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 tooltip: 'Generate Password',
//                                 icon: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
//                                 onPressed: _generatePassword,
//                               ),
//                               IconButton(
//                                 tooltip: _obscurePassword ? 'Show Password' : 'Hide Password',
//                                 icon: Icon(
//                                   _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                                   color: theme.colorScheme.primary,
//                                 ),
//                                 onPressed: _togglePasswordVisibility,
//                               ),
//                             ],
//                           ),
//                         ),
//                         validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
//                       ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Service Type
//                 TextFormField(
//                   controller: _serviceTypeController,
//                   decoration: const InputDecoration(
//                     labelText: 'Service Type',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // URL
//                 TextFormField(
//                   controller: _urlController,
//                   decoration: const InputDecoration(
//                     labelText: 'URL',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.url,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Note
//                 TextFormField(
//                   controller: _noteController,
//                   decoration: const InputDecoration(
//                     labelText: 'Note',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Active Switch
//                 SwitchListTile(
//                   value: _isActive,
//                   onChanged: (val) => setState(() => _isActive = val),
//                   title: const Text('Active'),
//                   contentPadding: EdgeInsets.zero, // Removes default padding for better alignment
//                 ),
//                 const SizedBox(height: 20.0), // Reduced spacing

//                 // Action Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Cancel Button
//                     TextButton(
//                       onPressed: () {
//                         widget.onCancel?.call();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     const SizedBox(width: 16.0),

//                     // Save/Update Button
//                     ElevatedButton(
//                       onPressed: _savePassword,
//                       child: Text(isEditMode ? 'Update' : 'Save'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                       ),
//                     ),

//                     if (isEditMode) ...[
//                       const SizedBox(width: 16.0),
//                       // Delete Button
//                       ElevatedButton.icon(
//                         onPressed: _deletePassword,
//                         icon: const Icon(Icons.delete, color: Colors.white),
//                         label: const Text(
//                           'Delete',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red, // Red color for delete action
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// -------------------------------------------------------------------------------------------- ^ NEWER
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------- V OLDER

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';

// import 'package:passguard/frontend/providers/password_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/widgets/password_generator_dialog.dart'; // Ensure correct import path

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

//   bool _isActive = true;
//   bool _obscurePassword = true; // Controls password visibility

//   bool get isEditMode => widget.existingRecord != null;

//   @override
//   void initState() {
//     super.initState();
//     if (isEditMode) {
//       _serviceNameController.text = widget.existingRecord!['service'] ?? '';
//       _usernameController.text = widget.existingRecord!['username'] ?? '';
//       _passwordController.text = widget.existingRecord!['password'] ?? '';
//       _serviceTypeController.text = widget.existingRecord!['servicetype'] ?? '';
//       _urlController.text = widget.existingRecord!['url'] ?? '';
//       _noteController.text = widget.existingRecord!['notes'] ?? '';
//       _isActive = widget.existingRecord!['isactive'] == 1;
//     }
//   }

//   @override
//   void dispose() {
//     _serviceNameController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _serviceTypeController.dispose();
//     _urlController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   /// Opens the Password Generator Dialog and populates the password fields with the generated password.
//   void _generatePassword() async {
//     // Open the ComplexPasswordGeneratorDialog and wait for the generated password
//     final generatedPassword = await showDialog<String>(
//       context: context,
//       builder: (context) => const ComplexPasswordGeneratorDialog(),
//     );

//     // If a password was generated, populate the password fields
//     if (generatedPassword != null && generatedPassword.isNotEmpty) {
//       setState(() {
//         _passwordController.text = generatedPassword;
//       });
//     }
//   }

//   /// Toggles the visibility of the password field.
//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscurePassword = !_obscurePassword;
//     });
//   }

//   Future<void> _savePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Build the data map
//     final data = {
//       'service': _serviceNameController.text,
//       'username': _usernameController.text,
//       'password': _passwordController.text,
//       'servicetype': _serviceTypeController.text,
//       'url': _urlController.text,
//       'notes': _noteController.text,
//       'isactive': _isActive ? 1 : 0, // Assuming isactive is stored as integer
//     };

//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       String newOrUpdatedId;
//       if (isEditMode) {
//         snackbarProvider.showMessage("Updating password");
//         data['id'] = widget.existingRecord!['id'];
//         await passwordProvider.addOrUpdatePassword(data);
//         newOrUpdatedId = data['id'] as String;
//       } else {
//         // Creation
//         snackbarProvider.showMessage("Creating password");
//         await passwordProvider.addOrUpdatePassword(data);
//         // Assuming the new ID is generated and the last password in the list is the new one
//         newOrUpdatedId = passwordProvider.passwords.last['id'] as String;
//       }

//       // Call the onSaveComplete callback if provided
//       widget.onSaveComplete?.call(newOrUpdatedId);
//     } catch (e) {
//       snackbarProvider.showMessage("Error saving password: $e");
//     }
//   }

//   Future<void> _deletePassword() async {
//     if (!isEditMode) return;
//     final record = widget.existingRecord!;
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
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;

//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       await passwordProvider.deletePassword(record['id']);

//       snackbarProvider.showMessage("Password deleted successfully");

//       // Call the onDeleteComplete callback if provided
//       widget.onDeleteComplete?.call(record['id']);
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
//         padding: const EdgeInsets.all(20.0), // Reduced padding for smaller vertical spacing
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header
//                 Text(
//                   isEditMode ? 'Edit Password' : 'Create Password',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20.0), // Reduced spacing

//                 // Service Name
//                 TextFormField(
//                   controller: _serviceNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Service Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Username
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Password
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           tooltip: 'Generate Password',
//                           icon: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
//                           onPressed: _generatePassword,
//                         ),
//                         // Show/Hide Password Icon
//                         IconButton(
//                           tooltip: _obscurePassword ? 'Show Password' : 'Hide Password',
//                           icon: Icon(
//                             _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                             color: theme.colorScheme.primary,
//                           ),
//                           onPressed: _togglePasswordVisibility,
//                         ),
//                         // Generate Password Icon
//                       ],
//                     ),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 if (!isEditMode) ...[
//                   // Note: Removed Confirm Password Field
//                   // If you decide to keep it in some scenarios, adjust accordingly.
//                 ],

//                 // Service Type
//                 TextFormField(
//                   controller: _serviceTypeController,
//                   decoration: const InputDecoration(
//                     labelText: 'Service Type',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // URL
//                 TextFormField(
//                   controller: _urlController,
//                   decoration: const InputDecoration(
//                     labelText: 'URL',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.url,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Note
//                 TextFormField(
//                   controller: _noteController,
//                   decoration: const InputDecoration(
//                     labelText: 'Note',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 2,
//                 ),
//                 const SizedBox(height: 12.0), // Reduced spacing

//                 // Active Switch
//                 SwitchListTile(
//                   value: _isActive,
//                   onChanged: (val) => setState(() => _isActive = val),
//                   title: const Text('Active'),
//                   contentPadding: EdgeInsets.zero, // Removes default padding for better alignment
//                 ),
//                 const SizedBox(height: 20.0), // Reduced spacing

//                 // Action Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Cancel Button
//                     TextButton(
//                       onPressed: () {
//                         widget.onCancel?.call();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     const SizedBox(width: 16.0),

//                     // Save/Update Button
//                     ElevatedButton(
//                       onPressed: _savePassword,
//                       child: Text(isEditMode ? 'Update' : 'Save'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                       ),
//                     ),

//                     if (isEditMode) ...[
//                       const SizedBox(width: 16.0),
//                       // Delete Button
//                       ElevatedButton.icon(
//                         onPressed: _deletePassword,
//                         icon: const Icon(Icons.delete, color: Colors.white),
//                         label: const Text(
//                           'Delete',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red, // Red color for delete action
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// -------------------------------------------------------------------------------------------- ^ NEWER
// -------------------------------------------------------------------------------------------- V OLDER
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/providers/password_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';

// import 'package:passguard/frontend/widgets/password_generator_dialog.dart';

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
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   final TextEditingController _serviceTypeController = TextEditingController();
//   final TextEditingController _urlController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   bool _isActive = true;

//   bool get isEditMode => widget.existingRecord != null;

//   @override
//   void initState() {
//     super.initState();
//     if (isEditMode) {
//       _serviceNameController.text = widget.existingRecord!['service'] ?? '';
//       _usernameController.text = widget.existingRecord!['username'] ?? '';
//       _passwordController.text = widget.existingRecord!['password'] ?? '';
//       _serviceTypeController.text = widget.existingRecord!['servicetype'] ?? '';
//       _urlController.text = widget.existingRecord!['url'] ?? '';
//       _noteController.text = widget.existingRecord!['notes'] ?? '';
//       _isActive = widget.existingRecord!['isactive'] == 1;
//     }
//   }

//   @override
//   void dispose() {
//     _serviceNameController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _serviceTypeController.dispose();
//     _urlController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   void _generatePassword() {
//     const generatedPassword = "StrongGeneratedPassword123!";
//     setState(() {
//       _passwordController.text = generatedPassword;
//       _confirmPasswordController.text = generatedPassword;
//     });
//   }

//   Future<void> _savePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Build the data map
//     final data = {
//       'service': _serviceNameController.text,
//       'username': _usernameController.text,
//       'password': _passwordController.text,
//       'servicetype': _serviceTypeController.text,
//       'url': _urlController.text,
//       'notes': _noteController.text,
//       'isactive': _isActive ? true : false,
//     };

//     final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       String newOrUpdatedId;
//       if (isEditMode) {
//         snackbarProvider.showMessage("Updating password");
//         print("updating password ${data}");
//         data['id'] = widget.existingRecord!['id'];
//         await passwordProvider.addOrUpdatePassword(data);
//         newOrUpdatedId = (data['id']) as String;
//       } else {
//         // Creation
//         snackbarProvider.showMessage("Creating password");
//         print("Creating new password $data");
//         await passwordProvider.addOrUpdatePassword(data);
//         // Assuming the new ID is generated and the last password in the list is the new one
//         newOrUpdatedId = passwordProvider.passwords.last['id'];
//       }

//       // Call the onSaveComplete callback if provided
//       widget.onSaveComplete?.call(newOrUpdatedId);
//     } catch (e) {
//       snackbarProvider.showMessage("Error");
//     }
//   }

//   Future<void> _deletePassword() async {
//     if (!isEditMode) return;
//     final record = widget.existingRecord!;
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
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;

//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//       await passwordProvider.deletePassword(record['id']);

//       // Call the onDeleteComplete callback if provided
//       widget.onDeleteComplete?.call(record['id']);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting password: $e')),
//       );
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
//         padding: const EdgeInsets.all(24.0), // Increased padding for better spacing
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header
//                 Text(
//                   isEditMode ? 'Edit Password' : 'Create Password',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     // TODO See if we want titleLarge.
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 24.0),

//                 // Service Name
//                 TextFormField(
//                   controller: _serviceNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Service Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
//                 ),
//                 const SizedBox(height: 16.0),

//                 // Username
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
//                 ),
//                 const SizedBox(height: 16.0),

//                 // Password
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.refresh),
//                       onPressed: _generatePassword,
//                       tooltip: 'Generate Password',
//                     ),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
//                 ),
//                 if (!isEditMode) ...[
//                   const SizedBox(height: 16.0),
//                   // Confirm Password
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Confirm Password',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
//                   ),
//                 ],
//                 const SizedBox(height: 16.0),

//                 // Service Type
//                 TextFormField(
//                   controller: _serviceTypeController,
//                   decoration: const InputDecoration(
//                     labelText: 'Service Type',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),

//                 // URL
//                 TextFormField(
//                   controller: _urlController,
//                   decoration: const InputDecoration(
//                     labelText: 'URL',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.url,
//                 ),
//                 const SizedBox(height: 16.0),

//                 // Note
//                 TextFormField(
//                   controller: _noteController,
//                   decoration: const InputDecoration(
//                     labelText: 'Note',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 16.0),

//                 // Active Switch
//                 SwitchListTile(
//                   value: _isActive,
//                   onChanged: (val) => setState(() => _isActive = val),
//                   title: const Text('Active'),
//                 ),
//                 const SizedBox(height: 24.0),

//                 // Action Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Cancel Button
//                     TextButton(
//                       onPressed: () {
//                         widget.onCancel?.call();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     const SizedBox(width: 16.0),

//                     // Save/Update Button
//                     ElevatedButton(
//                       onPressed: _savePassword,
//                       child: Text(isEditMode ? 'Update' : 'Save'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                       ),
//                     ),

//                     if (isEditMode) ...[
//                       const SizedBox(width: 16.0),
//                       // Delete Button
//                       ElevatedButton.icon(
//                         onPressed: _deletePassword,
//                         icon: const Icon(Icons.delete, color: Colors.white),
//                         label: const Text('Delete'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red, // Red color for delete action
//                           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
