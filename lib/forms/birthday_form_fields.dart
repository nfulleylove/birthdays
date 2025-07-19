import 'package:birthdays/enums/sex.dart';
import 'package:flutter/material.dart';
import '../models/birthday.dart';

class BirthdayDetailsFormFields extends StatefulWidget {
  const BirthdayDetailsFormFields({super.key, required this.birthday});

  final Birthday birthday;

  @override
  State<BirthdayDetailsFormFields> createState() =>
      _BirthdayDetailsFormFieldsState();
}

class _BirthdayDetailsFormFieldsState extends State<BirthdayDetailsFormFields> {
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var birthday = widget.birthday;

    _dateController.text = birthday.shortDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () async {
            await setDate();
          },
          decoration: const InputDecoration(label: Text('Date')),
        ),
        TextFormField(
          initialValue: birthday.forename,
          onSaved: (newValue) => birthday.forename = newValue?.trim() ?? '',
          decoration: const InputDecoration(label: Text('Forename')),
          maxLength: 50,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (value) =>
              value?.isEmpty == true ? 'Forename is required.' : null,
        ),
        TextFormField(
          initialValue: birthday.surname,
          onSaved: (newValue) => birthday.surname = newValue?.trim() ?? '',
          decoration: const InputDecoration(label: Text('Surname')),
          maxLength: 50,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        Row(
          children: [
            Icon(
              Icons.male_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.lightBlue.shade300
                  : Colors.lightBlue,
            ),
            Switch(
              value: birthday.sex == Sex.female,
              onChanged: (newValue) => setState(() {
                birthday.sex = newValue ? Sex.female : Sex.male;
              }),
              activeTrackColor: Colors.pinkAccent,
              inactiveTrackColor: Colors.lightBlueAccent,
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white,
            ),
            Icon(
              Icons.female_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.pink.shade200
                  : Colors.pink,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("Reminder Preferences",
            style: Theme.of(context).textTheme.titleMedium),
        SwitchListTile(
          title: const Text("Remind one week before"),
          value: birthday.reminders.remindOneWeek,
          onChanged: (val) => setState(() {
            birthday.reminders.remindOneWeek = val;
          }),
        ),
        SwitchListTile(
          title: const Text("Remind two weeks before"),
          value: birthday.reminders.remindTwoWeeks,
          onChanged: (val) => setState(() {
            birthday.reminders.remindTwoWeeks = val;
          }),
        ),
        SwitchListTile(
          title: const Text("Remind four weeks before"),
          value: birthday.reminders.remindFourWeeks,
          onChanged: (val) => setState(() {
            birthday.reminders.remindFourWeeks = val;
          }),
        ),
      ],
    );
  }

  Future<void> setDate() async {
    var result = await showDatePicker(
      context: context,
      initialDate: widget.birthday.date,
      firstDate: DateTime.now().add(const Duration(days: -365 * 200)),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        widget.birthday.date = result;
        _dateController.text = widget.birthday.shortDate;
      });
    }
  }
}
