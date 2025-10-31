import 'dart:io';

import 'package:elearn/databasefavourite/db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../consttants.dart';

// Constantes
const kPdfNotFoundMsg = "PDF não disponível localmente";
const kPdfNotFoundDetailsMsg =
    "Faça o download do livro primeiro para visualizá-lo";
const kLoadingPdfMsg = "Carregando PDF...";
const kBlack90 = Color(0xE6000000);

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({
    Key? key,
    required this.bookid,
    required this.bookTitle,
    required this.image,
  }) : super(key: key);

  final int bookid;
  final String bookTitle;
  final String image;

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  String? filePath;
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 0;
  int _totalPages = 0;
  double _zoomLevel = 1.0;

  // Valores de limite para zoom
  final double _minZoomLevel = 0.5;
  final double _maxZoomLevel = 3.0;
  final double _zoomStep = 0.25;

  final TextEditingController _pageNumberController = TextEditingController();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    loadPDF();
    super.initState();
  }

  @override
  void dispose() {
    _pageNumberController.dispose();
    super.dispose();
  }

  // Estilos de texto centralizados
  TextStyle get _titleStyle => TextStyle(
        fontFamily: 'Gilroy-Bold',
        color: comboWhiteAndBlack(),
      );

  TextStyle get _bodyStyle => TextStyle(
        fontFamily: 'Gilroy-Medium',
        fontSize: 14.sp,
        color: comboWhiteAndBlack(),
      );

  TextStyle get _errorStyle => TextStyle(
        color: comboWhiteAndBlack().withValues(alpha: 0.7),
        fontFamily: "Gilroy-Medium",
        fontSize: 14.sp,
      );

  Future<void> loadPDF() async {
    try {
      // Verificar se o arquivo existe localmente
      bool fileExists = await checkLocalFile();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = !fileExists;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar PDF: $e");
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<String?> _getValidFilePath(String basePath) async {
    // Verificar o arquivo original primeiro
    final originalFile = File(basePath);
    if (await originalFile.exists() && await originalFile.length() > 0) {
      return basePath;
    }

    // Remover qualquer extensão existente
    final pathWithoutExt = basePath.replaceAll(RegExp(r'\.[^.]+$'), '');

    // Tentar apenas com extensão PDF
    final file = File('$pathWithoutExt.pdf');
    if (await file.exists() && await file.length() > 0) {
      if (kDebugMode) {
        print("Encontrado arquivo válido: ${file.path}");
      }
      return file.path;
    }

    return null;
  }

  Future<bool> checkLocalFile() async {
    try {
      // Verificar se existe registro no banco de dados
      bool isDownloaded =
          await DatabaseHelper.instance.retrieveDownloadID(id: widget.bookid);

      if (isDownloaded) {
        // Obter os dados de download do banco de dados
        final downloads = await DatabaseHelper.instance.retrieveDownLoad();
        final downloadModel = downloads.firstWhere(
          (item) => item['id'] == widget.bookid,
          orElse: () => {},
        );

        if (downloadModel.isNotEmpty) {
          final path = downloadModel['link'];
          if (kDebugMode) {
            print("Caminho encontrado no banco: $path");
          }

          // Tentar encontrar um arquivo válido
          final validPath = await _getValidFilePath(path);

          if (validPath != null) {
            filePath = validPath;
            return true;
          }
        } else if (kDebugMode) {
          print("Registro encontrado mas sem dados válidos");
        }
      } else if (kDebugMode) {
        print(
            "Nenhum registro de download encontrado para ID: ${widget.bookid}");
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao verificar arquivo local: $e");
      }
      return false;
    }
  }

  void _onPdfLoaded(PdfDocumentLoadedDetails details) {
    if (mounted) {
      setState(() {
        _totalPages = details.document.pages.count;
        _currentPage = 1; // Iniciar na página 1
      });
    }
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    if (mounted) {
      setState(() {
        _currentPage = details.newPageNumber;
      });
    }
  }

  void _handleZoomIn() {
    if (_zoomLevel < _maxZoomLevel) {
      _pdfViewerController.zoomLevel = _zoomLevel + _zoomStep;
      setState(() {
        _zoomLevel = _pdfViewerController.zoomLevel;
      });
    }
  }

  void _handleZoomOut() {
    if (_zoomLevel > _minZoomLevel + _zoomStep) {
      _pdfViewerController.zoomLevel = _zoomLevel - _zoomStep;
      setState(() {
        _zoomLevel = _pdfViewerController.zoomLevel;
      });
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: comboWhiteAndBlack(),
          ),
          SizedBox(height: 20.h),
          Text(
            kLoadingPdfMsg,
            style: _bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: comboWhiteAndBlack(),
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            kPdfNotFoundMsg,
            style: _bodyStyle.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            kPdfNotFoundDetailsMsg,
            textAlign: TextAlign.center,
            style: _errorStyle,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: comboToggleButtonColor(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Get.back(),
            child: Text("Voltar"),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (filePath == null) return _buildErrorView();

    return Column(
      children: [
        Expanded(
          child: SfPdfViewer.file(
            File(filePath!),
            controller: _pdfViewerController,
            onDocumentLoaded: _onPdfLoaded,
            onPageChanged: _onPageChanged,
            enableDoubleTapZooming: true,
            enableTextSelection: false,
            canShowScrollHead: true,
            canShowScrollStatus: false,
            pageSpacing: 4,
            initialZoomLevel: 1.0,
            canShowPaginationDialog: false,
            maxZoomLevel: _maxZoomLevel,
            enableDocumentLinkAnnotation: false,
          ),
        ),
        _buildNavigationBar(),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      color: mode.value ? kBlack90 : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.navigate_before,
              color: comboWhiteAndBlack(),
              size: 24.sp,
            ),
            onPressed: _currentPage > 1
                ? () => _pdfViewerController.previousPage()
                : null,
          ),
          GestureDetector(
            onTap: () => _showPagePickerDialog(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: comboWhiteAndBlack(),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Página $_currentPage de $_totalPages',
                    style: _bodyStyle,
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: comboWhiteAndBlack(),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.navigate_next,
              color: comboWhiteAndBlack(),
              size: 24.sp,
            ),
            onPressed: _currentPage < _totalPages
                ? () => _pdfViewerController.nextPage()
                : null,
          ),
        ],
      ),
    );
  }

  void _showPagePickerDialog() {
    _pageNumberController.text = _currentPage.toString();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: comboBlackAndWhite(),
            title: Text(
              "Ir para a página",
              style: _titleStyle,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _pageNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Número da página (1-$_totalPages)",
                    hintStyle: TextStyle(
                      color: comboWhiteAndBlack().withValues(alpha: 0.6),
                      fontFamily: "Gilroy-Medium",
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: comboWhiteAndBlack()),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: comboToggleButtonColor()),
                    ),
                    errorText: errorMessage,
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontFamily: "Gilroy-Medium",
                    ),
                  ),
                  style: _bodyStyle,
                  autofocus: true,
                  onChanged: (value) {
                    // Limpar mensagem de erro quando o usuário digita
                    if (errorMessage != null) {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: comboWhiteAndBlack(),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("CANCELAR"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: comboToggleButtonColor(),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final pageNumber = int.tryParse(_pageNumberController.text);
                  if (pageNumber == null) {
                    setState(() {
                      errorMessage = "Por favor, digite um número válido";
                    });
                  } else if (pageNumber < 1 || pageNumber > _totalPages) {
                    setState(() {
                      errorMessage = "Página fora do intervalo válido";
                    });
                  } else {
                    _pdfViewerController.jumpToPage(pageNumber);
                    Navigator.pop(context);
                  }
                },
                child: Text("IR"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        backgroundColor: comboBlackAndWhite(),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 10.sp,
            color: comboWhiteAndBlack(),
          ),
          onPressed: () => Get.back(),
        ),
        title: Hero(
          tag: 'book_title_${widget.bookid}',
          child: Text(
            widget.bookTitle,
            style: _titleStyle.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        actions: [
          // Controles de zoom
          IconButton(
            icon: Icon(Icons.zoom_in, color: comboWhiteAndBlack()),
            onPressed: !_isLoading && !_hasError && filePath != null
                ? _handleZoomIn
                : null,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: comboWhiteAndBlack()),
            onPressed: !_isLoading &&
                    !_hasError &&
                    filePath != null &&
                    _zoomLevel > _minZoomLevel
                ? _handleZoomOut
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _hasError
              ? _buildErrorView()
              : _buildPdfViewer(),
    );
  }
}
