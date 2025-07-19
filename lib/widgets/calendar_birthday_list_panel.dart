import 'package:flutter/material.dart';
import '../models/birthday.dart';
import '../widgets/birthday_tile.dart';

class CalendarBirthdayListPanel extends StatelessWidget {
  final List<Birthday> birthdays;
  final void Function(Birthday) onDelete;
  final void Function(Birthday) onUpdate;

  const CalendarBirthdayListPanel({
    super.key,
    required this.birthdays,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (birthdays.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No birthdays on this day.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: birthdays.length,
      itemBuilder: (context, index) {
        final b = birthdays[index];
        return BirthdayTile(
          birthday: b,
          onBirthdayDeleted: (_) => onDelete(b),
          onBirthdayUpdated: onUpdate,
        );
      },
    );
  }
}
