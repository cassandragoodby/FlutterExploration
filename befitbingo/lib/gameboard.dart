import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'package:flutter/widgets.dart';
// import 'custom_icons_icons.dart';

class GameBoard extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Board"),
      ),
      body: Center(
        child: _buildBoardBody(context),
        
      ),
      );
      
  }
}

Widget _buildBoardBody(BuildContext context) {
  var thisMonthObject = Firestore.instance.collection('ThisMonth').snapshots();
  //  print("this month:");
  print("LLLLLLLLLL");
   print(thisMonthObject);
  //  return _buildMonthList(context, thisMonthObject);
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection('ThisMonth').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return LinearProgressIndicator();

      return _buildBoardUI(context, snapshot.data.documents);
    },
  );
 }

 Widget _buildBoardUI(BuildContext context, List<DocumentSnapshot> snapshot) {
   return GridView.count(
     crossAxisCount: 5,
     childAspectRatio: 1.0,
     padding: const EdgeInsets.only(top: 50.0),
     children: snapshot.map((data) => _buildGameListItem(context, data)).toList(),
   );
 }

 Widget _buildGameListItem(BuildContext context, DocumentSnapshot data) {
  // final recordMonth = RecordMonth.fromSnapshot(data);
   return Padding(
     padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
     child: Container(
       width: 50.0,
       height: 50.0,
       decoration: BoxDecoration(
        //  border: Border.all(color: Colors.grey),
        //  borderRadius: BorderRadius.circular(25.0),
       ),
       child: GridTile(
         
         child: _getGridTile(context, data)
          
       ),
   )
   );
 }
class CustomIcons{
  CustomIcons._();

  static const _kFontFam = 'CustomIcons';

  static const IconData checkmark = const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData exercise = const IconData(0xe801, fontFamily: _kFontFam);
  static const IconData food = const IconData(0xe802, fontFamily: _kFontFam);
  static const IconData lifestyle = const IconData(0xe803, fontFamily: _kFontFam);
  static const IconData sleep = const IconData(0xe804, fontFamily: _kFontFam);
}

 Widget _getGridTile(BuildContext context, DocumentSnapshot data) {
   final recordMonth = RecordMonth.fromSnapshot(data);
    if (recordMonth.typeMonth.toString() == "Exercise"  && recordMonth.completedMonth != true) {
      return InkWell(
        onTap: () => 
        {
          print(recordMonth),
          _settingModalBottomSheet(context,data),
        },
        child: new Card(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
          color: Color(0xfffcb11f),
          child: _getPopupIconSmall(context,data),
        )
      );
    } 
    else if(recordMonth.typeMonth.toString() == "Sleep"  && recordMonth.completedMonth != true) {
      return InkWell(
        onTap: () => 
        {
          print(recordMonth),
          _settingModalBottomSheet(context,data),
        },
        child: new Card(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
          color: const Color(0xff46c3f3),
          child: _getPopupIconSmall(context,data),
        )
      );
    }else if(recordMonth.typeMonth.toString() == "Food"  && recordMonth.completedMonth != true) {
      return InkWell(
        onTap: () => 
        {
          print(recordMonth),
          _settingModalBottomSheet(context,data),
        },
        child: new Card(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
          color: Color(0xffee6e57),
          child: _getPopupIconSmall(context,data),
        )
      );
    }else if(recordMonth.typeMonth.toString() == "Lifestyle"  && recordMonth.completedMonth != true) {
      return InkWell(
        onTap: () => {
          print(recordMonth),
          _settingModalBottomSheet(context,data),
        },
        child: new Card(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
          color: Color(0xffba5abb),
          child: _getPopupIconSmall(context,data),
        )
      );
    } else {
      return InkWell(
        onTap: () => {
          print(recordMonth),
          _settingModalBottomSheet(context,data),
        },
        child: new Card(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
          color: Color(0xff7cc04f),
          child: _getPopupIconSmall(context,data),
        )
      );
      
    }
  }

  _getPopupIconSmall(BuildContext context, DocumentSnapshot data) {
   final recordMonth = RecordMonth.fromSnapshot(data);
    if (recordMonth.typeMonth.toString() == "Exercise" && recordMonth.completedMonth != true){
      return new Icon(
        CustomIcons.exercise,
        color: Colors.white,
        size: 30.0,);
    } 
    else if(recordMonth.typeMonth.toString() == "Sleep" && recordMonth.completedMonth != true) {
      return new Icon(
        CustomIcons.sleep,
      color: Colors.white,
      size: 30.0,);
    }else if(recordMonth.typeMonth.toString() == "Food" && recordMonth.completedMonth != true) {
      return new Icon(
        CustomIcons.food,
        color: Colors.white,
        size: 30.0,);
    }else if(recordMonth.typeMonth.toString() == "Lifestyle" && recordMonth.completedMonth != true) {
      return new Icon(
        CustomIcons.lifestyle,
        color: Colors.white,
        size: 30.0,);
    } else {
      return new Icon(
        CustomIcons.checkmark,
        color: Colors.white,
        size: 30.0,);
    }
  }
  
  //popup card when clicked

  void _settingModalBottomSheet(context,data){
    final recordMonth = RecordMonth.fromSnapshot(data);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            color: _getColor(context, data),
            height: 400.0,
            child: new Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
      new Container( 
        width: 70.0,
        height: 70.0,
        color: _getColor(context, data),
        margin: const EdgeInsets.all(50.0),
        child: _getPopupIcon(context,data)),
      new Text(
        recordMonth.goalNameMonth.toString(),
        style: TextStyle(color: Colors.white, fontSize: 25.0,fontWeight: FontWeight.bold)),
      new Text(
        recordMonth.typeMonth.toString(),
        style: TextStyle(color: Colors.white, fontSize: 25.0),),
      new Container(
        margin: const EdgeInsets.all(50.0),
        //IF RECORD MONTH COMPLETE IS FALSE SHOW BUTTON
        child: _showButton(context, data),
      )
          ],
          ),
          );
      }
    );
}

Widget _showButton(BuildContext context, DocumentSnapshot data){
  final recordMonth = RecordMonth.fromSnapshot(data);
  if( recordMonth.completedMonth != true){
  return RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            child: const Text(
              'COMPLETE GOAL',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            color: Colors.white,
            elevation: 4.0,
            splashColor: const Color(0xff7cc04f),
            onPressed: () {
              // Check off this months goal
              // Change color and to checkmark
              print('updating data');
              Firestore.instance.collection('ThisMonth').document(data.documentID).updateData({'completed': true});
              // Navigator.push(context, ThisMonthAdded())
              Navigator.pop(context);
            },
          );
  }
  else{
    return const Text(
      'COMPLETED',
      style: TextStyle(color: Colors.white,fontSize: 25.0,fontWeight: FontWeight.bold),
    );
  }
}

Color _getColor(BuildContext context, DocumentSnapshot data){
  final recordMonth = RecordMonth.fromSnapshot(data);
  if(recordMonth.typeMonth.toString() == "Exercise" && recordMonth.completedMonth != true){
    return Color(0xfffcb11f);
  }
  else if(recordMonth.typeMonth.toString() == "Sleep" && recordMonth.completedMonth != true){
    return Color(0xff46c3f3);
  }
  else if(recordMonth.typeMonth.toString() == "Food" && recordMonth.completedMonth != true) {
    return Color(0xffee6e57);
  }
  else if(recordMonth.typeMonth.toString() == "Lifestyle" && recordMonth.completedMonth != true) {
    return Color(0xffba5abb);
  }
  else{
    return Color(0xff7cc04f);
  }
}

_getPopupIcon(BuildContext context, DocumentSnapshot data) {
   final recordMonth = RecordMonth.fromSnapshot(data);
    if (recordMonth.typeMonth.toString() == "Exercise") {
      return new Icon(
        CustomIcons.exercise,
        color: Colors.white,
        size: 70.0,);
    } 
    else if(recordMonth.typeMonth.toString() == "Sleep") {
      return new Icon(
        CustomIcons.sleep,
      color: Colors.white,
      size: 70.0,);
    }else if(recordMonth.typeMonth.toString() == "Food") {
      return new Icon(
        CustomIcons.food,
        color: Colors.white,
        size: 70.0,);
    }else if(recordMonth.typeMonth.toString() == "Lifestyle") {
      return new Icon(
        CustomIcons.lifestyle,
        color: Colors.white,
        size: 70.0,);
    } else {
      return Container();
    }
  }




//IMPORT THIS MONTH GOALS
//CREATE 5X5 images based upon this month goals
//create popup if they click on it 

// class GameBoardPage extends StatefulWidget {
//   @override
//   _GameBoardPageState createState() => _GameBoardPageState();
// }

// class _GameBoardPageState extends State<GameBoardPage> {
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//       title: new Text("Main Board"),
//       )
//     );
//   }
// }