import 'package:birthdays/birthdays/enums/sex.dart';
import 'package:birthdays/birthdays/models/colours.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/birthday.dart';

class BirthdayDetailsFormFields extends StatefulWidget {
  const BirthdayDetailsFormFields({Key? key, required this.birthday})
      : super(key: key);

  final BirthdayModel birthday;

  @override
  State<BirthdayDetailsFormFields> createState() =>
      _BirthdayDetailsFormFieldsState();
}

class _BirthdayDetailsFormFieldsState extends State<BirthdayDetailsFormFields> {
  final TextEditingController _dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var birthday = widget.birthday;
    _dateController.text = DateFormat('dd/MM/yyyy').format(birthday.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () async {
              await setDate();
            },
            decoration: const InputDecoration(label: Text('Date'))),
        TextFormField(
            initialValue: widget.birthday.forename,
            onSaved: (newValue) => widget.birthday.forename = newValue ?? '',
            decoration: const InputDecoration(label: Text('Forename*')),
            maxLength: 50,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                value?.isEmpty == true ? 'Forename is required.' : null),
        TextFormField(
          initialValue: widget.birthday.surname,
          onSaved: (newValue) => widget.birthday.surname = newValue ?? '',
          decoration: const InputDecoration(label: Text('Surname')),
          maxLength: 50,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        Row(
          children: [
            const Icon(
              Icons.male_outlined,
              color: Colours.blue,
            ),
            Switch(
              value: widget.birthday.sex == Sex.male ? false : true,
              onChanged: (newValue) => setState(() => widget.birthday.sex =
                  (newValue == false ? Sex.male : Sex.female)),
              activeTrackColor: Colours.pink,
              inactiveTrackColor: Colours.blue,
              inactiveThumbColor: Colors.white,
            ),
            const Icon(
              Icons.female_outlined,
              color: Colours.pink,
            )
          ],
        ),
      ],
    );
  }

  setDate() async {
    var result = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: widget.birthday.date,
        firstDate: DateTime.now().add(const Duration(days: -365 * 200)),
        lastDate: DateTime.now(),
        locale: const Locale('en'));

    if (result != null) {
      setState(() {
        widget.birthday.date = result;
        _dateController.text =
            DateFormat('dd/MM/yyyy').format(widget.birthday.date);
      });
    }
  }
}
