import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Encryptilock/frontend/providers/settings_provider.dart';
import 'package:Encryptilock/frontend/providers/password_provider.dart';
import 'package:Encryptilock/frontend/providers/snackbar_provider.dart';

class PasswordListView extends StatefulWidget {
  final void Function(int)? onItemSelected; // 0 for selection, 1 for create

  const PasswordListView({
    Key? key,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<PasswordListView> createState() => _PasswordListViewState();
}

class _PasswordListViewState extends State<PasswordListView> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<PasswordProvider, SnackBarProvider, SettingsProvider>(
      builder: (ctx, passwordProv, snackBarProv, settingsProv, _) {
        final allRecords = passwordProv.passwords;

        // Apply the "Show Inactive Passwords" filter
        final visibleRecords = settingsProv.showHiddenPasswords ? allRecords : allRecords.where((r) => r['isactive'] == 1).toList();

        final allEntries = visibleRecords.map((record) {
          return PasswordEntry(
            id: record['id'],
            service: record['service'] ?? '',
            serviceType: record['servicetype'] ?? '',
            username: record['username'] ?? '',
            creationDate: record['createdt'] ?? '',
            updateDate: record['updatedt'] ?? '',
          );
        }).toList();

        // Apply search filter
        final filteredEntries = searchQuery.isNotEmpty
            ? allEntries.where((entry) {
                final q = searchQuery.toLowerCase();
                return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q) || entry.updateDate.contains(q);
              }).toList()
            : allEntries;

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (q) => setState(() => searchQuery = q),
                decoration: InputDecoration(
                  labelText: "Search Passwords",
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),

            // "Create New" button
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onItemSelected?.call(1); // Indicate create new
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Password'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),

            // Password List
            Expanded(
              child: ListView.builder(
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(entry.service, style: theme.textTheme.bodyLarge),
                      subtitle: Text(entry.serviceType),
                      onTap: () {
                        snackBarProv.showMessage("Selected password: ${entry.service}");
                        passwordProv.selectPasswordId(entry.id);
                        widget.onItemSelected?.call(0); // Indicate a selection
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class PasswordEntry {
  final String id;
  final String service;
  final String serviceType;
  final String username;
  final String creationDate;
  final String updateDate;

  PasswordEntry({
    required this.id,
    required this.service,
    required this.serviceType,
    required this.username,
    required this.creationDate,
    required this.updateDate,
  });
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:Encryptilock/frontend/providers/password_provider.dart';
// import 'package:Encryptilock/frontend/providers/snackbar_provider.dart';

// class PasswordListView extends StatefulWidget {
//   final void Function(int)? onItemSelected; // 0 for selection, 1 for create

//   const PasswordListView({
//     Key? key,
//     this.onItemSelected,
//   }) : super(key: key);

//   @override
//   State<PasswordListView> createState() => _PasswordListViewState();
// }

// class _PasswordListViewState extends State<PasswordListView> {
//   String searchQuery = "";

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // return Consumer<PasswordProvider>(
//     //   builder: (ctx, passwordProv, child) {
//     return Consumer2<PasswordProvider, SnackBarProvider>(
//       builder: (ctx, passwordProv, snackBarProv, _) {
//         final allRecords = passwordProv.passwords;
//         final allEntries = allRecords.map((record) {
//           return PasswordEntry(
//             id: record['id'],
//             service: record['service'] ?? '',
//             serviceType: record['servicetype'] ?? '',
//             username: record['username'] ?? '',
//             creationDate: record['createdt'] ?? '',
//           );
//         }).toList();

//         // Filter based on search query
//         final filteredEntries = searchQuery.isNotEmpty
//             ? allEntries.where((entry) {
//                 final q = searchQuery.toLowerCase();
//                 return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q);
//               }).toList()
//             : allEntries;

//         return Column(
//           children: [
//             // Search bar
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 onChanged: (q) => setState(() => searchQuery = q),
//                 decoration: InputDecoration(
//                   labelText: "Search Passwords",
//                   prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//               ),
//             ),
//             // "Create New" button at the bottom
//             Padding(
//               padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0), //const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   widget.onItemSelected?.call(1); // Indicate create new
//                 },
//                 icon: const Icon(Icons.add),
//                 label: const Text('Create New Password'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50), // Make button full-width
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                 ),
//               ),
//             ),
//             // Password list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredEntries.length,
//                 itemBuilder: (context, index) {
//                   final entry = filteredEntries[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: ListTile(
//                       title: Text(entry.service, style: theme.textTheme.bodyLarge),
//                       subtitle: Text(entry.serviceType),
//                       onTap: () {
//                         snackBarProv.showMessage("Selected password: ${entry.service}");
//                         passwordProv.selectPasswordId(entry.id);
//                         widget.onItemSelected?.call(0); // Indicate a selection
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

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
