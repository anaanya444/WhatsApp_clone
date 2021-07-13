import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/extras/user_provider.dart';
import 'package:teams_clone/models/app_user.dart';
import 'package:teams_clone/models/contact.dart';
import 'package:teams_clone/models/message.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import 'package:teams_clone/screens/chat_screen.dart';
import 'package:teams_clone/widgets/cached_image.dart';
import 'package:teams_clone/widgets/custom_tile.dart';
import '../extras/universal_variables.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final FirebaseMethods _firebase = FirebaseMethods();
  ContactView({@required this.contact});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    Color getColor(int state) {
      switch (state) {
        case 0:
          return Colors.red;
          break;
        case 1:
          return Colors.green;
          break;
        default:
          return Colors.orange;
          break;
      }
    }

    return FutureBuilder(
      future: _firebase.getUserDetailsById(contact.uid),
      builder: (context, AsyncSnapshot<AppUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        AppUser user = snapshot.data;
        return CustomTile(
          isMini: false,
          title: Text(
            user.name,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: StreamBuilder(
            stream: _firebase.lastMessageStream(
              senderId: userProvider.getUser.uid,
              receiverId: contact.uid,
            ),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Text(
                  '...',
                  style: TextStyle(fontSize: 14, color: UnivVars.greyColor),
                );
              Map<String, dynamic> lastDocData = snapshot.data.docs.last.data();
              if (lastDocData['type'] == 'text')
                return Text(
                  Message.fromMap(lastDocData).message ?? 'No message',
                  style: TextStyle(fontSize: 14, color: UnivVars.greyColor),
                  overflow: TextOverflow.ellipsis,
                );
              else
                return Text(
                  'IMAGE',
                  style: TextStyle(fontSize: 14, color: UnivVars.greyColor),
                );
            },
          ),
          leading: Container(
            constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
            child: Stack(
              children: [
                CachedImage(
                  user.profilePicUrl,
                  radius: 40,
                  isRound: true,
                ),
                StreamBuilder(
                  stream: _firebase.getUserStream(user.uid),
                  builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Container();
                    int state = snapshot.data.data();
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 17,
                        width: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: getColor(state),
                          border: Border.all(
                            color: UnivVars.blackColor,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(receiver: user)),
          ),
        );
      },
    );
  }
}
