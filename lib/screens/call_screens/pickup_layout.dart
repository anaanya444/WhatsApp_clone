import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/screens/call_screens/pickup_screen.dart';
import 'package:teams_clone/extras/user_provider.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();
  PickupLayout({this.scaffold});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data() != null) {
                Call call = Call.fromMap(snapshot.data.data());
                if (!call.hasDialed) return PickupScreen(call: call);
              }
              return scaffold;
            },
          )
        : Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
