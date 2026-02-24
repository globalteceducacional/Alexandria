
import 'dart:convert';

CategoryId categoryIdFromJson(String str) =>
    CategoryId.fromJson(json.decode(str));

String categoryIdToJson(CategoryId data) => json.encode(data.toJson());

class CategoryId {
  CategoryId({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
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
    required this.sectionTitle,
    required this.songList,
  });

  final String id;
  final String sectionTitle;
  final String songList;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        id: json["id"],
        sectionTitle: json["section_title"],
        songList: json["song_list"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "section_title": sectionTitle,
        "song_list": songList,
      };
}
