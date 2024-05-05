import 'package:flutter/material.dart';

import 'birthdays/views/list_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Birthdays",
      home: BirthdaysListView(),
    );
  }
}
