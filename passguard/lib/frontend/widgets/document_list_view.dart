// doc_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:encryptilock/frontend/providers/document_provider.dart';

class DocListView extends StatefulWidget {
  final void Function(int)? onItemSelected; // callback to parent if needed

  const DocListView({Key? key, this.onItemSelected}) : super(key: key);

  @override
  State<DocListView> createState() => _DocListViewState();
}

class _DocListViewState extends State<DocListView> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final docProv = context.watch<DocProvider>();

    final allDocs = docProv.docs;

    // Filter by search
    final filteredDocs = searchQuery.isNotEmpty
        ? allDocs.where((doc) {
            final query = searchQuery.toLowerCase();
            final title = doc.title.toLowerCase();
            final content = doc.content.toLowerCase();

            // Extract tags from content
            final tagMatch = RegExp(r'<!--\s*tags:\s*(.*?)\s*-->').firstMatch(content);
            final tags = tagMatch != null ? tagMatch.group(1)!.toLowerCase() : '';

            return title.contains(query) || tags.contains(query);
          }).toList()
        : allDocs;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (q) => setState(() => searchQuery = q),
            decoration: InputDecoration(
              labelText: "Search Docs",
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        // List of Docs
        Expanded(
          child: ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final docItem = filteredDocs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  title: Text(docItem.title, style: theme.textTheme.bodyLarge),
                  onTap: () {
                    // We need to figure out original index in _docs
                    final actualIndex = allDocs.indexOf(docItem);
                    docProv.selectDoc(actualIndex);
                    widget.onItemSelected?.call(actualIndex);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
