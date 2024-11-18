import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message,
    {Color backgroundColor = Colors.black, int durationInSeconds = 3}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: backgroundColor,
    duration: Duration(seconds: durationInSeconds),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> showAlertDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmButtonText,
  String? cancelButtonText,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          if (cancelButtonText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelButtonText),
            ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: Text(confirmButtonText ?? 'OK'),
          ),
        ],
      );
    },
  );
}

Future<void> showCustomDialog(
  BuildContext context, {
  required Widget content,
  String? title,
  required VoidCallback onConfirm,
  String confirmButtonText = 'Confirm',
  String cancelButtonText = 'Cancel',
  VoidCallback? onCancel,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
              ],
              content,
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    child: Text(cancelButtonText),
                  ),
                  TextButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop();
                    },
                    child: Text(confirmButtonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
