import 'package:flutter/material.dart';
import 'package:hschool/pages/HomePage.dart';
import 'package:hschool/routes.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UR Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(title: 'UR Portal'),
      routes: routes,
    );
  }
}