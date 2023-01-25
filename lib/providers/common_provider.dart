import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


final loginProvider = StateNotifierProvider.autoDispose<LoginProvider, bool>((ref) => LoginProvider(true));

class LoginProvider extends StateNotifier<bool>{
  LoginProvider(super.state);

   void toggleState(){
      state = !state;
   }

}


final imageProvider = StateNotifierProvider.autoDispose<ImageProvider, XFile?>((ref) => ImageProvider(null));

class ImageProvider extends StateNotifier<XFile?>{
  ImageProvider(super.state);

  void pickImage(bool isGallery) async{
    final ImagePicker _picker = ImagePicker();
     if(isGallery){
       state = await _picker.pickImage(source: ImageSource.gallery);
     }else{
       state  = await _picker.pickImage(source: ImageSource.camera);
     }
  }



}



final validateProvider = StateNotifierProvider<ValidateProvider, AutovalidateMode>((ref) => ValidateProvider(AutovalidateMode.disabled));

class ValidateProvider extends StateNotifier< AutovalidateMode>{
  ValidateProvider(super.state);

  void toggleState(){
    state = AutovalidateMode.onUserInteraction;
  }

}