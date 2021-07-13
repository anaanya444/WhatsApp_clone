import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Message {
  String message, senderId, receiverId, type, photoUrl;
  Timestamp timestamp;

  Message({
    @required this.message,
    @required this.senderId,
    @required this.receiverId,
    @required this.type,
    @required this.timestamp,
  });

  Message.imageMessage({
    @required this.message,
    @required this.photoUrl,
    @required this.senderId,
    @required this.receiverId,
    @required this.type,
    @required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'message': message,
      'timestamp': timestamp,
    };
  }

  Map<String, dynamic> toImageMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'timestamp': timestamp,
      'photoUrl': photoUrl,
    };
  }

  Message.fromMap(Map<String, dynamic> map) {
    message = map['message'];
    receiverId = map['receiverId'];
    senderId = map['senderId'];
    timestamp = map['timestamp'];
    type = map['type'];
  }

  Message.fromImageMap(Map<String, dynamic> map) {
    photoUrl = map['photoUrl'];
    receiverId = map['receiverId'];
    senderId = map['senderId'];
    timestamp = map['timestamp'];
    type = map['type'];
  }
}
