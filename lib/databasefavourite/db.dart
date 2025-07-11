import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseHelper {
  //Create a private constructor
  DatabaseHelper._();

  static const databaseName = 'todos_database.db';
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database!;
  }

  initializeDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), databaseName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE ${Todo.TABLENAME}(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,title TEXT, authorDescription TEXT, bookDescription TEXT ,bookid INTEGER, authorName TEXT, image TEXT, rating TEXT)");
      await db.execute(
          "CREATE TABLE ${DownloadModel.TABLENAME}(id	INTEGER,image	TEXT ,link	TEXT,title TEXT,PRIMARY KEY(id AUTOINCREMENT))");
    });
  }

  /// Favorite set into table
  insertTodo(Todo todo) async {
    final db = await database;
    var res = await db
        .insert(Todo.TABLENAME, todo.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => print("inserted Favorite $value"));
    return res;
  }

  /// get table
  Future<List<Map<String, dynamic>>> retrieveTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(Todo.TABLENAME);
    return maps;
  }

  Future<bool> likeOrNot(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(Todo.TABLENAME, where: 'id = ?', whereArgs: [id]);
    return maps.length > 0 ? true : false;
  }

  updateTodo(Todo todo) async {
    final db = await database;
    await db.update(Todo.TABLENAME, todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTodo({id}) async {
    var db = await database;
    db.delete(Todo.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }

  /// download  ******

  insertDownLoad(DownloadModel todo) async {
    try {
      final db = await database;
      print("DEBUG DATABASE: Inserindo download para ID: ${todo.id}");
      print("DEBUG DATABASE: Dados do download: ${todo.toMap()}");

      // Primeiro verifica se já existe um registro com este ID
      final List<Map<String, dynamic>> existingMaps = await db.query(
          DownloadModel.TABLENAME,
          where: 'id = ?',
          whereArgs: [todo.id]);

      if (existingMaps.isNotEmpty) {
        print("DEBUG DATABASE: Registro já existe, atualizando dados");
        var res = await db.update(DownloadModel.TABLENAME, todo.toMap(),
            where: 'id = ?',
            whereArgs: [todo.id],
            conflictAlgorithm: ConflictAlgorithm.replace);
        print("DEBUG DATABASE: Atualização concluída, resultado: $res");
        return res;
      } else {
        print("DEBUG DATABASE: Criando novo registro");
        var res = await db.insert(DownloadModel.TABLENAME, todo.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        print("DEBUG DATABASE: Inserção concluída, resultado: $res");
        return res;
      }
    } catch (e) {
      print('DEBUG DATABASE: ERRO NA INSERÇÃO: $e');
      return null;
    }
  }

  /// get table
  Future<List<Map<String, dynamic>>> retrieveDownLoad() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(DownloadModel.TABLENAME);
    return maps;
  }

  Future<bool> retrieveDownloadID({id}) async {
    try {
      final db = await database;
      print("DEBUG DATABASE: Verificando download para ID: $id");
      final List<Map<String, dynamic>> maps = await db
          .query(DownloadModel.TABLENAME, where: 'id = ?', whereArgs: [id]);

      print("DEBUG DATABASE: Encontrados ${maps.length} registros para ID $id");
      if (maps.isEmpty) {
        print("DEBUG DATABASE: Nenhum registro encontrado no banco");
        return false;
      }

      // Verifica se o arquivo existe fisicamente
      final downloadData = maps.first;
      String filePath = downloadData['link'];
      print(
          "DEBUG DATABASE: Verificando se o arquivo existe fisicamente em: $filePath");

      final file = File(filePath);
      bool fileExists = await file.exists();
      print("DEBUG DATABASE: Arquivo existe fisicamente? $fileExists");

      if (!fileExists) {
        // Tente procurar por variações do arquivo (ex: extensões diferentes)
        String basePath = filePath.replaceAll(RegExp(r'\.[^.]+$'), '');

        // Tente com .pdf
        final pdfFile = File('$basePath.pdf');
        if (await pdfFile.exists()) {
          print(
              "DEBUG DATABASE: Arquivo encontrado com extensão .pdf em: ${pdfFile.path}");
          // Atualiza o banco com o caminho correto
          await db.update(DownloadModel.TABLENAME, {'link': pdfFile.path},
              where: 'id = ?', whereArgs: [id]);
          return true;
        }

        // Tente com .epub
        final epubFile = File('$basePath.epub');
        if (await epubFile.exists()) {
          print(
              "DEBUG DATABASE: Arquivo encontrado com extensão .epub em: ${epubFile.path}");
          // Atualiza o banco com o caminho correto
          await db.update(DownloadModel.TABLENAME, {'link': epubFile.path},
              where: 'id = ?', whereArgs: [id]);
          return true;
        }

        print("DEBUG DATABASE: Nenhuma variação do arquivo foi encontrada");
        return false;
      }

      return true;
    } catch (e) {
      print("DEBUG DATABASE: Erro ao verificar download: $e");
      return false;
    }
  }

  Future<void> deleteDownLoad(int id) async {
    var db = await database;
    db.delete(DownloadModel.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }
}

class Todo {
  final int id;
  final int bookid;
  final String rating;
  final String title;
  final String authorName;
  final String authorDescription;
  final String bookDescription;
  final String image;
  static const String TABLENAME = "favorite";

  Todo(
      {required this.id,
      required this.authorName,
      required this.bookid,
      required this.rating,
      required this.bookDescription,
      required this.authorDescription,
      required this.title,
      required this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'rating': rating,
      'bookid': bookid,
      'authorName': authorName,
      'authorDescription': authorDescription,
      'bookDescription': bookDescription,
      'image': image
    };
  }
}

/// download

class DownloadModel {
  final int id;
  final String image;
  final String title;
  final String link;

  static const String TABLENAME = "download";

  DownloadModel({
    required this.id,
    required this.image,
    required this.link,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'link': link,
      'title': title,
    };
  }
}
