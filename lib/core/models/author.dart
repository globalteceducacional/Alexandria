import '../config/app_config.dart';
import '../utils/html_decode.dart';

class Author {
  Author({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  final String id;
  final String name;
  final String image;
  final String description;

  factory Author.fromJson(Map<String, dynamic> json) {
    String d(dynamic v) => decodeHtmlEntities(v?.toString() ?? '');

    return Author(
      id: '${json['id'] ?? json['author_id'] ?? ''}',
      name: d(json['name'] ?? json['author_name'] ?? ''),
      image: d(json['image'] ?? json['author_image'] ?? ''),
      description: d(json['description'] ?? json['author_description'] ?? ''),
    );
  }

  String get imageUrl {
    return AppConfig.resolveMediaUrl(image, folder: 'images');
  }
}
