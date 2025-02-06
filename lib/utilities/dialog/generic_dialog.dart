import 'package:flutter/material.dart';

typedef DialogOptions<T> = Map<String, T?> Function();
Future<T?> showMyGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptions optionsCreator,
}) {
  final options = optionsCreator();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((buttontext) {
          final valueOfKey = options[buttontext];
          return TextButton(
              onPressed: () {
                if (valueOfKey != null) {
                  Navigator.of(context).pop(valueOfKey);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(buttontext));
        }).toList(),
      );
    },
  );
}
