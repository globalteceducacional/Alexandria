import 'dart:convert';

ExploreAuthor exploreAuthorFromJson(String str) =>
    ExploreAuthor.fromJson(json.decode(str));

String exploreAuthorToJson(ExploreAuthor data) => json.encode(data.toJson());

class ExploreAuthor {
  ExploreAuthor({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory ExploreAuthor.fromJson(Map<String, dynamic> json) => ExploreAuthor(
        ebookApp: List<EbookApp>.from(
            json["EBOOK_APP"].map((x) => EbookApp.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": List<dynamic>.from(ebookApp.map((x) => x.toJson())),
      };
}

class EbookApp {
  EbookApp({
    required this.authorId,
    required this.authorName,
    required this.authorImage,
    required this.authorDescription,
  });

  final String authorId;
  final String authorName;
  final String authorImage;
  final String authorDescription;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        authorId: json["author_id"],
        authorName: json["author_name"],
        authorImage: json["author_image"],
        authorDescription: json["author_description"],
      );

  Map<String, dynamic> toJson() => {
        "author_id": authorId,
        "author_name": authorName,
        "author_image": authorImage,
        "author_description": authorDescription,
      };
}
