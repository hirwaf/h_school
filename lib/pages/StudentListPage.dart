import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/models/Course.dart';
import 'package:hschool/models/Student.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';

class StudentListPage extends StatefulWidget {
  static final String routeName = 'studentList';

  @override
  State<StatefulWidget> createState() => _StudentListState();
}

class _StudentListState extends State<StudentListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  @override
  initState() {
    super.initState();

    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    var _user;
    Course course = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(course.name),
          elevation: 5.5,
          actions: <Widget>[
            GestureDetector(
              onTap: () {},
              child: IconButton(
                icon: const Icon(Icons.av_timer),
                onPressed: () {
                  _scaffoldKey.currentState.showSnackBar(
                    new SnackBar(
                      content: new Text(
                        "Attendance of ${course.department} ${course.year}",
                      ),
                    ),
                  );
                },
                tooltip: 'Student Attendance',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.near_me),
              onPressed: () {
                _scaffoldKey.currentState.showSnackBar(
                  new SnackBar(
                    content: new Text(
                        "Send Message to all students of ${course.department} ${course.year}"),
                  ),
                );
              },
              tooltip: 'Send notification',
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: !isOffline ? _body(course) : _loading(),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
    );
  }

  void _logout() {}

  List<Student> _students_list() {
    List<Student> students = [
      new Student(
        name: 'MDASIRU Elphaz',
        id: "216247554",
        department: 'Information Sytems',
        year: 'Y4',
      ),
      new Student(
        name: 'NISHIMWE Theodosie',
        id: "216138364",
        department: 'Information Sytems',
        year: 'Y4',
      ),
      new Student(
        name: 'HIRWA Felix',
        id: "216238994",
        department: 'Information Sytems',
        year: 'Y4',
      ),
    ];
    return students;
  }

  Widget _body(Course course) {
    final makeListTile = (String name, String id) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          leading: Container(
            padding: EdgeInsets.only(right: 10.0, top: 7.0),
            child: Icon(Icons.school, color: Colors.white24),
          ),
          title: Text(
            name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
              Icon(Icons.arrow_right, color: Colors.blueAccent[100]),
              SizedBox(width: 10.0),
              Text(id, style: TextStyle(color: Colors.white))
            ],
          ),
          trailing: Icon(Icons.message, color: Colors.white, size: 30.0),
        );

    final makeCard = (String name, String id) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(64, 75, 96, .9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.showSnackBar(
                  new SnackBar(
                    content: new Text("$name - $id"),
                  ),
                );
              },
              child: makeListTile(name, id),
            ),
          ),
        );

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.2),
            color: const Color.fromRGBO(6, 5, 24, 1),
          ),
          child: Text(
            "Students list of ${course.year}",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ),
        Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _students_list().length,
            itemBuilder: (BuildContext context, int index) {
              return makeCard(
                _students_list()[index].name,
                _students_list()[index].id,
              );
            },
          ),
        )
      ],
    );
  }

  Widget _loading() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "There is not internet connection !!!",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SpinKitFadingCircle(
            itemBuilder: (_, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.red : Colors.green,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
