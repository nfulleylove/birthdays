import 'package:birthdays/models/birthday.dart';

class SectionItem {
  final bool isHeader;
  final String? header;
  final Birthday? birthday;
  final String? emptyMessage;
  final int monthIndex;

  SectionItem.header(this.header, this.monthIndex)
      : isHeader = true,
        birthday = null,
        emptyMessage = null;

  SectionItem.birthday(this.birthday, this.monthIndex)
      : isHeader = false,
        emptyMessage = null,
        header = null;

  SectionItem.empty(this.emptyMessage, this.monthIndex)
      : isHeader = false,
        birthday = null,
        header = null;
}
