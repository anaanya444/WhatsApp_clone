import 'package:flutter/foundation.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import '../models/app_user.dart';

class UserProvider with ChangeNotifier {
  AppUser _user;
  AppUser get getUser => _user;

  Future<void> refreshUser() async {
    _user = await FirebaseMethods().getUserDetails();
    notifyListeners();
  }
}
