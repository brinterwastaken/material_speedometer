import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class LocationPermDialog {
  static Future<void> locationPermDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: Text(
            'To track and display your speed, please allow VelocityView to access your device\'s location.\n\n'
                'In the next screen, tap "Permissions", then "Location", then select "Allow only while using the app.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton.tonal(
              child: const Text('Open Settings'),
              onPressed: () async {
                await AppSettings.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}