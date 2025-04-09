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
    final docProv = context.watch<DocProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 750;
    final leftOffset = isDesktop ? drawerWidth : 0.0;
    // ───── MOBILE: Always show list if nothing selected ─────
    if (!isDesktop && !docProv.hasSelection) {
      return const DocListView();
    }

    // ───── DESKTOP: Show "No document selected" ─────
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

    // ───── Document Content View (Both Desktop & Mobile) ─────
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
                    context.read<DocProvider>().clearSelection();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:encryptilock/frontend/providers/document_provider.dart';

// class InfoScreen extends StatelessWidget {
//   final bool isDrawerPinned;
//   final double drawerWidth;

//   const InfoScreen({
//     Key? key,
//     required this.isDrawerPinned,
//     required this.drawerWidth,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final docProv = context.watch<DocProvider>();
//     final isDesktop = MediaQuery.of(context).size.width > 750;
//     final shouldOffset = isDrawerPinned && isDesktop;

//     if (!docProv.hasSelection) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.only(left: shouldOffset ? drawerWidth : 0),
//           child: Text(
//             'No document selected.',
//             style: Theme.of(context).textTheme.bodyLarge,
//           ),
//         ),
//       );
//     }

//     final docItem = docProv.selectedDoc;

//     return Padding(
//       padding: EdgeInsets.only(left: shouldOffset ? drawerWidth : 0),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Stack(
//           children: [
//             FutureBuilder<String>(
//               future: docProv.getDbPathDisplayString(),
//               builder: (context, snapshot) {
//                 final dbPath = snapshot.data ?? "{{DB_PATH}}";
//                 final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

//                 return Markdown(
//                   data: content,
//                   styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
//                 );
//               },
//             ),
//             // Mobile "X" close button
//             if (!isDesktop)
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: IconButton(
//                   icon: const Icon(Icons.close),
//                   tooltip: 'Close Document',
//                   onPressed: () {
//                     context.read<DocProvider>().clearSelection();
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// --------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:encryptilock/frontend/providers/document_provider.dart';
// import 'package:encryptilock/frontend/widgets/document_list_view.dart';

// class InfoScreen extends StatelessWidget {
//   final bool isDrawerPinned;
//   final double drawerWidth;

//   const InfoScreen({
//     Key? key,
//     required this.isDrawerPinned,
//     required this.drawerWidth,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final docProv = context.watch<DocProvider>();
//     final isDesktop = MediaQuery.of(context).size.width > 750;
//     final leftOffset = isDrawerPinned && isDesktop ? drawerWidth : 0.0;

//     // ----- MOBILE BEHAVIOR -----
//     if (!isDesktop) {
//       if (!docProv.hasSelection) {
//         return const DocListView();
//       } else {
//         final docItem = docProv.selectedDoc;
//         return Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: FutureBuilder<String>(
//                 future: docProv.getDbPathDisplayString(),
//                 builder: (context, snapshot) {
//                   final dbPath = snapshot.data ?? "{{DB_PATH}}";
//                   final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

//                   return Markdown(
//                     data: content,
//                     styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               top: 12,
//               right: 12,
//               child: IconButton(
//                 icon: const Icon(Icons.close),
//                 tooltip: "Back to Docs",
//                 onPressed: () => docProv.clearSelection(),
//               ),
//             ),
//           ],
//         );
//       }
//     }

//     // ----- DESKTOP BEHAVIOR -----
//     if (!docProv.hasSelection) {
//       return Padding(
//         padding: EdgeInsets.only(left: leftOffset),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final maxWidth = constraints.maxWidth;
//             if (maxWidth > 1000) {
//               return _buildWideLayout(context);
//             } else if (maxWidth > 600) {
//               return _buildMediumLayout(context);
//             } else {
//               return _buildNarrowLayout(context);
//             }
//           },
//         ),
//       );
//     } else {
//       final docItem = docProv.selectedDoc;

//       return Padding(
//         padding: EdgeInsets.only(left: leftOffset),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: FutureBuilder<String>(
//             future: docProv.getDbPathDisplayString(),
//             builder: (context, snapshot) {
//               final dbPath = snapshot.data ?? "{{DB_PATH}}";
//               final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

//               return Markdown(
//                 data: content,
//                 styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
//               );
//             },
//           ),
//         ),
//       );
//     }
//   }

// // ----------------------------------
//   // WIDE DESKTOP LAYOUT ( > 1000px )
//   // ----------------------------------
//   Widget _buildWideLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(32.0),
//         child: SizedBox(
//           width: 1000,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 40),
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // MEDIUM LAYOUT ( > 600px && <=1000 )
//   // ----------------------------------
//   Widget _buildMediumLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: SizedBox(
//           width: 600,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 24),
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // NARROW LAYOUT ( <=600px )
//   // ----------------------------------
//   Widget _buildNarrowLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(context),
//           const SizedBox(height: 16),
//           Text(
//             'Encryptilock',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Data Security, just right.',
//             style: theme.textTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           _buildTipsAndWebsite(context, isCentered: true),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogo(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final iconPath = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';

//     return Image.asset(
//       iconPath,
//       width: 100,
//       height: 100,
//     );
//   }

//   Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
//     final theme = Theme.of(context);
//     final textAlign = isCentered ? TextAlign.center : TextAlign.left;

//     return Column(
//       crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
//       children: [
//         ElevatedButton(
//           onPressed: _launchWebsite,
//           child: const Text('Visit Our Website'),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           'Helpful Tips:',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: textAlign,
//         ),
//         const SizedBox(height: 8),
//         const Text('- Use unique passwords for each account.'),
//         const Text('- Don\'t forget your master password.'),
//         const Text('- Enable two-factor authentication.'),
//         const SizedBox(height: 16),
//         Text(
//           'Need support? Contact us at support@encryptilock.com',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//           ),
//           textAlign: textAlign,
//         ),
//       ],
//     );
//   }

//   void _launchWebsite() async {
//     final url = Uri.https('www.encryptilock.com', '');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }
// }

// --------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:encryptilock/frontend/providers/document_provider.dart';

// class InfoScreen extends StatelessWidget {
//   final bool isDrawerPinned;
//   final double drawerWidth;

//   const InfoScreen({
//     Key? key,
//     required this.isDrawerPinned,
//     required this.drawerWidth,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final docProv = context.watch<DocProvider>();
//     final isDesktop = MediaQuery.of(context).size.width > 750;

//     final leftOffset = isDrawerPinned && isDesktop ? drawerWidth : 0.0;

//     if (!docProv.hasSelection) {
//       return Padding(
//         padding: EdgeInsets.only(left: leftOffset),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final maxWidth = constraints.maxWidth;
//             if (maxWidth > 1000) {
//               return _buildWideLayout(context);
//             } else if (maxWidth > 600) {
//               return _buildMediumLayout(context);
//             } else {
//               return _buildNarrowLayout(context);
//             }
//           },
//         ),
//       );
//     } else {
//       final docItem = docProv.selectedDoc;

//       return Padding(
//         padding: EdgeInsets.only(left: leftOffset),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: FutureBuilder<String>(
//             future: docProv.getDbPathDisplayString(),
//             builder: (context, snapshot) {
//               final dbPath = snapshot.data ?? "{{DB_PATH}}";
//               final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

//               return Markdown(
//                 data: content,
//                 styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
//               );
//             },
//           ),
//         ),
//       );
//     }
//   }

//   // ----------------------------------
//   // WIDE DESKTOP LAYOUT ( > 1000px )
//   // ----------------------------------
//   Widget _buildWideLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(32.0),
//         child: SizedBox(
//           width: 1000,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 40),
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // MEDIUM LAYOUT ( > 600px && <=1000 )
//   // ----------------------------------
//   Widget _buildMediumLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: SizedBox(
//           width: 600,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 24),
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // NARROW LAYOUT ( <=600px )
//   // ----------------------------------
//   Widget _buildNarrowLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(context),
//           const SizedBox(height: 16),
//           Text(
//             'Encryptilock',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Data Security, just right.',
//             style: theme.textTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           _buildTipsAndWebsite(context, isCentered: true),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogo(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final iconPath = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';

//     return Image.asset(
//       iconPath,
//       width: 100,
//       height: 100,
//     );
//   }

//   Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
//     final theme = Theme.of(context);
//     final textAlign = isCentered ? TextAlign.center : TextAlign.left;

//     return Column(
//       crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
//       children: [
//         ElevatedButton(
//           onPressed: _launchWebsite,
//           child: const Text('Visit Our Website'),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           'Helpful Tips:',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: textAlign,
//         ),
//         const SizedBox(height: 8),
//         const Text('- Use unique passwords for each account.'),
//         const Text('- Don\'t forget your master password.'),
//         const Text('- Enable two-factor authentication.'),
//         const SizedBox(height: 16),
//         Text(
//           'Need support? Contact us at support@encryptilock.com',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//           ),
//           textAlign: textAlign,
//         ),
//       ],
//     );
//   }

//   void _launchWebsite() async {
//     final url = Uri.https('www.encryptilock.com', '');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }
// }

// -------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:encryptilock/frontend/providers/document_provider.dart';

// class InfoScreen extends StatelessWidget {
//   const InfoScreen({Key? key}) : super(key: key);

//   static const double drawerWidth = 250.0;

//   @override
//   Widget build(BuildContext context) {
//     final docProv = context.watch<DocProvider>();
//     final isDesktop = MediaQuery.of(context).size.width > 750 && docProv.hasSelection;
//     final isDrawerPinned = isDesktop && docProv.hasSelection;

//     // If no doc selected => show the original marketing layout
//     if (!docProv.hasSelection) {
//       return Padding(
//         padding: EdgeInsets.only(left: isDrawerPinned ? InfoScreen.drawerWidth : 0.0),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final maxWidth = constraints.maxWidth;
//             if (maxWidth > 1000) {
//               return _buildWideLayout(context);
//             } else if (maxWidth > 600) {
//               return _buildMediumLayout(context);
//             } else {
//               return _buildNarrowLayout(context);
//             }
//           },
//         ),
//       );
//     } else {
//       // Markdown view with left offset for the drawer
//       final docItem = docProv.selectedDoc;

//       return Padding(
//         padding: EdgeInsets.only(left: isDrawerPinned ? drawerWidth : 0.0),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: FutureBuilder<String>(
//             future: docProv.getDbPathDisplayString(),
//             builder: (context, snapshot) {
//               final dbPath = snapshot.data ?? "{{DB_PATH}}";
//               final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

//               return Markdown(
//                 data: content,
//                 styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
//               );
//             },
//           ),
//         ),
//       );
//     }
//   }

// // class InfoScreen extends StatelessWidget {
// //   const InfoScreen({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final docProv = context.watch<DocProvider>();
// //     final isDrawerPinned = context.select<MainAppState>((state) => state.pinnedIndex == 0);
// //     // If no doc selected => show the original marketing layout
// //     if (!docProv.hasSelection) {
// //       return LayoutBuilder(
// //         builder: (context, constraints) {
// //           final maxWidth = constraints.maxWidth;
// //           if (maxWidth > 1000) {
// //             return _buildWideLayout(context);
// //           } else if (maxWidth > 600) {
// //             return _buildMediumLayout(context);
// //           } else {
// //             return _buildNarrowLayout(context);
// //           }
// //         },
// //       );
// //     } else {
// //       // If a doc is selected => show doc content
// //       final docItem = docProv.selectedDoc; // safe, if hasSelection is true
// //       return Container(
// //         padding: const EdgeInsets.all(16),
// //         child: FutureBuilder<String>(
// //           future: docProv.getDbPathDisplayString(),
// //           builder: (context, snapshot) {
// //             final dbPath = snapshot.data ?? "{{DB_PATH}}";
// //             final content = docItem.content.replaceAll("{{DB_PATH}}", dbPath);

// //             return Markdown(
// //               data: content,
// //               styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
// //             );
// //           },
// //         ),
// //       );
// //     }
// //   }

//   // ----------------------------------
//   // WIDE DESKTOP LAYOUT ( > 1000px )
//   // ----------------------------------
//   Widget _buildWideLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(32.0),
//         child: SizedBox(
//           width: 1000, // Give a max constraint or as you like
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Left column: Logo + Title
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 40),
//               // Right column: Website button + tips
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // MEDIUM LAYOUT ( > 600px && <=1000 )
//   // ----------------------------------
//   Widget _buildMediumLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: SizedBox(
//           width: 600, // narrower container
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Left side: logo & text
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 24),
//               // Right side: tips + website
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // NARROW LAYOUT ( <=600px )
//   // ----------------------------------
//   Widget _buildNarrowLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(context),
//           const SizedBox(height: 16),
//           Text(
//             'Encryptilock',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Data Security, just right.',
//             style: theme.textTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           _buildTipsAndWebsite(context, isCentered: true),
//         ],
//       ),
//     );
//   }

//   // ----------------------------------
//   // BUILD LOGO WIDGET
//   // ----------------------------------
//   Widget _buildLogo(BuildContext context) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;
//     String iconPath = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';
//     return Image.asset(
//       iconPath,
//       width: 100,
//       height: 100,
//     );
//   }

//   // ----------------------------------
//   // BUILD TIPS + WEBSITE BUTTON
//   // ----------------------------------
//   Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
//     final theme = Theme.of(context);
//     final textAlign = isCentered ? TextAlign.center : TextAlign.left;

//     return Column(
//       crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
//       children: [
//         ElevatedButton(
//           onPressed: _launchWebsite,
//           child: const Text('Visit Our Website'),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           'Helpful Tips:',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: textAlign,
//         ),
//         const SizedBox(height: 8),
//         const Text('- Use unique passwords for each account.'),
//         const Text('- Don\'t forget your master password.'),
//         const Text('- Enable two-factor authentication.'),
//         const SizedBox(height: 16),
//         Text(
//           'Need support? Contact us at support@encryptilock.com',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//           ),
//           textAlign: textAlign,
//         ),
//       ],
//     );
//   }

//   // ----------------------------------
//   // LAUNCH WEBSITE
//   // ----------------------------------
//   void _launchWebsite() async {
//     final url = Uri.https('www.encryptilock.com', '');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }
// }

// -------------------------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class InfoScreen extends StatelessWidget {
//   const InfoScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // We can define breakpoints as we like
//         // e.g. >1000px => wide (desktop w/ 2 columns)
//         //      >600px => medium (tablet or large phone)
//         //      <=600px => small (mobile)
//         final maxWidth = constraints.maxWidth;
//         if (maxWidth > 1000) {
//           // Wide: side-by-side columns
//           return _buildWideLayout(context);
//         } else if (maxWidth > 600) {
//           // Medium: still side-by-side but narrower
//           return _buildMediumLayout(context);
//         } else {
//           // Small: stack in a single column
//           return _buildNarrowLayout(context);
//         }
//       },
//     );
//   }

//   // ----------------------------------
//   // WIDE DESKTOP LAYOUT ( > 1000px )
//   // ----------------------------------
//   Widget _buildWideLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(32.0),
//         child: SizedBox(
//           width: 1000, // Give a max constraint or as you like
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Left column: Logo + Title
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 40),
//               // Right column: Website button + tips
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // MEDIUM LAYOUT ( > 600px && <=1000 )
//   // ----------------------------------
//   Widget _buildMediumLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: SizedBox(
//           width: 600, // narrower container
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Left side: logo & text
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogo(context),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Encryptilock',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Data Security, just right.',
//                       style: theme.textTheme.bodyMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 24),
//               // Right side: tips + website
//               Expanded(
//                 child: _buildTipsAndWebsite(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------------------
//   // NARROW LAYOUT ( <=600px )
//   // ----------------------------------
//   Widget _buildNarrowLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(context),
//           const SizedBox(height: 16),
//           Text(
//             'Encryptilock',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Data Security, just right.',
//             style: theme.textTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           _buildTipsAndWebsite(context, isCentered: true),
//         ],
//       ),
//     );
//   }

//   // ----------------------------------
//   // BUILD LOGO WIDGET
//   // ----------------------------------
//   Widget _buildLogo(BuildContext context) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;
//     String iconPath = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';
//     return Image.asset(
//       iconPath,
//       width: 100,
//       height: 100,
//     );
//   }

//   // ----------------------------------
//   // BUILD TIPS + WEBSITE BUTTON
//   // ----------------------------------
//   Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
//     final theme = Theme.of(context);
//     final textAlign = isCentered ? TextAlign.center : TextAlign.left;

//     return Column(
//       crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
//       children: [
//         ElevatedButton(
//           onPressed: _launchWebsite,
//           child: const Text('Visit Our Website'),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           'Helpful Tips:',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: textAlign,
//         ),
//         const SizedBox(height: 8),
//         const Text('- Use unique passwords for each account.'),
//         const Text('- Dont forget your master password.'),
//         const Text('- Enable two-factor authentication.'),
//         const SizedBox(height: 16),
//         Text(
//           'Need support? Contact us at support@encryptilock.com',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//           ),
//           textAlign: textAlign,
//         ),
//       ],
//     );
//   }

//   // ----------------------------------
//   // LAUNCH WEBSITE
//   // ----------------------------------
//   void _launchWebsite() async {
//     final url = Uri.https('www.encryptilock.com', '');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }
// }
