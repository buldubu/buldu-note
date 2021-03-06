import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note/notes_page.dart';
import 'main.dart';
import 'dart:async';



class NotePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _NotePage();
  }
}

class NoteData{
  final int id;
  String title;
  String text;
  NoteData({this.id, this.title, this.text});
  factory NoteData.fromJson(Map<String, dynamic> json) {
    return NoteData(
      id: json['id'] as int,
      title: json['title'] as String,
      text: json['note'] as String,
    );
  }
}



class _NotePage extends State<NotePage>{
  var noteID = "-2";
  var author = "-1";
  NoteData note = new NoteData();
  String urlNote = "https://buldu-note.herokuapp.com/users/note";
  String urlNoteEdit = "https://buldu-note.herokuapp.com/users/noteEdit";
  String urlNoteAdd = "https://buldu-note.herokuapp.com/users/noteAdd";

  final textTitle = new TextEditingController();
  final textNote = new TextEditingController();

  postNote() async {
    await http.post(
      urlNote,
      body: {
        'id': noteID
      }
    ).then((value) {
      final parsed = jsonDecode(value.body);
      NoteData data = NoteData.fromJson(parsed);
      setState(() {
        note = data;
        textTitle.text = note.title;
        textNote.text = note.text;
      });
    });  
  }

  onTitleType(String value){
    setState(() {
      note.title = value;
    });
  }

  onTextType(String value){
    setState(() {
      note.text = value;
    });
  }

  updateNote() async {
    await http.post(
      urlNoteEdit,
      body: {
        'id': note.id.toString(),
        'title': note.title,
        'note': note.text
      }
    ).then((value) {
      Navigator.pop(context);
    });
  }

  addNote() async {
    await http.post(
      urlNoteAdd,
      body: {
        'author': author.toString(),
        'title': note.title,
        'note': note.text
      }
    ).then((value) {
      Navigator.pop(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    if(noteID == "-2"){
      final NoteArg args = ModalRoute.of(context).settings.arguments;
      noteID = args.noteID;
      author = args.authorID;
    }
    if(note.id == null && noteID != "-1"){      
      postNote();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: TextFormField(
                  controller: textTitle,
                  onChanged: onTitleType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Title"
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: TextFormField(
                  controller: textNote,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  onChanged: onTextType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Note"
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: RaisedButton(
                  onPressed: (note.title==null?true:(note.title.trim().length==0) || note.text==null?true:(note.text.trim().length==0)) ? null:(noteID == "-1"?addNote:updateNote),
                  child: Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomPadding: true,
    );
  }

}