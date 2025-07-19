import 'package:birthdays/forms/birthday_form_fields.dart';
import 'package:birthdays/helpers/birthdays_helper.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/services/birthday_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBirthdayView extends StatelessWidget {
  final void Function(Birthday added)? onBirthdayAdded;

  const AddBirthdayView({super.key, this.onBirthdayAdded});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final birthday = Birthday(
      -1,
      DateTime.now(),
      '',
      '',
      DateTime.now().year,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Add Birthday')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600, // Adjust maxWidth as needed
            ),
            child: Form(
              key: formKey,
              child: BirthdayDetailsFormFields(birthday: birthday),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () async {
          if (formKey.currentState?.validate() ?? false) {
            formKey.currentState!.save();
            final newId = await BirthdaysHelper().addBirthday(birthday);
            if (!context.mounted) return;

            if (newId > 0) {
              birthday.id = newId;

              await Provider.of<BirthdayNotifier>(context, listen: false)
                  .addBirthday(birthday);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Birthday added')),
              );

              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error adding birthday')),
              );
            }
          }
        },
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
