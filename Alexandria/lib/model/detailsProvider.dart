import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elearn/widgets/download_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DetailsProvider extends ChangeNotifier {
  bool loading = true;
  RxBool barrierDismissible = false.obs;

  Future<void> downloadFile(BuildContext context,
      {required String url,
      required String filename,
      required int id,
      required String img}) async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    // Garantir que o diretório Ebook exista no Android
    if (Platform.isAndroid && appDocDir != null) {
      Directory ebookDir = Directory('${appDocDir.path}/Ebook');
      if (!await ebookDir.exists()) {
        await ebookDir.create(recursive: true);
        print(
            "DEBUG PROVIDER: Diretório para e-books criado em: ${ebookDir.path}");
      }
    }

    try {
      // Determinar a extensão correta do arquivo a partir da URL
      String fileExtension = '.pdf';
      if (url.toLowerCase().contains('.epub')) {
        fileExtension = '.epub';
      } else if (url.toLowerCase().contains('.pdf')) {
        fileExtension = '.pdf';
      }

      print("DEBUG PROVIDER: URL para download: $url");
      print("DEBUG PROVIDER: Extensão detectada: $fileExtension");

      String path = Platform.isIOS
          ? '${appDocDir!.path}/$filename$fileExtension'
          : '${appDocDir!.path}/Ebook/$filename$fileExtension';

      print("DEBUG PROVIDER: Caminho de destino: $path");

      // Garantir que o diretório pai exista
      Directory parent = Directory(File(path).parent.path);
      if (!await parent.exists()) {
        await parent.create(recursive: true);
        print("DEBUG PROVIDER: Diretório pai criado: ${parent.path}");
      }

      // Criar ou substituir o arquivo
      File file = File(path);
      if (!await file.exists()) {
        await file.create();
        print("DEBUG PROVIDER: Arquivo criado: $path");
      } else {
        await file.delete();
        await file.create();
        print("DEBUG PROVIDER: Arquivo substituído: $path");
      }

      // Resetar o estado do download antes de começar
      down.value = false;

      // Mostrar o diálogo de download
      var result = await showDialog(
        barrierDismissible: barrierDismissible.value,
        context: context,
        builder: (context) => DownloadAlert(url: url, path: path, id: id),
      );

      // Verificar se o download foi bem-sucedido
      if (result != null) {
        barrierDismissible.value = true;
        print("DEBUG PROVIDER: Download concluído. Verificando arquivo...");

        // Verificar se o arquivo existe e tem tamanho
        if (await file.exists()) {
          int fileSize = await file.length();
          print("DEBUG PROVIDER: Arquivo existe. Tamanho: $fileSize bytes");

          if (fileSize > 0) {
            print("DEBUG PROVIDER: Download bem-sucedido!");
          } else {
            print("DEBUG PROVIDER: Arquivo foi criado mas está vazio!");
          }
        } else {
          print("DEBUG PROVIDER: Arquivo não foi encontrado após o download!");
        }

        // Notificar mudanças se o contexto ainda estiver válido
        if (context.mounted) {
          notifyListeners();
        }
      }
    } on DioException catch (e) {
      print('DEBUG PROVIDER: DioException $e');
      print('DEBUG PROVIDER: DioException message: ${e.message}');
      down.value = false;
    } catch (e) {
      print('DEBUG PROVIDER: Erro geral: $e');
      down.value = false;
    }

    // Só notifique mudanças se o contexto ainda estiver válido
    if (context.mounted) {
      notifyListeners();
    }
  }
}
