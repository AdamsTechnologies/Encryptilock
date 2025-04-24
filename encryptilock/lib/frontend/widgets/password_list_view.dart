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
  final GlobalKey _filterCardKey = GlobalKey();
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
        final counts = <String, int>{};
        for (var e in allEntries) {
          counts[e.serviceType] = (counts[e.serviceType] ?? 0) + 1;
        }
        // category filter
        final byCategory = isAll ? allEntries : allEntries.where((e) => selectedFilters.contains(e.serviceType)).toList();

        // search filter
        final filtered = searchQuery.isNotEmpty
            ? byCategory.where((e) {
                final q = searchQuery.toLowerCase();
                return e.service.toLowerCase().contains(q) || e.serviceType.toLowerCase().contains(q) || e.creationDate.contains(q) || e.updateDate.contains(q);
              }).toList()
            : byCategory;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (!_showFilterOptions) return;

            // Find the filter card's render box
            final box = _filterCardKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) {
              final pos = box.localToGlobal(Offset.zero);
              final size = box.size;
              final dx = event.position.dx;
              final dy = event.position.dy;

              // If the tap is outside the card's rect, collapse after 200ms
              if (!(dx >= pos.dx && dx <= pos.dx + size.width && dy >= pos.dy && dy <= pos.dy + size.height)) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted && _showFilterOptions) {
                    setState(() => _showFilterOptions = false);
                  }
                });
              }
            }
          },
          child: Column(
            children: [
              // SEARCH + FILTER CARD
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedContainer(
                  key: _filterCardKey, // ← key it!
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _showFilterOptions
                            ? Column(
                                children: [
                                  const SizedBox(height: 5),
                                  // … your LayoutBuilder/GridView here …
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final w = constraints.maxWidth;
                                      int crossAxisCount;
                                      if (w < 200) {
                                        crossAxisCount = 1;
                                      } else if (w < 350) {
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
                                          childAspectRatio: 6,
                                          mainAxisSpacing: 4,
                                          crossAxisSpacing: 4,
                                          shrinkWrap: true,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          children: allCategories.map((cat) {
                                            // final label = cat.isEmpty ? '(Uncategorized)' : cat;
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
                                                      if (v == true) {
                                                        nf.add(cat);
                                                      } else {
                                                        nf.remove(cat);
                                                      }
                                                      settingsProv.setCategoryFilters(nf);
                                                    },
                                                  ),
                                                  // Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
                                                  Expanded(
                                                    child: Text(
                                                      '$cat (${counts[cat] ?? 0})',
                                                      style: theme.textTheme.bodyMedium,
                                                    ),
                                                  ),
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
                              )
                            : const SizedBox.shrink(),
                      ),
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
          ),
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
