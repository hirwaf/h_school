import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/components/portal_button.dart';
import 'package:hschool/pages/LecturerLoginPage.dart';
import 'package:hschool/pages/StudentLoginPage.dart';
import 'package:hschool/routes.dart';
import 'package:hschool/utils/auth_utils.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';
import 'package:hschool/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomePage extends StatefulWidget {
  static final String routeName = 'studentHome';

  @override
  State<StatefulWidget> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  bool _isLoading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _user;
  var _user_id;
  SharedPreferences _sharedPreferences;
  var _authToken;

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
    _user = await NetworkUtils.fetchStudentUser(authToken);

    if (_user == null) {
      NetworkUtils.showSnackBar(_scaffoldKey, 'Something went wrong!');
      // ignore: unrelated_type_equality_checks
    } else if (_user == 'NetworkError') {
      NetworkUtils.showSnackBar(_scaffoldKey, null);
    } else if (_user == false) {
      _logout();
    }

    setState(() {
      _user = _user;
      _user_id = _user.id;
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
          title: Text('UR Student'),
          elevation: 5.5,
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 5.0, 5.0),
              child: Text(
                _user != null ? _user.name : "Loading ...",
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
        body: !isOffline
            ? _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _body()
            : _loading(),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
    );
  }

  Widget _body() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 140.0, right: 140.0),
        children: <Widget>[
          new Button(
            text: "Notifications",
            color: const Color.fromRGBO(155, 209, 133, 1),
            callback: () => Navigator.pushNamed(context, "studentNotification", arguments: "notification"),
          ),
          const SizedBox(height: 30),
          new Button(
            text: "Reports",
            color: const Color.fromRGBO(250, 121, 33, 1),
            callback: () => Navigator.pushNamed(context, "studentReports", arguments: "reports"),
          ),
          const SizedBox(height: 30),
          new Button(
            text: "Register",
            color: const Color.fromRGBO(50, 51, 141, 1),
            callback: () => Navigator.pushNamed(context, "studentRegister", arguments: "register"),
          ),
          const SizedBox(height: 30),
          new Button(
            text: "My Information",
            color: const Color.fromRGBO(248, 51, 60, 1),
            callback: () => Navigator.pushNamed(context, "studentInformation", arguments: "information"),
          ),
        ],
      ),
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
