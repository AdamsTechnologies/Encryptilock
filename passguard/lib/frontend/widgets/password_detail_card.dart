import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PasswordDetailCard extends StatelessWidget {
  final String serviceName;
  final String username;
  final String password;
  final String? url;
  final String creationDate;
  final String serviceType;
  final VoidCallback onEdit;

  const PasswordDetailCard({
    Key? key,
    required this.serviceName,
    required this.username,
    required this.password,
    this.url,
    required this.creationDate,
    required this.serviceType,
    required this.onEdit,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard!')),
    );
  }

  void _openUrl(BuildContext context) async {
    if (url != null && url!.isNotEmpty) {
      final uri = Uri.tryParse(url!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceName,
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                  tooltip: 'Edit',
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(
              context,
              label: 'Username',
              value: username,
              copyable: true,
            ),
            const SizedBox(height: 8.0),
            _buildDetailRow(
              context,
              label: 'Password',
              value: password,
              copyable: true,
              obscurable: true,
            ),
            const SizedBox(height: 8.0),
            if (url != null && url!.isNotEmpty)
              _buildDetailRow(
                context,
                label: 'URL',
                value: url!,
                copyable: false,
                clickable: true,
              ),
            const SizedBox(height: 16.0),
            Text(
              'Service Type: $serviceType',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Created: $creationDate',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool copyable = false,
    bool obscurable = false,
    bool clickable = false,
  }) {
    final theme = Theme.of(context);
    bool isObscured = obscurable;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: clickable ? () => _openUrl(context) : null,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: clickable ? theme.colorScheme.primary : null,
                decoration: clickable ? TextDecoration.underline : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (copyable || obscurable)
          Row(
            children: [
              if (copyable)
                IconButton(
                  onPressed: () => _copyToClipboard(context, value, label),
                  icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
                  tooltip: 'Copy $label',
                ),
              if (obscurable)
                StatefulBuilder(
                  builder: (context, setState) {
                    return IconButton(
                      onPressed: () => setState(() => isObscured = !isObscured),
                      icon: Icon(
                        isObscured ? Icons.visibility : Icons.visibility_off,
                        color: theme.colorScheme.secondary,
                      ),
                      tooltip: isObscured ? 'Show $label' : 'Hide $label',
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}
