import 'package:flutter/material.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/extras/permissions.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/screens/call_screens/call_screen.dart';
import 'package:teams_clone/widgets/cached_image.dart';

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();
  PickupScreen({@required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Incoming...', style: TextStyle(fontSize: 30)),
            SizedBox(height: 50),
            CachedImage(call.callerPic, isRound: true, radius: 180),
            SizedBox(height: 15),
            Text(
              call.callerName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async => await callMethods.endCall(call: call),
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async =>
                      await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(call: call),
                              ),
                            )
                          : {},
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
