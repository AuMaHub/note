import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:intl/intl.dart';
import 'package:note/service/db/sqflite.dart';
import 'package:get/get.dart';

class NoteData {
  int noteId;
  String title;
  String incomingJSONText;
  Color backgroundColor;
  String writeDate;

  NoteData({
    this.noteId,
    this.title,
    this.incomingJSONText,
    this.backgroundColor,
    this.writeDate,
  });
}

class NoteCreateScreen extends StatefulWidget {
  final NoteData noteData;
  NoteCreateScreen({@required this.noteData, Key key}) : super(key: key);

  @override
  _NoteCreateScreenState createState() => _NoteCreateScreenState(noteData);
}

class _NoteCreateScreenState extends State<NoteCreateScreen> {
  NoteData noteData;

  _NoteCreateScreenState(this.noteData);

  QuillController _controller = QuillController.basic();
  TextEditingController _title = TextEditingController();
  Color currentColor = Colors.red;
  Color textColor = Colors.black;

  bool isReading = true;
  bool isSaving = false;
  bool readyDB = false;

  SqfliteSql sqflite;
  String _tableName = 'user_note';

  @override
  void initState() {
    super.initState();
    initDB();

    if (noteData.incomingJSONText != null) {
      var myJSON = jsonDecode(noteData.incomingJSONText);
      _controller = QuillController(
        document: Document.fromJson(myJSON),
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
  }

  Future<void> initDB() async {
    sqflite = SqfliteSql();

    await sqflite.connectDB();
    readyDB = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: TextField(
            controller: _title,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: '??????',
              hintStyle: TextStyle(color: textColor),
              labelStyle: TextStyle(color: textColor),
            ),
            style: TextStyle(color: textColor),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('?????? ???????????????.'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: currentColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.palette),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
            ),
          ),
        ],
        elevation: 0.0,
        backgroundColor: currentColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: currentColor,
              child: QuillEditor(
                controller: _controller,
                readOnly: isReading,
                autoFocus: false,
                expands: true,
                focusNode: FocusNode(),
                padding: EdgeInsets.all(10.0),
                scrollable: true,
                scrollController: ScrollController(), // true for view only mode
              ),
            ),
          ),
          QuillToolbar.basic(controller: _controller),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeRead,
        child: Icon(isReading ? Icons.edit : Icons.done),
      ),
    );
  }

  void changeRead() {
    isReading = !isReading;

    if (isReading) {
      saveNotePad(
        noteTitle: _title.text,
        content: jsonEncode(_controller.document.toDelta().toJson()),
        color: currentColor,
        writeDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
    }
    if (mounted) setState(() {});
  }

  void changeColor(Color color) {
    currentColor = color;

    if (currentColor == Color(0xff000000))
      textColor = Colors.white;
    else
      textColor = Colors.black;

    if (mounted) setState(() {});
  }

  /// ???????????? ?????? ??? ??????
  void saveNotePad({
    String noteTitle,
    String content,
    Color color,
    String writeDate,
  }) async {
    if (!readyDB) {
      Get.snackbar('????????? ??? ????????????.', '?????? ????????? ????????? ?????? ???????????????.');
      return;
    }
    isSaving = true;

    try {
      Map<String, dynamic> _columnsData = {
        'noteTitle': noteTitle,
        'content': content,
        'color': color.toString(),
        'writeDate': writeDate,
      };
      // ??? ??????
      if (noteData.noteId == null) {
        final d = InsertTableData(
          tableName: _tableName,
          columnsData: _columnsData,
        );
        int index = await sqflite.insertTable(datas: d);

        noteData.noteId = index;
        noteData.title = noteTitle;
        noteData.incomingJSONText = content;
        noteData.backgroundColor = color;
      }
      // ????????????
      else {
        String where = 'noteId = ${noteData.noteId}';

        await sqflite.updateTable(
          datas: UpdateTableData(
            tableName: _tableName,
            columnsData: _columnsData,
            where: where,
          ),
        );
      }
      isSaving = false;
      if (mounted) setState(() {});

      Get.snackbar('?????? ??????', '??????????????? ??????????????????.');
    } catch (e) {
      isSaving = false;
      Get.snackbar('?????? ??????', '????????? ?????? ???????????????.');
      print(e);
      if (mounted) setState(() {});
    }
  }
}
