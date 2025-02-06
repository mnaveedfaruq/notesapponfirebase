import 'package:firebasenotesapp/utilities/dialog/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog({
  required BuildContext context,
}) {
  return showMyGenericDialog(
          context: context,
          title: 'Delete',
          content: 'Do you realy want to delete this note',
          optionsCreator: () => {'Cancel': false, 'Delete': true})
      .then((value) => value ?? false);
}
