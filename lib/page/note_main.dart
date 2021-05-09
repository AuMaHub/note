import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/page/noteCreate.dart';
import 'package:note/service/db/sqflite.dart';

class NoteMainScreen extends StatefulWidget {
  NoteMainScreen({Key key}) : super(key: key);

  @override
  _NoteMainScreenState createState() => _NoteMainScreenState();
}

class _NoteMainScreenState extends State<NoteMainScreen> {
  List<NoteData> _noteDatas = [];
  SqfliteSql sqflite;
  String _tableName = 'user_note';
  List<String> _columns = [
    'noteId',
    'noteTitle',
    'content',
    'color',
    'writeDate',
  ];
  List<String> _type = [
    'INTEGER',
    'TEXT',
    'TEXT',
    'TEXT',
    'TEXT',
  ];
  Map<int, String> _options = {0: 'PRIMARY KEY AUTOINCREMENT'};

  @override
  void initState() {
    initDB();
    super.initState();
  }

  void initDB() async {
    sqflite = SqfliteSql();

    await sqflite.connectDB();

    await sqflite.createTable(
      datas: CreateTableData(
        tableName: _tableName,
        columnsName: _columns,
        types: _type,
        options: _options,
      ),
    );
    List<Map<String, dynamic>> noteData = await sqflite.selectTable(
      datas: SelectTableData(
        tableName: _tableName,
        columns: _columns,
        orderBy: _columns[0],
      ),
    );

    noteData.forEach((e) {
      _noteDatas.add(
        NoteData(
          noteId: e['noteId'],
          title: e['noteTitle'],
          incomingJSONText: e['content'],
          // backgroundColor: e['color'],
          writeDate: e['writeDate'],
        ),
      );
    });
    if (mounted) setState(() {});

    // print(_noteData.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메모장'),
      ),
      backgroundColor: Colors.brown,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _noteDatas.isEmpty ? 0 : _noteDatas.length,
                itemBuilder: (_, index) {
                  return noteList(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => NoteCreateScreen(noteData: NoteData())),
        heroTag: 'memo',
        icon: Icon(Icons.add),
        label: Text('메모하기'),
      ),
    );
  }

  Widget noteList(int index) {
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0, bottom: 5.0),
      color: Colors.yellow[200],
      child: InkWell(
        onTap: () =>
            Get.to(() => NoteCreateScreen(noteData: _noteDatas[index])),
        child: Container(
          height: 60.0,
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Text(
                    _noteDatas[index].title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(child: Icon(Icons.check)),
              Container(child: defulatText(_noteDatas[index].writeDate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget defulatText(String text, {double fontSize = 18}) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
    );
  }
}
