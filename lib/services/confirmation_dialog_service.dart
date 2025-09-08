import 'package:flutter/material.dart';

class ConfirmationDialogService {
  Future<bool?> showConfirmationDialog(
    BuildContext context,
    {
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text(confirmText),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }
}
