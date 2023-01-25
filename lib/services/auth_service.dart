import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../commons/firebase_instances.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final userStream = StreamProvider.family.autoDispose((ref, String id) => AuthService.getSingleUser(id));
final allUserStream = StreamProvider.autoDispose((ref) =>FirebaseInstances.firebaseChatCore.users());

class AuthService {

  static CollectionReference userDb = FirebaseInstances.firebaseCloud.collection('users');

 static Stream<types.User> getSingleUser (String uid){
   final data = FirebaseInstances.firebaseCloud.collection('users').doc(uid).snapshots().map((event) {
     final json = event.data() as Map<String, dynamic>;
     return types.User(
         id: event.id,
         firstName: json['firstName'],
         imageUrl: json['imageUrl'],
         metadata: {
           'email' : json['metadata']['email']
         }
     );
   });
    return data;
  }


 static Future<Either<String, bool>> userSignUp({
  required String email,
    required String username,
    required XFile image,
    required String password
})async{

    try{
   final ref = FirebaseInstances.firebaseStorage.ref().child('userImages/${image.name}');
   await ref.putFile(File(image.path));
   final url = await ref.getDownloadURL();

   final credential = await FirebaseInstances.firebaseAuth.createUserWithEmailAndPassword(
     email: email,
     password: password,
   );
   final token = await FirebaseMessaging.instance.getToken();
   await  FirebaseInstances.firebaseChatCore.createUserInFirestore(
     types.User(
       firstName: username,
       id: credential.user!.uid,
       imageUrl: url,
       lastName: '',
       metadata: {
         'email': email,
         'token': token
       }
     ),
   );

      return Right(true);
    }on FirebaseAuthException catch (err){
     return  Left('${err.message}');
    }


  }



 static Future<Either<String, bool>> userLogin({
   required String email,
   required String password
 })async{
   try{
     final credential = await FirebaseInstances.firebaseAuth.signInWithEmailAndPassword(
       email: email,
       password: password,
     );
     final token = await FirebaseMessaging.instance.getToken();
     await userDb.doc(credential.user!.uid).update({
       'metadata': {
         'email': email,
         'token': token
       }
     });

     return Right(true);
   }on FirebaseAuthException catch (err){
     return  Left('${err.message}');
   }
 }



 static Future<Either<String, bool>> userLogOut()async{
   try{
     final credential = await FirebaseInstances.firebaseAuth.signOut();
     return Right(true);
   }on FirebaseAuthException catch (err){
     return  Left('${err.message}');
   }
 }




}