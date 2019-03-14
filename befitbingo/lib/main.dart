// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:english_words/english_words.dart';
import 'authentication.dart';
import 'root_page.dart';

import 'package:flutter/material.dart';
// import 'login_signup_page.dart';

void main() => runApp(new MyApp());

//Email Authentication from https://medium.com/flutterpub/flutter-how-to-do-user-login-with-firebase-a6af760b14d5
//& https://codelabs.developers.google.com/codelabs/flutter-firebase/#8
//& https://pub.dartlang.org/packages/firebase_auth#-readme-tab-
//& https://www.youtube.com/watch?v=GDrlQ0L4ogg

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Be Fit Bingo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}
