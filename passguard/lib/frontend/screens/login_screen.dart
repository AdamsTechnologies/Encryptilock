import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/widgets/permanent_snackbar.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/backend/devsec/obfuscation_util.dart';
import 'package:encryptilock/frontend/widgets/reset_app_dialog.dart';

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
  String? _errorMessage;
  String? _passwordError;
  bool _showWelcome = false;
  String? _marker;
  bool _rememberMe = false;
  bool _usernameFieldMasked = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    final configManager = context.read<AuthProvider>().configManager;
    final marker = await configManager.getHashedSetting('session_marker');
    print("marker: $marker");
    final remember = await configManager.getHashedSetting('remember_user');
    setState(() {
      _marker = marker;
      _isRegisterMode = marker == null;
      _showWelcome = marker == null;
      if (remember != null && remember.toLowerCase() == 'true') {
        _rememberMe = true;
        _usernameFieldMasked = true;
        _usernameController.text = '••••••••••';
      }
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
    final configManager = authProvider.configManager;

    try {
      print("marker: $_marker");
      final usernameHash = (_rememberMe && _marker != null) ? _marker! : ObfuscationUtil.hashObject(_usernameController.text);
      print("usernameHash: $usernameHash");
      final passwordHash = ObfuscationUtil.hashObject(_passwordController.text);
      await authProvider.login(usernameHash, passwordHash);

      // Save "remember me" setting AFTER login
      await configManager.setHashedSetting('remember_user', _rememberMe.toString());
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

  Widget _buildLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String iconPath = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';
    return Image.asset(
      iconPath,
      width: 120,
      height: 120,
    );
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
                constraints: isDesktop ? const BoxConstraints(maxWidth: 500) : null,
                child: _showWelcome ? _buildWelcome(context, theme) : _buildForm(context, theme),
              ),
            ),
          ),
          const PermanentSnackBar(),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced welcome experience
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            children: [
              // Animated container for the logo
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(24),
                child: _buildLogo(context),
              ),
              const SizedBox(height: 28),
              Text(
                "Welcome to Encryptilock",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 3,
                width: 60,
                margin: const EdgeInsets.only(top: 16, bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),

        // Description section with enhanced styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            // "Encryptilock is an offline password vault. Your data is stored only on this device.",
            "Encryptilock is a private, offline password vault. Your data stays 100% on this device — in your control.",
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        // Feature highlights with improved visual presentation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildFeatureItem(theme, Icons.cloud_off_outlined, "No online account or cloud sync"),
              Divider(height: 24, color: theme.colorScheme.outline.withOpacity(0.3)),
              _buildFeatureItem(theme, Icons.shield_outlined, "Full control, total privacy, zero tracking"),
              Divider(height: 24, color: theme.colorScheme.outline.withOpacity(0.3)),
              _buildFeatureItem(theme, Icons.lock_outline, "No password recovery — only you can access your vault"),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Enhanced CTA button
        ElevatedButton(
          onPressed: () => setState(() => _showWelcome = false),
          style: ElevatedButton.styleFrom(
            // foregroundColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Account",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Form(
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
            enabled: !_usernameFieldMasked,
            validator: (value) {
              if (!_usernameFieldMasked && (value == null || value.trim().isEmpty)) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
              ),
            ),
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
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() => _passwordVisible = !_passwordVisible);
                  },
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(context),
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
          CheckboxListTile(
            title: const Text('Remember Me'),
            contentPadding: EdgeInsets.zero,
            value: _rememberMe,
            onChanged: (val) async {
              final config = context.read<AuthProvider>().configManager;
              setState(() {
                _rememberMe = val ?? false;
              });
              if (!(val ?? false)) {
                // If user unchecks, clear saved state
                await config.setHashedSetting('remember_user', 'false');
                setState(() {
                  _usernameController.text = '';
                  _usernameFieldMasked = false;
                });
              }
            },
          ),
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
            child: _isLoading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary)) : Text(_isRegisterMode ? 'Register' : 'Login'),
          ),
          if (!_isRegisterMode)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ResetAppDialog(configManager: context.read<AuthProvider>().configManager),
              ),
              child: const Text("Having trouble logging in?"),
            ),
          if (_isRegisterMode) ...[
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "There's no password recovery, only factor reset. Be sure to remember your credentials.",
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ]
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
