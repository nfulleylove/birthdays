import 'package:birthdays/data/birthdays_database.dart';
import 'package:birthdays/widgets/permission_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:birthdays/helpers/preferences_helper.dart';
import 'package:birthdays/services/notification_service.dart';
import 'package:birthdays/services/birthday_notifier.dart';
import 'package:birthdays/views/list_view.dart';
import 'package:birthdays/views/calendar_view.dart';
import 'package:birthdays/views/settings_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _startApp();
}

Future<void> _startApp() async {
  if (kDebugMode) {
    await BirthdaysDatabase().resetAndSeedDevDatabase();
  }

  tz.initializeTimeZones();
  final currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  await NotificationService().initialise();

  final defaultIndex = await PreferencesHelper().getDefaultTabIndex();

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final notifier = BirthdayNotifier();

        notifier.loadAll();

        return notifier;
      },
      child: MainApp(defaultPageIndex: defaultIndex),
    ),
  );
}

class MainApp extends StatefulWidget {
  final int defaultPageIndex;

  const MainApp({super.key, required this.defaultPageIndex});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late int pageIndex;

  static const List<Widget> _pages = [
    BirthdaysListView(),
    CalendarView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    pageIndex = widget.defaultPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Birthdays',
        themeMode: ThemeMode.system,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: PermissionGate(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isPortrait = orientation == Orientation.portrait;

              return Scaffold(
                appBar: isPortrait
                    ? AppBar(
                        title: const Text("Birthdays",
                            style: TextStyle(fontSize: 18)),
                        leading: const Icon(Icons.cake, size: 20),
                        centerTitle: true,
                        toolbarHeight: 42,
                        backgroundColor:
                            Theme.of(context).appBarTheme.backgroundColor,
                        foregroundColor:
                            Theme.of(context).appBarTheme.foregroundColor,
                      )
                    : AppBar(
                        toolbarHeight: 40,
                        title: const Text('Birthdays'),
                      ),
                drawer: isPortrait
                    ? null
                    : Drawer(
                        child: SafeArea(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              const DrawerHeader(
                                decoration:
                                    BoxDecoration(color: Colors.deepPurple),
                                child: Text('Birthdays',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24)),
                              ),
                              _buildDrawerItem(
                                context,
                                Icons.list,
                                'List',
                                0,
                                pageIndex == 0,
                              ),
                              _buildDrawerItem(
                                context,
                                Icons.calendar_month,
                                'Calendar',
                                1,
                                pageIndex == 1,
                              ),
                              _buildDrawerItem(
                                context,
                                Icons.settings,
                                'Settings',
                                2,
                                pageIndex == 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                bottomNavigationBar: isPortrait
                    ? NavigationBar(
                        selectedIndex: pageIndex,
                        onDestinationSelected: (i) =>
                            setState(() => pageIndex = i),
                        destinations: const [
                          NavigationDestination(
                              icon: Icon(Icons.list_outlined), label: 'List'),
                          NavigationDestination(
                              icon: Icon(Icons.calendar_month_outlined),
                              label: 'Calendar'),
                          NavigationDestination(
                              icon: Icon(Icons.settings_outlined),
                              label: 'Settings'),
                        ],
                      )
                    : null,
                body: _pages[pageIndex],
              );
            },
          ),
        ));
  }

  Widget _buildDrawerItem(
      BuildContext ctx, IconData icon, String title, int index, bool selected) {
    return Builder(
      builder: (drawerCtx) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        selected: selected,
        onTap: () {
          Navigator.of(drawerCtx).pop();
          setState(() => pageIndex = index);
        },
      ),
    );
  }
}
