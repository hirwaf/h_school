import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/components/portal_button.dart';
import 'package:hschool/pages/LecturerLoginPage.dart';
import 'package:hschool/pages/StudentLoginPage.dart';
import 'package:hschool/routes.dart';
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

    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('UR Lecturer'),
          elevation: 5.5,
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 5.0, 5.0),
              child: Text(
                _user != null ? _user.name : "Hirwa Felix",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: !isOffline ? _body() : _loading(),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
    );
  }

  void _logout() {}

  List<dynamic> _course_list() {
    List<String> courses = [
      'Information System',
      'IS Project Management',
      'IS Security'
    ];
    return courses;
  }

  Widget _body() {
    final makeListTile = (String course, String department) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          leading: Container(
            padding: EdgeInsets.only(right: 10.0, top: 7.0),
            child: Icon(Icons.stars, color: Colors.white24),
          ),
          title: Text(
            course,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
              Icon(Icons.linear_scale, color: Colors.blueAccent[100]),
              SizedBox(width: 10.0),
              Text(department, style: TextStyle(color: Colors.white))
            ],
          ),
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
        );

    final makeCard = (String course, String department) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(64, 75, 96, .9),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.showSnackBar(
                  new SnackBar(
                    content: new Text(course),
                  ),
                );
              },
              child: makeListTile(course, department),
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
            "Available Courses",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ),
        Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _course_list().length,
            itemBuilder: (BuildContext context, int index) {
              return makeCard(
                  _course_list()[index], "Information Systems | Y4");
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
