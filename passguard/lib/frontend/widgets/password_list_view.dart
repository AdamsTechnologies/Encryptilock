// password_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/password_provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';

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

/// A self-contained widget that:
///  - Reads passwords from PasswordProvider
///  - Builds list items (PasswordEntry)
///  - Provides a search box
///  - On tap, selects that password in PasswordProvider & optionally shows snack bar
class PasswordListView extends StatefulWidget {
  // Instead of your old arguments, or alongside them:
  final void Function(int itemSelect)? onItemSelected;

  const PasswordListView({
    Key? key,
    this.onItemSelected,
  }) : super(key: key);

  @override
  _PasswordListViewState createState() => _PasswordListViewState();
}

class _PasswordListViewState extends State<PasswordListView> {
  // your search/filter logic
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use Consumer to get your PasswordProvider and SnackBarProvider
    return Consumer2<PasswordProvider, SnackBarProvider>(
      builder: (ctx, passwordProv, snackBarProv, _) {
        // transform Map<String,dynamic> to PasswordEntry
        final allRecords = passwordProv.passwords;
        final allEntries = allRecords.map((record) {
          return PasswordEntry(
            id: record['id'],
            service: record['service'] ?? '',
            serviceType: record['servicetype'] ?? '',
            username: record['username'] ?? '',
            creationDate: record['createdt'] ?? '',
          );
        }).toList();

        // filter if needed
        final filteredEntries = (searchQuery.isNotEmpty)
            ? allEntries.where((entry) {
                final q = searchQuery.toLowerCase();
                return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q);
              }).toList()
            : allEntries;

        return Column(
          children: [
            // search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (q) => setState(() => searchQuery = q),
                decoration: InputDecoration(
                  labelText: "Search Passwords",
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                ),
              ),
            ),

            // list
            Expanded(
              child: ListView.builder(
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry.service),
                      subtitle: Text(entry.serviceType),
                      onTap: () {
                        // 1) Set the selected password in provider
                        passwordProv.selectPasswordId(entry.id);
                        // 2) Optionally show a snack message
                        snackBarProv.showMessage("Selected password: ${entry.service}");
                        // 3) If the parent has a callback, call it
                        if (widget.onItemSelected != null) {
                          widget.onItemSelected!(0);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            // "Create New" button at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  passwordProv.setMode('create');
                  if (widget.onItemSelected != null) {
                    widget.onItemSelected!(1);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Password'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';

// class PasswordEntry {
//   final String id;
//   final String service;
//   final String serviceType;
//   final String username;
//   final String creationDate;

//   PasswordEntry({
//     required this.id,
//     required this.service,
//     required this.serviceType,
//     required this.username,
//     required this.creationDate,
//   });
// }
// // TODO this should just dynamically retrieve the list from the password provider.
// class PasswordListView extends StatefulWidget {
//   final List<PasswordEntry> passwordEntries;
//   final void Function(PasswordEntry entry) onEntryTap;

//   const PasswordListView({
//     Key? key,
//     required this.passwordEntries,
//     required this.onEntryTap,
//   }) : super(key: key);

//   @override
//   _PasswordListViewState createState() => _PasswordListViewState();
// }

// class _PasswordListViewState extends State<PasswordListView> {
//   late List<PasswordEntry> filteredEntries;
//   String searchQuery = "";

//   @override
//   void initState() {
//     super.initState();
//     filteredEntries = widget.passwordEntries;
//   }

//   void _filterEntries(String query) {
//     setState(() {
//       searchQuery = query;
//       filteredEntries = widget.passwordEntries.where((entry) {
//         final queryLower = query.toLowerCase();
//         return entry.service.toLowerCase().contains(queryLower) ||
//             entry.serviceType.toLowerCase().contains(queryLower) ||
//             entry.creationDate.contains(queryLower);
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),//const EdgeInsets.all(8.0),
//           child: TextField(
//             onChanged: _filterEntries,
//             decoration: InputDecoration(
//               labelText: "Search Passwords",
//               prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
//               border: theme.inputDecorationTheme.border ?? OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(4.0),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: filteredEntries.length,
//             itemBuilder: (context, index) {
//               final entry = filteredEntries[index];
//               return Card(
//                 margin: const EdgeInsets.fromLTRB(8, 2, 2, 2),//const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4.0),
//                 ),
//                 child: ListTile(
//                   onTap: () => widget.onEntryTap(entry),
//                   title: Text(entry.service, style: theme.textTheme.bodyLarge),
//                   subtitle: Text(entry.serviceType), // "${entry.serviceType} \u2022 ${entry.username}" can concat other stuff.. but I don't think thats necessary.
//                   trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
