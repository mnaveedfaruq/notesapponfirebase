import 'package:firebasenotesapp/utilities/dialog/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String message,
) {
  return showMyGenericDialog<void>(
    context: context,
    title: 'Error',
    content: message,
    optionsCreator: () => {'ok': null},
  );
}
