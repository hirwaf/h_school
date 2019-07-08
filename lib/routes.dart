import 'package:flutter/material.dart';
import 'package:hschool/pages/HomePage.dart';
import 'package:hschool/pages/LecturerHomePage.dart';
import 'package:hschool/pages/LecturerLoginPage.dart';
import 'package:hschool/pages/StudentHomePage.dart';
import 'package:hschool/pages/StudentListPage.dart';
import 'package:hschool/pages/StudentLoginPage.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

final routes = {
  HomePage.routeName: (BuildContext context) => new HomePage(),
  StudentLoginPage.routeName: (BuildContext context) => new StudentLoginPage(),
  StudentHomePage.routeName: (BuildContext context) => new StudentHomePage(),
  LecturerLoginPage.routeName: (BuildContext context) =>
      new LecturerLoginPage(),
  LecturerHomePage.routeName: (BuildContext context) => new LecturerHomePage(),
  StudentListPage.routeName: (BuildContext context) => new StudentListPage(),
  '/application': (_) => new WebviewScaffold(
        url: "https://school.hirwaf.dev/app/application?_key=JM8bHNyYKJEtCx",
        appBar: new AppBar(
          title: const Text('UR Students Application'),
          elevation: 5.5,
        ),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
};
