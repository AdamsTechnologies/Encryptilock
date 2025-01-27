import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/password_provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';

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

    // return Consumer<PasswordProvider>(
    //   builder: (ctx, passwordProv, child) {
    return Consumer2<PasswordProvider, SnackBarProvider>(
      builder: (ctx, passwordProv, snackBarProv, _) {
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

        // Filter based on search query
        final filteredEntries = searchQuery.isNotEmpty
            ? allEntries.where((entry) {
                final q = searchQuery.toLowerCase();
                return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q);
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

            // Password list
            Expanded(
              child: ListView.builder(
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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

            // "Create New" button at the bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onItemSelected?.call(1); // Indicate create new
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Password'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50), // Make button full-width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
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

  PasswordEntry({
    required this.id,
    required this.service,
    required this.serviceType,
    required this.username,
    required this.creationDate,
  });
}



// // password_list_view.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/providers/password_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';

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

//     return Consumer<PasswordProvider>(
//       builder: (ctx, passwordProv, child) {
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

//             // Password list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredEntries.length,
//                 itemBuilder: (context, index) {
//                   final entry = filteredEntries[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: ListTile(
//                       title: Text(entry.service, style: theme.textTheme.bodyLarge),
//                       subtitle: Text(entry.serviceType),
//                       onTap: () {
//                         passwordProv.selectPasswordId(entry.id);
//                         widget.onItemSelected?.call(0); // Indicate a selection
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // "Create New" button at the bottom
//             Padding(
//               padding: const EdgeInsets.all(8.0),
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
//           ],
//         );
//       },
//     );
//   }
// }


// ----------------------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/providers/password_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';

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

// /// A self-contained widget that:
// ///  - Reads passwords from PasswordProvider
// ///  - Builds list items (PasswordEntry)
// ///  - Provides a search box
// ///  - On tap, selects that password in PasswordProvider & optionally shows snack bar
// class PasswordListView extends StatefulWidget {
//   // Instead of your old arguments, or alongside them:
//   final void Function(int itemSelect)? onItemSelected;

//   const PasswordListView({
//     Key? key,
//     this.onItemSelected,
//   }) : super(key: key);

//   @override
//   _PasswordListViewState createState() => _PasswordListViewState();
// }

// class _PasswordListViewState extends State<PasswordListView> {
//   // your search/filter logic
//   String searchQuery = "";

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Use Consumer to get your PasswordProvider and SnackBarProvider
    // return Consumer2<PasswordProvider, SnackBarProvider>(
    //   builder: (ctx, passwordProv, snackBarProv, _) {
//         // transform Map<String,dynamic> to PasswordEntry
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

//         // filter if needed
//         final filteredEntries = (searchQuery.isNotEmpty)
//             ? allEntries.where((entry) {
//                 final q = searchQuery.toLowerCase();
//                 return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q);
//               }).toList()
//             : allEntries;

//         return Column(
//           children: [
//             // search bar
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 onChanged: (q) => setState(() => searchQuery = q),
//                 decoration: InputDecoration(
//                   labelText: "Search Passwords",
//                   prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
//                 ),
//               ),
//             ),

//             // list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredEntries.length,
//                 itemBuilder: (context, index) {
//                   final entry = filteredEntries[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(entry.service),
//                       subtitle: Text(entry.serviceType),
//                       onTap: () {
//                         // 1) Set the selected password in provider
//                         passwordProv.selectPasswordId(entry.id);
//                         // 2) Optionally show a snack message
//                         snackBarProv.showMessage("Selected password: ${entry.service}");
//                         // 3) If the parent has a callback, call it
//                         if (widget.onItemSelected != null) {
//                           widget.onItemSelected!(0);
//                         }
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             // "Create New" button at the bottom
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   passwordProv.setMode('create');
//                   if (widget.onItemSelected != null) {
//                     widget.onItemSelected!(1);
//                   }
//                 },
//                 icon: const Icon(Icons.add),
//                 label: const Text('Create New Password'),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }