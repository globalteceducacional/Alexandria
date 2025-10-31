import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'robust_image_widget.dart';

/// Widget personalizado para carregamento seguro de imagens
/// Resolve problemas de "Invalid image data" com tratamento robusto de erros
class SafeImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final File? file;
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final bool enableRetry;
  final int maxRetries;

  const SafeImageWidget({
    Key? key,
    this.imageUrl,
    this.assetPath,
    this.file,
    this.bytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.enableRetry = true,
    this.maxRetries = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RobustImageWidget(
      imageUrl: imageUrl,
      assetPath: assetPath,
      file: file,
      bytes: bytes,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      enableMemoryCache: enableMemoryCache,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
    );
  }
}

/// Widget específico para imagens de perfil com tratamento especial
class SafeProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const SafeProfileImageWidget({
    Key? key,
    this.imageUrl,
    this.size = 60,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

/// Widget específico para imagens de capa de livros
class SafeBookCoverWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SafeBookCoverWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: (width != null && height != null)
                  ? (width! < height! ? width! * 0.3 : height! * 0.3)
                  : 40,
              color: Colors.grey[600],
            ),
            SizedBox(height: 4),
            Text(
              'Capa não disponível',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget específico para imagens de categoria
class SafeCategoryImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SafeCategoryImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: (width != null && height != null)
                  ? (width! < height! ? width! * 0.3 : height! * 0.3)
                  : 40,
              color: Colors.grey[600],
            ),
            SizedBox(height: 4),
            Text(
              'Categoria',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
