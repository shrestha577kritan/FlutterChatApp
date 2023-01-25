import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/commons/firebase_instances.dart';
import 'package:get/get.dart';
import '../providers/room_provider.dart';
import 'chat_page.dart';




class RecentChats extends ConsumerWidget {

  final userId = FirebaseInstances.firebaseAuth.currentUser!.uid;
  @override
  Widget build(BuildContext context, ref) {
    final roomData = ref.watch(roomsStream);
    return Scaffold(
      body: roomData.when(
          data: (data){
            return ListView.builder(
              itemCount: data.length,
                itemBuilder: (context, index){
                final otherUser = data[index].users.firstWhere((element) => element.id !=userId);
                final currentUser = data[index].users.firstWhere((element) => element.id == userId);
                return ListTile(
                  onTap: (){
                    Get.to(() => ChatPage(data[index], currentUser.firstName!, otherUser.metadata!['token']), transition: Transition.leftToRight);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data[index].imageUrl!)
                  ),
                  title: Text(data[index].name!),

                );
                }
            );
          },
          error: (err, stack) => Center(child: Text('$err')),
          loading: () => Center(child: CircularProgressIndicator())
      ),
    );
  }
}
