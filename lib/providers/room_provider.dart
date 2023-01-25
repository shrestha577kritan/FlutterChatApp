import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/commons/firebase_instances.dart';


final roomsStream = StreamProvider.autoDispose((ref) => FirebaseInstances.firebaseChatCore.rooms());
final messageStream = StreamProvider.family.autoDispose((ref, types.Room room) => FirebaseInstances.firebaseChatCore.messages(room));
final roomProvider = Provider((ref) => RoomProvider());

class RoomProvider {

  Future<types.Room?>  roomCreate (types.User user) async{
       try{
         final response = await FirebaseInstances.firebaseChatCore.createRoom(user);
         return response;
       }catch (err){
         return null;
       }
  }


}