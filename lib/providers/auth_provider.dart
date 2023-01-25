import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/commons/firebase_instances.dart';
import 'package:flutterrun/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import '../models/authState.dart';



final authStream = StreamProvider.autoDispose((ref) =>FirebaseInstances.firebaseAuth.authStateChanges());


final authProvider = StateNotifierProvider<AuthProvider, AuthState>(
    (ref) => AuthProvider(AuthState.initState()));

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider(super.state);

  Future<void> userSignUp(
      {required String email,
      required String username,
      required XFile image,
      required String password}) async {
    state = state.copyWith(isLoad: true);
    final response = await AuthService.userSignUp(
        email: email, username: username, image: image, password: password);
    response.fold((l) {
      state = state.copyWith(isLoad: false, isSuccess: false, err: l);
    }, (r) {
      state = state.copyWith(isLoad: false, isSuccess: r, err: '');
    });
  }




   Future<void> userLogin({
    required String email,
    required String password
  })async{
     state = state.copyWith(isLoad: true, err: '');
      final response = await AuthService.userLogin(
        email: email,
        password: password,
      );

     response.fold((l) {
       state = state.copyWith(isLoad: false, isSuccess: false, err: l);
     }, (r) {
       state = state.copyWith(isLoad: false, isSuccess: r, err: '');
     });

  }


  Future<void> userLogOut()async{
    state = state.copyWith(isLoad: true, err: '');
    final response = await AuthService.userLogOut();
    response.fold((l) {
      state = state.copyWith(isLoad: false, isSuccess: false, err: l);
    }, (r) {
      state = state.copyWith(isLoad: false, isSuccess: r, err: '');
    });
  }





}
