import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../commons/firebase_instances.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/posts.dart';


final dataStream = StreamProvider((ref) => CrudService.getData());

class CrudService {


  static CollectionReference postDb = FirebaseInstances.firebaseCloud.collection('posts');


  static Stream<List<Post>> getData (){
    // final data = postDb.where('title',isEqualTo: 'sample' ).snapshots();
    return  postDb.snapshots().map((event){
      return event.docs.map((e) {
        final json = e.data() as Map<String, dynamic>;
        return Post(
            imageUrl: json['imageUrl'],
            id: e.id,
            title: json['title'],
            userId: json['userId'],
            detail: json['detail'],
            comments: (json['comments'] as List).map((e) => Comment.fromJson(e)).toList(),
            imageId: json['imageId'],
            like: Like.fromJson(json['like'])
        );
      }).toList();
    });
  }





  static Future<Either<String, bool>> postAdd({
    required String title,
    required String detail,
    required XFile image,
    required String uid
  })async{

    try{
      final imageId = DateTime.now().toString();
      final ref = FirebaseInstances.firebaseStorage.ref().child('postImages/$imageId');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await  postDb.add({
      'userId': uid,
      'title': title,
      'imageUrl': url,
      'imageId': imageId,
      'detail': detail,
      'comments': [],
        'like': {
          'usernames': [],
          'likes': 0
        }

      });
      return Right(true);
    }on FirebaseAuthException catch (err){
      return  Left('${err.message}');
    }


  }



  static Future<Either<String, bool>> postUpdate({
    required String title,
    required String detail,
     XFile? image,
    required String id,
     String? imageId
  })async{
    try{
      if(image == null){
        await postDb.doc(id).update({
          'title': title,
          'detail': detail
        });
      }else{
        final oldRef = FirebaseInstances.firebaseStorage.ref().child('postImages/$imageId');
        await oldRef.delete();
        final newImageId = DateTime.now().toString();
        final ref = FirebaseInstances.firebaseStorage.ref().child('postImages/$newImageId');
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        await postDb.doc(id).update({
          'title': title,
          'imageUrl': url,
          'imageId': newImageId,
          'detail': detail,
        });
      }
      return Right(true);
    }on FirebaseAuthException catch (err){
      return  Left('${err.message}');
    }
  }



  static Future<Either<String, bool>> postRemove({
    required String id,
    required String imageId
 })async{
    try{
      final oldRef = FirebaseInstances.firebaseStorage.ref().child('postImages/$imageId');
      await oldRef.delete();
      await postDb.doc(id).delete();
      return Right(true);
    }on FirebaseAuthException catch (err){
      return  Left('${err.message}');
    }
  }

  static Future<Either<String, bool>> addLike({
    required String id,
    required List<String> username,
    required int oldLikes
  })async{
    try{
       await postDb.doc(id).update({
         'like': {
           'likes': oldLikes + 1,
           'usernames': FieldValue.arrayUnion(username)
         }
       });
      return Right(true);
    }on FirebaseAuthException catch (err){
      return  Left('${err.message}');
    }
  }




  static Future<Either<String, bool>> addComment({
    required String id,
    required List<Comment> comments,
  })async{
    try{
      await postDb.doc(id).update({
        'comments': FieldValue.arrayUnion(comments.map((e) => e.toJson()).toList())
      });
      return Right(true);
    }on FirebaseAuthException catch (err){
      return  Left('${err.message}');
    }
  }

}