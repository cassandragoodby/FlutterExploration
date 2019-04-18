import 'package:flutter/material.dart';
 
 
class LeaveBehindView extends StatelessWidget {
  LeaveBehindView({Key key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(16.0),
      child: new Row (
        children: <Widget>[
        new Icon(Icons.delete),
        new Expanded(
          child: new Text(''),
        ),
        new Icon(Icons.delete),
        ],
      ),
    );
  }
 
}