import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/providers/common_provider.dart';
import 'package:get/get.dart';
import '../commons/firebase_instances.dart';
import '../commons/snack_show.dart';
import '../models/posts.dart';
import '../providers/crud_provider.dart';



class EditPage extends ConsumerStatefulWidget{

  final Post post;

  EditPage(this.post);

  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  final uid = FirebaseInstances.firebaseAuth.currentUser!.uid;

  TextEditingController titleController = TextEditingController();

  TextEditingController detailController = TextEditingController();


  @override
  void initState() {
    titleController..text = widget.post.title;
    detailController..text = widget.post.detail;
    super.initState();
  }


  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.listen(crudProvider, (previous, next) {
      if(next.err.isNotEmpty){
        SnackShow.showFailure(context, next.err);
      }else if(next.isSuccess){
        Get.back();
      }
    });
    final crud = ref.watch(crudProvider);
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
                      child: Text('Edit Form', style: TextStyle(fontSize: 22, letterSpacing: 2),),
                    ),

                    TextFormField(
                      controller: titleController,
                      validator: (val){
                        if(val!.isEmpty){
                          return 'please provide title';
                        }
                        return null;
                      },
                      decoration:  InputDecoration(
                          hintText: 'Title',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          border: OutlineInputBorder()
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                      controller: detailController,
                      validator: (val){
                        if(val!.isEmpty){
                          return 'please provide detail';
                        }else if(val.length > 500){
                          return 'detail character is limit to less than 20';
                        }
                        return null;
                      },
                      decoration:  InputDecoration(
                          hintText: 'Detail',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          border: OutlineInputBorder()
                      ),
                    ),
                    SizedBox(height: 20,),
                    InkWell(
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
                        child: image == null ? Image.network(widget.post.imageUrl)
                         : Image.file(File(image.path)),
                      ),
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton(
                        onPressed: crud.isLoad ? null : (){

                          _form.currentState!.save();
                          if(_form.currentState!.validate()){
                            FocusScope.of(context).unfocus();
                            if(image == null){
                             ref.read(crudProvider.notifier).postUpdate(
                                 title: titleController.text.trim(),
                                 detail: detailController.text.trim(),
                                 id: widget.post.id,
                             );
                            }else{
                              ref.read(crudProvider.notifier).postUpdate(
                                title: titleController.text.trim(),
                                detail: detailController.text.trim(),
                                id: widget.post.id,
                                imageId: widget.post.imageId,
                                image: image
                              );

                            }
                          }else{
                            ref.read(validateProvider.notifier).toggleState();
                          }

                        }, child:crud.isLoad ? Center(child: CircularProgressIndicator()) :Text( 'Submit')),
                    SizedBox(height: 20,),

                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
