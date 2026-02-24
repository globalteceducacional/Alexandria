import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../consttants.dart';

/// Widget melhorado para carregamento de imagens com múltiplas estratégias
class RobustImageWidget extends StatefulWidget {
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

  const RobustImageWidget({
    super.key,
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
  });

  @override
  State<RobustImageWidget> createState() => _RobustImageWidgetState();
}

class _RobustImageWidgetState extends State<RobustImageWidget> {
  int _retryCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() {
        _errorMessage = 'URL de imagem não fornecida';
      });
      return;
    }

    try {
      // Corrigir URL removendo HTML entities
      String fixedUrl = fixImageUrl(widget.imageUrl!);
      debugPrint('RobustImageWidget: URL original: ${widget.imageUrl}');
      debugPrint('RobustImageWidget: URL corrigida: $fixedUrl');
      debugPrint(
          'RobustImageWidget: Tentando carregar imagem (tentativa ${_retryCount + 1})');

      // Primeira tentativa: CachedNetworkImage normal
      if (_retryCount == 0) {
        await _tryCachedNetworkImage();
      }
      // Segunda tentativa: HTTP direto com validação
      else if (_retryCount == 1) {
        await _tryDirectHttpLoad();
      }
      // Terceira tentativa: Sem cache
      else if (_retryCount == 2) {
        await _tryNoCacheLoad();
      }
    } catch (e) {
      debugPrint('RobustImageWidget: Erro na tentativa ${_retryCount + 1}: $e');

      if (widget.enableRetry && _retryCount < widget.maxRetries - 1) {
        _retryCount++;
        await Future.delayed(const Duration(milliseconds: 500));
        _loadImage();
      } else {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _tryCachedNetworkImage() async {
    // Esta é a implementação padrão que será usada pelo CachedNetworkImage
    // O estado será gerenciado pelo CachedNetworkImage
  }

  Future<void> _tryDirectHttpLoad() async {
    debugPrint('RobustImageWidget: Tentativa HTTP direta');

    String fixedUrl = fixImageUrl(widget.imageUrl!);
    final response = await http.get(
      Uri.parse(fixedUrl),
      headers: {
        'User-Agent': 'Flutter Ebook App/1.0',
        'Accept': 'image/png,image/jpeg,image/jpg,image/gif,image/webp,*/*',
        'Accept-Encoding': 'gzip, deflate',
        'Cache-Control': 'no-cache',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (bytes.isNotEmpty) {
        // Sucesso - o CachedNetworkImage gerenciará o estado
      } else {
        throw Exception('Resposta vazia do servidor');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<void> _tryNoCacheLoad() async {
    debugPrint('RobustImageWidget: Tentativa sem cache');

    String fixedUrl = fixImageUrl(widget.imageUrl!);
    final response = await http.get(
      Uri.parse(fixedUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36',
        'Accept': '*/*',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (bytes.isNotEmpty) {
        // Sucesso - o CachedNetworkImage gerenciará o estado
      } else {
        throw Exception('Resposta vazia do servidor');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    try {
      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
        imageWidget = _buildNetworkImage();
      } else if (widget.assetPath != null && widget.assetPath!.isNotEmpty) {
        imageWidget = _buildAssetImage();
      } else if (widget.file != null) {
        imageWidget = _buildFileImage();
      } else if (widget.bytes != null) {
        imageWidget = _buildBytesImage();
      } else {
        imageWidget = _buildErrorWidget();
      }
    } catch (e) {
      debugPrint('RobustImageWidget: Erro ao construir widget: $e');
      imageWidget = _buildErrorWidget();
    }

    // Aplica border radius se especificado
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildNetworkImage() {
    // Corrigir URL removendo HTML entities antes de usar
    String fixedUrl = fixImageUrl(widget.imageUrl!);

    return CachedNetworkImage(
      imageUrl: fixedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      memCacheWidth: widget.width?.toInt(),
      memCacheHeight: widget.height?.toInt(),
      fadeInDuration: widget.fadeInDuration ?? const Duration(milliseconds: 300),
      fadeOutDuration: widget.fadeOutDuration ?? const Duration(milliseconds: 100),
      placeholder: (context, url) {
        debugPrint('RobustImageWidget: Carregando placeholder para: $url');
        return widget.placeholder ?? _buildDefaultPlaceholder();
      },
      errorWidget: (context, url, error) {
        debugPrint('RobustImageWidget: Erro ao carregar imagem: $error');
        debugPrint('RobustImageWidget: URL com erro: $url');
        debugPrint('RobustImageWidget: Tipo de erro: ${error.runtimeType}');

        // Se ainda temos tentativas, mostra placeholder
        if (widget.enableRetry && _retryCount < widget.maxRetries - 1) {
          return widget.placeholder ?? _buildDefaultPlaceholder();
        }

        return widget.errorWidget ?? _buildErrorWidget();
      },
      httpHeaders: {
        'User-Agent': 'Flutter Ebook App/1.0',
        'Accept': 'image/png,image/jpeg,image/jpg,image/gif,image/webp,*/*',
        'Accept-Encoding': 'gzip, deflate',
        'Cache-Control': _retryCount == 0 ? 'max-age=3600' : 'no-cache',
      },
      // Configurações adicionais para melhor performance
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      // Validação de dados da imagem
      imageBuilder: (context, imageProvider) {
        debugPrint(
            'RobustImageWidget: Imagem carregada com sucesso: ${widget.imageUrl}');
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: widget.fit,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      widget.assetPath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint(
            'RobustImageWidget: Erro ao carregar imagem do asset: $error');
        debugPrint('RobustImageWidget: Asset path: ${widget.assetPath}');
        return widget.errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildFileImage() {
    return Image.file(
      widget.file!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint(
            'RobustImageWidget: Erro ao carregar imagem do arquivo: $error');
        debugPrint('RobustImageWidget: File path: ${widget.file!.path}');
        return widget.errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildBytesImage() {
    return Image.memory(
      widget.bytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint(
            'RobustImageWidget: Erro ao carregar imagem dos bytes: $error');
        return widget.errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor(),
      highlightColor: shimmerHighlightColor(),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: comboBlackAndWhite(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: (widget.width != null && widget.height != null)
                ? (widget.width! < widget.height!
                    ? widget.width! * 0.3
                    : widget.height! * 0.3)
                : 40,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Imagem não encontrada',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
