import 'package:flutter/material.dart';

class NoteMainScreen extends StatefulWidget {
  NoteMainScreen({Key key}) : super(key: key);

  @override
  _NoteMainScreenState createState() => _NoteMainScreenState();
}

class _NoteMainScreenState extends State<NoteMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('메모장')),
      body: Container(
        child: Text(''),
      ),
    );
  }
}
