import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<void> checkAndRequestAll(BuildContext context) async {
    await _requestNotificationPermission(context);

    if (Platform.isAndroid && context.mounted) {
      await _requestExactAlarmPermission(context);
    }
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.notification.request();
      if (!result.isGranted && context.mounted) {
        await _showRationaleDialogue(
          context,
          title: 'Notifications Disabled',
          message:
              'To receive birthday reminder notifications, please enable notifications.',
        );
      }
    }
  }

  Future<void> _requestExactAlarmPermission(BuildContext context) async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.scheduleExactAlarm.request();
      if (!result.isGranted && context.mounted) {
        await _showRationaleDialogue(
          context,
          title: 'Alarm Permission Required',
          message:
              'To receive birthday reminder notifications, please enable the “Alarms & Reminders” permission.',
        );
      }
    }
  }

  Future<void> _showRationaleDialogue(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
