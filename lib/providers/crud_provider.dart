import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_state.dart';
import '../models/posts.dart';
import '../services/crud_service.dart';





final crudProvider = StateNotifierProvider<CrudProvider, PostState>(
        (ref) => CrudProvider(PostState.initState()));

class CrudProvider extends StateNotifier<PostState> {
  CrudProvider(super.state);



 Future<void> postAdd({
    required String title,
    required String detail,
    required XFile image,
    required String uid
  })async{
     state = state.copyWith(isLoad: true, err: '', isSuccess: false);
    final response = await CrudService.postAdd(title: title, detail: detail, image: image, uid: uid);
    response.fold(
            (l) {
              state = state.copyWith(isLoad: false, err: l, isSuccess: false);
            },
            (r) {
              state = state.copyWith(isLoad: false, err: '', isSuccess: r);
            }
    );


  }



   Future<void> postUpdate({
    required String title,
    required String detail,
    XFile? image,
    required String id,
    String? imageId
  })async{
    state = state.copyWith(isLoad: true, err: '', isSuccess: false);
    final response = await CrudService.postUpdate(title: title, detail: detail, id: id, image: image, imageId: imageId);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, err: l, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, err: '', isSuccess: r);
        }
    );

  }



   Future<void> postRemove({
    required String id,
    required String imageId
  })async{
    state = state.copyWith(isLoad: true, err: '');
    final response = await CrudService.postRemove(id: id, imageId: imageId);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, err: l, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, err: '', isSuccess: true);
        }
    );
  }


   Future<void> addLike({
    required String id,
    required List<String> username,
    required int oldLikes
  })async{
     state = state.copyWith(isLoad: true, err: '');
     final response = await CrudService.addLike(id: id, username: username, oldLikes: oldLikes);
     response.fold(
             (l) {
           state = state.copyWith(isLoad: false, err: l, isSuccess: false);
         },
             (r) {
           state = state.copyWith(isLoad: false, err: '', isSuccess: true);
         }
     );
  }


   Future<void> addComment({
    required String id,
    required List<Comment> comments,
  })async{
     state = state.copyWith(isLoad: true, err: '');
     final response = await CrudService.addComment(id: id, comments: comments);
     response.fold(
             (l) {
           state = state.copyWith(isLoad: false, err: l, isSuccess: false);
         },
             (r) {
           state = state.copyWith(isLoad: false, err: '', isSuccess: true);
         }
     );
  }



}
