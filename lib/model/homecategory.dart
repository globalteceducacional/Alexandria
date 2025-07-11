import 'dart:convert';

CategoryById categoryByIdFromJson(String str) =>
    CategoryById.fromJson(json.decode(str));

String categoryByIdToJson(CategoryById data) => json.encode(data.toJson());

class CategoryById {
  CategoryById({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory CategoryById.fromJson(Map<String, dynamic> json) => CategoryById(
        ebookApp: List<EbookApp>.from(
            json["EBOOK_APP"].map((x) => EbookApp.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": List<dynamic>.from(ebookApp.map((x) => x.toJson())),
      };
}

class EbookApp {
  EbookApp({
    required this.totalRecords,
    required this.id,
    required this.catId,
    required this.featured,
    required this.bookTitle,
    required this.bookPrice,
    required this.bookDescription,
    required this.bookCoverImg,
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
  });

  final String totalRecords;
  final String id;
  final String catId;
  final String featured;
  final String bookTitle;
  final dynamic bookPrice;
  final String bookDescription;
  final String bookCoverImg;
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

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        totalRecords: json["total_records"],
        id: json["id"],
        catId: json["cat_id"],
        featured: json["featured"],
        bookTitle: json["book_title"],
        bookPrice: json["book_price"] == null ? null : json["book_price"],
        bookDescription: json["book_description"],
        bookCoverImg: json["book_cover_img"],
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
      );

  Map<String, dynamic> toJson() => {
        "total_records": totalRecords,
        "id": id,
        "cat_id": catId,
        "featured": featured,
        "book_title": bookTitle,
        "book_price": bookPrice,
        "book_description": bookDescription,
        "book_cover_img": bookCoverImg,
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
      };
}
