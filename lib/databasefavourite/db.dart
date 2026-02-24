import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/material.dart';

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
          "CREATE TABLE ${Todo.tableName}(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,title TEXT, authorDescription TEXT, bookDescription TEXT ,bookid INTEGER, authorName TEXT, image TEXT, rating TEXT)");
      await db.execute(
          "CREATE TABLE ${DownloadModel.tableName}(id	INTEGER,image	TEXT ,link	TEXT,title TEXT,PRIMARY KEY(id AUTOINCREMENT))");
    });
  }

  /// Favorite set into table
  insertTodo(Todo todo) async {
    final db = await database;
    var res = await db
        .insert(Todo.tableName, todo.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => debugPrint("inserted Favorite $value"));
    return res;
  }

  /// get table
  Future<List<Map<String, dynamic>>> retrieveTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(Todo.tableName);
    return maps;
  }

  Future<bool> likeOrNot(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(Todo.tableName, where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? true : false;
  }

  updateTodo(Todo todo) async {
    final db = await database;
    await db.update(Todo.tableName, todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTodo({id}) async {
    var db = await database;
    db.delete(Todo.tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// download  ******

  insertDownLoad(DownloadModel todo) async {
    try {
      final db = await database;
      debugPrint("DEBUG DATABASE: Inserindo download para ID: ${todo.id}");
      debugPrint("DEBUG DATABASE: Dados do download: ${todo.toMap()}");

      // Primeiro verifica se já existe um registro com este ID
      final List<Map<String, dynamic>> existingMaps = await db.query(
          DownloadModel.tableName,
          where: 'id = ?',
          whereArgs: [todo.id]);

      if (existingMaps.isNotEmpty) {
        debugPrint("DEBUG DATABASE: Registro já existe, atualizando dados");
        var res = await db.update(DownloadModel.tableName, todo.toMap(),
            where: 'id = ?',
            whereArgs: [todo.id],
            conflictAlgorithm: ConflictAlgorithm.replace);
        debugPrint("DEBUG DATABASE: Atualização concluída, resultado: $res");
        return res;
      } else {
        debugPrint("DEBUG DATABASE: Criando novo registro");
        var res = await db.insert(DownloadModel.tableName, todo.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        debugPrint("DEBUG DATABASE: Inserção concluída, resultado: $res");
        return res;
      }
    } catch (e) {
      debugPrint('DEBUG DATABASE: ERRO NA INSERÇÃO: $e');
      return null;
    }
  }

  /// get table
  Future<List<Map<String, dynamic>>> retrieveDownLoad() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(DownloadModel.tableName);
    return maps;
  }

  Future<bool> retrieveDownloadID({id}) async {
    try {
      final db = await database;
      debugPrint("DEBUG DATABASE: Verificando download para ID: $id");
      final List<Map<String, dynamic>> maps = await db
          .query(DownloadModel.tableName, where: 'id = ?', whereArgs: [id]);

      debugPrint("DEBUG DATABASE: Encontrados ${maps.length} registros para ID $id");
      if (maps.isEmpty) {
        debugPrint("DEBUG DATABASE: Nenhum registro encontrado no banco");
        return false;
      }

      // Verifica se o arquivo existe fisicamente
      final downloadData = maps.first;
      String filePath = downloadData['link'];
      debugPrint(
          "DEBUG DATABASE: Verificando se o arquivo existe fisicamente em: $filePath");

      final file = File(filePath);
      bool fileExists = await file.exists();
      debugPrint("DEBUG DATABASE: Arquivo existe fisicamente? $fileExists");

      if (!fileExists) {
        // Tente procurar por variações do arquivo (ex: extensões diferentes)
        String basePath = filePath.replaceAll(RegExp(r'\.[^.]+$'), '');

        // Tente com .pdf
        final pdfFile = File('$basePath.pdf');
        if (await pdfFile.exists()) {
          debugPrint(
              "DEBUG DATABASE: Arquivo encontrado com extensão .pdf em: ${pdfFile.path}");
          // Atualiza o banco com o caminho correto
          await db.update(DownloadModel.tableName, {'link': pdfFile.path},
              where: 'id = ?', whereArgs: [id]);
          return true;
        }

        // Tente com .epub
        final epubFile = File('$basePath.epub');
        if (await epubFile.exists()) {
          debugPrint(
              "DEBUG DATABASE: Arquivo encontrado com extensão .epub em: ${epubFile.path}");
          // Atualiza o banco com o caminho correto
          await db.update(DownloadModel.tableName, {'link': epubFile.path},
              where: 'id = ?', whereArgs: [id]);
          return true;
        }

        debugPrint("DEBUG DATABASE: Nenhuma variação do arquivo foi encontrada");
        return false;
      }

      return true;
    } catch (e) {
      debugPrint("DEBUG DATABASE: Erro ao verificar download: $e");
      return false;
    }
  }

  Future<void> deleteDownLoad(int id) async {
    var db = await database;
    db.delete(DownloadModel.tableName, where: 'id = ?', whereArgs: [id]);
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
  static const String tableName = "favorite";

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

  static const String tableName = "download";

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
