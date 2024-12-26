import 'package:flutter/material.dart';

class Message {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
      BuildContext context, String msg,
      [double fontSize = 18, int durationsecond = 3]) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      width: 200,
      content: Text(
        msg,
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade900,
      elevation: 20,
      duration: Duration(seconds: durationsecond),
    ));
  }
}
