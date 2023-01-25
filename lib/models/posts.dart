

class Like{
  final List<String> usernames;
  final int like;
  Like({
    required this.like,
    required this.usernames
});

  factory Like.fromJson(Map<String, dynamic> json){
    return Like(
        like: json['likes'],
        usernames: (json['usernames'] as List).map((e) => e as String).toList()
    );
  }

}


class Comment{
  final String username;
  final String text;
  final String userImage;

  Comment({
    required this.text,
    required this.username,
    required this.userImage
});

  factory Comment.fromJson(Map<String, dynamic> json ){
    return Comment(
        text: json['text'],
        username: json['username'],
        userImage: json['userImage']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'text': this.text,
      'username': this.username,
      'userImage': this.userImage
    };
  }

}



class Post{
 final String id;
 final String userId;
 final String title;
 final String imageUrl;
 final String imageId;
 final String detail;
 final Like like;
 final List<Comment> comments;

 Post({
   required this.imageUrl,
   required this.id,
   required this.title,
   required this.userId,
   required this.detail,
   required this.comments,
   required this.imageId,
   required this.like
});


}