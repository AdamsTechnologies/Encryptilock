import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:encryptilock/frontend/providers/document_provider.dart';
import 'package:encryptilock/frontend/widgets/document_list_view.dart';

class InfoScreen extends StatelessWidget {
  final bool isDrawerPinned;
  final double drawerWidth;

  const InfoScreen({
    Key? key,
    required this.isDrawerPinned,
    required this.drawerWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DocProvider>(
      builder: (context, docProv, _) {
        final isDesktop = MediaQuery.of(context).size.width > 750;
        final leftOffset = isDesktop ? drawerWidth : 0.0;

        if (!isDesktop && !docProv.hasSelection) {
          return const DocListView();
        }

        if (isDesktop && !docProv.hasSelection) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(left: leftOffset),
              child: Text(
                'No document selected.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        final docItem = docProv.selectedDoc;

        return Padding(
          padding: EdgeInsets.only(left: leftOffset),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                FutureBuilder<String>(
                  future: docProv.getDbPathDisplayString(),
                  builder: (context, snapshot) {
                    final dbPath = snapshot.data ?? "{{DB_PATH}}";
                    final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

                    return Markdown(
                      data: content,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                    );
                  },
                ),
                if (!isDesktop)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close Document',
                      onPressed: () {
                        docProv.clearSelection();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
