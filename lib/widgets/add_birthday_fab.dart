import 'package:birthdays/views/add_birthday_view.dart';
import 'package:flutter/material.dart';
import 'package:birthdays/models/birthday.dart';

class AddBirthdayFab extends StatefulWidget {
  final void Function(Birthday added)? onBirthdayAdded;
  final String heroTag;
  const AddBirthdayFab(
      {super.key, this.onBirthdayAdded, required this.heroTag});

  @override
  State<AddBirthdayFab> createState() => _AddBirthdayFabState();
}

class _AddBirthdayFabState extends State<AddBirthdayFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: widget.heroTag,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddBirthdayView(
              onBirthdayAdded: widget.onBirthdayAdded,
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
