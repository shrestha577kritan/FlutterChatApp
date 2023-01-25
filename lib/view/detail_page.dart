import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/models/posts.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutterrun/providers/crud_provider.dart';

import '../services/crud_service.dart';


class DetailPage extends ConsumerWidget {
 final Post post;
 final types.User user;

 DetailPage(this.post, this.user);
final text = TextEditingController();
  @override
  Widget build(BuildContext context, ref) {
    final postData = ref.watch(dataStream);
    return Scaffold(
      resizeToAvoidBottomInset: false,  
        body: Column(
              children: [
                Image.network(post.imageUrl, height: 390,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: text,
                        onFieldSubmitted: (val) {
                          if (val.isNotEmpty) {
                            ref.read(crudProvider.notifier).addComment(
                                id: post.id, comments: [...post.comments, Comment(text: val,
                                username: user.firstName!, userImage: user.imageUrl!)]
                            );
                            text.clear();
                          }
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(),
                            hintText: 'Add Some Comment'
                        ),
                      ),




                    ],
                  ),
                ),

                Expanded(
                  child: postData.when(
                      data: (data){
                        final currentPost = data.firstWhere((element) => element.id == post.id);
                        return  ListView.builder(
                            itemCount: currentPost.comments.length,
                            itemBuilder: (context, index){
                              final comment = currentPost.comments[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: Image.network(comment.userImage),
                                    title: Text(comment.username),
                                    subtitle: Text(comment.text),
                                  )
                                ),
                              );
                            }
                        );
                      },
                      error: (err, stack) => Text('$err'),
                      loading: () => Center(child: CircularProgressIndicator())
                  ),
                )

              ],

        )
    );
  }
}
