import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static final String endPoint = '/api/v1/auth/';

  // Keys to store and fetch data from SharedPreferences
  static final String authTokenKey = 'access_token';
  static final String tokenType = 'token_type';
  static final String userIdKey = 'user_id';
  static final String nameKey = 'name';
  static final String roleKey = 'role';

  static String getToken(SharedPreferences prefs) {
    return prefs.getString(authTokenKey);
  }

  static String getTokenType(SharedPreferences prefs) {
    return prefs.getString(tokenType);
  }

  static String getAuthorization(SharedPreferences prefs) {
    return prefs.getString(tokenType) + " " + prefs.getString(authTokenKey);
  }

  static insertDetails(SharedPreferences prefs, var response) {
    prefs.setString(authTokenKey, response['access_token']);
    prefs.setString(tokenType, response['token_type']);
//    var user = response['user'];
//    prefs.setInt(userIdKey, user['id']);
//    prefs.setString(nameKey, user['name']);
  }
}
