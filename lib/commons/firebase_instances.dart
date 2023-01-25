import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseInstances{

  static final firebaseAuth = FirebaseAuth.instance;
  static final firebaseChatCore = FirebaseChatCore.instance;
  static final firebaseCloud = FirebaseFirestore.instance;
  static final firebaseStorage = FirebaseStorage.instance;

}