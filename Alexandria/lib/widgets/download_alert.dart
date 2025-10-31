import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elearn/databasefavourite/db.dart';
import 'package:elearn/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../consttants.dart';

RxBool down = false.obs;

class DownloadAlert extends StatefulWidget {
  final String url;
  final String path;
  final int id;

  DownloadAlert({
    Key? key,
    required this.url,
    required this.path,
    required this.id,
  }) : super(key: key);

  @override
  _DownloadAlertState createState() => _DownloadAlertState();
}

class _DownloadAlertState extends State<DownloadAlert> {
  Dio dio = Dio();
  int received = 0;
  String progress = '0';
  int total = 0;
  CancelToken cancelToken = CancelToken();
  bool isDownloading = true;

  Future<void> download() async {
    try {
      print("DEBUG ALERT: Iniciando download do arquivo");
      print("DEBUG ALERT: URL de origem: ${widget.url}");
      print("DEBUG ALERT: Caminho de destino: ${widget.path}");

      // Resetar o status de download
      down.value = false;

      await dio.download(
        widget.url,
        widget.path,
        options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
        deleteOnError: true,
        cancelToken: cancelToken,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (mounted) {
            setState(() {
              received = receivedBytes;
              total = totalBytes;
              if (total != -1) {
                progress = (received / total * 100).toStringAsFixed(0);
              }
            });
          }

          // Log periodicamente o progresso
          if (receivedBytes % (totalBytes ~/ 10) == 0 ||
              receivedBytes == totalBytes) {
            print(
                "DEBUG ALERT: Download progresso: $progress% - ${Constants.formatBytes(receivedBytes, 1)} de ${Constants.formatBytes(totalBytes, 1)}");
          }

          if (receivedBytes == totalBytes) {
            if (mounted) {
              setState(() {
                isDownloading = false;
              });

              print("DEBUG ALERT: Download concluído com sucesso!");
              print("DEBUG ALERT: Arquivo salvo em: ${widget.path}");

              // Verificar se o arquivo realmente existe
              File downloadedFile = File(widget.path);
              downloadedFile.exists().then((exists) {
                print("DEBUG ALERT: O arquivo existe no sistema? $exists");
                if (exists) {
                  int fileSize = downloadedFile.lengthSync();
                  print("DEBUG ALERT: Tamanho do arquivo: $fileSize bytes");

                  if (fileSize > 0) {
                    // Definir o download como concluído
                    down.value = true;

                    // Registrar o download no banco de dados
                    registerDownloadInDatabase();
                  } else {
                    print("DEBUG ALERT: Arquivo está vazio!");
                    down.value = false;
                  }
                } else {
                  print("DEBUG ALERT: Arquivo não encontrado após download!");
                  down.value = false;
                }

                Navigator.pop(context, '${Constants.formatBytes(total, 1)}');
              });
            }
          }
        },
      );
    } on DioException catch (e) {
      print("DEBUG ALERT: Erro no download: ${e.error} - ${e.message}");
      print("DEBUG ALERT: Caminho que falhou: ${widget.path}");
      cancelToken.cancel("Error");
      down.value = false;
      DatabaseHelper.instance.deleteDownLoad(widget.id);
      if (mounted) {
        customSnackBar(context, title: "${e.message}");
        Navigator.pop(context);
      }
    }
  }

  // Registra o download no banco de dados
  void registerDownloadInDatabase() {
    try {
      print(
          "DEBUG ALERT: Registrando download no banco de dados: ID=${widget.id}");

      // Obter dados do livro do arquivo de download
      String title = "Livro ${widget.id}";
      String image = "";

      // Registrar no banco de dados
      DatabaseHelper.instance.insertDownLoad(
        DownloadModel(
          id: widget.id,
          link: widget.path,
          image: image,
          title: title,
        ),
      );

      print("DEBUG ALERT: Download registrado no banco de dados com sucesso");
    } catch (e) {
      print("DEBUG ALERT: Erro ao registrar download: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    download();
  }

  @override
  void dispose() {
    cancelToken.cancel("Widget disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: CustomAlert(
        child: Padding(
          padding: EdgeInsets.all(20.0.h.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isDownloading ? Icons.downloading : Icons.download_done,
                size: 50,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 20.0.h),
              Text(
                isDownloading
                    ? 'Seu livro está sendo baixado, aguarde...'
                    : 'Download concluído!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Gilroy-Bold",
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0.h),
              LinearProgressIndicator(
                value: double.parse(progress) / 100.0,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.secondary,
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 10.0.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$progress %',
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontFamily: "Gilroy-Medium",
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${Constants.formatBytes(received, 1)} '
                    'of ${Constants.formatBytes(total, 1)}',
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontFamily: "Gilroy-Medium",
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0.h),
              if (isDownloading)
                ElevatedButton(
                  onPressed: () {
                    cancelToken.cancel("Download cancelado");
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                  ),
                  child: Text(
                    "Cancelar download",
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontFamily: "Gilroy-Medium",
                      color: Colors.white,
                    ),
                  ),
                ),
              if (!isDownloading)
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                  ),
                  child: Text(
                    "Fechar",
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontFamily: "Gilroy-Medium",
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
