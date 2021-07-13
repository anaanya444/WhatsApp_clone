import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/screens/login_screen.dart';
import 'package:teams_clone/screens/search_screens.dart';
import 'package:teams_clone/screens/splash_screen.dart';
import 'package:teams_clone/extras/user_provider.dart';
import 'screens/home_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TeamsClone());
}

class TeamsClone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Teams Clone',
        theme: ThemeData(brightness: Brightness.dark),
        routes: {SearchScreen.routeName: (context) => SearchScreen()},
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return SplashScreen();
            return snapshot.hasData ? HomeScreen() : LoginScreen();
          },
        ),
      ),
    );
  }
}
