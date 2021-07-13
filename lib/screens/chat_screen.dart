import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teams_clone/models/app_user.dart';
import 'package:teams_clone/models/message.dart';
import 'package:teams_clone/extras/permissions.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import 'package:teams_clone/screens/call_screens/pickup_layout.dart';
import 'package:teams_clone/extras/universal_variables.dart';
import 'package:teams_clone/widgets/cached_image.dart';
import 'package:teams_clone/widgets/custom_appbar.dart';
import 'package:teams_clone/widgets/custom_tile.dart';
import '../extras/constants.dart';

class ChatScreen extends StatefulWidget {
  final AppUser receiver;
  ChatScreen({@required this.receiver});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseMethods _firebase = FirebaseMethods();
  User _currentUser;
  CallMethods _callMethods = CallMethods();
  AppUser sender;

  @override
  void initState() {
    _firebase = FirebaseMethods();
    _currentUser = FirebaseMethods().getCurrentUser;
    sender = AppUser(
      uid: _currentUser.uid,
      name: _currentUser.displayName,
      profilePicUrl: _currentUser.photoURL,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UnivVars.blackColor,
        appBar: CustomAppBar(
          circleAvatar: CachedImage(
            widget.receiver.profilePicUrl,
            radius: 40,
            isRound: true,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.receiver.name),
          centreTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () async =>
                  await Permissions.cameraAndMicrophonePermissionsGranted()
                      ? _callMethods.dial(
                          from: sender,
                          to: widget.receiver,
                          context: context,
                        )
                      : {},
            ),
            IconButton(
              icon: Icon(Icons.phone),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Flexible(child: messageList()),
            ChatControls(
              currentUser: _currentUser,
              firebase: _firebase,
              receiver: widget.receiver,
            ),
          ],
        ),
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUser.uid)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        List<QueryDocumentSnapshot> messageDocs = snapshot.data.docs;
        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: messageDocs.length,
          itemBuilder: (context, index) => messageBubble(messageDocs[index]),
        );
      },
    );
  }

  Widget messageBubble(QueryDocumentSnapshot snapshot) {
    bool _isTextMessage = true; //snapshot.data() == 'text';
    Message _message = _isTextMessage
        ? Message.fromMap(snapshot.data())
        : Message.fromImageMap(snapshot.data());
    bool _isSender = _message.senderId == _currentUser.uid;
    Radius _messageRadius = Radius.circular(20);
    return Row(
      mainAxisAlignment:
          _isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          decoration: BoxDecoration(
            color: _isSender ? UnivVars.senderColor : UnivVars.receiverColor,
            borderRadius: BorderRadius.only(
              topLeft: _messageRadius,
              topRight: _messageRadius,
              bottomLeft: !_isSender ? Radius.circular(0) : _messageRadius,
              bottomRight: _isSender ? Radius.circular(0) : _messageRadius,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(13),
            child: _isTextMessage
                ? Text(
                    _message.message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                : CachedImage(
                    _message.photoUrl,
                    height: 250,
                    width: 250,
                    radius: 10,
                  ),
          ),
        ),
      ],
    );
  }
}

class ChatControls extends StatefulWidget {
  final User currentUser;
  final FirebaseMethods firebase;
  final AppUser receiver;
  const ChatControls({
    @required this.currentUser,
    @required this.firebase,
    @required this.receiver,
  });

  @override
  _ChatControlsState createState() => _ChatControlsState();
}

class _ChatControlsState extends State<ChatControls> {
  TextEditingController _textFieldController = TextEditingController();
  bool _isTyping = false;
  int _loadingImages = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          InkWell(
            onTap: () => addMediaModal(context),
            child: Container(
              child: Icon(Icons.add),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UnivVars.fabGradient,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              autocorrect: false,
              controller: _textFieldController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: UnivVars.greyColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(const Radius.circular(50)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                filled: true,
                fillColor: UnivVars.separatorColor,
              ),
              onChanged: (value) => value.trim() == ''
                  ? setState(() => _isTyping = false)
                  : setState(() => _isTyping = true),
            ),
          ),
          _isTyping
              ? Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    gradient: UnivVars.fabGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, size: 15),
                    onPressed: () async => await sendMessage(context),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async => await pickImage(ImageSource.camera),
                ),
        ],
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    // ignore: deprecated_member_use
    final _picker = ImagePicker();
    PickedFile image = await _picker.getImage(
      source: source,
      imageQuality: 60,
    );
    if (source == ImageSource.gallery) Navigator.pop(context);
    _loadingImages++;
    String msg = 'Uploading $_loadingImages image';
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      message: _loadingImages > 1 ? msg + 's' : msg,
      duration: Duration(milliseconds: 1500),
    )..show(context);
    await widget.firebase.uploadImage(
      ctx: context,
      image: PickedFile,
      senderId: widget.currentUser.uid,
      receiverId: widget.receiver.uid,
    );
    _loadingImages--;
  }

  Future<void> sendMessage(BuildContext ctx) async {
    setState(() => _isTyping = false);
    //_textFieldController.clear();
    FocusScope.of(context).unfocus();
    await widget.firebase.addMessageToDb(
      Message(
        message: _textFieldController.text,
        receiverId: widget.receiver.uid,
        senderId: widget.currentUser.uid,
        timestamp: Timestamp.now(),
        type: 'text',
      ),
      ctx,
    );
  }

  addMediaModal(BuildContext context) {
    showModalBottomSheet(
      elevation: 0,
      backgroundColor: UnivVars.blackColor,
      context: context,
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                TextButton(
                  child: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Content and tools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              children: [
                ModalTile(
                  title: 'Media',
                  subtitle: 'Share photos and videos',
                  iconData: Icons.image,
                  onTap: () async => await pickImage(ImageSource.gallery),
                ),
                ModalTile(
                  title: 'File',
                  subtitle: 'Share files',
                  iconData: Icons.tab,
                  onTap: () async => await pickImage(ImageSource.gallery),
                ),
                ModalTile(
                  title: 'Contact',
                  subtitle: 'Share contacts',
                  iconData: Icons.contacts,
                ),
                ModalTile(
                  title: 'Location',
                  subtitle: 'Share a location',
                  iconData: Icons.add_location,
                ),
                ModalTile(
                  title: 'Schedule call',
                  subtitle: 'Arrange a teams call and get reminders',
                  iconData: Icons.schedule,
                ),
                ModalTile(
                  title: 'Create poll',
                  subtitle: 'Share polls',
                  iconData: Icons.poll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title, subtitle;
  final IconData iconData;
  final Function onTap;
  ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.iconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: onTap,
        isMini: false,
        leading: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UnivVars.receiverColor,
          ),
          child: Icon(iconData, size: 38, color: UnivVars.greyColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: UnivVars.greyColor, fontSize: 14),
        ),
      ),
    );
  }
}
