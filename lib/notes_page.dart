import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class NotesPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _NotesPage();
  }
}

class Titles{
  final int id;
  final String title;
  Titles({this.id, this.title});
  factory Titles.fromJson(Map<String, dynamic> json) {
    return Titles(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}



class _NotesPage extends State<NotesPage>{
  bool reload = true;
  var id = "-1";
  List<Titles> notes = <Titles>[];
  String urlTitles = "https://buldu-note.herokuapp.com/users/titles";
  String urlDeleteNote = "https://buldu-note.herokuapp.com/users/noteDelete";
  
  postTitles(BuildContext context) async {
    final http.Response response = await http.post(
      urlTitles,
      body: {
        'author': id,
      }
    );  
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Titles> data = parsed.map<Titles>((json) => Titles.fromJson(json)).toList();
    
    setState(() {
      notes = data;
    });
  }

  getNote(BuildContext context, int noteID) {
    reload=true;
    Navigator.pushNamed(
      context,
      '/notePage',
      arguments: NoteArg(
        noteID.toString(),
        id.toString()
      ),
    ).then((value) {
      setState(() {
        reload = true;
      });
    });
  }

  deleteNote(BuildContext context, int index) async {
    await http.post(
      urlDeleteNote,
      body: {
        'id': notes[index].id.toString(),
      }
    ).then((value) {
      setState(() {
        reload = true;
      });
    });
  }

  void _showDialog(int index) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete note"),
          content: new Text("Do you want to delete this note?\n" + notes[index].title),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                setState((){
                  deleteNote(context, index);
                  postTitles(context);
                  reload = true;
                });
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  deleteNoteButton(int index){
    setState(() {
      _showDialog(index);
      postTitles(context);
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    final UserArg args = ModalRoute.of(context).settings.arguments;
    id = args.userID;
    if(reload){
      postTitles(context);
      reload = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index){
              return Card(
                child: ListTile(
                  title: new Text(notes[index].title),
                  onTap: () => getNote(context, notes[index].id),
                  onLongPress: () => deleteNoteButton(index),
                ),
              );
            },
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getNote(context, -1),
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteArg {
  final String noteID;
  final String authorID;

  NoteArg(this.noteID, this.authorID);
}