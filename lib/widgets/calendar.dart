import 'package:birthdays/extensions/birthday_model_copier.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';
import '../models/birthday_month.dart';

class CalendarWidget extends StatelessWidget {
  final int minYear;
  final int maxYear;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<BirthdayMonth> months;
  final bool isLandscape;
  final void Function(DateTime)? onHeaderTap;
  final void Function(DateTime)? onPreviousMonth;
  final void Function(DateTime)? onNextMonth;
  final void Function(DateTime, DateTime)? onDaySelected;
  final void Function(DateTime)? onPageChanged;

  const CalendarWidget({
    super.key,
    required this.minYear,
    required this.maxYear,
    required this.focusedDay,
    required this.selectedDay,
    required this.months,
    required this.isLandscape,
    required this.onHeaderTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  List<Birthday> getBirthdaysForDay(DateTime day) {
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
    return TableCalendar<Birthday>(
      firstDay: DateTime(minYear),
      lastDay: DateTime(maxYear, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (d) => isSameDay(d, selectedDay),
      daysOfWeekHeight: isLandscape ? 20.0 : 32.0,
      rowHeight: isLandscape ? 35.0 : 52.0,
      sixWeekMonthsEnforced: false,
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      headerVisible: true,
      headerStyle: HeaderStyle(
        titleCentered: false,
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        headerPadding: EdgeInsets.only(
          top: isLandscape ? 0 : 10,
          bottom: isLandscape ? 0 : 10,
          left: 10,
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: isLandscape ? 16.0 : 20.0,
              fontWeight: FontWeight.w600,
            ),
      ),
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day) {
          final locale = Localizations.localeOf(context).toString();
          final title = DateFormat.yMMMM(locale).format(day);

          return SizedBox(
            height: isLandscape ? 40.0 : null,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onHeaderTap?.call(day),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontSize: isLandscape ? 16.0 : 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: isLandscape ? 20.0 : 24.0,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: isLandscape ? 20.0 : 24.0,
                  icon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => onPreviousMonth?.call(day),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: isLandscape ? 20.0 : 24.0,
                  icon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => onNextMonth?.call(day),
                ),
              ],
            ),
          );
        },
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          shape: BoxShape.circle,
        ),
        markerSize: 6.0,
        markersMaxCount: 1,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        weekendStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date),
      ),
      eventLoader: (day) => getBirthdaysForDay(day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
    );
  }
}
