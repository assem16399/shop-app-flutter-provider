import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_application/models/HttpException.dart';
import 'package:shared_preferences/shared_preferences.dart';

const ApiKey = 'AIzaSyDMnraafzzalMqTwAX-9GMJdDgpp6wPcsc';

class Auth with ChangeNotifier {
  String? _userId;
  String? _token;
  DateTime? _expiryDate;
  Timer? _authTimer;
  String? _tokenRefresher;

  bool get isAuth {
    if (tokenGetter != null) return true;
    return false;
  }

  String? get tokenGetter {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String? get userIdGetter {
    return _userId;
  }

  Future<void> _auth(
      {String? email, String? password, String? authMode}) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$authMode?key=$ApiKey');
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final extractedBody = jsonDecode(response.body);

      if (extractedBody.containsKey('error')) {
        throw HttpException(extractedBody['error']['message']);
      }

      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(extractedBody['expiresIn'])));
      _userId = extractedBody['localId'];
      _token = extractedBody['idToken'];
      _tokenRefresher = extractedBody['refreshToken'];
      _autoLogout();
      //_refreshToken();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
        'tokenRefresher': _tokenRefresher
      });
      prefs.setString('userData', userData);
    } catch (error) {
      // we throw error if there is an error status code or network failure
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    await _auth(authMode: 'signUp', password: password, email: email);
  }

  Future<void> logIn(String email, String password) async {
    await _auth(
        authMode: 'signInWithPassword', password: password, email: email);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _tokenRefresher = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) return false;

    final extractedUserData =
        jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    //comment this if u wanna use the refreshToken
    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    _tokenRefresher = extractedUserData['tokenRefresher'];

    notifyListeners();

    _autoLogout();
    //_refreshToken();

    return true;
  }

  //auto logout comment it if u wanna use refresh token
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  // void _refreshToken() async {
  //   if (_authTimer != null) {
  //     _authTimer!.cancel();
  //   }
  //   final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpiry), () async {
  //     final url =
  //         Uri.parse('https://securetoken.googleapis.com/v1/token?key=$ApiKey');
  //     try {
  //       final response = await http.post(url, body: {
  //         'grant_type': 'refresh_token',
  //         'refresh_token': _tokenRefresher,
  //       });
  //
  //       final extractedRefresh = jsonDecode(response.body);
  //
  //       if (extractedRefresh['error'] != null) {
  //         throw HttpException(extractedRefresh['error']['message']);
  //       }
  //
  //       _token = extractedRefresh['id_token'];
  //       _userId = extractedRefresh['user_id'];
  //       _tokenRefresher = extractedRefresh['refresh_token'];
  //       _expiryDate = DateTime.now()
  //           .add(Duration(seconds: int.parse(extractedRefresh['expires_in'])));
  //
  //       print('token refreshed');
  //       print(_expiryDate.toString());
  //       notifyListeners();
  //
  //       //Saving the new data in a map
  //       final prefs = await SharedPreferences.getInstance();
  //       final userData = json.encode({
  //         'token': _token,
  //         'tokenRefresher': _tokenRefresher,
  //         'userId': _userId,
  //         'expiryDate': _expiryDate!.toIso8601String(),
  //       });
  //
  //       if (prefs.containsKey('userData'))
  //         prefs.remove('userData'); //remove the old data
  //
  //       //save the map of the new data in Shared Preferences
  //       prefs.setString('userData', userData);
  //     } catch (error) {
  //       throw error;
  //     }
  //   });
  // }
}
