import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/providers/common_provider.dart';
import 'package:get/get.dart';

import '../commons/snack_show.dart';
import '../providers/auth_provider.dart';



class AuthPage extends ConsumerWidget {
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(authProvider, (previous, next) {
      if(next.err.isNotEmpty){
        SnackShow.showFailure(context, next.err);
      }
    });
    final isLogin = ref.watch(loginProvider);
    final auth = ref.watch(authProvider);
    final image = ref.watch(imageProvider);
    final mode = ref.watch(validateProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
             autovalidateMode: mode,
            key: _form,
            child: Container(
              padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 45, top: 10),
                    child: Text(isLogin ? 'Login Form': 'SignUp Form', style: TextStyle(fontSize: 22, letterSpacing: 2),),
                  ),

                if(!isLogin)  TextFormField(
                  controller: nameController,
                    validator: (val){
                    if(val!.isEmpty){
                      return 'please provide name';
                    }
                      return null;
                    },
                    decoration:  InputDecoration(
                      hintText: 'username',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: mailController,
                    validator: (val){
                      // final bool emailValid =
                      // RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      //     .hasMatch(val!);
                      // print(emailValid);
                      if(val!.isEmpty){
                        return 'please provide email';
                      }else if(!RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(val.trim())){
                        return 'please provide valid email';
                      }
                      return null;
                    },
                    decoration:  InputDecoration(
                        hintText: 'Email',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: passController,
                    // inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    validator: (val){
                      if(val!.isEmpty){
                        return 'please provide password';
                      }else if(val.length > 20){
                        return 'password character is limit to less than 20';
                      }
                      return null;
                    },
                      obscureText: true,
                    decoration:  InputDecoration(
                        hintText: 'Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 20,),
                  if(!isLogin)    InkWell(
                    onTap: (){
                      Get.defaultDialog(
                        title: 'pick an image',
                        content: Text('Select image option'),
                        actions: [
                          TextButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                            ref.read(imageProvider.notifier).pickImage(true);
                          }, child: Text('Gallery')),
                          TextButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                                ref.read(imageProvider.notifier).pickImage(false);
                              }, child: Text('Camera')),
                        ]
                      );
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration:  BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      child: image == null ? Center(child: Text('please select a image')
                      ) : Image.file(File(image.path)),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                      onPressed: auth.isLoad ? null : (){
                        final m = passController.text.trim().replaceAll(RegExp('\\s+'), ' ');
                        _form.currentState!.save();
                        if(_form.currentState!.validate()){
                          FocusScope.of(context).unfocus();
                          if(isLogin){
                            ref.read(authProvider.notifier).userLogin(
                                email: mailController.text.trim(),
                                password: passController.text.trim()
                            );
                          }else{
                           if(image == null){
                             Get.defaultDialog(
                                 title: 'pick an image',
                                 content: Text('image is required'),
                                 actions: [
                                   TextButton(
                                       onPressed: (){
                                         Navigator.of(context).pop();
                                       }, child: Text('Close')),

                                 ]
                             );
                           }else{

                             ref.read(authProvider.notifier).userSignUp(
                                 email: mailController.text.trim(),
                                 password: passController.text.trim(),
                               image: image,
                               username: nameController.text.trim()
                             );
                           }
                          }
                        }else{
                          ref.read(validateProvider.notifier).toggleState();
                        }


                      }, child:auth.isLoad ? Center(child: CircularProgressIndicator()) :Text(isLogin ? 'Login' : 'Sign Up')),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLogin ?'Don\'t have an account' : 'Already have an account'),
                      TextButton(onPressed: (){
                        // _form.currentState!.reset();
                        ref.read(loginProvider.notifier).toggleState();
                      }, child: Text(isLogin ? 'Sign Up' : 'Login'))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
