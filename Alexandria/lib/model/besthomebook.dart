import 'dart:convert';

BestHomeBook bestHomeBookFromJson(String str) =>
    BestHomeBook.fromJson(json.decode(str));

String bestHomeBookToJson(BestHomeBook data) => json.encode(data.toJson());

class BestHomeBook {
  BestHomeBook({
    required this.ebookApp,
  });

  final EbookApp ebookApp;

  factory BestHomeBook.fromJson(Map<String, dynamic> json) => BestHomeBook(
        ebookApp: EbookApp.fromJson(json["EBOOK_APP"]),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": ebookApp.toJson(),
      };
}

class EbookApp {
  EbookApp({
    required this.featuredBooks,
    required this.latestBooks,
    required this.popularBooks,
  });

  final List<Book> featuredBooks;
  final List<Book> latestBooks;
  final List<Book> popularBooks;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        featuredBooks: List<Book>.from(
            json["featured_books"].map((x) => Book.fromJson(x))),
        latestBooks:
            List<Book>.from(json["latest_books"].map((x) => Book.fromJson(x))),
        popularBooks:
            List<Book>.from(json["popular_books"].map((x) => Book.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "featured_books":
            List<dynamic>.from(featuredBooks.map((x) => x.toJson())),
        "latest_books": List<dynamic>.from(latestBooks.map((x) => x.toJson())),
        "popular_books":
            List<dynamic>.from(popularBooks.map((x) => x.toJson())),
      };
}

class Book {
  Book({
    required this.id,
    required this.catId,
    required this.aid,
    required this.bookTitle,
    required this.bookCoverImg,
    required this.bookBgImg,
    required this.bookFileType,
    required this.bookFileUrl,
    required this.bookDescription,
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
  });

  final String id;
  final String catId;
  final String aid;
  final String bookTitle;
  final String bookCoverImg;
  final dynamic bookBgImg;
  final BookFileType? bookFileType;
  final String bookFileUrl;
  final String bookDescription;
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

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json["id"],
        catId: json["cat_id"],
        aid: json["aid"],
        bookTitle: json["book_title"],
        bookCoverImg: json["book_cover_img"],
        bookBgImg: json["book_bg_img"],
        bookFileType: bookFileTypeValues.map[json["book_file_type"]],
        bookFileUrl: json["book_file_url"],
        bookDescription: json["book_description"],
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
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cat_id": catId,
        "aid": aid,
        "book_title": bookTitle,
        "book_cover_img": bookCoverImg,
        "book_bg_img": bookBgImg,
        "book_file_type": bookFileTypeValues.reverse[bookFileType],
        "book_file_url": bookFileUrl,
        "book_description": bookDescription,
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
      };
}

enum BookFileType { LOCAL, SERVER_URL }

final bookFileTypeValues = EnumValues(
    {"local": BookFileType.LOCAL, "server_url": BookFileType.SERVER_URL});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
