import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:encryptilock/frontend/providers/document_provider.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docProv = context.watch<DocProvider>();

    // If no doc selected => show the original marketing layout
    if (!docProv.hasSelection) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          if (maxWidth > 1000) {
            return _buildWideLayout(context);
          } else if (maxWidth > 600) {
            return _buildMediumLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      );
    } else {
      // If a doc is selected => show doc content
      final docItem = docProv.selectedDoc; // safe, if hasSelection is true
      return Container(
        padding: const EdgeInsets.all(16),
        child: Markdown(
          data: docItem.content,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
        ),
      );
    }
  }

  // ----------------------------------
  // WIDE DESKTOP LAYOUT ( > 1000px )
  // ----------------------------------
  Widget _buildWideLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: SizedBox(
          width: 1000, // Give a max constraint or as you like
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left column: Logo + Title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(context),
                    const SizedBox(height: 16),
                    Text(
                      'Encryptilock',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data Security, just right.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Right column: Website button + tips
              Expanded(
                child: _buildTipsAndWebsite(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------
  // MEDIUM LAYOUT ( > 600px && <=1000 )
  // ----------------------------------
  Widget _buildMediumLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 600, // narrower container
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: logo & text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(context),
                    const SizedBox(height: 16),
                    Text(
                      'Encryptilock',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data Security, just right.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right side: tips + website
              Expanded(
                child: _buildTipsAndWebsite(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------
  // NARROW LAYOUT ( <=600px )
  // ----------------------------------
  Widget _buildNarrowLayout(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(context),
          const SizedBox(height: 16),
          Text(
            'Encryptilock',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Data Security, just right.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTipsAndWebsite(context, isCentered: true),
        ],
      ),
    );
  }

  // ----------------------------------
  // BUILD LOGO WIDGET
  // ----------------------------------
  Widget _buildLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String iconPath = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';
    return Image.asset(
      iconPath,
      width: 100,
      height: 100,
    );
  }

  // ----------------------------------
  // BUILD TIPS + WEBSITE BUTTON
  // ----------------------------------
  Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
    final theme = Theme.of(context);
    final textAlign = isCentered ? TextAlign.center : TextAlign.left;

    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _launchWebsite,
          child: const Text('Visit Our Website'),
        ),
        const SizedBox(height: 24),
        Text(
          'Helpful Tips:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 8),
        const Text('- Use unique passwords for each account.'),
        const Text('- Don\'t forget your master password.'),
        const Text('- Enable two-factor authentication.'),
        const SizedBox(height: 16),
        Text(
          'Need support? Contact us at support@encryptilock.com',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }

  // ----------------------------------
  // LAUNCH WEBSITE
  // ----------------------------------
  void _launchWebsite() async {
    final url = Uri.https('www.encryptilock.com', '');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

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
