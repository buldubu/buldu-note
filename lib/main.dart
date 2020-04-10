import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'note.dart';
import 'notes_page.dart';

void main() {
  runApp(Note());
}

class Note extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note",
      theme: ThemeData(
      ),
      //home: LoginScreen(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/notesPage': (context) => NotesPage(),
        '/notePage': (context) => NotePage(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen>{

  String username = "";
  String password = "";
  String url = "https://buldu-note.herokuapp.com/users/user";
  String urlUserName = "https://buldu-note.herokuapp.com/users/userName";
  String urlNewUser = "https://buldu-note.herokuapp.com/users/userAdd";
  onUsernameType(String value){
    setState(() {
      this.username = value;
    });
  }

  onPasswordType(String value){
    setState(() {
      this.password = value;
    });
  }

  post(BuildContext context) async {
    final http.Response response = await http.post(
      url,
      body: {
        'username': username,
        'password': password,
      }
    );
    if(response.body == "-1"){
      showToast(context,1);
    }else{
      Navigator.pushNamed(
        context,
        '/notesPage',
        arguments: UserArg(
          response.body,
        ),
      );
    }
  }

  postNewUser(BuildContext context) async {
    final http.Response res = await http.post(
      urlUserName,
      body: {
        'username': username,
      }
    );

    if(res.body != "-1"){
      showToast(context,2);
      return;
    }

    final http.Response response = await http.post(
      urlNewUser,
      body: {
        'username': username,
        'password': password,
      }
    );
    Navigator.pushNamed(
      context,
      '/notesPage',
      arguments: UserArg(
        response.body,
      ),
    );
  }

 showToast(BuildContext context, int ind) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: ind == 1 ?const Text('Incorrect username/password!'):const Text('Username has already taken!'),
      ),
    );
  }
  
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text("Please sign in"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: TextFormField(
                  onChanged: onUsernameType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username"
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: TextFormField(
                  onChanged: onPasswordType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password"
                  ),
                  obscureText: true,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: RaisedButton(
                      onPressed: (username.trim().length == 0 || password.trim().length == 0) ? null:() => postNewUser(context),
                      child: Text("Register"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: RaisedButton(
                      onPressed: (username.trim().length == 0 || password.trim().length == 0) ? null:() => post(context),
                      child: Text("Log In"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    ); 
  }
}

class UserArg {
  final String userID;

  UserArg(this.userID);
}

