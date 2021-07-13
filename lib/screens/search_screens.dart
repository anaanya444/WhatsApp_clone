import 'package:flutter/material.dart';

import 'package:teams_clone/models/app_user.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import 'package:teams_clone/screens/call_screens/pickup_layout.dart';
import 'package:teams_clone/screens/chat_screen.dart';
import 'package:teams_clone/extras/universal_variables.dart';
import 'package:teams_clone/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseMethods _firebase = FirebaseMethods();
  List<AppUser> _userList;
  String _query = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _firebase
        .fetchAllUsers(_firebase.getCurrentUser)
        .then((allUsers) => setState(() => _userList = allUsers));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UnivVars.blackColor,
        appBar: searchAppBar(context),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestions(_query),
        ),
      ),
    );
  }

  AppBar searchAppBar(BuildContext context) {
    return AppBar(

      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
        },
      ),
      elevation: 0,
      bottom: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            cursorColor: UnivVars.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: UnivVars.searchHintColor),
                onPressed: () => _searchController.clear(),
              ),
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: UnivVars.searchHintColor,
              ),
            ),
          ),
        ),
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      ),
    );
  }

  buildSuggestions(String query) {
    final List<AppUser> suggestionList = query.isEmpty
        ? []
        : _userList == null
            ? []
            : _userList.where((appUser) {
                return appUser.username
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    appUser.name.toLowerCase().contains(query.toLowerCase());
              }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        AppUser searchedUser = AppUser(
          uid: suggestionList[index].uid,
          name: suggestionList[index].name,
          username: suggestionList[index].username,
          profilePicUrl: suggestionList[index].profilePicUrl,
          state: suggestionList[index].state,
        );
        return CustomTile(
          isMini: false,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(receiver: searchedUser),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(searchedUser.profilePicUrl),
          ),
          title: Text(
            searchedUser.username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            searchedUser.name,
            style: TextStyle(color: UnivVars.greyColor),
          ),
        );
      },
    );
  }
}
