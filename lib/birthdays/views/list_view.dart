import 'package:birthdays/birthdays/data/birthdays_sql_helper.dart';
import 'package:birthdays/birthdays/helpers/birthdays_helper.dart';
import 'package:birthdays/birthdays/models/birthday.dart';
import 'package:birthdays/birthdays/models/birthdays_in_month.dart';
import 'package:birthdays/birthdays/models/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../enums/sex.dart';
import '../forms/birthday_form_fields.dart';

class BirthdaysListView extends StatefulWidget {
  const BirthdaysListView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BirthdaysListViewState();
}

class _BirthdaysListViewState extends State<BirthdaysListView> {
  final BirthdaysSqlHelper sqlHelper = BirthdaysSqlHelper();
  List<MonthWithBirthdays> birthdays = [];
  Future<List<MonthWithBirthdays>> get _birthdays => getBirthdays();

  bool hasScrolled = false;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  void scrollToCurrentMonth() {
    int currentMonthIndex = 10;
    // DateTime.now().month - 1;

    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
          index: currentMonthIndex, duration: Durations.long1);
      hasScrolled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => scrollToCurrentMonth());

    return Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.cake,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            "Birthdays",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: addBirthday, child: const Icon(Icons.add)),
        body: FutureBuilder<List<MonthWithBirthdays>>(
            future: _birthdays,
            builder: ((context, snapshot) {
              birthdays = snapshot.hasData
                  ? snapshot.data as List<MonthWithBirthdays>
                  : [];

              if (birthdays.isNotEmpty) {
                return ScrollablePositionedList.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: birthdays.length,
                  itemScrollController: itemScrollController,
                  scrollOffsetController: scrollOffsetController,
                  itemPositionsListener: itemPositionsListener,
                  scrollOffsetListener: scrollOffsetListener,
                  itemBuilder: (context, index) {
                    var birthdayMonth = birthdays[index];
                    return Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: ListTile(
                                      title: Text(
                                    birthdayMonth.month.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ))),
                              //Text(month.text),
                              birthdayMonth.birthdays.isEmpty
                                  ? Text(
                                      "No birthdays in ${birthdayMonth.month.name}")
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: birthdayMonth.birthdays.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        BirthdayModel birthday =
                                            birthdayMonth.birthdays[index];
                                        // Return a widget representing the item
                                        return Dismissible(
                                            key: Key(birthday.id.toString()),
                                            direction:
                                                DismissDirection.endToStart,
                                            confirmDismiss: confirmDeletion,
                                            onDismissed: (direction) async =>
                                                await deleteBirthday(birthday),
                                            background: Container(
                                                color: Colors.red,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                alignment: AlignmentDirectional
                                                    .centerEnd,
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                )),
                                            child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                shadowColor: Colors.transparent,
                                                color: const Color.fromRGBO(
                                                    254, 254, 254, 0.2),
                                                child: ListTile(
                                                  onTap: () =>
                                                      updateBirthday(birthday),
                                                  leading: Icon(
                                                    Icons.cake_rounded,
                                                    color:
                                                        birthday.sex == Sex.male
                                                            ? Colours.blue
                                                            : Colours.pink,
                                                  ),
                                                  title:
                                                      Text(birthday.shortDate),
                                                  subtitle:
                                                      Text(birthday.title),
                                                )));
                                      },
                                    )
                            ]));
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                );
              } else {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Text("No birthdays have been added"),
                      ElevatedButton(
                          onPressed: () async => addBirthday(),
                          child: const Text("Add a Birthday"))
                    ]));
              }
            })));
  }

  Future deleteBirthday(BirthdayModel birthday) async {
    bool wasDeleted = await sqlHelper.deleteBirthday(birthday);

    if (wasDeleted) {
      setState(() {
        birthdays
            .where((x) => x.month.number == birthday.date.month)
            .forEach((month) => month.birthdays.remove(birthday));
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Birthday deleted"),
        ));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error deleting birthday"),
        ));
      }
    }
  }

  Future addBirthday() async {
    final formKey = GlobalKey<FormState>();
    var birthday = BirthdayModel(-1, DateTime.now(), "", "");

    return await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Birthday'),
          content: SingleChildScrollView(
              child: Form(
            key: formKey,
            child: BirthdayDetailsFormFields(birthday: birthday),
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text('Add'),
                onPressed: () async {
                  var form = formKey.currentState;

                  if (form!.validate()) {
                    form.save();
                    int birthdayId = await sqlHelper.insertBirthday(birthday);

                    if (birthdayId > 0) {
                      setState(() {
                        birthday.id = birthdayId;

                        for (var month in birthdays.where((element) =>
                            element.month.number == birthday.date.month)) {
                          month.birthdays.add(birthday);
                        }
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Birthday added"),
                        ));

                        Navigator.of(context).pop();
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Error adding birthday"),
                        ));
                      }
                    }
                  }
                }),
          ],
        );
      },
    );
  }

  Future updateBirthday(BirthdayModel birthday) async {
    final formKey = GlobalKey<FormState>();

    return await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Birthday'),
          content: SingleChildScrollView(
              child: Form(
            key: formKey,
            child: BirthdayDetailsFormFields(birthday: birthday),
          )),
          actions: <Widget>[
            TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
                child: const Text('Update'),
                onPressed: () async {
                  var form = formKey.currentState;

                  if (form!.validate()) {
                    form.save();
                    bool wasUpdated = await sqlHelper.updateBirthday(birthday);

                    if (wasUpdated) {
                      setState(() {});

                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Birthday updated"),
                        ));

                        Navigator.of(context).pop();
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Error updating birthday"),
                        ));
                      }
                    }
                  }
                }),
          ],
        );
      },
    );
  }

  Future<List<MonthWithBirthdays>> getBirthdays() async {
    try {
      return await BirthdaysHelper().getBirthdaysForCurrentYear();
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error retrieving birthdays"),
      ));

      return Future.error(ex);
    }
  }

  Future<bool?> confirmDeletion(DismissDirection direction) async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Birthday'),
          content: const Text('Are you sure you want to delete the birthday?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
