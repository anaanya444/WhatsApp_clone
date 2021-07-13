import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teams_clone/models/app_user.dart';
import 'package:teams_clone/models/contact.dart';
import 'package:teams_clone/models/message.dart';
import '../extras/constants.dart';

class FirebaseMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Reference firebaseStorage = FirebaseStorage.instance.ref();
  User get getCurrentUser => _auth.currentUser;
  var _messageCollection = _firestore.collection(MESSAGES_COLLECTION);
  var _userCollection = _firestore.collection(USERS_COLLECTION);

  Future<User> signInWithGoogle() async {
    GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn().signIn();
    } catch (_) {
      return null;
    }
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<bool> isNewUser(User user) async {
    QuerySnapshot result =
        await _userCollection.where(EMAIL_FIELD, isEqualTo: user.email).get();
    return result.docs.length == 0 ? true : false;
  }

  Future<void> addUserToDb(User currentUser) async {
    _userCollection.doc(currentUser.uid).set(
          AppUser(
            uid: currentUser.uid,
            name: currentUser.displayName,
            username: 'live:${currentUser.email.split('@')[0]}',
            profilePicUrl: currentUser.photoURL,
            state: null,
          ).toMap(),
        );
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<List<AppUser>> fetchAllUsers(User currentUser) async {
    List<AppUser> userList = [];
    QuerySnapshot querySnapshot = await _userCollection.get();
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      if (docSnapshot.id != currentUser.uid)
        userList.add(AppUser.fromMap(docSnapshot.data()));
    }
    return userList;
  }

  Future<void> addMessageToDb(
    Message message,
    BuildContext ctx, {
    bool isImage = false,
  }) async {
    try {
      Map<String, dynamic> messageMap =
          isImage ? message.toImageMap() : message.toMap();
      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(messageMap);
      Timestamp time = Timestamp.now();
      await addToSenderContacts(message.senderId, message.receiverId, time);
      await addToReceiverContacts(message.senderId, message.receiverId, time);
      await _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(messageMap);
    } on PlatformException catch (err) {
      String errMessage = 'An error occurred while uploading the image...';
      Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text(err.message ?? errMessage)),
      );
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> uploadImage({
    @required var image,
    @required String senderId,
    @required String receiverId,
    @required BuildContext ctx,
  }) async {
    try {
      Reference _storageRef = firebaseStorage.child(
        '${senderId}_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _storageRef.putFile(image);
      String imageUrl = await _storageRef.getDownloadURL();
      Message message = Message.imageMessage(
        message: 'MESSAGE',
        photoUrl: imageUrl,
        senderId: senderId,
        receiverId: receiverId,
        type: 'image',
        timestamp: Timestamp.now(),
      );
      addMessageToDb(message, ctx, isImage: true);
    } on PlatformException catch (err) {
      String errMessage = 'An error occurred while uploading the image...';
      Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text(err.message ?? errMessage)),
      );
    } catch (err) {}
  }

  Future<void> uploadProfilePic({
    @required var image,
    @required String uid,
    @required BuildContext ctx,
  }) async {
    try {
      Reference _storageRef = firebaseStorage.child('profilePic/$uid');
      await _storageRef.putFile(image);
      String imageUrl = await _storageRef.getDownloadURL();
      await _userCollection.doc(uid).update({'profilePicUrl': imageUrl});
    } on PlatformException catch (err) {
      String errMessage = 'An error occurred while uploading the image...';
      Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text(err.message ?? errMessage)),
      );
    } catch (err) {}
  }

  Future<void> updateProfile({
    @required String name,
    @required String username,
    @required String uid,
    @required BuildContext ctx,
  }) async {
    try {
      await _userCollection.doc(uid).update({
        'name': name,
        'username': username,
      });
    } on PlatformException catch (err) {
      String errMessage = 'An error occurred while uploading the image...';
      Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text(err.message ?? errMessage)),
      );
    } catch (err) {}
  }

  Future<AppUser> getUserDetails() async {
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(getCurrentUser.uid).get();
    return AppUser.fromMap(documentSnapshot.data());
  }

  Future<void> addToContacts({String senderId, String receiverId}) async {}

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot = await _userCollection
        .doc(senderId)
        .collection(CONTACTS_COLLECTION)
        .doc(receiverId)
        .get();

    if (!senderSnapshot.exists)
      await _userCollection
          .doc(senderId)
          .collection(CONTACTS_COLLECTION)
          .doc(receiverId)
          .set(Contact(uid: receiverId, addedOn: currentTime).toMap());
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot = await _userCollection
        .doc(receiverId)
        .collection(CONTACTS_COLLECTION)
        .doc(senderId)
        .get();

    if (!receiverSnapshot.exists)
      await _userCollection
          .doc(receiverId)
          .collection(CONTACTS_COLLECTION)
          .doc(senderId)
          .set(Contact(uid: senderId, addedOn: currentTime).toMap());
  }

  Stream<QuerySnapshot> fetchContacts(String uid) =>
      _userCollection.doc(uid).collection(CONTACTS_COLLECTION).snapshots();

  Future<AppUser> getUserDetailsById(String uid) async {
    try {
      DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
      return AppUser.fromMap(userDoc.data());
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<void> updateUserState(String uid, int state) async {
    _userCollection.doc('uid').update({'state': state});
  }

  Stream<QuerySnapshot> lastMessageStream(
      {String senderId, String receiverId}) {
    return _messageCollection
        .doc(senderId)
        .collection(receiverId)
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserStream(String uid) =>
      _userCollection.doc(uid).snapshots();
}
