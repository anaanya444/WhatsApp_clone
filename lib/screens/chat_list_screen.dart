import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/models/contact.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import 'package:teams_clone/screens/call_screens/pickup_layout.dart';
import 'package:teams_clone/screens/search_screens.dart';
import 'package:teams_clone/extras/universal_variables.dart';
import 'package:teams_clone/extras/user_provider.dart';
import 'package:teams_clone/widgets/contact_view.dart';
import 'package:teams_clone/widgets/custom_appbar.dart';
import 'package:teams_clone/widgets/quiet_box.dart';
import 'package:teams_clone/widgets/user_circle.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        body: ChatListContainer(),
        floatingActionButton: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: UnivVars.fabGradient,
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            icon: Icon(Icons.edit, size: 25, color: Colors.white),
            onPressed: () {},
          ),
        ),
        backgroundColor: UnivVars.blackColor,
        appBar: CustomAppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => Navigator.pushNamed(
                context,
                SearchScreen.routeName,
              ),
            ),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
          centreTitle: true,
          leading: IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          title: UserCircle(),
        ),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final FirebaseMethods _firebase = FirebaseMethods();
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firebase.fetchContacts(userProvider.getUser.uid),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          List<DocumentSnapshot> contacts = snapshot.data.docs;
          return contacts.length > 0
              ? ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (_, index) => ContactView(
                    contact: Contact.fromMap(contacts[index].data()),
                  ),
                )
              : QuietBox();
        },
      ),
    );
  }
}
