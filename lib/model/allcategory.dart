import 'dart:convert';

AllCategory allCategoryFromJson(String str) =>
    AllCategory.fromJson(json.decode(str));

String allCategoryToJson(AllCategory data) => json.encode(data.toJson());

class AllCategory {
  AllCategory({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory AllCategory.fromJson(Map<String, dynamic> json) => AllCategory(
        ebookApp: List<EbookApp>.from(
            json["EBOOK_APP"].map((x) => EbookApp.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": List<dynamic>.from(ebookApp.map((x) => x.toJson())),
      };
}

class EbookApp {
  EbookApp({
    required this.cid,
    required this.categoryName,
    required this.categoryImage,
    required this.categoryImageThumb,
    required this.totalBooks,
  });

  final String cid;
  final String categoryName;
  final String categoryImage;
  final String categoryImageThumb;
  final String totalBooks;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        cid: json["cid"],
        categoryName: json["category_name"],
        categoryImage: json["category_image"],
        categoryImageThumb: json["category_image_thumb"],
        totalBooks: json["total_books"],
      );

  Map<String, dynamic> toJson() => {
        "cid": cid,
        "category_name": categoryName,
        "category_image": categoryImage,
        "category_image_thumb": categoryImageThumb,
        "total_books": totalBooks,
      };
}
