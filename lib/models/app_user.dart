import 'package:flutter/foundation.dart';

class AppUser {
  String uid, name, username, profilePicUrl;
  int state;

  AppUser({
    @required this.uid,
    @required this.name,
    this.username,
    @required this.profilePicUrl,
    this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'state': state,
    };
  }

  AppUser.fromMap(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    name = mapData['name'];
    username = mapData['username'];
    profilePicUrl = mapData['profilePicUrl'];
    state = mapData['state'];
  }
}
