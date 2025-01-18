import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For PasswordProvider
import 'package:passguard/frontend/providers/password_provider.dart'; // For PasswordProvider
// import 'package:flutter/services.dart';

class PasswordCreationEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingRecord; // Null for creation mode

  const PasswordCreationEditPage({Key? key, this.existingRecord})
      : super(key: key);

  @override
  State<PasswordCreationEditPage> createState() =>
      _PasswordCreationEditPageState();
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

  @override
  void initState() {
    super.initState();

    if (widget.existingRecord != null) {
      // Pre-fill fields for edit mode
      _serviceNameController.text = widget.existingRecord!['serviceName'] ?? '';
      _usernameController.text = widget.existingRecord!['username'] ?? '';
      _passwordController.text = widget.existingRecord!['password'] ?? '';
      _serviceTypeController.text = widget.existingRecord!['serviceType'] ?? '';
      _urlController.text = widget.existingRecord!['url'] ?? '';
      _noteController.text = widget.existingRecord!['note'] ?? '';
      _isActive = widget.existingRecord!['isActive'] ?? true;
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
    final generatedPassword = "StrongGeneratedPassword123!"; // Example
    setState(() {
      _passwordController.text = generatedPassword;
      _confirmPasswordController.text = generatedPassword;
    });
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'serviceName': _serviceNameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'serviceType': _serviceTypeController.text,
        'url': _urlController.text,
        'note': _noteController.text,
        'isActive': _isActive,
      };

      try {
        final passwordProvider =
            Provider.of<PasswordProvider>(context, listen: false);
        if (widget.existingRecord == null) {
          await passwordProvider.addOrUpdatePassword(data);
        } else {
          data['id'] = widget.existingRecord!['id'];
          await passwordProvider.addOrUpdatePassword(data);
        }
        Navigator.pop(context); // Navigate back on success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving password: $e')),
        );
      }
    }
  }

  Future<void> _deletePassword() async {
    if (widget.existingRecord != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Password'),
          content: Text(
              'Are you sure you want to delete the password for "${widget.existingRecord!['serviceName']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        try {
          final passwordProvider =
              Provider.of<PasswordProvider>(context, listen: false);
          await passwordProvider.deletePassword(widget.existingRecord!['id']);
          Navigator.pop(context); // Navigate back on success
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting password: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord == null
            ? 'Create Password'
            : 'Edit Password'),
        actions: widget.existingRecord != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deletePassword,
                )
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _serviceNameController,
                  decoration: InputDecoration(labelText: 'Service Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Service name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value!.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _generatePassword,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Password is required' : null,
                ),
                if (widget.existingRecord == null) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: InputDecoration(labelText: 'Service Type'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'URL'),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText: 'Note'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: Text('Active'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _savePassword,
                  child: Text(widget.existingRecord == null ? 'Save' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
