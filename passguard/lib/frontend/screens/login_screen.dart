import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/backend/devsec/deterministic_hash.dart';
import 'package:passguard/frontend/app_main.dart'; // Ensure MainApp is imported

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false; // Added loading state
  String? _errorMessage;
  String? _passwordError;

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isRegisterMode && _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = "Passwords do not match";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.login(
        hashObject(_usernameController.text),
        hashObject(_passwordController.text),
      );
      // if (!authProvider.isLoggedIn) return; // break if we didn't successfully login.
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            constraints: isDesktop ? BoxConstraints(maxWidth: 400) : null,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegisterMode ? 'Register' : 'Login',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  if (_isRegisterMode)
                    Column(
                      children: [
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return null;
                          },
                        ),
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _passwordError!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 24.0),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitForm(context),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          )
                        : Text(_isRegisterMode ? 'Register' : 'Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                        _passwordError = null;
                        _confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      _isRegisterMode
                          ? 'Already have an account? Login'
                          : "Don't have an account? Register",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:passguard/frontend/providers/auth_provider.dart';
// import 'package:passguard/backend/devsec/deterministic_hash.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _isRegisterMode = false;
//   String? _passwordError;


//   void _submitForm(BuildContext context) async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_isRegisterMode && _passwordController.text != _confirmPasswordController.text) {
//       setState(() {
//         _passwordError = "Passwords do not match";
//       });
//       return;
//     }

//     final authProvider = context.read<AuthProvider>();
//     await authProvider.login(
//       hashObject(_usernameController.text), // irreversibly hashes the input so app never has plaintexts
//       hashObject(_passwordController.text),
//     );

//     if (!mounted) return; // check if we're mounted.

//     if (authProvider.isLoggedIn) {
//       Navigator.pushReplacementNamed(context, '/main');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final authProvider = context.watch<AuthProvider>();
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 24.0),
//           child: Container(
//             constraints: isDesktop ? BoxConstraints(maxWidth: 400) : null,
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     _isRegisterMode ? 'Register' : 'Login',
//                     style: theme.textTheme.headlineMedium?.copyWith(
//                       color: theme.colorScheme.primary,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 24.0),
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(
//                       labelText: 'Username',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your username';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 16.0),
//                   TextFormField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       return null;
//                     },
//                   ),
//                   if (_isRegisterMode)
//                     Column(
//                       children: [
//                         SizedBox(height: 16.0),
//                         TextFormField(
//                           controller: _confirmPasswordController,
//                           decoration: InputDecoration(
//                             labelText: 'Confirm Password',
//                             border: OutlineInputBorder(),
//                           ),
//                           obscureText: true,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please confirm your password';
//                             }
//                             return null;
//                           },
//                         ),
//                         if (_passwordError != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Text(
//                               _passwordError!,
//                               style: TextStyle(color: theme.colorScheme.error),
//                             ),
//                           ),
//                       ],
//                     ),
//                   SizedBox(height: 24.0),
//                   if (authProvider.errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Text(
//                         authProvider.errorMessage!,
//                         style: TextStyle(color: theme.colorScheme.error),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ElevatedButton(
//                     onPressed: authProvider.isLoading
//                         ? null
//                         : () => _submitForm(context),
//                     child: authProvider.isLoading
//                         ? CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               theme.colorScheme.onPrimary,
//                             ),
//                           )
//                         : Text(_isRegisterMode ? 'Register' : 'Login'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _isRegisterMode = !_isRegisterMode;
//                         _passwordError = null;
//                         _confirmPasswordController.clear();
//                       });
//                     },
//                     child: Text(
//                       _isRegisterMode
//                           ? 'Already have an account? Login'
//                           : 'Don’t have an account? Register',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
