import 'package:flutter/material.dart';

enum BottomActionBarStyle {
  iconOnly,
  iconWithText,
}

class BottomActionBar extends StatelessWidget {
  final bool isEditMode;
  final bool showDeleteButton;
  final VoidCallback onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;
  final BottomActionBarStyle style;

  const BottomActionBar({
    Key? key,
    required this.isEditMode,
    required this.showDeleteButton,
    required this.onCancel,
    this.onEdit,
    this.onDelete,
    this.onSave,
    this.style = BottomActionBarStyle.iconOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final error = Theme.of(context).colorScheme.error;
    final textStyle = Theme.of(context).textTheme.labelLarge;

    Widget buildButton({
      required IconData icon,
      required Color color,
      required VoidCallback? onPressed,
      String? label,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 48), // wider presence
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          onPressed: onPressed,
          child: style == BottomActionBarStyle.iconOnly
              ? Icon(icon)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label ?? '', style: textStyle),
                  ],
                ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left-aligned delete
          if (showDeleteButton && onDelete != null)
            buildButton(
              icon: Icons.delete,
              color: error,
              onPressed: onDelete,
              label: 'Delete',
            )
          else
            const SizedBox(width: 100), // keeps spacing consistent

          // Right-aligned action group
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditMode && onEdit != null)
                buildButton(
                  icon: Icons.edit,
                  color: secondary,
                  onPressed: onEdit,
                  label: 'Edit',
                ),
              if (onSave != null)
                buildButton(
                  icon: Icons.save,
                  color: secondary,
                  onPressed: onSave,
                  label: 'Save',
                ),
              buildButton(
                icon: Icons.cancel,
                color: Colors.grey,
                onPressed: onCancel,
                label: 'Cancel',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
