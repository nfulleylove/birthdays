import 'package:birthdays/services/permissions_service.dart';
import 'package:flutter/material.dart';

class PermissionGate extends StatefulWidget {
  final Widget child;
  const PermissionGate({required this.child, super.key});
  @override
  PermissionGateState createState() => PermissionGateState();
}

class PermissionGateState extends State<PermissionGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionsService().checkAndRequestAll(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
