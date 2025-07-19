import 'package:birthdays/forms/birthday_form_fields.dart';
import 'package:birthdays/helpers/birthdays_helper.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/services/birthday_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditBirthdayView extends StatelessWidget {
  final Birthday birthday;
  final void Function(Birthday)? onBirthdayUpdated;

  const EditBirthdayView({
    super.key,
    required this.birthday,
    this.onBirthdayUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Birthday')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Form(
              key: formKey,
              child: BirthdayDetailsFormFields(birthday: birthday),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "edit_birthday_fab",
        onPressed: () async {
          final form = formKey.currentState;
          if (form != null && form.validate()) {
            form.save();
            final updated = await BirthdaysHelper().updateBirthday(birthday);

            if (updated && context.mounted) {
              Provider.of<BirthdayNotifier>(context, listen: false)
                  .updateBirthday(birthday);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Birthday updated')),
              );

              Navigator.pop(context);
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error updating birthday')),
              );
            }
          }
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
