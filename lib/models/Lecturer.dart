class Lecturer {
  final String id;
  final String names;
  final String telephone;
  final String email;
  final String gender;

  Lecturer({this.id, this.names, this.telephone, this.email, this.gender});

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
        id: json['id'].toString(),
        names: json['names'],
        telephone: json['telephone'],
        email: json['email'],
        gender: json['gender']
    );
  }
}
