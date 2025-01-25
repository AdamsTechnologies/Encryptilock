import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';

class PermanentSnackBar extends StatelessWidget {
  final double height;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double leftPaddingWhenDrawerOpen;

  const PermanentSnackBar({
    Key? key,
    this.height = 30.0,
    this.backgroundColor,
    this.textStyle,
    this.leftPaddingWhenDrawerOpen = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: leftPaddingWhenDrawerOpen,
      right: 0,
      bottom: 0,
      // Always pinned to the bottom
      child: Container(
        height: height,
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        // Use Consumer to watch the message; if null, show nothing
        child: Consumer<SnackBarProvider>(
          builder: (ctx, snackBarProvider, child) {
            final message = snackBarProvider.currentMessage;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // If there's a message, show it; else show an empty box so the row stays
                if (message != null)
                  Text(
                    message,
                    style: textStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
