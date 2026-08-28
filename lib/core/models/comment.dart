import '../utils/html_decode.dart';

class Comment {
  Comment({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.commentText,
    required this.date,
  });

  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String userImage;
  final String commentText;
  final String date;

  factory Comment.fromJson(Map<String, dynamic> json) {
    String d(dynamic v) => decodeHtmlEntities(v?.toString() ?? '');

    return Comment(
      id: '${json['id'] ?? ''}',
      bookId: '${json['bookId'] ?? json['book_id'] ?? ''}',
      userId: '${json['userId'] ?? json['user_id'] ?? ''}',
      userName: d(json['userName'] ?? json['user_name']),
      userImage: d(json['userImage'] ?? json['user_image']),
      commentText: d(json['commentText'] ?? json['comment_text']),
      date: (json['commentOn'] ?? json['dt_rate'] ?? '').toString(),
    );
  }
}
