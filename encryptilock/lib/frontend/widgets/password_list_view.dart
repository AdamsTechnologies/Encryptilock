import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';

class PasswordListView extends StatefulWidget {
  final void Function(int)? onItemSelected; // 0=select,1=create

  const PasswordListView({Key? key, this.onItemSelected}) : super(key: key);

  @override
  State<PasswordListView> createState() => _PasswordListViewState();
}

class _PasswordListViewState extends State<PasswordListView> {
  String searchQuery = "";
  bool _showFilterOptions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<PasswordProvider, SnackBarProvider, SettingsProvider>(
      builder: (ctx, passwordProv, snackBarProv, settingsProv, _) {
        final allRecords = passwordProv.passwords;

        // categories
        final allCategories = allRecords.map((r) => (r['servicetype'] ?? '').toString()).where((s) => s.trim().isNotEmpty).toSet();

        final selectedFilters = settingsProv.categoryFilters;
        final isAll = settingsProv.isAllCategoriesSelected;

        // active/inactive
        final visible = settingsProv.showHiddenPasswords ? allRecords : allRecords.where((r) => r['isactive'] == 1).toList();

        // view models
        final allEntries = visible.map((r) {
          return PasswordEntry(
            id: r['id'],
            service: r['service'] ?? '',
            serviceType: r['servicetype'] ?? '',
            username: r['username'] ?? '',
            creationDate: r['createdt'] ?? '',
            updateDate: r['updatedt'] ?? '',
          );
        }).toList();

        // category filter
        final byCategory = isAll ? allEntries : allEntries.where((e) => selectedFilters.contains(e.serviceType)).toList();

        // search filter
        final filtered = searchQuery.isNotEmpty
            ? byCategory.where((e) {
                final q = searchQuery.toLowerCase();
                return e.service.toLowerCase().contains(q) || e.serviceType.toLowerCase().contains(q) || e.creationDate.contains(q) || e.updateDate.contains(q);
              }).toList()
            : byCategory;

        return Column(
          children: [
            // SEARCH + FILTER CARD
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: _showFilterOptions ? Border.all(color: theme.dividerColor) : null,
                ),
                child: Column(
                  children: [
                    // search field + icon
                    TextField(
                      onChanged: (q) => setState(() => searchQuery = q),
                      decoration: InputDecoration(
                        labelText: "Search Passwords",
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.filter_list, color: _showFilterOptions ? theme.colorScheme.primary : theme.iconTheme.color),
                          onPressed: () => setState(() => _showFilterOptions = !_showFilterOptions),
                        ),
                        border: InputBorder.none,
                      ),
                    ),

                    // filter panel
                    if (_showFilterOptions) ...[
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          int crossAxisCount;
                          if (w < 200) {
                            crossAxisCount = 1;
                          } else if (w < 300) {
                            crossAxisCount = 2;
                          } else if (w < 400) {
                            crossAxisCount = 3;
                          } else {
                            crossAxisCount = 4;
                          }

                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 120),
                            child: GridView.count(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 4,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: allCategories.map((cat) {
                                final label = cat.isEmpty ? '(Uncategorized)' : cat;
                                final sel = selectedFilters.contains(cat);
                                return GestureDetector(
                                  onTap: () {
                                    final nf = Set<String>.from(selectedFilters);
                                    sel ? nf.remove(cat) : nf.add(cat);
                                    settingsProv.setCategoryFilters(nf);
                                  },
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: sel,
                                        onChanged: (v) {
                                          final nf = Set<String>.from(selectedFilters);
                                          if (v == true)
                                            nf.add(cat);
                                          else
                                            nf.remove(cat);
                                          settingsProv.setCategoryFilters(nf);
                                        },
                                      ),
                                      Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => settingsProv.clearCategoryFilters(),
                          child: const Text('Clear Filters'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // CREATE BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => widget.onItemSelected?.call(1),
                child: const Text('Create Password'),
              ),
            ),

            // PASSWORD LIST
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final e = filtered[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(e.service, style: theme.textTheme.bodyLarge),
                      subtitle: Text(e.serviceType),
                      onTap: () {
                        snackBarProv.showMessage("Selected: ${e.service}");
                        passwordProv.selectPasswordId(e.id);
                        widget.onItemSelected?.call(0);
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
// import 'package:encryptilock/frontend/providers/settings_provider.dart';
// import 'package:encryptilock/frontend/providers/password_provider.dart';
// import 'package:encryptilock/frontend/providers/snackbar_provider.dart';

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

//     return Consumer3<PasswordProvider, SnackBarProvider, SettingsProvider>(
//       builder: (ctx, passwordProv, snackBarProv, settingsProv, _) {
//         final allRecords = passwordProv.passwords;

//         // Collect all service types
//         final allCategories = <String>{
//           ...allRecords.map((r) => (r['servicetype'] ?? '').toString()).where((s) => s.trim().isNotEmpty)
//         };

//         final selectedFilters = settingsProv.categoryFilters;
//         final isAllSelected = settingsProv.isAllCategoriesSelected;

//         // Filter active/inactive
//         final visibleRecords = settingsProv.showHiddenPasswords ? allRecords : allRecords.where((r) => r['isactive'] == 1).toList();

//         // Convert to view model
//         final allEntries = visibleRecords.map((record) {
//           return PasswordEntry(
//             id: record['id'],
//             service: record['service'] ?? '',
//             serviceType: record['servicetype'] ?? '',
//             username: record['username'] ?? '',
//             creationDate: record['createdt'] ?? '',
//             updateDate: record['updatedt'] ?? '',
//           );
//         }).toList();

//         // Apply category filter
//         final categoryFiltered = isAllSelected ? allEntries : allEntries.where((e) => selectedFilters.contains(e.serviceType)).toList();

//         // Apply search
//         final filteredEntries = searchQuery.isNotEmpty
//             ? categoryFiltered.where((entry) {
//                 final q = searchQuery.toLowerCase();
//                 return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q) || entry.updateDate.contains(q);
//               }).toList()
//             : categoryFiltered;

//         return Column(
//           children: [
//             // Multi-select category filter trigger
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () => _showCategoryFilterDialog(allCategories, selectedFilters),
//                 child: Text(isAllSelected ? 'Filter: All Categories' : 'Filter: ${selectedFilters.join(', ')}'),
//               ),
//             ),

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

//             // Create button
//             Padding(
//               padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                 ),
//                 onPressed: () => widget.onItemSelected?.call(1),
//                 child: const Text('Create Password'),
//               ),
//             ),

//             // Password List
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
//                         widget.onItemSelected?.call(0);
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

//   void _showCategoryFilterDialog(Set<String> allCategories, Set<String> currentFilters) {
//     final tempSelections = Set<String>.from(currentFilters);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Select Categories'),
//           content: SingleChildScrollView(
//             child: Column(
//               children: allCategories.map((cat) {
//                 final label = cat.isEmpty ? '(Uncategorized)' : cat;
//                 return CheckboxListTile(
//                   title: Text(label),
//                   value: tempSelections.contains(cat),
//                   onChanged: (selected) {
//                     setState(() {
//                       if (selected == true) {
//                         tempSelections.add(cat);
//                       } else {
//                         tempSelections.remove(cat);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Provider.of<SettingsProvider>(context, listen: false).clearCategoryFilters();
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Clear All'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Provider.of<SettingsProvider>(context, listen: false).setCategoryFilters(tempSelections);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Apply'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   final theme = Theme.of(context);

//   //   return Consumer3<PasswordProvider, SnackBarProvider, SettingsProvider>(
//   //     builder: (ctx, passwordProv, snackBarProv, settingsProv, _) {
//   //       final allRecords = passwordProv.passwords;

//   //       // Apply the "Show Inactive Passwords" filter
//   //       final visibleRecords = settingsProv.showHiddenPasswords ? allRecords : allRecords.where((r) => r['isactive'] == 1).toList();

//   //       final allEntries = visibleRecords.map((record) {
//   //         return PasswordEntry(
//   //           id: record['id'],
//   //           service: record['service'] ?? '',
//   //           serviceType: record['servicetype'] ?? '',
//   //           username: record['username'] ?? '',
//   //           creationDate: record['createdt'] ?? '',
//   //           updateDate: record['updatedt'] ?? '',
//   //         );
//   //       }).toList();

//   //       // Apply search filter
//   //       final filteredEntries = searchQuery.isNotEmpty
//   //           ? allEntries.where((entry) {
//   //               final q = searchQuery.toLowerCase();
//   //               return entry.service.toLowerCase().contains(q) || entry.serviceType.toLowerCase().contains(q) || entry.creationDate.contains(q) || entry.updateDate.contains(q);
//   //             }).toList()
//   //           : allEntries;

//   //       return Column(
//   //         children: [
//   //           // Search bar
//   //           Padding(
//   //             padding: const EdgeInsets.all(8.0),
//   //             child: TextField(
//   //               onChanged: (q) => setState(() => searchQuery = q),
//   //               decoration: InputDecoration(
//   //                 labelText: "Search Passwords",
//   //                 prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
//   //                 border: OutlineInputBorder(
//   //                   borderRadius: BorderRadius.circular(8.0),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),

//   //           // "Create New" button
//   //           Padding(
//   //             padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
//   //             child: ElevatedButton(
//   //               style: ElevatedButton.styleFrom(
//   //                 minimumSize: const Size.fromHeight(50),
//   //                 shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(12.0),
//   //                 ),
//   //               ),
//   //               onPressed: () {
//   //                 widget.onItemSelected?.call(1); // Indicate create new
//   //               },
//   //               child: const Text('Create Password'),
//   //             ),
//   //           ),

//   //           // Password List
//   //           Expanded(
//   //             child: ListView.builder(
//   //               itemCount: filteredEntries.length,
//   //               itemBuilder: (context, index) {
//   //                 final entry = filteredEntries[index];
//   //                 return Card(
//   //                   margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(8.0),
//   //                   ),
//   //                   child: ListTile(
//   //                     title: Text(entry.service, style: theme.textTheme.bodyLarge),
//   //                     subtitle: Text(entry.serviceType),
//   //                     onTap: () {
//   //                       snackBarProv.showMessage("Selected password: ${entry.service}");
//   //                       passwordProv.selectPasswordId(entry.id);
//   //                       widget.onItemSelected?.call(0); // Indicate a selection
//   //                     },
//   //                   ),
//   //                 );
//   //               },
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
// }

// class PasswordEntry {
//   final String id;
//   final String service;
//   final String serviceType;
//   final String username;
//   final String creationDate;
//   final String updateDate;

//   PasswordEntry({
//     required this.id,
//     required this.service,
//     required this.serviceType,
//     required this.username,
//     required this.creationDate,
//     required this.updateDate,
//   });
// }
