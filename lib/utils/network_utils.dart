import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hschool/models/Student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_utils.dart';

class NetworkUtils {
  static final String productionHost = 'https://school.hirwaf.dev';
  static final String developmentHost = 'http://192.168.43.44';
  static final String host = productionHost;

  static dynamic authenticateStudent(String std_id, String password) async {
    var uri = host + AuthUtils.endPoint + "student/login";

    try {
      final response =
          await http.post(uri, body: {'std_id': std_id, 'password': password});
      print(response.body);
      final responseJson = json.decode(response.body);
      return responseJson;
    } catch (exception) {
      print(exception);
      if (exception.toString().contains('SocketException')) {
        return 'NetworkError';
      } else {
        return null;
      }
    }
  }

  static logoutStudentUser(BuildContext context, SharedPreferences prefs) {
    String authToken = AuthUtils.getAuthorization(prefs);

    prefs.setString(AuthUtils.authTokenKey, null);
    prefs.setString(AuthUtils.tokenType, null);

    fetch(authToken, '/api/v1/auth/student/logout');

    Navigator.of(context).pushReplacementNamed('/');
  }

  static showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message ?? 'You are offline'),
    ));
  }

  static fetch(var authToken, var endPoint) async {
    var uri = host + endPoint;

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': authToken},
      );

      final responseJson = json.decode(response.body);
      return responseJson;
    } catch (exception) {
      print(exception);
      if (exception.toString().contains('SocketException')) {
    return 'NetworkError';
    } else {
    return null;
    }
  }
}

static fetchStudentUser(var authToken) async {
  var uri = host + '/api/v1/auth/student/user';

  try {
    final response = await http.get(
      uri,
      headers: {'Authorization': authToken},
    );

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      print(response.body);
      return Student.fromJson(json.decode(response.body));

    } else {
      return false;
    }
  } catch (exception) {
      print(exception);
      if (exception.toString().contains('SocketException')) {
        return 'NetworkError';
      } else {
        return null;
      }
    }
  }

}
