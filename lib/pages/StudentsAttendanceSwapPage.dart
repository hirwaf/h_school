import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/models/Course.dart';
import 'package:hschool/models/Student.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';
import 'package:hschool/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue/flutter_blue.dart';

class StudentsAttendanceSwapPage extends StatefulWidget {
  static final String routeName = 'studentList';
  final Course course;
  final List<Student> students;
  final dynamic token;

  const StudentsAttendanceSwapPage(
      {Key key, this.course, this.students, this.token})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _StudentListState(course, students, token);
}

class _StudentListState extends State<StudentsAttendanceSwapPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Course course;
  final List<Student> students;
  final dynamic token;
  StreamSubscription _connectionChangeStream;
  var scanSubscription;
  bool isOffline = false;
  bool _isLoading = false;
  SharedPreferences _sharedPreferences;
  var _authToken;
  var _list_students;

  _StudentListState(this.course, this.students, this.token);

  @override
  initState() {
    super.initState();
    _list_students = students;
    _authToken = token;
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

  _logout() {
    NetworkUtils.logoutStudentUser(
        _scaffoldKey.currentContext, _sharedPreferences);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Attendance"),
          elevation: 5.5,
          actions: <Widget>[
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
        );

    final makeCard = (String name, String id) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(64, 75, 96, .9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: makeListTile(name, id),
          ),
        );

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.2),
                  color: const Color.fromRGBO(6, 5, 24, 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${course.department} | Y${course.year}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                    Text(
                      "Remain Students (${_list_students.length}) / (${students.length})",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.white),
                    )
                  ],
                ),
              ),
              _list_students.length > 0
                  ? Container(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _list_students.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Dismissible(
                            key: ObjectKey(_list_students[index]),
                            child: makeCard(
                              _list_students[index].name,
                              _list_students[index].id,
                            ),
                            onDismissed: (direction) {
                              var student = _list_students.elementAt(index);
                              _scaffoldKey.currentState.showSnackBar(
                                new SnackBar(
                                  content: new Text(student.name),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "No Students fund !!!",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
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
