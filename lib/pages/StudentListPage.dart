import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/models/Course.dart';
import 'package:hschool/models/Student.dart';
import 'package:hschool/pages/StudentsAttendanceSwapPage.dart';
import 'package:hschool/utils/auth_utils.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';
import 'package:hschool/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'StudentsAttendancePage.dart';

class StudentListPage extends StatefulWidget {
  static final String routeName = 'studentList';
  final Course course;

  const StudentListPage({Key key, this.course}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StudentListState(course);
}

class _StudentListState extends State<StudentListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Course course;
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  bool _isLoading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _user;
  SharedPreferences _sharedPreferences;
  var _authToken;
  var _list_students = new List<Student>();

  _StudentListState(this.course);

  @override
  initState() {
    super.initState();
    _fetchSessionAndNavigate();
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

  _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  _fetchSessionAndNavigate() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getAuthorization(_sharedPreferences);

    _fetchHome(authToken);

    setState(() {
      _authToken = authToken;
    });
    if (_authToken == null) {
      _logout();
    }
  }

  _fetchHome(String authToken) async {
    _showLoading();
    var __user = await NetworkUtils.fetchLecturerUser(authToken);
    if (__user == null) {
      NetworkUtils.showSnackBar(_scaffoldKey, 'Something went wrong!');
      // ignore: unrelated_type_equality_checks
    } else if (__user == 'NetworkError') {
      NetworkUtils.showSnackBar(_scaffoldKey, null);
    } else if (__user == false) {
      _logout();
    }

    var _list_students_ = await NetworkUtils.fetch(_authToken,
        '/api/v1/app/lecturer/students/${course.department_id}/${course.year}');
    var p = _list_students_.cast<Map<String, dynamic>>();
    var pp = p.map<Student>((json) => Student.fromJson(json)).toList();

    setState(() {
      _user = __user;
      _list_students = pp;
    });

    _hideLoading();
  }

  _logout() {
    NetworkUtils.logoutStudentUser(
        _scaffoldKey.currentContext, _sharedPreferences);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    var _user;

    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar:AppBar(
          title: Text(course.name),
          elevation: 5.5,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.av_timer),
              onPressed: () {
                if (_list_students.length > 0) {
                  Navigator.push(
                    _scaffoldKey.currentContext,
                    MaterialPageRoute(
                      builder: (context) => StudentsAttendanceSwapPage(
                            course: course,
                            students: _list_students,
                          ),
                    ),
                  );
                }
              },
              tooltip: 'Student Attendance',
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
                child: Text(
                  "Students list of Y${course.year}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w400, color: Colors.white),
                ),
              ),
              _list_students.length > 0
                  ? Container(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _list_students.length,
                        itemBuilder: (BuildContext context, int index) {
                          return makeCard(
                            _list_students[index].name,
                            _list_students[index].id,
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
