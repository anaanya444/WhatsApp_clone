import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent[700]),
      )),
    );
  }
}
