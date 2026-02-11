import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  final bool isEditMode;
  final bool showDeleteButton;
  final VoidCallback onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;

  const TopActionBar({
    Key? key,
    required this.isEditMode,
    required this.showDeleteButton,
    required this.onCancel,
    this.onEdit,
    this.onDelete,
    this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDeleteButton && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              color: Theme.of(context).colorScheme.error,
              onPressed: onDelete,
            ),
          if (isEditMode && onSave != null)
            IconButton(
              icon: Icon(Icons.save, color: iconColor),
              tooltip: 'Save',
              onPressed: onSave,
            ),
          if (!isEditMode && onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: iconColor),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
          IconButton(
            icon: Icon(
              isEditMode ? Icons.close : Icons.cancel,
              color: iconColor,
            ),
            tooltip: isEditMode ? 'Cancel Editing' : 'Close',
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
