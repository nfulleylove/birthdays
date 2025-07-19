import 'package:birthdays/extensions/birthday_model_copier.dart';
import 'package:birthdays/widgets/calendar.dart';
import 'package:birthdays/widgets/calendar_birthday_list_panel.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import '../models/birthday.dart';
import '../models/birthday_month.dart';
import '../services/birthday_notifier.dart';
import '../widgets/add_birthday_fab.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final int _minYear = DateTime.now().year;
  final int _maxYear = DateTime.now().year + 1;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Future<void> _handleHeaderTap([DateTime? focused]) async {
    final init = focused ?? _focusedDay;
    final picked = await showMonthPicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(_minYear),
      lastDate: DateTime(_maxYear, 12),
    );
    if (picked != null) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = picked;
      });
    }
  }

  void _previousMonth() {
    final prev = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    setState(() {
      _focusedDay = prev;
      _selectedDay = prev;
    });
  }

  void _nextMonth() {
    final next = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    setState(() {
      _focusedDay = next;
      _selectedDay = next;
    });
  }

  List<Birthday> _getBirthdaysForDay(DateTime day, List<BirthdayMonth> months) {
    final seen = <int>{};
    return months
        .expand((m) => m.birthdays)
        .where((b) =>
            b.date.month == day.month &&
            b.date.day == day.day &&
            seen.add(b.id))
        .map((b) => b.copyWith(year: day.year))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayNotifier>(
      builder: (ctx, notifier, _) {
        final months = notifier.months;
        final todays = _getBirthdaysForDay(_selectedDay, months);
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        final calendar = CalendarWidget(
          minYear: _minYear,
          maxYear: _maxYear,
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          months: months,
          isLandscape: isLandscape,
          onHeaderTap: _handleHeaderTap,
          onPreviousMonth: (_) => _previousMonth(),
          onNextMonth: (_) => _nextMonth(),
          onDaySelected: (day, focused) => setState(() {
            _selectedDay = day;
            _focusedDay = focused;
          }),
          onPageChanged: (focused) => setState(() {
            _focusedDay = focused;
            _selectedDay = DateTime(focused.year, focused.month, 1);
          }),
        );

        final birthdayList = CalendarBirthdayListPanel(
          birthdays: todays,
          onUpdate: notifier.updateBirthday,
          onDelete: notifier.deleteBirthday,
        );

        final body = isLandscape
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(child: calendar),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(flex: 2, child: birthdayList),
                ],
              )
            : Column(
                children: [
                  calendar,
                  const Divider(height: 1),
                  Expanded(child: birthdayList),
                ],
              );

        return Scaffold(
          body: body,
          floatingActionButton: AddBirthdayFab(
            heroTag: 'calendar_view_add_birthday_fab',
            onBirthdayAdded: notifier.addBirthday,
          ),
        );
      },
    );
  }
}
