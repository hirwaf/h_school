import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/components/portal_button.dart';
import 'package:hschool/pages/StudentHomePage.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';

class StudentLoginPage extends StatefulWidget {
  static final String routeName = 'studentLogin';

  const StudentLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  TextEditingController studentIdController;
  TextEditingController passwordController;

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

  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('assets/images/logo.png'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('UR Students Portal Login'),
          elevation: 5.5,
        ),
        body: !isOffline ? _body() : _loading(),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
    );
  }

  Widget _body() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          logo,
          SizedBox(height: 48.0),
          TextFormField(
            keyboardType: TextInputType.number,
            autofocus: true,
            controller: studentIdController,
            decoration: InputDecoration(
              hintText: 'Student ID',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            autofocus: false,
            obscureText: true,
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
          SizedBox(height: 24.0),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: () =>
                  Navigator.of(_scaffoldKey.currentContext)
                      .pushNamed(StudentHomePage.routeName),
              padding: EdgeInsets.all(12),
              color: Colors.lightBlueAccent,
              child: Text('Log In', style: TextStyle(color: Colors.white)),
            ),
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
