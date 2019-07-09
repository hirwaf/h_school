import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/models/Course.dart';
import 'package:hschool/pages/StudentListPage.dart';
import 'package:hschool/utils/auth_utils.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';
import 'package:hschool/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LecturerHomePage extends StatefulWidget {
  static final String routeName = 'lecturerHome';

  @override
  State<StatefulWidget> createState() => _LecturerHomeState();
}

class _LecturerHomeState extends State<LecturerHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  bool _isLoading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _user;
  SharedPreferences _sharedPreferences;
  var _authToken;
  var _list_courses = new List<Course>();

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

    var _list_courses_ = await NetworkUtils.fetch(
        _authToken, '/api/v1/app/lecturer/${__user.id}/courses');
    var p = _list_courses_.cast<Map<String, dynamic>>();
    var pp = p.map<Course>((json) => Course.fromJson(json)).toList();

    setState(() {
      _user = __user;
      _list_courses = pp;
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
                _user != null ? _user.names : "Loading ...",
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
        body: !isOffline ? _body(_user) : _loading(),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
    );
  }

  Widget _body(var user) {
    final makeListTile = (String course, String department, String year) =>
        ListTile(
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
              Text('$department | Y$year',
                  style: TextStyle(color: Colors.white))
            ],
          ),
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
        );

    final makeCard = (Course course) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(64, 75, 96, .9),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  _scaffoldKey.currentContext,
                  MaterialPageRoute(builder: (context) => StudentListPage(course: course)),
                );
              },
              child: makeListTile(course.name, course.department, course.year),
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
                  "Available Courses",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w400, color: Colors.white),
                ),
              ),
              Container(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _list_courses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return makeCard(_list_courses[index]);
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
