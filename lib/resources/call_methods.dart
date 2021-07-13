import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teams_clone/extras/constants.dart';
import 'package:teams_clone/models/app_user.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/screens/call_screens/call_screen.dart';

class CallMethods {
  final CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Future<bool> makeCall({@required Call call}) async {
    try {
      call.hasDialed = true;
      Map<String, dynamic> hasDialed = call.toMap();
      call.hasDialed = false;
      Map<String, dynamic> hasNotDialed = call.toMap();
      await callCollection.doc(call.callerId).set(hasDialed);
      await callCollection.doc(call.recieverId).set(hasNotDialed);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> endCall({@required Call call}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.recieverId).delete();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Stream<DocumentSnapshot> callStream(String uid) =>
      callCollection.doc(uid).snapshots();

  Future<void> dial({AppUser from, AppUser to, BuildContext context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePicUrl,
      recieverId: to.uid,
      recieverName: to.name,
      recieverPic: to.profilePicUrl,
      channelId: UniqueKey().toString(),
    );
    bool callMade = await makeCall(call: call);
    call.hasDialed = true;
    if (callMade)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CallScreen(call: call)),
      );
  }
}
