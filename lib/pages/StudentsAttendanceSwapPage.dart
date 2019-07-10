import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/models/Course.dart';
import 'package:hschool/models/Student.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';
import 'package:hschool/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  void deleteItem(index) {
    /*
    By implementing this method, it ensures that upon being dismissed from our widget tree,
    the item is removed from our list of items and our list is updated, hence
    preventing the "Dismissed widget still in widget tree error" when we reload.
    */
    setState(() {
      _list_students.removeAt(index);
    });
  }

  void undoDeletion(index, item) {
    /*
    This method accepts the parameters index and item and re-inserts the {item} at
    index {index}
    */
    setState(() {
      _list_students.insert(index, item);
    });
  }

  Widget stackBehindDismiss(var date) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.green,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.white,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text("$date")
        ],
      ),
    );
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

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-d kk:mm:ss').format(now);

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
                            background: stackBehindDismiss(formattedDate),
                            key: ObjectKey(_list_students[index]),
                            child: makeCard(
                              _list_students[index].name,
                              _list_students[index].id,
                            ),
                            onDismissed: (direction) {
                              var student = _list_students.elementAt(index);
                              var item = _list_students[index];
                              deleteItem(index);
                              _scaffoldKey.currentState.showSnackBar(
                                new SnackBar(
                                  content: new Text("${student.name}"),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () {
                                      //To undo deletion
                                      undoDeletion(index, item);
                                    },
                                  ),
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
