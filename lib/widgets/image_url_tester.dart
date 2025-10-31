import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

/// Widget de teste para verificar URLs de imagens
class ImageUrlTester extends StatefulWidget {
  final String imageUrl;

  const ImageUrlTester({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ImageUrlTesterState createState() => _ImageUrlTesterState();
}

class _ImageUrlTesterState extends State<ImageUrlTester> {
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  int? statusCode;
  String? contentType;
  int? contentLength;

  @override
  void initState() {
    super.initState();
    _testImageUrl();
  }

  Future<void> _testImageUrl() async {
    try {
      debugPrint('=== TESTE DE URL DE IMAGEM ===');
      debugPrint('URL: ${widget.imageUrl}');

      final uri = Uri.parse(widget.imageUrl);
      final response = await http.head(uri).timeout(
            Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
                'Timeout na requisição', Duration(seconds: 10)),
          );

      setState(() {
        isLoading = false;
        statusCode = response.statusCode;
        contentType = response.headers['content-type'];
        contentLength = int.tryParse(response.headers['content-length'] ?? '0');
        hasError = response.statusCode != 200;
        errorMessage = hasError ? 'Status Code: ${response.statusCode}' : null;
      });

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Content-Type: ${response.headers['content-type']}');
      debugPrint('Content-Length: ${response.headers['content-length']}');
      debugPrint('Headers: ${response.headers}');
    } catch (e) {
      debugPrint('Erro no teste: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teste de URL de Imagem',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'URL: ${widget.imageUrl}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            if (isLoading)
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Testando...'),
                ],
              )
            else if (hasError)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text('ERRO',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (errorMessage != null)
                    Text(errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text('OK',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (statusCode != null)
                    Text('Status: $statusCode', style: TextStyle(fontSize: 12)),
                  if (contentType != null)
                    Text('Tipo: $contentType', style: TextStyle(fontSize: 12)),
                  if (contentLength != null)
                    Text(
                        'Tamanho: ${(contentLength! / 1024).toStringAsFixed(1)} KB',
                        style: TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget para testar múltiplas URLs
class ImageUrlBatchTester extends StatefulWidget {
  final List<String> imageUrls;

  const ImageUrlBatchTester({
    Key? key,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _ImageUrlBatchTesterState createState() => _ImageUrlBatchTesterState();
}

class _ImageUrlBatchTesterState extends State<ImageUrlBatchTester> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste de URLs de Imagem'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        children: widget.imageUrls
            .map((url) => ImageUrlTester(imageUrl: url))
            .toList(),
      ),
    );
  }
}
