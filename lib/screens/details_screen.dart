import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elearn/databasefavourite/db.dart';
import 'package:elearn/generated/l10n.dart';
import 'package:elearn/main.dart';
import 'package:elearn/model/allcomments.dart';
import 'package:elearn/model/detailsProvider.dart';
import 'package:elearn/model/singlebookbyid.dart';
import 'package:elearn/screens/explore.dart';
import 'package:elearn/screens/view.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../consttants.dart';

extension ColorUtils on Color {
  Color withAlpha(double opacity) {
    // Convert opacity (0.0-1.0) to alpha (0-255)
    int alpha = (opacity * 255).round();
    return Color.fromARGB(
        alpha, this.r.toInt(), this.g.toInt(), this.b.toInt());
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const ExpandableText({
    required this.text,
    required this.style,
    this.maxLines = 3,
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        SizedBox(height: 5.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Text(
            _expanded ? "Ver menos" : "Ler mais...",
            style: TextStyle(
              color: Color(0xff2055AD),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class DetailsScreen extends StatefulWidget {
  DetailsScreen({
    required this.bookCoverImg,
    required this.bookTitle,
    required this.bookDescription,
    required this.rating,
    required this.id,
    required this.authorDescription,
    required this.authorName,
  });

  final String bookCoverImg;
  final String bookDescription;
  final String authorDescription;
  final String rating;
  final int id;
  final String bookTitle;
  final String authorName;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _form = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  bool fav = false;
  bool read = false;
  RxBool isComment = false.obs;
  FocusNode focusNode = FocusNode();
  RxBool down = false.obs;
  String downloadProgress = "";
  double percentLoading = 0;

  @override
  void initState() {
    ensureDirectoriesExist().then((_) {
      Future.wait([getDatabase(), getBookData()]).whenComplete(() {
        if (mounted) {
          setState(() {});

          // Iniciar temporizador para verificar periodicamente o estado do botão
          _startPeriodicBookCheck();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // Cancelar temporizador
    _cancelPeriodicBookCheck();

    // Libera recursos e cancela quaisquer operações pendentes
    focusNode.dispose();
    commentController.dispose();
    // Certifique-se de que nenhuma operação assíncrona tentará atualizar o estado depois do dispose
    super.dispose();
  }

  // Temporizador para verificar o estado do livro periodicamente
  Timer? _periodicTimer;

  void _startPeriodicBookCheck() {
    // Verificar a cada 5 segundos se o estado do livro mudou
    _periodicTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        updateReadStatus();
      } else {
        _cancelPeriodicBookCheck();
      }
    });
  }

  void _cancelPeriodicBookCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  // Método para garantir que os diretórios necessários existam
  Future<void> ensureDirectoriesExist() async {
    try {
      if (Platform.isAndroid) {
        Directory? appDocDir = await getExternalStorageDirectory();
        if (appDocDir != null) {
          // Cria o diretório para os e-books se não existir
          Directory ebookDir = Directory('${appDocDir.path}/Ebook');
          if (!await ebookDir.exists()) {
            await ebookDir.create(recursive: true);
            print("DEBUG: Diretório para e-books criado em: ${ebookDir.path}");
          } else {
            print(
                "DEBUG: Diretório para e-books já existe em: ${ebookDir.path}");

            // Lista os arquivos no diretório para debug
            List<FileSystemEntity> files = await ebookDir.list().toList();
            print("DEBUG: ${files.length} arquivos encontrados no diretório");
            for (var file in files) {
              print("DEBUG: Arquivo encontrado: ${file.path}");
            }
          }
        }
      } else if (Platform.isIOS) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        // No iOS, os e-books são armazenados diretamente no diretório de documentos
        print("DEBUG: Diretório do iOS para e-books: ${appDocDir.path}");

        // Lista os arquivos no diretório para debug
        List<FileSystemEntity> files = await appDocDir.list().toList();
        print("DEBUG: ${files.length} arquivos encontrados no diretório iOS");
        for (var file in files) {
          print("DEBUG: Arquivo encontrado: ${file.path}");
        }
      }
    } catch (e) {
      print("DEBUG: Erro ao criar diretórios: $e");
    }
  }

  // Verifica fisicamente se existe um livro baixado para este ID
  Future<bool> checkPhysicalBook() async {
    try {
      bool dbResult =
          await DatabaseHelper.instance.retrieveDownloadID(id: widget.id);

      // Consulta direta por arquivos físicos em caso de falha no banco
      if (!dbResult) {
        String? filePath = await findBookFile();
        if (filePath != null) {
          print("DEBUG: Livro encontrado fora do banco em: $filePath");

          // Registra no banco de dados
          DatabaseHelper.instance.insertDownLoad(
            DownloadModel(
              id: widget.id,
              link: filePath,
              image: widget.bookCoverImg,
              title: widget.bookTitle,
            ),
          );

          return true;
        }
      }

      return dbResult;
    } catch (e) {
      print("DEBUG: Erro ao verificar arquivo físico: $e");
      return false;
    }
  }

  // Encontra o arquivo do livro no dispositivo
  Future<String?> findBookFile() async {
    try {
      Directory? directory;
      List<String> possiblePaths = [];

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          possiblePaths.add('${directory.path}/Ebook/${widget.id}.pdf');
          possiblePaths.add('${directory.path}/Ebook/${widget.id}.epub');
          possiblePaths.add('/storage/emulated/0/Download/${widget.id}.pdf');
          possiblePaths.add('/storage/emulated/0/Download/${widget.id}.epub');
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        possiblePaths.add('${directory.path}/${widget.id}.pdf');
        possiblePaths.add('${directory.path}/${widget.id}.epub');
      }

      for (String path in possiblePaths) {
        File file = File(path);
        if (await file.exists()) {
          int fileSize = await file.length();
          if (fileSize > 0) {
            print(
                "DEBUG: Arquivo encontrado em: $path com tamanho: $fileSize bytes");
            return path;
          }
        }
      }

      return null;
    } catch (e) {
      print("DEBUG: Erro ao procurar arquivo do livro: $e");
      return null;
    }
  }

  Future getDatabase() async {
    try {
      // Verifica favorito
      fav = await DatabaseHelper.instance.likeOrNot(widget.id.toString());

      // Verifica download no banco de dados E fisicamente
      read = await checkPhysicalBook();

      print("DEBUG: getDatabase() - Livro ID: ${widget.id}");
      print("DEBUG: getDatabase() - Favorito: $fav");
      print("DEBUG: getDatabase() - Baixado: $read");

      return;
    } catch (e) {
      print("DEBUG: Erro ao consultar banco de dados: $e");
    }
  }

  SingleBookById? singleBookById;

  Future getBookData() async {
    await HttpService().getSingleBookById(bookId: widget.id).then((value) {
      return singleBookById = value;
    });
  }

  sendComment() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      isComment.value = false;
      return;
    }
    _form.currentState!.save();
    var response = await http.get(Uri.parse(
        "$apiLink/api_comment.php?user_id=$userId&book_id=${widget.id}&comment_text=${commentController.text}"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["EBOOK_APP"][0]['success'] == "1") {
        setState(() {
          getBookData();
        });
        commentController.clear();
        focusNode.unfocus();
        isComment.value = false;
      }
    } else {
      throw "Fail To Get Comments !1!";
    }
  }

  Future<AllComments?> getAllComments() async {
    try {
      var response = await http.get(Uri.parse(
        "$apiLink/api.php?method_name=get_all_comments&books_id=${widget.id}",
      ));
      if (response.statusCode == 200) {
        return allCommentsFromJson(response.body);
      }
    } catch (e) {}
    return null;
  }

  Future deleteComment(id) async {
    var response = await http.get(
        Uri.parse("$apiLink/api.php?method_name=removecomment&comment_id=$id"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  }

  Color getTextColor() {
    return comboWhiteAndBlack();
  }

  MaterialColor getPrimaryAccentColor() {
    return MaterialColor(0xff2055AD, {
      50: Color(0xffE4E9F2),
      100: Color(0xffC9D3E5),
      200: Color(0xff93A7CB),
      300: Color(0xff5E7BB1),
      400: Color(0xff2055AD),
      500: Color(0xff2055AD),
      600: Color(0xff1B4A9A),
      700: Color(0xff174088),
      800: Color(0xff123675),
      900: Color(0xff0E2D62),
    });
  }

  MaterialColor getSecondaryAccentColor() {
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsProvider>(builder:
        (BuildContext context, DetailsProvider detailsProvider, child) {
      return Scaffold(
        backgroundColor: comboBlackAndWhite(),
        appBar: AppBar(
          backgroundColor: comboBlackAndWhite(),
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            widget.bookTitle,
            style: TextStyle(
              color: comboWhiteAndBlack(),
              fontFamily: "Gilroy-SemiBold",
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: getTextColor()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return _buildPortraitLayout(detailsProvider);
            } else {
              return _buildLandscapeLayout(detailsProvider);
            }
          },
        ),
      );
    });
  }

  // Layout para modo retrato
  Widget _buildPortraitLayout(DetailsProvider detailsProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 70.w),
            child: Column(
              children: [
                // Imagem do livro
                Hero(
                  tag: widget.bookCoverImg,
                  child: Container(
                    decoration: BoxDecoration(
                      color: comboWhiteAndBlack(),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: comboGreyAndBlack().withAlpha(76),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Imageview(
                      image: widget.bookCoverImg,
                      height: 225.0.w,
                      width: 170.0.w,
                      radius: 10.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Botões de ação
                Container(
                  width: 250.w,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: comboBlackAndWhite().withAlpha(153),
                    borderRadius: BorderRadius.circular(15.0.r),
                    boxShadow: [
                      BoxShadow(
                        color: comboGreyAndBlack().withAlpha(30),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Obx(() {
                        detailsProvider.barrierDismissible.value;
                        // Forçar atualização do estado quando down.value mudar
                        if (down.value) {
                          getDatabase();
                        }
                        return GestureDetector(
                          onTap: () async {
                            if (userId != null) {
                              if (singleBookById != null &&
                                  singleBookById!.ebookApp.isNotEmpty) {
                                Directory? appDocDir = Platform.isAndroid
                                    ? await getExternalStorageDirectory()
                                    : await getApplicationDocumentsDirectory();

                                // Determina a extensão do arquivo pela URL
                                String fileUrl = singleBookById!
                                    .ebookApp[0].bookFileUrl
                                    .toString();
                                String fileExtension =
                                    '.pdf'; // Extensão padrão

                                if (fileUrl.toLowerCase().contains('.epub')) {
                                  fileExtension = '.epub';
                                } else if (fileUrl
                                    .toLowerCase()
                                    .contains('.pdf')) {
                                  fileExtension = '.pdf';
                                }

                                // Constrói o caminho baseado na extensão correta
                                String path = Platform.isIOS
                                    ? '${appDocDir!.path}/${widget.id}$fileExtension'
                                    : '${appDocDir!.path}/Ebook/${widget.id}$fileExtension';

                                print("DEBUG: Caminho do livro: $path");
                                print(
                                    "DEBUG: Extensão detectada: $fileExtension");
                                print("DEBUG: URL original: $fileUrl");

                                if (read) {
                                  print(
                                      "DEBUG: Livro já baixado, abrindo visualizador");
                                  Get.to(() {
                                    return PdfViewerPage(
                                      bookid: widget.id,
                                      bookTitle: widget.bookTitle,
                                      image: widget.bookCoverImg,
                                    );
                                  })?.then((_) {
                                    // Atualiza o estado quando o usuário retorna do visualizador
                                    if (mounted) {
                                      getDatabase().whenComplete(() {
                                        setState(() {
                                          print(
                                              "DEBUG: Atualizando estado após retorno do visualizador");
                                        });
                                      });
                                    }
                                  });
                                } else {
                                  down.value = false;
                                  print("DEBUG: Iniciando download do livro");

                                  if (isAndroidVersionUp13 == true) {
                                    await detailsProvider.downloadFile(
                                      context,
                                      url: fileUrl,
                                      filename: widget.id.toString(),
                                      id: widget.id,
                                      img: widget.bookCoverImg,
                                    );
                                    if (down.value && mounted) {
                                      DatabaseHelper.instance.insertDownLoad(
                                        DownloadModel(
                                          id: widget.id,
                                          link: path,
                                          image: widget.bookCoverImg,
                                          title: widget.bookTitle,
                                        ),
                                      );

                                      // Atualiza imediatamente o status read e a interface
                                      await updateReadStatus();

                                      // Mostra mensagem de sucesso
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Download concluído! Agora você pode ler o livro.'),
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (await Permission.storage
                                        .request()
                                        .isGranted) {
                                      await detailsProvider.downloadFile(
                                        context,
                                        url: fileUrl,
                                        filename: widget.id.toString(),
                                        id: widget.id,
                                        img: widget.bookCoverImg,
                                      );
                                      if (down.value && mounted) {
                                        DatabaseHelper.instance.insertDownLoad(
                                          DownloadModel(
                                            id: widget.id,
                                            link: path,
                                            image: widget.bookCoverImg,
                                            title: widget.bookTitle,
                                          ),
                                        );

                                        // Atualiza imediatamente o status read e a interface
                                        await updateReadStatus();

                                        // Mostra mensagem de sucesso
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Download concluído! Agora você pode ler o livro.'),
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else if (await Permission.storage
                                        .request()
                                        .isDenied) {
                                      await Permission.storage.request();
                                    }
                                  }
                                }
                              } else {
                                customSnackBar(context,
                                    title: S.of(context).no_book_url_found);
                              }
                            } else {
                              customSnackBar(context);
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                read
                                    ? S.of(context).detail_screen_READ
                                    : S.of(context).setting_DOWNLOAD,
                                style: TextStyle(
                                  color:
                                      comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                  fontSize: 20.0.sp,
                                  fontFamily: "Gilroy-Bold",
                                ),
                              ),
                              Icon(
                                read
                                    ? Icons.menu_book_outlined
                                    : Icons.download_rounded,
                                color:
                                    comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                              ),
                            ],
                          ),
                        );
                      }),

                      // Botão de favoritos
                      userId == null
                          ? GestureDetector(
                              onTap: () async {
                                customSnackBar(context);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    S.of(context).detail_screen_LIKES,
                                    style: TextStyle(
                                      color:
                                          comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                      fontSize: 20.0.sp,
                                      fontFamily: "Gilroy-Bold",
                                    ),
                                  ),
                                  Icon(
                                    Icons.bookmark_border,
                                    color:
                                        comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () async {
                                if (fav) {
                                  await DatabaseHelper.instance
                                      .deleteTodo(id: widget.id);
                                } else {
                                  await DatabaseHelper.instance.insertTodo(
                                    Todo(
                                      id: widget.id,
                                      rating: widget.rating.toString(),
                                      authorDescription:
                                          widget.authorDescription,
                                      bookDescription: widget.bookDescription,
                                      image: widget.bookCoverImg,
                                      authorName: widget.authorName,
                                      bookid: widget.id,
                                      title: widget.bookTitle,
                                    ),
                                  );
                                  showToast(
                                      msg: S
                                          .of(context)
                                          .detail_screen_ADD_FAVOURITE);
                                }
                                getDatabase().whenComplete(() {
                                  setState(() {});
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    S.of(context).detail_screen_LIKES,
                                    style: TextStyle(
                                      color:
                                          comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                      fontSize: 20.0.sp,
                                      fontFamily: "Gilroy-Bold",
                                    ),
                                  ),
                                  Icon(
                                    fav
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color:
                                        comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: ExpandableText(
              text: htmlString(html: widget.bookDescription),
              style: TextStyle(
                fontSize: 14.sp,
                color: comboWhiteAndBlack().withAlpha(192),
                fontFamily: "Times New Roman",
                height: 1.4,
              ),
              maxLines: 5,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              "Por ${widget.authorName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.0.sp,
                color: comboWhiteAndBlack(),
                fontFamily: "Times New Roman",
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: ExpandableText(
              text: htmlString(html: widget.authorDescription),
              style: TextStyle(
                fontSize: 14.sp,
                color: comboWhiteAndBlack().withAlpha(192),
                fontFamily: "Times New Roman",
                height: 1.4,
              ),
              maxLines: 3,
            ),
          ),
          if (singleBookById != null && singleBookById!.ebookApp.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15.w, top: 10.0.h),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: comboWhiteAndBlack(),
                          fontSize: 20.0.sp,
                          fontFamily: "Gilroy-Bold"),
                      children: [
                        TextSpan(
                          text: S.of(context).detail_screen_YOU_MIGHT_ALSO,
                        ),
                        TextSpan(
                          text: S.of(context).detail_screen_LIKE,
                          style: TextStyle(fontFamily: "Gilroy-Bold"),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 280.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: singleBookById!.ebookApp[0].relatedBooks!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                authorName: singleBookById!.ebookApp[0]
                                    .relatedBooks![index].authorName,
                                authorDescription: singleBookById!.ebookApp[0]
                                    .relatedBooks![index].authorDescription,
                                bookCoverImg: singleBookById!.ebookApp[0]
                                    .relatedBooks![index].bookCoverImg,
                                bookTitle: singleBookById!
                                    .ebookApp[0].relatedBooks![index].bookTitle,
                                bookDescription: singleBookById!.ebookApp[0]
                                    .relatedBooks![index].bookDescription,
                                id: int.parse(singleBookById!
                                    .ebookApp[0].relatedBooks![index].id),
                                rating: singleBookById!
                                    .ebookApp[0].relatedBooks![index].rateAvg,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 180.h,
                                width: 135.w,
                                decoration: BoxDecoration(
                                  color: comboBlackAndWhite().withAlpha(30),
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: comboGreyAndBlack().withAlpha(30),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Imageview(
                                    image: singleBookById!.ebookApp[0]
                                        .relatedBooks![index].bookCoverImg,
                                    height: 180.h,
                                    width: 135.w,
                                    radius: 10.r,
                                  ),
                                ),
                              ),
                              SizedBox(height: 7.h),
                              Container(
                                width: 120.w,
                                child: Text(
                                  singleBookById!.ebookApp[0]
                                      .relatedBooks![index].bookTitle,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Gilroy-Bold",
                                    fontSize: 12.sp,
                                    color: comboWhiteAndBlack(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Container(
                                width: 120.w,
                                child: Text(
                                  singleBookById!.ebookApp[0]
                                      .relatedBooks![index].authorName,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Times New Roman",
                                    fontSize: 10.0.sp,
                                    color: comboWhiteAndBlack().withAlpha(192),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  S.of(context).details_screen_COMMENTS,
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontFamily: 'Gilroy-SemiBold',
                      color: comboWhiteAndBlack()),
                ),
              ],
            ),
          ),
          if (userId != null)
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 5.h),
              child: Form(
                key: _form,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty)
                            return S
                                .of(context)
                                .details_screen_comments_textField_validation;
                          else
                            return null;
                        },
                        controller: commentController,
                        autofocus: false,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10.w),
                          hintText: S
                              .of(context)
                              .details_screen_comments_textField_hint_text,
                          hintStyle: TextStyle(
                              fontSize: 15.sp,
                              color: comboWhiteAndBlack(),
                              fontFamily: "Gilroy-Medium"),
                          fillColor: comboWhiteAndBlack(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                color: comboWhiteAndBlack(), width: 1.w),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                color: comboWhiteAndBlack(), width: 1.w),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                color: comboWhiteAndBlack(), width: 1.w),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                color: comboWhiteAndBlack(), width: 1.w),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: comboWhiteAndBlack(),
                          fontFamily: "Gilroy-Medium",
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Obx(() {
                      return IconButton(
                        splashRadius: 10.r,
                        onPressed: () {
                          isComment.value = true;
                          sendComment();
                        },
                        icon: Center(
                          child: isComment.value == false
                              ? SvgPicture.asset(
                                  "assets/images/send.svg",
                                  // ignore: deprecated_member_use
                                  color: comboWhiteAndBlack(),
                                  fit: BoxFit.cover,
                                  height: 30.h,
                                  width: 25.w,
                                )
                              : SizedBox(
                                  width: 25.w,
                                  height: 25.w,
                                  child: CircularProgressIndicator()),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          SizedBox(height: 20.h),
          FutureBuilder<AllComments?>(
            future: getAllComments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null &&
                    snapshot.data!.ebookApp!.isNotEmpty) {
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.ebookApp!.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        String bookUserId =
                            snapshot.data!.ebookApp![index].userId!;
                        return ListTile(
                          visualDensity: VisualDensity(vertical: 4),
                          title: Text(
                            snapshot.data!.ebookApp![index].userName!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: comboWhiteAndBlack(),
                              fontFamily: "Gilroy-Bold",
                              fontSize: 17.sp,
                            ),
                          ),
                          subtitle: Text(
                            "${snapshot.data!.ebookApp![index].commentText}",
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: comboWhiteAndBlack().withAlpha(192),
                              fontFamily: "Times New Roman",
                              fontSize: 13.sp,
                              height: 1.3,
                            ),
                          ),
                          leading: Container(
                            decoration: BoxDecoration(
                              border: bookUserId == userId
                                  ? Border.all(
                                      width: 2,
                                      color: getSecondaryAccentColor())
                                  : Border(),
                              borderRadius: BorderRadius.circular(80.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80.r),
                              child: CachedNetworkImage(
                                imageUrl:
                                    snapshot.data!.ebookApp![index].userImage!,
                                fit: BoxFit.cover,
                                width: 60.w,
                                height: 60.w,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                        baseColor: shimmerBaseColor(),
                                        highlightColor: shimmerHighlightColor(),
                                        child: Container(
                                          width: 60.w,
                                          height: 60.w,
                                          color: comboBlackAndWhite(),
                                        )),
                                placeholderFadeInDuration: Duration(seconds: 2),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/images/noimagefound.jpg",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          trailing: Text(
                            snapshot.data!.ebookApp![index].dtRate.toString(),
                            style: TextStyle(
                              color: comboWhiteAndBlack(),
                              fontFamily: "Gilroy-SemiBold",
                              fontSize: 12.sp,
                            ),
                          ),
                          onTap: bookUserId == userId
                              ? () {
                                  if (userId != null) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                comboBlackAndWhite(),
                                            title: Text(
                                              "Delete Comment ??",
                                              style: TextStyle(
                                                color: comboWhiteAndBlack(),
                                                fontFamily: "Gilroy-Bold",
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                                child: ListBody(children: [
                                              Text(
                                                "${snapshot.data!.ebookApp![index].commentText}",
                                                style: TextStyle(
                                                  color: comboWhiteAndBlack(),
                                                  fontFamily: "Gilroy-Medium",
                                                ),
                                              ),
                                            ])),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color:
                                                        getPrimaryAccentColor(),
                                                    fontFamily: "Gilroy-Medium",
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color:
                                                        getSecondaryAccentColor(),
                                                    fontFamily: "Gilroy-Medium",
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Get.back();
                                                  deleteComment(snapshot.data!
                                                      .ebookApp![index].id);
                                                  focusNode.unfocus();
                                                },
                                              ),
                                            ],
                                          );
                                        }).whenComplete(() => setState(() {}));
                                  } else {
                                    customSnackBar(context);
                                  }
                                }
                              : null,
                        );
                      });
                } else {
                  return Center(
                    child: Text(
                      S.of(context).details_screen_comments_NO_COMMENTS_FOUND,
                      style: TextStyle(
                        color: comboWhiteAndBlack(),
                        fontFamily: "Gilroy-SemiBold",
                        fontSize: 15.sp,
                      ),
                    ),
                  );
                }
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: Random().nextInt(5),
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: shimmerBaseColor(),
                      highlightColor: shimmerHighlightColor(),
                      child: Container(
                        width: double.infinity,
                        height: 60.w,
                        margin: EdgeInsets.all(20),
                        color: comboBlackAndWhite(),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

// Layout para modo paisagem
  Widget _buildLandscapeLayout(DetailsProvider detailsProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Livro e botões em cima
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 70.w),
            child: Column(
              children: [
                // Imagem do livro
                Hero(
                  tag: widget.bookCoverImg,
                  child: Container(
                    decoration: BoxDecoration(
                      color: comboWhiteAndBlack(),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: comboGreyAndBlack().withAlpha(76),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Imageview(
                      image: widget.bookCoverImg,
                      height: 150.0.w,
                      width: 250.0.w,
                      radius: 10.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Botões de ação
                Container(
                  width: 250.w,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: comboBlackAndWhite().withAlpha(153),
                    borderRadius: BorderRadius.circular(15.0.r),
                    boxShadow: [
                      BoxShadow(
                        color: comboGreyAndBlack().withAlpha(30),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Obx(() {
                        detailsProvider.barrierDismissible.value;
                        // Forçar atualização do estado quando down.value mudar
                        if (down.value) {
                          getDatabase();
                        }
                        return GestureDetector(
                          onTap: () async {
                            if (userId != null) {
                              if (singleBookById != null &&
                                  singleBookById!.ebookApp.isNotEmpty) {
                                Directory? appDocDir = Platform.isAndroid
                                    ? await getExternalStorageDirectory()
                                    : await getApplicationDocumentsDirectory();

                                // Determina a extensão do arquivo pela URL
                                String fileUrl = singleBookById!
                                    .ebookApp[0].bookFileUrl
                                    .toString();
                                String fileExtension =
                                    '.pdf'; // Extensão padrão

                                if (fileUrl.toLowerCase().contains('.epub')) {
                                  fileExtension = '.epub';
                                } else if (fileUrl
                                    .toLowerCase()
                                    .contains('.pdf')) {
                                  fileExtension = '.pdf';
                                }

                                // Constrói o caminho baseado na extensão correta
                                String path = Platform.isIOS
                                    ? '${appDocDir!.path}/${widget.id}$fileExtension'
                                    : '${appDocDir!.path}/Ebook/${widget.id}$fileExtension';

                                print("DEBUG: Caminho do livro: $path");
                                print(
                                    "DEBUG: Extensão detectada: $fileExtension");
                                print("DEBUG: URL original: $fileUrl");

                                if (read) {
                                  print(
                                      "DEBUG: Livro já baixado, abrindo visualizador");
                                  Get.to(() {
                                    return PdfViewerPage(
                                      bookid: widget.id,
                                      bookTitle: widget.bookTitle,
                                      image: widget.bookCoverImg,
                                    );
                                  })?.then((_) {
                                    // Atualiza o estado quando o usuário retorna do visualizador
                                    if (mounted) {
                                      getDatabase().whenComplete(() {
                                        setState(() {
                                          print(
                                              "DEBUG: Atualizando estado após retorno do visualizador");
                                        });
                                      });
                                    }
                                  });
                                } else {
                                  down.value = false;
                                  print("DEBUG: Iniciando download do livro");

                                  if (isAndroidVersionUp13 == true) {
                                    await detailsProvider.downloadFile(
                                      context,
                                      url: fileUrl,
                                      filename: widget.id.toString(),
                                      id: widget.id,
                                      img: widget.bookCoverImg,
                                    );
                                    if (down.value && mounted) {
                                      DatabaseHelper.instance.insertDownLoad(
                                        DownloadModel(
                                          id: widget.id,
                                          link: path,
                                          image: widget.bookCoverImg,
                                          title: widget.bookTitle,
                                        ),
                                      );

                                      // Atualiza imediatamente o status read e a interface
                                      await updateReadStatus();

                                      // Mostra mensagem de sucesso
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Download concluído! Agora você pode ler o livro.'),
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (await Permission.storage
                                        .request()
                                        .isGranted) {
                                      await detailsProvider.downloadFile(
                                        context,
                                        url: fileUrl,
                                        filename: widget.id.toString(),
                                        id: widget.id,
                                        img: widget.bookCoverImg,
                                      );
                                      if (down.value && mounted) {
                                        DatabaseHelper.instance.insertDownLoad(
                                          DownloadModel(
                                            id: widget.id,
                                            link: path,
                                            image: widget.bookCoverImg,
                                            title: widget.bookTitle,
                                          ),
                                        );

                                        // Atualiza imediatamente o status read e a interface
                                        await updateReadStatus();

                                        // Mostra mensagem de sucesso
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Download concluído! Agora você pode ler o livro.'),
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else if (await Permission.storage
                                        .request()
                                        .isDenied) {
                                      await Permission.storage.request();
                                    }
                                  }
                                }
                              } else {
                                customSnackBar(context,
                                    title: S.of(context).no_book_url_found);
                              }
                            } else {
                              customSnackBar(context);
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                read
                                    ? S.of(context).detail_screen_READ
                                    : S.of(context).setting_DOWNLOAD,
                                style: TextStyle(
                                  color:
                                      comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                  fontSize: 20.0.sp,
                                  fontFamily: "Gilroy-Bold",
                                ),
                              ),
                              Icon(
                                read
                                    ? Icons.menu_book_outlined
                                    : Icons.download_rounded,
                                color:
                                    comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                              ),
                            ],
                          ),
                        );
                      }),

                      // Botão de favoritos
                      userId == null
                          ? GestureDetector(
                              onTap: () async {
                                customSnackBar(context);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    S.of(context).detail_screen_LIKES,
                                    style: TextStyle(
                                      color:
                                          comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                      fontSize: 20.0.sp,
                                      fontFamily: "Gilroy-Bold",
                                    ),
                                  ),
                                  Icon(
                                    Icons.bookmark_border,
                                    color:
                                        comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () async {
                                if (fav) {
                                  await DatabaseHelper.instance
                                      .deleteTodo(id: widget.id);
                                } else {
                                  await DatabaseHelper.instance.insertTodo(
                                    Todo(
                                      id: widget.id,
                                      rating: widget.rating.toString(),
                                      authorDescription:
                                          widget.authorDescription,
                                      bookDescription: widget.bookDescription,
                                      image: widget.bookCoverImg,
                                      authorName: widget.authorName,
                                      bookid: widget.id,
                                      title: widget.bookTitle,
                                    ),
                                  );
                                  showToast(
                                      msg: S
                                          .of(context)
                                          .detail_screen_ADD_FAVOURITE);
                                }
                                getDatabase().whenComplete(() {
                                  setState(() {});
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    S.of(context).detail_screen_LIKES,
                                    style: TextStyle(
                                      color:
                                          comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                      fontSize: 20.0.sp,
                                      fontFamily: "Gilroy-Bold",
                                    ),
                                  ),
                                  Icon(
                                    fav
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color:
                                        comboWhiteAndBlack(), // Alterado para comboWhiteAndBlack
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Descrição e comentários abaixo
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                ExpandableText(
                  text: htmlString(html: widget.bookDescription),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: comboWhiteAndBlack().withAlpha(192),
                    fontFamily: "Times New Roman",
                    height: 1.4,
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 8.h),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                    "Por ${widget.authorName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.0.sp,
                      color: comboWhiteAndBlack(),
                      fontFamily: "Times New Roman",
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                ExpandableText(
                  text: htmlString(html: widget.authorDescription),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: comboWhiteAndBlack().withAlpha(192),
                    fontFamily: "Times New Roman",
                    height: 1.4,
                  ),
                  maxLines: 3,
                ),
                if (singleBookById != null &&
                    singleBookById!.ebookApp.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 15.w, top: 10.0.h),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: comboWhiteAndBlack(),
                                fontSize: 20.0.sp,
                                fontFamily: "Gilroy-Bold"),
                            children: [
                              TextSpan(
                                text:
                                    S.of(context).detail_screen_YOU_MIGHT_ALSO,
                              ),
                              TextSpan(
                                text: S.of(context).detail_screen_LIKE,
                                style: TextStyle(fontFamily: "Gilroy-Bold"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 560.h,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount:
                              singleBookById!.ebookApp[0].relatedBooks!.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      authorName: singleBookById!.ebookApp[0]
                                          .relatedBooks![index].authorName,
                                      authorDescription: singleBookById!
                                          .ebookApp[0]
                                          .relatedBooks![index]
                                          .authorDescription,
                                      bookCoverImg: singleBookById!.ebookApp[0]
                                          .relatedBooks![index].bookCoverImg,
                                      bookTitle: singleBookById!.ebookApp[0]
                                          .relatedBooks![index].bookTitle,
                                      bookDescription: singleBookById!
                                          .ebookApp[0]
                                          .relatedBooks![index]
                                          .bookDescription,
                                      id: int.parse(singleBookById!
                                          .ebookApp[0].relatedBooks![index].id),
                                      rating: singleBookById!.ebookApp[0]
                                          .relatedBooks![index].rateAvg,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 350.h,
                                      width: 100.w,
                                      decoration: BoxDecoration(
                                        color:
                                            comboBlackAndWhite().withAlpha(30),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: comboGreyAndBlack()
                                                .withAlpha(30),
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        child: Imageview(
                                          image: singleBookById!
                                              .ebookApp[0]
                                              .relatedBooks![index]
                                              .bookCoverImg,
                                          height: 220.h,
                                          width: 165.w,
                                          radius: 10.r,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 7.h),
                                    Container(
                                      width: 120.w,
                                      child: Text(
                                        singleBookById!.ebookApp[0]
                                            .relatedBooks![index].bookTitle,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Gilroy-Bold",
                                          fontSize: 12.sp,
                                          color: comboWhiteAndBlack(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Container(
                                      width: 120.w,
                                      child: Text(
                                        singleBookById!.ebookApp[0]
                                            .relatedBooks![index].authorName,
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Times New Roman",
                                          fontSize: 10.0.sp,
                                          color: comboWhiteAndBlack()
                                              .withAlpha(192),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).details_screen_COMMENTS,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'Gilroy-SemiBold',
                            color: comboWhiteAndBlack()),
                      ),
                    ],
                  ),
                ),
                if (userId != null)
                  Padding(
                    padding:
                        EdgeInsets.only(left: 10.w, right: 10.w, bottom: 5.h),
                    child: Form(
                      key: _form,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty)
                                  return S
                                      .of(context)
                                      .details_screen_comments_textField_validation;
                                else
                                  return null;
                              },
                              controller: commentController,
                              autofocus: false,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.w),
                                hintText: S
                                    .of(context)
                                    .details_screen_comments_textField_hint_text,
                                hintStyle: TextStyle(
                                    fontSize: 15.sp,
                                    color: comboWhiteAndBlack(),
                                    fontFamily: "Gilroy-Medium"),
                                fillColor: comboWhiteAndBlack(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                      color: comboWhiteAndBlack(), width: 1.w),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                      color: comboWhiteAndBlack(), width: 1.w),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                      color: comboWhiteAndBlack(), width: 1.w),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                      color: comboWhiteAndBlack(), width: 1.w),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                color: comboWhiteAndBlack(),
                                fontFamily: "Gilroy-Medium",
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Obx(() {
                            return IconButton(
                              splashRadius: 10.r,
                              onPressed: () {
                                isComment.value = true;
                                sendComment();
                              },
                              icon: Center(
                                child: isComment.value == false
                                    ? SvgPicture.asset(
                                        "assets/images/send.svg",
                                        // ignore: deprecated_member_use
                                        color: comboWhiteAndBlack(),
                                        fit: BoxFit.cover,
                                        height: 30.h,
                                        width: 25.w,
                                      )
                                    : SizedBox(
                                        width: 25.w,
                                        height: 25.w,
                                        child: CircularProgressIndicator()),
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 20.h),
                FutureBuilder<AllComments?>(
                  future: getAllComments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null &&
                          snapshot.data!.ebookApp!.isNotEmpty) {
                        return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.ebookApp!.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              String bookUserId =
                                  snapshot.data!.ebookApp![index].userId!;
                              return ListTile(
                                visualDensity: VisualDensity(vertical: 4),
                                title: Text(
                                  snapshot.data!.ebookApp![index].userName!,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: comboWhiteAndBlack(),
                                    fontFamily: "Gilroy-Bold",
                                    fontSize: 17.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  "${snapshot.data!.ebookApp![index].commentText}",
                                  textAlign: TextAlign.start,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: comboWhiteAndBlack().withAlpha(192),
                                    fontFamily: "Times New Roman",
                                    fontSize: 13.sp,
                                    height: 1.3,
                                  ),
                                ),
                                leading: Container(
                                  decoration: BoxDecoration(
                                    border: bookUserId == userId
                                        ? Border.all(
                                            width: 2,
                                            color: getSecondaryAccentColor())
                                        : Border(),
                                    borderRadius: BorderRadius.circular(80.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80.r),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot
                                          .data!.ebookApp![index].userImage!,
                                      fit: BoxFit.cover,
                                      width: 60.w,
                                      height: 60.w,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                              baseColor: shimmerBaseColor(),
                                              highlightColor:
                                                  shimmerHighlightColor(),
                                              child: Container(
                                                width: 60.w,
                                                height: 60.w,
                                                color: comboBlackAndWhite(),
                                              )),
                                      placeholderFadeInDuration:
                                          Duration(seconds: 2),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        "assets/images/noimagefound.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: Text(
                                  snapshot.data!.ebookApp![index].dtRate
                                      .toString(),
                                  style: TextStyle(
                                    color: comboWhiteAndBlack(),
                                    fontFamily: "Gilroy-SemiBold",
                                    fontSize: 12.sp,
                                  ),
                                ),
                                onTap: bookUserId == userId
                                    ? () {
                                        if (userId != null) {
                                          showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          comboBlackAndWhite(),
                                                      title: Text(
                                                        "Delete Comment ??",
                                                        style: TextStyle(
                                                          color:
                                                              comboWhiteAndBlack(),
                                                          fontFamily:
                                                              "Gilroy-Bold",
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                      content:
                                                          SingleChildScrollView(
                                                              child: ListBody(
                                                                  children: [
                                                            Text(
                                                              "${snapshot.data!.ebookApp![index].commentText}",
                                                              style: TextStyle(
                                                                color:
                                                                    comboWhiteAndBlack(),
                                                                fontFamily:
                                                                    "Gilroy-Medium",
                                                              ),
                                                            ),
                                                          ])),
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                              color:
                                                                  getPrimaryAccentColor(),
                                                              fontFamily:
                                                                  "Gilroy-Medium",
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                              color:
                                                                  getSecondaryAccentColor(),
                                                              fontFamily:
                                                                  "Gilroy-Medium",
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Get.back();
                                                            deleteComment(
                                                                snapshot
                                                                    .data!
                                                                    .ebookApp![
                                                                        index]
                                                                    .id);
                                                            focusNode.unfocus();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  })
                                              .whenComplete(
                                                  () => setState(() {}));
                                        } else {
                                          customSnackBar(context);
                                        }
                                      }
                                    : null,
                              );
                            });
                      } else {
                        return Center(
                          child: Text(
                            S
                                .of(context)
                                .details_screen_comments_NO_COMMENTS_FOUND,
                            style: TextStyle(
                              color: comboWhiteAndBlack(),
                              fontFamily: "Gilroy-SemiBold",
                              fontSize: 15.sp,
                            ),
                          ),
                        );
                      }
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: Random().nextInt(5),
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: shimmerBaseColor(),
                            highlightColor: shimmerHighlightColor(),
                            child: Container(
                              width: double.infinity,
                              height: 60.w,
                              margin: EdgeInsets.all(20),
                              color: comboBlackAndWhite(),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Atualiza o status de leitura verificando os arquivos físicos
  Future<void> updateReadStatus() async {
    try {
      // Verificar se o arquivo existe fisicamente
      String? filePath = await findBookFile();
      if (filePath != null) {
        // Arquivo encontrado, atualizar o estado para indicar que o livro pode ser lido
        read = true;

        // Atualizar o banco de dados se necessário
        bool dbHasRecord =
            await DatabaseHelper.instance.retrieveDownloadID(id: widget.id);
        if (!dbHasRecord) {
          // Se não existe registro no banco, criar um
          DatabaseHelper.instance.insertDownLoad(
            DownloadModel(
              id: widget.id,
              link: filePath,
              image: widget.bookCoverImg,
              title: widget.bookTitle,
            ),
          );
          print("DEBUG: Registro de download criado no banco de dados");
        }

        if (mounted) {
          setState(() {
            print("DEBUG: Estado de leitura atualizado para: $read");
          });
        }
      } else {
        print("DEBUG: Arquivo não encontrado, livro não pode ser lido");
        read = false;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print("DEBUG: Erro ao atualizar status de leitura: $e");
    }
  }
}
