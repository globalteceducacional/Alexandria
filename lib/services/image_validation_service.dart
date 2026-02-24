import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Serviço para validação e processamento seguro de imagens
class ImageValidationService {
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
    'image/tiff',
    'application/octet-stream' // Para alguns servidores que não especificam o tipo
  ];

  /// Valida se uma URL de imagem é válida
  static Future<bool> isValidImageUrl(String url) async {
    try {
      if (url.isEmpty) return false;

      // Verifica se a URL tem formato válido
      final uri = Uri.tryParse(url);
      if (uri == null) return false;

      // Verifica se é uma URL HTTP/HTTPS
      if (!uri.scheme.startsWith('http')) return false;

      // Faz uma requisição HEAD para verificar se o arquivo existe
      final response = await http.head(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
                'Timeout na validação da imagem', const Duration(seconds: 10)),
          );

      if (response.statusCode != 200) return false;

      // Verifica o Content-Type
      final contentType = response.headers['content-type']?.toLowerCase();
      if (contentType == null || !allowedImageTypes.contains(contentType)) {
        return false;
      }

      // Verifica o tamanho do arquivo
      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        final size = int.tryParse(contentLength);
        if (size != null && size > maxImageSizeBytes) {
          debugPrint('Imagem muito grande: $size bytes');
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao validar URL da imagem: $e');
      return false;
    }
  }

  /// Valida se um arquivo de imagem é válido
  static Future<bool> isValidImageFile(File file) async {
    try {
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      if (fileSize == 0 || fileSize > maxImageSizeBytes) {
        debugPrint('Arquivo de imagem inválido: tamanho $fileSize bytes');
        return false;
      }

      // Verifica a extensão do arquivo
      final extension = path.extension(file.path).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

      if (!validExtensions.contains(extension)) {
        debugPrint('Extensão de arquivo inválida: $extension');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao validar arquivo de imagem: $e');
      return false;
    }
  }

  /// Valida se bytes de imagem são válidos
  static bool isValidImageBytes(Uint8List bytes) {
    try {
      if (bytes.isEmpty) return false;

      if (bytes.length > maxImageSizeBytes) {
        debugPrint('Bytes de imagem muito grandes: ${bytes.length} bytes');
        return false;
      }

      // Verifica os primeiros bytes para identificar o tipo de imagem
      if (bytes.length < 4) return false;

      // PNG: 89 50 4E 47 (0x89504E47)
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        debugPrint('Formato PNG detectado');
        return true;
      }

      // JPEG: FF D8 FF (0xFFD8FF)
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        debugPrint('Formato JPEG detectado');
        return true;
      }

      // JPEG alternativo: FF D8 FF E0 ou FF D8 FF E1
      if (bytes.length >= 4 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF &&
          (bytes[3] == 0xE0 || bytes[3] == 0xE1)) {
        debugPrint('Formato JPEG alternativo detectado');
        return true;
      }

      // GIF: 47 49 46 38
      if (bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38) {
        return true;
      }

      // WebP: 52 49 46 46 ... 57 45 42 50
      if (bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return true;
      }

      debugPrint('Formato de imagem não reconhecido');
      return false;
    } catch (e) {
      debugPrint('Erro ao validar bytes de imagem: $e');
      return false;
    }
  }

  /// Baixa e valida uma imagem da URL
  static Future<Uint8List?> downloadAndValidateImage(String url) async {
    try {
      if (!await isValidImageUrl(url)) {
        debugPrint('URL de imagem inválida: $url');
        return null;
      }

      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
                'Timeout no download da imagem', const Duration(seconds: 30)),
          );

      if (response.statusCode != 200) {
        debugPrint('Erro HTTP ao baixar imagem: ${response.statusCode}');
        return null;
      }

      final bytes = response.bodyBytes;

      if (!isValidImageBytes(bytes)) {
        debugPrint('Bytes de imagem inválidos');
        return null;
      }

      return bytes;
    } catch (e) {
      debugPrint('Erro ao baixar imagem: $e');
      return null;
    }
  }

  /// Salva bytes de imagem em um arquivo temporário
  static Future<File?> saveImageToTempFile(
      Uint8List bytes, String filename) async {
    try {
      if (!isValidImageBytes(bytes)) {
        debugPrint('Bytes de imagem inválidos para salvar');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(path.join(tempDir.path, filename));

      await file.writeAsBytes(bytes);

      if (await isValidImageFile(file)) {
        return file;
      } else {
        await file.delete();
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao salvar imagem em arquivo temporário: $e');
      return null;
    }
  }

  /// Limpa arquivos temporários de imagem antigos
  static Future<void> cleanupTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      final now = DateTime.now();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          // Remove arquivos com mais de 24 horas
          if (age.inHours > 24) {
            try {
              await file.delete();
              debugPrint('Arquivo temporário removido: ${file.path}');
            } catch (e) {
              debugPrint('Erro ao remover arquivo temporário: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao limpar arquivos temporários: $e');
    }
  }

  /// Obtém informações sobre uma imagem
  static Future<ImageInfo?> getImageInfo(String url) async {
    try {
      final bytes = await downloadAndValidateImage(url);
      if (bytes == null) return null;

      // Aqui você poderia usar um pacote como image para obter dimensões
      // Por enquanto, retornamos informações básicas
      return ImageInfo(
        url: url,
        size: bytes.length,
        isValid: true,
      );
    } catch (e) {
      debugPrint('Erro ao obter informações da imagem: $e');
      return null;
    }
  }
}

/// Classe para armazenar informações da imagem
class ImageInfo {
  final String url;
  final int size;
  final bool isValid;
  final int? width;
  final int? height;

  ImageInfo({
    required this.url,
    required this.size,
    required this.isValid,
    this.width,
    this.height,
  });
}

/// Exception personalizada para erros de imagem
class ImageValidationException implements Exception {
  final String message;
  final String? url;
  final dynamic originalError;

  ImageValidationException(this.message, {this.url, this.originalError});

  @override
  String toString() {
    return 'ImageValidationException: $message${url != null ? ' (URL: $url)' : ''}';
  }
}
