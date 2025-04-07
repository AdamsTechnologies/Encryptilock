import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Encryptilock/frontend/widgets/permanent_snackbar.dart';
import 'package:Encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:Encryptilock/frontend/providers/auth_provider.dart';
import 'package:Encryptilock/backend/devsec/deterministic_hash.dart';

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
  bool _isLoading = false;
  bool _checkedFirstTime = false;
  String? _errorMessage;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    final configManager = context.read<AuthProvider>().configManager;
    final marker = await configManager.getSetting('session_marker');
    if (marker == null) {
      setState(() {
        _isRegisterMode = true;
      });
    }
    setState(() {
      _checkedFirstTime = true;
    });
  }

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
      context.read<SnackBarProvider>().showMessage("Login failed: $error");
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
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                constraints: isDesktop ? const BoxConstraints(maxWidth: 400) : null,
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
                      const SizedBox(height: 24.0),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
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
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitForm(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      if (_isRegisterMode) ...[
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
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
                      const SizedBox(height: 24.0),
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
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                              )
                            : Text(_isRegisterMode ? 'Register' : 'Login'),
                      ),
                      if (!_isRegisterMode && _checkedFirstTime)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isRegisterMode = true;
                              _passwordError = null;
                              _confirmPasswordController.clear();
                            });
                          },
                          child: const Text("Don't have an account? Register"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const PermanentSnackBar(),
        ],
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
