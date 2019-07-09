import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:hschool/utils/auth_utils.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';
import 'package:hschool/utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentWebViewContainer extends StatefulWidget {
  @override
  createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<StudentWebViewContainer> {
  final _key = UniqueKey();
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
    });
    _hideLoading();
  }

  _logout() {
    NetworkUtils.logoutStudentUser(
        _scaffoldKey.currentContext, _sharedPreferences);
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute
        .of(context)
        .settings
        .arguments;
    if (!_isLoading && _user != null) {
      var _url = NetworkUtils.host + "/api/v1/app/student/${_user.id}/$args?_key=JM8bHNyYKJEtCx";
      return _getWebPage(_url, args, _authToken);
    }
    else {
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
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
          body: null,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        ),
      );
    }

  }

  Widget _getWebPage(var _url, var args, var authToken) {
    return WebviewScaffold(
      key: _key,
      url: _url,
      headers: {
        'Authorization': authToken
      },
      appBar: new AppBar(
          title: new Text('${args.toString().toUpperCase()}'),
          elevation: 5.5,
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 5.0, 5.0),
              child: Text(
                _user != null ? _user.name : "Loading ...",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ]
      ),
      withZoom: false,
      withLocalStorage: true,
      withJavascript: true,
      hidden: true,
      initialChild: Container(
        color: Colors.transparent,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
