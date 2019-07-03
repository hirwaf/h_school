import 'package:flutter/material.dart';
import 'package:hschool/pages/HomePage.dart';
import 'package:hschool/pages/LecturerHomePage.dart';
import 'package:hschool/pages/LecturerLoginPage.dart';
import 'package:hschool/pages/StudentHomePage.dart';
import 'package:hschool/pages/StudentLoginPage.dart';

final routes = {
  HomePage.routeName : (BuildContext context) => new HomePage(),
  StudentLoginPage.routeName : (BuildContext context) => new StudentLoginPage(),
  StudentHomePage.routeName : (BuildContext context) => new StudentHomePage(),
  LecturerLoginPage.routeName : (BuildContext context) => new LecturerLoginPage(),
  LecturerHomePage.routeName : (BuildContext context) => new LecturerHomePage(),
};