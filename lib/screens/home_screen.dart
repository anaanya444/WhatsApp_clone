import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import 'package:teams_clone/screens/call_screens/pickup_layout.dart';
import 'package:teams_clone/extras/universal_variables.dart';
import 'package:teams_clone/extras/user_provider.dart';
import 'package:teams_clone/screens/profile_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController _pageController;
  int _pageIndex = 0;
  UserProvider userProvider;
  FirebaseMethods _firebase = FirebaseMethods();

  @override
  void initState() {
    _pageController = PageController();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => Provider.of<UserProvider>(context, listen: false).refreshUser(),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = userProvider.getUser.uid;
    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _firebase.updateUserState(currentUserId, 1)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _firebase.updateUserState(currentUserId, 0)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _firebase.updateUserState(currentUserId, 2)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _firebase.updateUserState(currentUserId, 0)
            : print("detached state");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  Color _getColor(int i) =>
      _pageIndex == i ? UnivVars.lightBlueColor : UnivVars.greyColor;
  void _onPageChanged(int pageIndex) => setState(() => _pageIndex = pageIndex);

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UnivVars.blackColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ChatListScreen(),
            Scaffold(
              backgroundColor: UnivVars.blackColor,
              body: Center(
                child: Text('calls', style: TextStyle(color: Colors.white)),
              ),
            ),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: CupertinoTabBar(
            currentIndex: _pageIndex,
            onTap: (value) => _pageController.jumpToPage(value),
            backgroundColor: UnivVars.blackColor,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat, color: _getColor(0)),
                title: Text(
                  'Chat',
                  style: TextStyle(fontSize: 10, color: _getColor(0)),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call, color: _getColor(1)),
                title: Text(
                  'Call',
                  style: TextStyle(fontSize: 10, color: _getColor(1)),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle, color: _getColor(2)),
                title: Text(
                  'Profile',
                  style: TextStyle(fontSize: 10, color: _getColor(2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
