import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatefulWidget {
  static final String routeName = 'home';

  const HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _HomeState();

}

class _HomeState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _internet = false;

  StreamSubscription<ConnectivityResult> subscription;

  @override
  initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result) {
      _internet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(subscription);
    return SafeArea(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('${widget.title}'),
          elevation: 5.5,
        ),
        body: _internet ? _body() : _loading(),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
        children: <Widget>[
        ],
      ),
    );
  }

  Widget _loading() {
    return SpinKitFadingCircle(
      itemBuilder: (_, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.red : Colors.green,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    subscription.cancel();
  }

}