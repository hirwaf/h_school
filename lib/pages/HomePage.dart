import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hschool/components/portal_button.dart';
import 'package:hschool/pages/LecturerLoginPage.dart';
import 'package:hschool/pages/StudentLoginPage.dart';
import 'package:hschool/routes.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';

class HomePage extends StatefulWidget {
  static final String routeName = 'home';

  const HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
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

    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('${widget.title}'),
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
        padding: EdgeInsets.only(left: 140.0, right: 140.0),
        children: <Widget>[
          new Button(
            text: "New Application",
            color: Colors.indigo[700],
            callback: () => Navigator.of(_scaffoldKey.currentContext)
                .pushNamed('/application'),
          ),
          const SizedBox(height: 30),
          new Button(
            text: "Students Portal",
            color: Colors.blueGrey[700],
            callback: () => Navigator.of(_scaffoldKey.currentContext)
                .pushNamed(StudentLoginPage.routeName),
          ),
          const SizedBox(height: 30),
          new Button(
            text: "Lecturers Portal",
            callback: () => Navigator.of(_scaffoldKey.currentContext)
                .pushNamed(LecturerLoginPage.routeName),
            color: Colors.lightGreen[700],
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
