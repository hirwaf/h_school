class Student {
  final String name;
  final String id;
  final String department;
  final String year;

  Student({this.name, this.id, this.department, this.year});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        id: json['id'].toString(),
        name: json['name'],
        department: json['department'],
        year: json['year'].toString()
    );
  }

}