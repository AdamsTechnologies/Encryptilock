import 'package:passguard/backend/helpers/password_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComplexPasswordGeneratorDialog extends StatefulWidget {
  final void Function(String password)? onPasswordGenerated;

  const ComplexPasswordGeneratorDialog({Key? key, this.onPasswordGenerated})
      : super(key: key);

  @override
  State<ComplexPasswordGeneratorDialog> createState() =>
      _ComplexPasswordGeneratorDialogState();
}

class _ComplexPasswordGeneratorDialogState
    extends State<ComplexPasswordGeneratorDialog> {
  final _minLengthController = TextEditingController(text: '8');
  final _maxLengthController = TextEditingController(text: '16');
  final _excludeCharsController = TextEditingController();
  final _passwordController = TextEditingController();

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

  /// Show a SnackBar with the given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              decoration: InputDecoration(
                labelText: 'Minimum Length',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Maximum Length
            TextFormField(
              controller: _maxLengthController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Maximum Length',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Exclude Characters
            TextFormField(
              controller: _excludeCharsController,
              decoration: InputDecoration(
                labelText: 'Exclude Characters (Optional)',
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
                    decoration: InputDecoration(
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

// -----------------------------------------
// TODO try both options and pick the best!
// -----------------------------------------


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:passguard/backend/helpers/password_generator.dart';


// class SimplePasswordGeneratorDialog extends StatefulWidget {
//   const SimplePasswordGeneratorDialog({Key? key}) : super(key: key);

//   @override
//   State<SimplePasswordGeneratorDialog> createState() =>
//       _SimplePasswordGeneratorDialogState();
// }

// class _SimplePasswordGeneratorDialogState
//     extends State<SimplePasswordGeneratorDialog> {
//   final _minLengthController = TextEditingController(text: '8');
//   final _maxLengthController = TextEditingController(text: '16');
//   final _excludeCharsController = TextEditingController();
//   final _passwordController = TextEditingController();

//   /// Generate a password using PasswordFactory
//   void _generatePassword() {
//     try {
//       final minLength = int.tryParse(_minLengthController.text) ?? 0;
//       final maxLength = int.tryParse(_maxLengthController.text) ?? 0;

//       if (minLength <= 0 || maxLength <= 0 || minLength > maxLength) {
//         throw Exception('Invalid length parameters.');
//       }

//       final excludeChars = _excludeCharsController.text;

//       final generatedPassword = PasswordFactory.generatePassword(
//         minLength: minLength,
//         maxLength: maxLength,
//         excludeChars: excludeChars.isNotEmpty ? excludeChars : null,
//       );

//       setState(() {
//         _passwordController.text = generatedPassword;
//       });
//     } catch (e) {
//       _showSnackBar('Error: ${e.toString()}');
//     }
//   }

//   /// Display a SnackBar with an error message
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return AlertDialog(
//       title: const Text('Generate Password'),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Minimum Length
//             TextFormField(
//               controller: _minLengthController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Minimum Length',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Maximum Length
//             TextFormField(
//               controller: _maxLengthController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Maximum Length',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Exclude Characters
//             TextFormField(
//               controller: _excludeCharsController,
//               decoration: InputDecoration(
//                 labelText: 'Exclude Characters',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Generated Password Field
//             TextFormField(
//               controller: _passwordController,
//               readOnly: false,
//               decoration: InputDecoration(
//                 labelText: 'Generated Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Generate Button
//             ElevatedButton(
//               onPressed: _generatePassword,
//               child: const Text('Generate'),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(null), // Cancel
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () =>
//               Navigator.of(context).pop(_passwordController.text), // OK
//           child: const Text('OK'),
//         ),
//       ],
//     );
//   }
// }

// ------------------------------------
// TODO Compare NOVA o1-mini's suggested version!
// ------------------------------------


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:passguard/backend/helpers/password_generator.dart';

// class ComplexPasswordGeneratorDialog extends StatefulWidget {
//   final Function(String password) onPasswordGenerated;

//   const ComplexPasswordGeneratorDialog({
//     Key? key,
//     required this.onPasswordGenerated,
//   }) : super(key: key);

//   @override
//   _ComplexPasswordGeneratorDialogState createState() => _ComplexPasswordGeneratorDialogState();
// }

// class _ComplexPasswordGeneratorDialogState extends State<ComplexPasswordGeneratorDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _minLengthController = TextEditingController(text: '8');
//   final TextEditingController _maxLengthController = TextEditingController(text: '16');
//   final TextEditingController _excludeCharsController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _minLengthController.dispose();
//     _maxLengthController.dispose();
//     _excludeCharsController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _generatePassword() {
//     if (_formKey.currentState!.validate()) {
//       int minLength = int.parse(_minLengthController.text);
//       int maxLength = int.parse(_maxLengthController.text);
//       String excludedChars = _excludeCharsController.text;

//       String generatedPassword = PasswordFactory.generatePassword(
//         minLength: minLength,
//         maxLength: maxLength,
//         excludedChars: excludedChars,
//       );

//       setState(() {
//         _passwordController.text = generatedPassword;
//       });
//     }
//   }

//   void _copyPassword() {
//     Clipboard.setData(ClipboardData(text: _passwordController.text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Password copied to clipboard!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return AlertDialog(
//       title: const Text('Generate Password'),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Minimum Length
//               TextFormField(
//                 controller: _minLengthController,
//                 decoration: const InputDecoration(
//                   labelText: 'Minimum Length',
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter minimum length';
//                   }
//                   if (int.tryParse(value) == null || int.parse(value) <= 0) {
//                     return 'Enter a valid positive number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               // Maximum Length
//               TextFormField(
//                 controller: _maxLengthController,
//                 decoration: const InputDecoration(
//                   labelText: 'Maximum Length',
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter maximum length';
//                   }
//                   if (int.tryParse(value) == null || int.parse(value) <= 0) {
//                     return 'Enter a valid positive number';
//                   }
//                   if (int.parse(value) < int.parse(_minLengthController.text)) {
//                     return 'Maximum length must be >= minimum length';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               // Exclude Characters
//               TextFormField(
//                 controller: _excludeCharsController,
//                 decoration: const InputDecoration(
//                   labelText: 'Exclude Characters (optional)',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Generated Password
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _passwordController,
//                       decoration: const InputDecoration(
//                         labelText: 'Generated Password',
//                       ),
//                       readOnly: false,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.copy),
//                     color: theme.colorScheme.secondary,
//                     tooltip: 'Copy Password',
//                     onPressed: _copyPassword,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               // Generate Button
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: ElevatedButton.icon(
//                   onPressed: _generatePassword,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Generate'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         // Cancel Button
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text('Cancel'),
//         ),
//         // OK Button
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               String password = _passwordController.text;
//               if (password.length >= int.parse(_minLengthController.text) &&
//                   password.length <= int.parse(_maxLengthController.text)) {
//                 widget.onPasswordGenerated(password);
//                 Navigator.of(context).pop();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Password does not meet length requirements')),
//                 );
//               }
//             }
//           },
//           child: const Text('OK'),
//         ),
//       ],
//     );
//   }
// }
