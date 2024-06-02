import 'package:flutter/material.dart';

void showCustomDialog(
  BuildContext context,
  String title,
  String content,
  String prompt,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(prompt),
          ),
        ],
      );
    },
  );
}
