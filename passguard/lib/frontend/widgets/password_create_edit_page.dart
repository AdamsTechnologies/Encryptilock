import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/password_provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isActive = true;

  bool get isEditMode => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _serviceNameController.text = widget.existingRecord!['service'] ?? '';
      _usernameController.text = widget.existingRecord!['username'] ?? '';
      _passwordController.text = widget.existingRecord!['password'] ?? '';
      _serviceTypeController.text = widget.existingRecord!['servicetype'] ?? '';
      _urlController.text = widget.existingRecord!['url'] ?? '';
      _noteController.text = widget.existingRecord!['notes'] ?? '';
      _isActive = widget.existingRecord!['isactive'] == 1;
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _serviceTypeController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    const generatedPassword = "StrongGeneratedPassword123!";
    setState(() {
      _passwordController.text = generatedPassword;
      _confirmPasswordController.text = generatedPassword;
    });
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Build the data map
    final data = {
      'service': _serviceNameController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'servicetype': _serviceTypeController.text,
      'url': _urlController.text,
      'notes': _noteController.text,
      'isactive': _isActive ? true : false,
    };

    final snackbarProvider = Provider.of<SnackBarProvider>(context, listen: false);
    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      String newOrUpdatedId;
      if (isEditMode) {
        snackbarProvider.showMessage("Updating password");
        print("updating password ${data}");
        data['id'] = widget.existingRecord!['id'];
        await passwordProvider.addOrUpdatePassword(data);
        newOrUpdatedId = (data['id']) as String;
      } else {
        // Creation
        snackbarProvider.showMessage("Creating password");
        print("Creating new password $data");
        await passwordProvider.addOrUpdatePassword(data);
        // Assuming the new ID is generated and the last password in the list is the new one
        newOrUpdatedId = passwordProvider.passwords.last['id'];
      }

      // Call the onSaveComplete callback if provided
      widget.onSaveComplete?.call(newOrUpdatedId);
    } catch (e) {
      snackbarProvider.showMessage("Error");
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

    try {
      final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
      await passwordProvider.deletePassword(record['id']);

      // Call the onDeleteComplete callback if provided
      widget.onDeleteComplete?.call(record['id']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting password: $e')),
      );
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
        padding: const EdgeInsets.all(24.0), // Increased padding for better spacing
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Text(
                  isEditMode ? 'Edit Password' : 'Create Password',
                  style: theme.textTheme.titleLarge?.copyWith(
                    // TODO See if we want titleLarge.
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Service Name
                TextFormField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
                ),
                const SizedBox(height: 16.0),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16.0),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _generatePassword,
                      tooltip: 'Generate Password',
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                ),
                if (!isEditMode) ...[
                  const SizedBox(height: 16.0),
                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                ],
                const SizedBox(height: 16.0),

                // Service Type
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: const InputDecoration(labelText: 'Service Type'),
                ),
                const SizedBox(height: 16.0),

                // URL
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16.0),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),

                // Active Switch
                SwitchListTile(
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  title: const Text('Active'),
                ),
                const SizedBox(height: 24.0),

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
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Red color for delete action
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



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // For PasswordProvider
// import 'package:passguard/frontend/providers/password_provider.dart'; // For PasswordProvider
// // import 'package:flutter/services.dart';

// class PasswordCreationEditPage extends StatefulWidget {
//   final Map<String, dynamic>? existingRecord; // Null => creation mode

//   // Callbacks (optional)
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
//       final _isActiveInt = widget.existingRecord!['isactive'] ?? 1; // default 1 = active
//       _isActive = (_isActiveInt == 1);
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
//       'isactive': _isActive,
//     };

//     try {
//       final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);

//       String newOrUpdatedId;
//       if (isEditMode) {
//         data['id'] = widget.existingRecord!['id'];
//         await passwordProvider.addOrUpdatePassword(data);
//         newOrUpdatedId = (data['id']) as String;
//       } else {
//         // creation
//         await passwordProvider.addOrUpdatePassword(data);
//         // after creation, you can find the new record's ID if needed
//         // but since your logic automatically sets it, we could fetch from provider.
//         // For now, we’ll pretend the ID is set after insertion:
//         newOrUpdatedId = (data['id'] ?? "some-auto-gen-id") as String;
//       }

//       // If parent provided onSaveComplete, call it
//       if (widget.onSaveComplete != null) {
//         widget.onSaveComplete!(newOrUpdatedId);
//       }
//       // else do nothing or revert to a default state
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving password: $e')),
//       );
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

//       // If parent has onDeleteComplete, call it
//       if (widget.onDeleteComplete != null) {
//         widget.onDeleteComplete!(record['id']);
//       }
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
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Text(
//                   isEditMode ? 'Edit Password' : 'Create Password',
//                   style: theme.textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),
//                 // Service name
//                 TextFormField(
//                   controller: _serviceNameController,
//                   decoration: const InputDecoration(labelText: 'Service Name'),
//                   validator: (value) => value == null || value.isEmpty ? 'Service name is required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 // Username
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(labelText: 'Username'),
//                   validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 // Password
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.refresh),
//                       onPressed: _generatePassword,
//                     ),
//                   ),
//                   validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
//                 ),
//                 if (!isEditMode) ...[
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(labelText: 'Confirm Password'),
//                     validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 // Service type
//                 TextFormField(
//                   controller: _serviceTypeController,
//                   decoration: const InputDecoration(labelText: 'Service Type'),
//                 ),
//                 const SizedBox(height: 16),
//                 // URL
//                 TextFormField(
//                   controller: _urlController,
//                   decoration: const InputDecoration(labelText: 'URL'),
//                 ),
//                 const SizedBox(height: 16),
//                 // Notes
//                 TextFormField(
//                   controller: _noteController,
//                   decoration: const InputDecoration(labelText: 'Note'),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 16),
//                 // Active switch
//                 SwitchListTile(
//                   value: _isActive,
//                   onChanged: (val) => setState(() => _isActive = val),
//                   title: const Text('Active'),
//                 ),
//                 const SizedBox(height: 16),

//                 // Row of Buttons: Save, Cancel, and (if edit mode) Delete
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Cancel
//                     TextButton(
//                       onPressed: () {
//                         if (widget.onCancel != null) {
//                           widget.onCancel!();
//                         }
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     const SizedBox(width: 8),
//                     // Save
//                     ElevatedButton(
//                       onPressed: _savePassword,
//                       child: Text(isEditMode ? 'Update' : 'Save'),
//                     ),
//                     if (isEditMode) ...[
//                       const SizedBox(width: 16),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         tooltip: 'Delete',
//                         onPressed: _deletePassword,
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

// -------------------------------------------------------------------------
// -------------------------------------------------------------------OLDER


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // For PasswordProvider
// import 'package:passguard/frontend/providers/password_provider.dart'; // For PasswordProvider
// // import 'package:flutter/services.dart';

// class PasswordCreationEditPage extends StatefulWidget {
//   final Map<String, dynamic>? existingRecord; // Null for creation mode

//   const PasswordCreationEditPage({Key? key, this.existingRecord}) : super(key: key);

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

//   @override
//   void initState() {
//     super.initState();

//     if (widget.existingRecord != null) {
//       // Pre-fill fields for edit mode
//       _serviceNameController.text = widget.existingRecord!['serviceName'] ?? '';
//       _usernameController.text = widget.existingRecord!['username'] ?? '';
//       _passwordController.text = widget.existingRecord!['password'] ?? '';
//       _serviceTypeController.text = widget.existingRecord!['serviceType'] ?? '';
//       _urlController.text = widget.existingRecord!['url'] ?? '';
//       _noteController.text = widget.existingRecord!['note'] ?? '';
//       _isActive = widget.existingRecord!['isActive'] ?? true;
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
//     final generatedPassword = "StrongGeneratedPassword123!"; // Example
//     setState(() {
//       _passwordController.text = generatedPassword;
//       _confirmPasswordController.text = generatedPassword;
//     });
//   }

//   Future<void> _savePassword() async {
//     if (_formKey.currentState!.validate()) {
//       final data = {
//         'service': _serviceNameController.text,
//         'username': _usernameController.text,
//         'password': _passwordController.text,
//         'servicetype': _serviceTypeController.text,
//         'url': _urlController.text,
//         'notes': _noteController.text,
//         'isactive': _isActive,
//       };

//       try {
//         final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//         if (widget.existingRecord == null) {
//           await passwordProvider.addOrUpdatePassword(data);
//         } else {
//           data['id'] = widget.existingRecord!['id'];
//           await passwordProvider.addOrUpdatePassword(data);
//         }
//         Navigator.pop(context); // Navigate back on success
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving password: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _deletePassword() async {
//     if (widget.existingRecord != null) {
//       final confirmed = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Delete Password'),
//           content: Text('Are you sure you want to delete the password for "${widget.existingRecord!['serviceName']}"?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: Text('Delete'),
//             ),
//           ],
//         ),
//       );
//       if (confirmed == true) {
//         try {
//           final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
//           await passwordProvider.deletePassword(widget.existingRecord!['id']);
//           Navigator.pop(context); // Navigate back on success
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error deleting password: $e')),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.existingRecord == null ? 'Create Password' : 'Edit Password'),
//         actions: widget.existingRecord != null
//             ? [
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: _deletePassword,
//                 )
//               ]
//             : null,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: _serviceNameController,
//                   decoration: InputDecoration(labelText: 'Service Name'),
//                   validator: (value) => value!.isEmpty ? 'Service name is required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(labelText: 'Username'),
//                   validator: (value) => value!.isEmpty ? 'Username is required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.refresh),
//                       onPressed: _generatePassword,
//                     ),
//                   ),
//                   obscureText: true,
//                   validator: (value) => value!.isEmpty ? 'Password is required' : null,
//                 ),
//                 if (widget.existingRecord == null) ...[
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     decoration: InputDecoration(labelText: 'Confirm Password'),
//                     obscureText: true,
//                     validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _serviceTypeController,
//                   decoration: InputDecoration(labelText: 'Service Type'),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _urlController,
//                   decoration: InputDecoration(labelText: 'URL'),
//                   keyboardType: TextInputType.url,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _noteController,
//                   decoration: InputDecoration(labelText: 'Note'),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 16),
//                 SwitchListTile(
//                   value: _isActive,
//                   onChanged: (value) => setState(() => _isActive = value),
//                   title: Text('Active'),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _savePassword,
//                   child: Text(widget.existingRecord == null ? 'Save' : 'Update'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
