


class AuthState{

 final bool isSuccess;
 final String err;
 final bool isLoad;


 AuthState({
  required this.err,
  required this.isLoad,
  required this.isSuccess
});

 AuthState.initState(): isSuccess=false,isLoad=false, err='' ;

 AuthState copyWith({
  bool? isSuccess,
  String? err,
  bool? isLoad
}){
  return AuthState(
      err: err ?? this.err,
      isLoad: isLoad ?? this.isLoad,
      isSuccess: isSuccess ?? this.isSuccess
  );
 }


}