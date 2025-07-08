import 'package:flutter/material.dart';

void showSnackBar({
  required String content,
  required BuildContext context,
  Color? backgroundColor,
  Color? textColor,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
    );
}
