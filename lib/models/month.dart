class Month {
  int number = 0;
  String name = "January";

  Month(this.number, this.name);

  static List<Month> getAll() => [
        Month(DateTime.january, "January"),
        Month(DateTime.february, "February"),
        Month(DateTime.march, "March"),
        Month(DateTime.april, "April"),
        Month(DateTime.may, "May"),
        Month(DateTime.june, "June"),
        Month(DateTime.july, "July"),
        Month(DateTime.august, "August"),
        Month(DateTime.september, "September"),
        Month(DateTime.october, "October"),
        Month(DateTime.november, "November"),
        Month(DateTime.december, "December"),
      ];
}
