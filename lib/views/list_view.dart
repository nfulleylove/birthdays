import 'package:birthdays/models/section_item.dart';
import 'package:birthdays/models/birthday_month.dart';
import 'package:birthdays/services/birthday_notifier.dart';
import 'package:birthdays/widgets/add_birthday_fab.dart';
import 'package:birthdays/widgets/birthday_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BirthdaysListView extends StatefulWidget {
  const BirthdaysListView({super.key});

  @override
  State<BirthdaysListView> createState() => _BirthdaysListViewState();
}

class _BirthdaysListViewState extends State<BirthdaysListView> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  final Set<int> _collapsedMonths = {};
  bool _hasInitialisedCollapsed = false;
  bool _hasScrolled = false;

  List<SectionItem> _buildSections(List<BirthdayMonth> months) {
    final out = <SectionItem>[];
    for (var i = 0; i < months.length; i++) {
      final m = months[i];
      out.add(SectionItem.header('${m.month.name} ${m.year}', i));

      if (_collapsedMonths.contains(i)) continue;

      if (m.birthdays.isEmpty) {
        out.add(SectionItem.empty('No birthdays in ${m.month.name}', i));
      } else {
        for (var b in m.birthdays) {
          out.add(SectionItem.birthday(b, i));
        }
      }
    }
    return out;
  }

  void _scrollToCurrentMonth(List<SectionItem> sections) {
    if (_hasScrolled) return;

    final now = DateTime.now();
    final dateLabel = '${DateFormat.MMMM().format(now)} ${now.year}';

    final sectionIndex = sections.indexWhere(
      (s) => s.isHeader && s.header == dateLabel,
    );
    if (sectionIndex == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.scrollTo(
        index: sectionIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _hasScrolled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayNotifier>(
      builder: (context, notifier, child) {
        final months = notifier.months;

        // 1) Initialize collapsed state only once, after months load
        if (!_hasInitialisedCollapsed && months.isNotEmpty) {
          final now = DateTime.now();
          final currentMonthIndex = months.indexWhere((m) =>
              m.month.name == DateFormat.MMMM().format(now) &&
              m.year == now.year);

          for (var i = 0; i < months.length; i++) {
            final m = months[i];
            // collapse empty months except the current one
            if (m.birthdays.isEmpty && i != currentMonthIndex) {
              _collapsedMonths.add(i);
            }
          }
          _hasInitialisedCollapsed = true;
        }

        final sections = _buildSections(months);
        _scrollToCurrentMonth(sections);

        return Scaffold(
          floatingActionButton: AddBirthdayFab(
            heroTag: 'list_view_add_birthday_fab',
            onBirthdayAdded: notifier.addBirthday,
          ),
          body: ScrollablePositionedList.builder(
            itemCount: sections.length,
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            itemBuilder: (ctx, idx) {
              final item = sections[idx];
              final isCollapsed = _collapsedMonths.contains(item.monthIndex);

              if (item.isHeader) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isCollapsed) {
                        _collapsedMonths.remove(item.monthIndex);
                      } else {
                        _collapsedMonths.add(item.monthIndex);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.header!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          isCollapsed ? Icons.expand_more : Icons.expand_less,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (item.emptyMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, bottom: 20),
                  child: Text(
                    item.emptyMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                );
              }

              return BirthdayTile(
                birthday: item.birthday!,
                onBirthdayUpdated: (u) => notifier.updateBirthday(u),
                onBirthdayDeleted: (id) =>
                    notifier.deleteBirthday(item.birthday!),
              );
            },
          ),
        );
      },
    );
  }
}
