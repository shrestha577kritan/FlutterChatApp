import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/commons/firebase_instances.dart';
import 'package:flutterrun/providers/crud_provider.dart';
import 'package:flutterrun/services/auth_service.dart';
import 'package:flutterrun/services/crud_service.dart';
import 'package:flutterrun/view/create_page.dart';
import 'package:flutterrun/view/edit_page.dart';
import 'package:flutterrun/view/recent_chats.dart';
import 'package:flutterrun/view/sample_page.dart';
import 'package:flutterrun/view/user_detail.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../commons/snack_show.dart';
import '../notification_service.dart';
import '../providers/auth_provider.dart';
import 'detail_page.dart';


class HomePage extends ConsumerStatefulWidget{

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final uid = FirebaseInstances.firebaseAuth.currentUser!.uid;

  late types.User user;


  @override
  void initState() {


    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");

          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    // 2. This method only call when App in foreground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
          (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
         // Get.to(() => SamplePage());
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    super.initState();
  }





  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    final userData = ref.watch(userStream(uid));
    final allUserData = ref.watch(allUserStream);
    final postData = ref.watch(dataStream);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Chat'),
      ),
      drawer: Drawer(
        child: userData.when(
            data: (data){
              user = data;
              return ListView(
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(data.imageUrl!), fit: BoxFit.cover)
                      ),
                      child: Container()),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(data.firstName!),
                  ),
                  ListTile(
                    leading: Icon(Icons.mail),
                    title: Text(data.metadata!['email']),
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.of(context).pop();
                      Get.to(() => AddPage(), transition: Transition.leftToRight);
                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Create Post'),
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.of(context).pop();
                      Get.to(() => RecentChats(), transition: Transition.leftToRight);
                    },
                    leading: Icon(Icons.message),
                    title: Text('Recent Chats'),
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.of(context).pop();
                      ref.read(authProvider.notifier).userLogOut();
                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text('SignOut'),
                  )
                ],
              );
            },
            error: (err, stack) => Center(child: Text('$err')),
            loading: () => Center(child: CircularProgressIndicator())
        )
      ),
        body: Column(
            children: [
              Container(
                height: 190,
                child: allUserData.when(
                    data: (data){
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.length,
                          itemBuilder: (context, index){
                          return InkWell(
                            onTap: (){
                              Get.to(() => UserDetail(data[index]), transition: Transition.leftToRight);
                            },
                            child: Padding(
                              padding:index == 0 ? EdgeInsets.only(left: 10, top: 10) : EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                margin: EdgeInsets.only(right: 15),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(data[index].imageUrl!),
                                    ),
                                    SizedBox(height: 10,),
                                    Text(data[index].firstName!, style: TextStyle(fontSize: 17),)
                                  ],
                                ),
                              ),
                            ),
                          );
                          }
                      );
                    },
                    error: (err, stack) => Center(child: Text('$err')),
                    loading: () => Container()
                ),
              ),
              Expanded(
                  child: Container(
                    child: postData.when(
                        data: (data){
                          return ListView.builder(
                            itemCount: data.length,
                              itemBuilder: (context, index){
                              final post = data[index];
                              return InkWell(
                                onTap: (){
                                    Get.to(() => DetailPage(post, user), transition: Transition.leftToRight);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(post.title),
                                       if(uid == post.userId)   IconButton(
                                           onPressed: (){
                                             Get.defaultDialog(
                                               cancel: IconButton(
                                                   onPressed: (){
                                                     Get.back();
                                                   },
                                                   icon: Icon(Icons.close)
                                               ),
                                               title: 'Customize post',
                                               content: Text('Edit or remove post'),
                                               actions: [
                                                 IconButton(
                                                     onPressed: (){
                                                       Get.back();
                                                       Get.to(() => EditPage(post), transition: Transition.leftToRight);
                                                     }, icon: Icon(Icons.edit)),
                                                 IconButton(
                                                     onPressed: (){
                                                       Get.back();
                                                       Get.defaultDialog(
                                                         title: 'Hold on',
                                                         content: Text('Are you sure you want to remove this post ?'),
                                                         actions: [
                                                           TextButton(
                                                               onPressed: (){
                                                                 Get.back();
                                                                 ref.read(crudProvider.notifier).postRemove(id: post.id, imageId: post.imageId);
                                                               }, child: Text('yes')),
                                                           TextButton(
                                                               onPressed: (){
                                                                 Get.back();
                                                               }, child: Text('no')),
                                                         ]
                                                       );
                                                     }, icon: Icon(Icons.delete)),
                                               ]
                                             );
                                           }, icon: Icon(Icons.more_horiz_outlined)
                                       )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Image.network(post.imageUrl, height: 350, width: double.infinity),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(post.detail, maxLines: 2,)),
                                      if(uid != post.userId )    Row(
                                        children: [
                                          IconButton(
                                              onPressed: (){
                                          if(post.like.usernames.contains(user.firstName)){
                                            SnackShow.showFailure(context, 'you have already like this post');
                                          }else{
                                            ref.read(crudProvider.notifier).addLike(
                                                id: post.id,
                                                username: [...post.like.usernames, user.firstName!],
                                                oldLikes: post.like.like
                                            );
                                          }
                                          }, icon: Icon(Icons.thumb_up_alt_outlined)),
                                        if(post.like.like != 0)  Text('${post.like.like}')
                                        ],
                                      )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              }
                          );
                        },
                        error: (err, stack) => Center(child: Text('$err')),
                        loading: () => Center(child: CircularProgressIndicator(),)
                    ),
                  )
              )
            ]
        )
    );
  }
}
