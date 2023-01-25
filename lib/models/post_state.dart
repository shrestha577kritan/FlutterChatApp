



class PostState{

  final bool isSuccess;
  final String err;
  final bool isLoad;


  PostState({
    required this.err,
    required this.isLoad,
    required this.isSuccess,
  });

  PostState.initState(): isSuccess=false,isLoad=false, err='' ;

  PostState copyWith({
    bool? isSuccess,
    String? err,
    bool? isLoad
  }){
    return PostState(
        err: err ?? this.err,
        isLoad: isLoad ?? this.isLoad,
        isSuccess: isSuccess ?? this.isSuccess
    );
  }


}