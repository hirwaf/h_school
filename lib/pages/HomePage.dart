import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                "New Application",
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {},
              padding: EdgeInsets.all(10),
              elevation: 5.2,
            ),
            const SizedBox(height: 30),
            RaisedButton(
              child: Text(
                "Students Portal",
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {},
              padding: EdgeInsets.all(10),
              elevation: 5.2,
            ),
            const SizedBox(height: 30),
            RaisedButton(
              child: Text(
                "Lecturers Portal",
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {},
              padding: EdgeInsets.all(10),
              elevation: 5.2,
            ),
          ],
        ),
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
