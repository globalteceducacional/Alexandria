import '../config/app_config.dart';
import '../utils/html_decode.dart';

class Category {
  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.imageThumb,
    required this.totalBooks,
  });

  final String id;
  final String name;
  final String image;
  final String imageThumb;
  final int totalBooks;

  factory Category.fromJson(Map<String, dynamic> json) {
    String d(dynamic v) => decodeHtmlEntities(v?.toString() ?? '');
    final image = d(json['image'] ?? json['category_image'] ?? '');

    return Category(
      id: '${json['id'] ?? json['cid'] ?? ''}',
      name: d(json['name'] ?? json['category_name'] ?? ''),
      image: image,
      imageThumb: d(
        json['imageThumb'] ??
            json['category_image_thumb'] ??
            image,
      ),
      totalBooks: int.tryParse('${json['totalBooks'] ?? json['total_books'] ?? 0}') ??
          0,
    );
  }

  String get imageUrl {
    return AppConfig.resolveMediaUrl(image, folder: 'images');
  }

  String get imageThumbUrl {
    if (imageThumb.isEmpty || imageThumb == image) return imageUrl;
    return AppConfig.resolveMediaUrl(imageThumb, folder: 'images/thumbs');
  }
}
