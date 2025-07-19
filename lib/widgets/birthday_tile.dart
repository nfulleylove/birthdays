import 'package:birthdays/data/birthdays_sql_helper.dart';
import 'package:birthdays/services/birthday_notifier.dart';
import 'package:birthdays/views/edit_birthday_view.dart';
import 'package:flutter/material.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/enums/sex.dart';
import 'package:provider/provider.dart';

class BirthdayTile extends StatelessWidget {
  final Birthday birthday;
  final void Function(Birthday updated)? onBirthdayUpdated;
  final void Function(Birthday deleted)? onBirthdayDeleted;

  const BirthdayTile({
    super.key,
    required this.birthday,
    this.onBirthdayUpdated,
    this.onBirthdayDeleted,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.day == date.day && now.month == date.month;
  }

  Color _todayColor(BuildContext context) {
    return const Color(0xFFB8860B);
  }

  Color _iconColorForSex(BuildContext context, Sex sex, bool isToday) {
    if (isToday) return _todayColor(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return sex == Sex.female
        ? (isDark ? Colors.pink.shade200 : Colors.pink)
        : (isDark ? Colors.lightBlue.shade300 : Colors.lightBlue);
  }

  Future<void> _updateBirthday(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditBirthdayView(
          birthday: birthday,
          onBirthdayUpdated: onBirthdayUpdated,
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Birthday'),
        content: const Text('Are you sure you want to delete this birthday?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteBirthday(BuildContext context) async {
    final wasDeleted = await BirthdaysSqlHelper().deleteBirthday(birthday);
    if (wasDeleted && context.mounted) {
      Provider.of<BirthdayNotifier>(context, listen: false)
          .deleteBirthday(birthday);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Birthday deleted")),
      );
      // onBirthdayDeleted?.call(birthday.id);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting birthday")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(birthday.date);
    final todayColor = _todayColor(context);

    final tileContent = ListTile(
      leading: Icon(
        Icons.cake_rounded,
        color: _iconColorForSex(context, birthday.sex, isToday),
        semanticLabel: 'Birthday icon',
      ),
      title: Text(
        birthday.dateTextForGivenYear(birthday.year),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? todayColor : null,
            ),
      ),
      subtitle: Text(
        birthday.title(birthday.date.year),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? todayColor : null,
            ),
      ),
      onTap: () => _updateBirthday(context),
    );

    return Dismissible(
      key: Key(birthday.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.red.shade400
            : Colors.red,
        child: const Icon(Icons.delete,
            color: Colors.white, semanticLabel: 'Delete'),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _deleteBirthday(context),
      child: tileContent,
    );
  }
}
