import 'dart:convert';

SingleBookById singleBookByIdFromJson(String str) =>
    SingleBookById.fromJson(json.decode(str));

String singleBookByIdToJson(SingleBookById data) => json.encode(data.toJson());

class SingleBookById {
  SingleBookById({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory SingleBookById.fromJson(Map<String, dynamic> json) => SingleBookById(
        ebookApp: List<EbookApp>.from(
            json["EBOOK_APP"].map((x) => EbookApp.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": List<dynamic>.from(ebookApp.map((x) => x.toJson())),
      };
}

class EbookApp {
  EbookApp({
    required this.id,
    required this.catId,
    required this.aid,
    required this.featured,
    required this.bookTitle,
    required this.bookDescription,
    required this.bookCoverImg,
    required this.bookBgImg,
    required this.bookFileType,
    required this.bookFileUrl,
    required this.totalRate,
    required this.rateAvg,
    required this.bookViews,
    required this.authorId,
    required this.authorName,
    required this.authorDescription,
    required this.cid,
    required this.categoryName,
    required this.categoryImage,
    required this.categoryImageThumb,
    required this.relatedBooks,
    required this.userComments,
  });

  final String id;
  final String catId;
  final String aid;
  final dynamic featured;
  final String bookTitle;
  final String bookDescription;
  final String bookCoverImg;
  final dynamic bookBgImg;
  final String bookFileType;
  final String bookFileUrl;
  final String totalRate;
  final String rateAvg;
  final String bookViews;
  final String authorId;
  final String authorName;
  final String authorDescription;
  final String cid;
  final String categoryName;
  final String categoryImage;
  final String categoryImageThumb;
  final List<EbookApp>? relatedBooks;
  final List<UserComment>? userComments;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        id: json["id"],
        catId: json["cat_id"],
        aid: json["aid"],
        featured: json["featured"] == null ? null : json["featured"],
        bookTitle: json["book_title"],
        bookDescription: json["book_description"],
        bookCoverImg: json["book_cover_img"],
        bookBgImg: json["book_bg_img"],
        bookFileType: json["book_file_type"],
        bookFileUrl: json["book_file_url"],
        totalRate: json["total_rate"],
        rateAvg: json["rate_avg"],
        bookViews: json["book_views"],
        authorId: json["author_id"],
        authorName: json["author_name"],
        authorDescription: json["author_description"],
        cid: json["cid"],
        categoryName: json["category_name"],
        categoryImage: json["category_image"],
        categoryImageThumb: json["category_image_thumb"],
        relatedBooks: json["related_books"] == null
            ? null
            : List<EbookApp>.from(
                json["related_books"].map((x) => EbookApp.fromJson(x))),
        userComments: json["user_comments"] == null
            ? null
            : List<UserComment>.from(
                json["user_comments"].map((x) => UserComment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cat_id": catId,
        "aid": aid,
        "featured": featured == null ? null : featured,
        "book_title": bookTitle,
        "book_description": bookDescription,
        "book_cover_img": bookCoverImg,
        "book_bg_img": bookBgImg,
        "book_file_type": bookFileType,
        "book_file_url": bookFileUrl,
        "total_rate": totalRate,
        "rate_avg": rateAvg,
        "book_views": bookViews,
        "author_id": authorId,
        "author_name": authorName,
        "author_description": authorDescription,
        "cid": cid,
        "category_name": categoryName,
        "category_image": categoryImage,
        "category_image_thumb": categoryImageThumb,
        "related_books": relatedBooks == null
            ? null
            : List<dynamic>.from(relatedBooks!.map((x) => x.toJson())),
        "user_comments": userComments == null
            ? null
            : List<dynamic>.from(userComments!.map((x) => x.toJson())),
      };
}

class UserComment {
  UserComment({
    required this.bookId,
    required this.userName,
    required this.commentText,
    required this.userImage,
    required this.dtRate,
  });

  final String bookId;
  final String userName;
  final String commentText;
  final String userImage;
  final String dtRate;

  factory UserComment.fromJson(Map<String, dynamic> json) => UserComment(
        bookId: json["book_id"],
        userName: json["user_name"],
        commentText: json["comment_text"],
        userImage: json["user_image"],
        dtRate: json["dt_rate"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "user_name": userName,
        "comment_text": commentText,
        "user_image": userImage,
        "dt_rate": dtRate,
      };
}
