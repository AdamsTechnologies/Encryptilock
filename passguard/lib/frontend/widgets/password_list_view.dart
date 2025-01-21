import 'package:flutter/material.dart';

class PasswordEntry {
  final String id;
  final String service;
  final String serviceType;
  final String username;
  final String creationDate;

  PasswordEntry({
    required this.id,
    required this.service,
    required this.serviceType,
    required this.username,
    required this.creationDate,
  });
}
// TODO this should just dynamically retrieve the list from the password provider.
class PasswordListView extends StatefulWidget {
  final List<PasswordEntry> passwordEntries;
  final void Function(PasswordEntry entry) onEntryTap;

  const PasswordListView({
    Key? key,
    required this.passwordEntries,
    required this.onEntryTap,
  }) : super(key: key);

  @override
  _PasswordListViewState createState() => _PasswordListViewState();
}

class _PasswordListViewState extends State<PasswordListView> {
  late List<PasswordEntry> filteredEntries;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredEntries = widget.passwordEntries;
  }

  void _filterEntries(String query) {
    setState(() {
      searchQuery = query;
      filteredEntries = widget.passwordEntries.where((entry) {
        final queryLower = query.toLowerCase();
        return entry.service.toLowerCase().contains(queryLower) ||
            entry.serviceType.toLowerCase().contains(queryLower) ||
            entry.creationDate.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),//const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterEntries,
            decoration: InputDecoration(
              labelText: "Search Passwords",
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              border: theme.inputDecorationTheme.border ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredEntries.length,
            itemBuilder: (context, index) {
              final entry = filteredEntries[index];
              return Card(
                margin: const EdgeInsets.fromLTRB(8, 2, 2, 2),//const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  onTap: () => widget.onEntryTap(entry),
                  title: Text(entry.service, style: theme.textTheme.bodyLarge),
                  subtitle: Text(entry.serviceType), // "${entry.serviceType} \u2022 ${entry.username}" can concat other stuff.. but I don't think thats necessary.
                  trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
