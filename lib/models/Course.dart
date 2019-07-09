class Course {
  final String id;
  final String name;
  final String department;
  final String year;
  final String department_id;

  Course({this.id, this.name, this.department, this.year, this.department_id});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        id: json['id'].toString(),
        name: json['name'],
        department: json['department'],
        year: json['year'].toString(),
        department_id: json['department_id'].toString()
    );
  }

}