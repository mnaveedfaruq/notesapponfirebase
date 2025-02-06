import 'package:firebasenotesapp/utilities/dialog/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showMyGenericDialog(
          context: context,
          title: 'Log Out',
          content: 'are you sure you want to logout',
          optionsCreator: () => {'yes': true, 'No': false})
      .then((value) => value ?? false);
}
