import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Contact {
  String uid;
  Timestamp addedOn;
  Contact({@required this.uid, @required this.addedOn});

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'addedOn': addedOn};
  }

  Contact.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    addedOn = map['addedOn'];
  }
}
