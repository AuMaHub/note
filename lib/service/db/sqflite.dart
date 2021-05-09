import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as pa;

class CreateTableData {
  String tableName;
  List<String> columnsName;
  List<String> types;
  Map<int, String> options;
  bool isNomal;

  CreateTableData(
      {this.tableName, this.columnsName, this.types, this.options}) {
    if (tableName.isEmpty || columnsName.isEmpty || types.isEmpty) {
      isNomal = false;
    }

    List<int> optionsList = options.keys.toList();

    optionsList.forEach((key) {
      if (key > columnsName.length - 1) isNomal = false;
    });

    tableName = tableName.replaceAll(' ', '');

    if (tableName == '' ||
        tableName.contains("\'") ||
        columnsName.length == 0 ||
        types.length == 0 ||
        columnsName.length != types.length) {
      isNomal = false;
    }
    if (isNomal == null)
      isNomal = true;
    else
      isNomal = false;
  }
}

class InsertTableData {
  String tableName;
  Map<String, dynamic> columnsData;

  InsertTableData({this.tableName, this.columnsData});
}

class UpdateTableData {
  String tableName;
  String where;
  Map<String, dynamic> columnsData;

  UpdateTableData({this.tableName, this.where, this.columnsData});
}

class DeleteTableData {
  String tableName;
  String where;

  DeleteTableData({this.tableName, this.where});
}

class SelectTableData {
  String tableName;
  String where;
  String orderBy;
  List<String> columns;

  SelectTableData({this.tableName, this.where, this.orderBy, this.columns});
}

class SqfliteSql {
  Database database;
  String databasesPath;
  String path;

  // Sqflite();

  Future<void> initSqflite() async {
    databasesPath = await getDatabasesPath();
    path = pa.join(databasesPath, 'note.db');
  }

  Future<bool> connectDB() async {
    await initSqflite();
    if (path.isEmpty) return false;
    try {
      database = await openDatabase(path, version: 1);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createTable({@required CreateTableData datas}) async {
    if (database == null) return false;

    try {
      final count = await database.rawQuery('''
          SELECT name FROM sqlite_master 
          WHERE type='table' 
          AND name='${datas.tableName}' ''');

      if (count.length != 0) return true;

      String sql = 'CREATE TABLE ${datas.tableName}';

      sql += '(';
      for (int i = 0; i < datas.columnsName.length; i++) {
        sql += '${datas.columnsName[i]} ';
        sql += '${datas.types[i]} ';
        if (datas.options.containsKey(i)) {
          sql += '${datas.options[i]} ';
        }
        sql += ',';
      }
      sql = sql.substring(0, sql.length - 1);
      sql += ')';

      database.execute(sql);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> insertTable({@required InsertTableData datas}) async {
    if (database == null) return null;
    try {
      int index = await database.insert(
        datas.tableName,
        datas.columnsData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return index;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTable({@required UpdateTableData datas}) async {
    if (database == null) return false;
    try {
      var batch = database.batch();
      batch.update(datas.tableName, datas.columnsData, where: datas.where);
      await batch.commit(noResult: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTable({@required DeleteTableData datas}) async {
    if (database == null) return false;
    try {
      var batch = database.batch();
      batch.delete(datas.tableName, where: datas.where);
      await batch.commit(noResult: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<dynamic, dynamic>>> selectTable(
      {@required SelectTableData datas}) async {
    if (database == null) return null;
    try {
      List<Map<dynamic, dynamic>> result = await database.query(datas.tableName,
          columns: datas.columns, orderBy: datas.orderBy);

      return result;
    } catch (e) {
      return null;
    }
  }
}
