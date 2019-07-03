import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hschool/utils/connectionStatusSingleton.dart';

import 'app.dart';

void main() {
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(App());

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));
}
