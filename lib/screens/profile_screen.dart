import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/extras/universal_variables.dart';
import 'package:teams_clone/extras/user_provider.dart';
import 'package:teams_clone/resources/firebase_methods.dart';
import 'package:teams_clone/widgets/cached_image.dart';

class ProfileScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final FirebaseMethods _firebase = FirebaseMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    String inputName, inputUsername;
    return Scaffold(
      backgroundColor: UnivVars.blackColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CachedImage(
                    userProvider.getUser.profilePicUrl,
                    isRound: true,
                    radius: 100,
                  ),
                  ChangeProfilePicButton(
                    userProvider: userProvider,
                    firebase: _firebase,
                  ),
                  TextFormField(
                    validator: (value) => value.isEmpty ? 'Enter a name' : null,
                    initialValue: userProvider.getUser.name,
                    onSaved: (newValue) => inputName = newValue,
                    decoration: InputDecoration(hintText: 'Enter name'),
                  ),
                  TextFormField(
                    validator: (value) =>
                        value.isEmpty ? 'Enter a username' : null,
                    initialValue: userProvider.getUser.username,
                    onSaved: (newValue) => inputUsername = newValue,
                    decoration: InputDecoration(hintText: 'Enter username'),
                  ),
                  UpdateProfileButton(
                    formKey: _formKey,
                    firebase: _firebase,
                    inputName: inputName,
                    inputUsername: inputUsername,
                  ),
                  FlatButton(
                    child: Text('Log Out', style: TextStyle(color: Colors.red)),
                    onPressed: () async => await _firebase.signOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateProfileButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FirebaseMethods firebase;
  final String inputName, inputUsername;
  const UpdateProfileButton({
    @required this.inputName,
    @required this.inputUsername,
    @required this.formKey,
    @required this.firebase,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Update Profile',
        style: TextStyle(color: UnivVars.lightBlueColor),
      ),
      onPressed: () {
        if (formKey.currentState.validate()) {
          formKey.currentState.save();
          firebase.updateProfile(
            name: inputName,
            username: inputUsername,
            uid: firebase.getCurrentUser.uid,
            ctx: context,
          );
        }
      },
    );
  }
}

class ChangeProfilePicButton extends StatelessWidget {
  final UserProvider userProvider;
  final FirebaseMethods firebase;
  ChangeProfilePicButton(
      {@required this.userProvider, @required this.firebase});

  Future<void> pickImage(String uid, BuildContext ctx) async {
    // ignore: deprecated_member_use
    final _picker = ImagePicker();
    PickedFile image = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      message: 'Updating profile photo',
      duration: Duration(milliseconds: 1500),
    )..show(ctx);
    await firebase.uploadProfilePic(
      ctx: ctx,
      image: PickedFile,
      uid: uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Change Profile Photo',
        style: TextStyle(color: UnivVars.lightBlueColor),
      ),
      onPressed: () async => await pickImage(userProvider.getUser.uid, context),
    );
  }
}
