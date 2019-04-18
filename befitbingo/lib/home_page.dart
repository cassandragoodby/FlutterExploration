// import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication.dart';
import 'package:flutter/material.dart';
// import 'dart:async';
// import 'root_page.dart';
import 'gameboard.dart';

int amountFilled = 0;

class CustomIcons{
  CustomIcons._();

  static const _kFontFam = 'CustomIcons';

  static const IconData checkmark = const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData exercise = const IconData(0xe801, fontFamily: _kFontFam);
  static const IconData food = const IconData(0xe802, fontFamily: _kFontFam);
  static const IconData lifestyle = const IconData(0xe803, fontFamily: _kFontFam);
  static const IconData sleep = const IconData(0xe804, fontFamily: _kFontFam);
}

class HomePageState extends StatefulWidget{
  HomePageState({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);
  
   final BaseAuth auth;
   final VoidCallback onSignedOut;
   final String userId;

  // _signOut(auth);
  
  void _signOut() async {
    // print("here");
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  @override 
  State createState() => new HomePage();
}

typedef void VoidCallback();

class HomePage extends State<HomePageState> {
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Add 25 Goals"),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: () {
                print("signing out");
                widget._signOut();
                // VoidCallback();
              }
          )
        ],
      ),
      body: Stack(children: <Widget>[
        _buildBody(context),
        _buildUItracker(context),
      ]),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add),
        backgroundColor: Color(0xfffcb11f),
        onPressed: () {
          //OPEN ADD FORM
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNew()),
          );
        },
      ),
    );
  }

  // String amountFilled = "0";
  // int amountFilled = 0;
  String outOf = " / 25";

totalMonth() async {
  var thisMonthQuery = Firestore.instance.collection('ThisMonth');
  var querySnapshot = await thisMonthQuery.getDocuments();
  amountFilled = querySnapshot.documents.length;
  // print('in totalmonth');
  // print(amountFilled);
  setState(() {
    // print("set state");
  });
  return amountFilled;
}

  Widget _buildUItracker(context) {
    totalMonth();
    // print("insideUI");
    // print(amountFilled);
    // print(amountFilled);
    return GestureDetector(
        onTap: () {
          print("Container clicked");
          //Move to this months goal list
          totalMonth();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThisMonthAddedState()),
          );
        },
        child: Container(
          constraints: BoxConstraints.expand(
            height: Theme.of(context).textTheme.display1.fontSize * 1.1 + 30.0,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3.0),
          margin: const EdgeInsets.all(15.0),
          decoration: new BoxDecoration(
            
            //https://medium.com/@rjstech/flutter-custom-paint-tutorial-build-a-radial-progress-6f80483494df
            //USE FOR CIRCLE ^^^^
            border: Border.all(color: Color(0xff7cc04f)),
            borderRadius: BorderRadius.circular(5.0),
            color: Color(0xff7cc04f),
          ),
          //IF 25 switch to next
          child: _getNext(),
        ));
  }

  Widget _getNext() {
    // print('get next');
    if(amountFilled < 25){
    return Text(amountFilled.toString() + outOf,
      style: Theme.of(context)
          .textTheme
          .display1
          .copyWith(color: Colors.white));
    }
    else{
      return Text("NEXT",
        style: Theme.of(context)
            .textTheme
            .display1
            .copyWith(color: Colors.white));
    }
  }
  

  Widget _buildBody(BuildContext context) {
    // var thisMonthsGoals = Firestore.instance.collection('ThisMonth').snapshots();
    // print(thisMonthsGoals);
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Goals').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  // Widget _buildList(BuildContext context, List<Map> snapshot) {
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Container(
        margin: EdgeInsets.only(top: 90.0, bottom: 40.0),
        child: ListView(
          //  padding: EdgeInsets.only(top: 8.0),
          //  padding: const EdgeInsets.only(top: 90.0),
          //  margin: const EdgeInsets.all(15.0),
          children:
              snapshot.map((data) => _buildListItem(context, data)).toList(),
        ));
  }

//  Widget _buildListItem(BuildContext context, Map data) {
//    final record = Record.fromMap(data);
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
//  print(record);
    return Padding(
      key: ValueKey(record.goalName),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _getBorderColor(context, data),
            width: 3
            ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: new Dismissible(
          background: Container(color: Color(0xffee6e57)),
          key: new Key(record.goalName.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (DismissDirection direction) {
            showAlertDialog(context,data);
            // _delete(data);
          },
          resizeDuration: null,
          dismissThresholds: _dismissThresholds(),
          // background: new LeaveBehindView(),
        child: new ListTile(
          // leading: Icon(Icons.favorite),
          leading: _getListIcon(context, data),
          title: Text(record.goalName),
          subtitle: Text(record.type.toString()),
          onTap: () {
            print("ssssssss");
            print("amount filled: ");
            print( amountFilled);
            totalMonth();
            if(amountFilled < 25){
            record.reference.updateData({'AmountUsed': record.usedAmount + 1});
            record.reference.updateData({'thisMonth': true});
            Firestore.instance.collection('ThisMonth').add({
              'GoalName': record.goalName,
              'Type': record.type,
              'AmountUsed': record.usedAmount + 1,
              "thisMonth": record.storeForMonth,
              "Used": true,
              "completed":false
            });
            
            //ADD TO THISMONTHOBJECT if under 25 (count)
            //UPDATE NUMBER IN THIS MONTH
            //After getting totalMonth() data update
            print("WAITING DATA");
            totalMonth();
            //WORKAROUND ^^^
            // build(context);
            // _buildUItracker(context,amountFilled);
          }
          totalMonth();
          if(amountFilled >= 24){
              //auto open next page
              //popup stating next
              print("25 push to next");
               
            }
          },
        ),
      ),
      )
    );
  }
}

Map<DismissDirection, double> _dismissThresholds() {
  Map<DismissDirection, double> map = new Map<DismissDirection, double>();
  map.putIfAbsent(DismissDirection.horizontal, () => 0.5);
  return map;
}
 
void _delete(DocumentSnapshot data) {
  // final record = Record.fromSnapshot(data);
  Firestore.instance.collection('Goals').document(data.documentID).delete();
}

showAlertDialog(BuildContext context,DocumentSnapshot data) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Delete"),
          content: new Text("Are you sure you want to delete?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                _delete(data);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
}


Color _getBorderColor(BuildContext context, DocumentSnapshot data){
  final recordMonth = RecordMonth.fromSnapshot(data);
  if(recordMonth.typeMonth.toString() == "Exercise"){
    return Color(0xfffcb11f);
  }
  else if(recordMonth.typeMonth.toString() == "Sleep"){
    return Color(0xff46c3f3);
  }
  else if(recordMonth.typeMonth.toString() == "Food") {
    return Color(0xffee6e57);
  }
  else if(recordMonth.typeMonth.toString() == "Lifestyle") {
    return Color(0xffba5abb);
  }
  else{
    return Colors.grey;
  }
}

Widget _getListIcon(BuildContext context, DocumentSnapshot data) {
  final recordMonth = RecordMonth.fromSnapshot(data);
  if(recordMonth.typeMonth.toString() == "Exercise"){
    return Icon(
      CustomIcons.exercise,
      color: _getBorderColor(context, data),
      size: 35.0,
      );
  }
  else if(recordMonth.typeMonth.toString() == "Sleep") {
    return Icon(
      CustomIcons.sleep,
      color: _getBorderColor(context, data),
      size: 35.0,
      );
  }
  else if(recordMonth.typeMonth.toString() == "Food") {
    return Icon(
      CustomIcons.food,
      color: _getBorderColor(context, data),
      size: 35.0,
      );
  }
  else if(recordMonth.typeMonth.toString() == "Lifestyle") {
    return Icon(
      CustomIcons.lifestyle,
      color: _getBorderColor(context, data),
      size: 35.0,
      );
  }
  else {
      return Icon(
      CustomIcons.checkmark,
      color: _getBorderColor(context, data),
      size: 35.0,
      );
    }
}

class Record {
  final String goalName;
  final String type;
  final int usedAmount;
  final bool storeForMonth;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['GoalName'] != null),
        assert(map['Type'] != null),
        assert(map['AmountUsed'] != null),
        assert(map['thisMonth'] != null),
        goalName = map['GoalName'],
        type = map['Type'],
        usedAmount = map['AmountUsed'],
        storeForMonth = map['thisMonth'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$goalName:$type>";
}

// ADD NEW PAGE

class AddNew extends StatefulWidget {
  AddNewState createState() => AddNewState();
}

class AddNewState extends State<AddNew> {
  String goalName = "";
  String _goalNameNew;
  String _typeNew;
  String _errorMessage;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New"),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Save',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: () {
                _goalNameNew = getTextInput.text;
                print(_goalNameNew);
                print(_typeNew);
                if (_goalNameNew != '' && _typeNew != null) {
                  //Add to firebase
                  _errorMessage = "";
                  // Firestore.instance.collection('Goals').document(firebaseUser.uid).setData(
                  // {'nickname': firebaseUser.displayName, 'photoUrl': firebaseUser.photoUrl, 'id': firebaseUser.uid});
                  // }
                  Firestore.instance.collection('Goals').add({
                    'GoalName': _goalNameNew,
                    'Type': _typeNew,
                    'AmountUsed': 0,
                    "thisMonth": true,
                    "completed":false
                  });
                  print("Adding to firebase");
                  //exit back to screen
                  Navigator.pop(context);
                } else if (_goalNameNew == '' && _typeNew != null) {
                  _errorMessage = "Please add a goal";
                  print(_errorMessage);
                  // _showErrorMessage();
                } else if (_typeNew == null && _goalNameNew != '') {
                  _errorMessage = "Please choose a type";
                  print(_errorMessage);
                  //  _showErrorMessage();
                } else if (_goalNameNew == '' && _typeNew == null) {
                  _errorMessage = "Please fill out the form";
                  print(_errorMessage);
                  // _showErrorMessage();
                }
              })
        ],
      ),
      body: Stack(
        children: <Widget>[_showForm()],
      ),
    );
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showGoalInput(),
              _showTypeInput(),
              _showErrorMessage()
              // _showSaveButton(),
            ],
          ),
        ));
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('images/BeFit-icon.png'),
        ),
      ),
    );
  }

  final getTextInput = TextEditingController();

  Widget _showGoalInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0.0),
      child: new TextField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Goal Name',
          // icon: new Icon(
          //   Icons.mail,
          //   color: Colors.grey,
          // )
        ),
        controller: getTextInput,
      ),
    );
  }

  String dropdownValue = 'Please choose a type';

  Widget _showTypeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      // alignedDropdown: true,
      child: new DropdownButton(
        isExpanded: true,
        items: <String>['Lifestyle', 'Exercise', 'Food', 'Sleep']
            .map((String value) {
          return new DropdownMenuItem<String>(
              value: value,
              child: new Container(
                child: new Text(value),
                width: 200,
              ));
        }).toList(),
        hint: Text(dropdownValue),
        onChanged: (newValue) {
          setState(() {
            print(newValue);
            dropdownValue = newValue;
            this.setState(() {});
            _typeNew = dropdownValue;
          });
        },
        // onSaved: (value) => _typeNew = value,
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null) {
      return new Text(
        _errorMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13.0,
            color: Color(0xffee6e57),
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}

// THIS MONTH PAGE

class ThisMonthAddedState extends StatefulWidget{
  @override 
  State createState() => new ThisMonthAdded();
}

class ThisMonthAdded extends State<ThisMonthAddedState>  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This Month Goals"),
      ),
      body: Center(
        child: _buildMonthBody(context),
        
      ),
      floatingActionButton: _getFAB(context),
    );
  }

  Widget _getFAB(BuildContext context) {
    // totalMonth();
    print("inside this month");
    print(amountFilled);
    if (amountFilled >= 25) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameBoard()),
          );
        },
        //TO GAME BOARD VIEW
        icon: Icon(Icons.arrow_forward),
        label: Text("Next"),
        backgroundColor: Color(0xff7cc04f),
      );
    } else {
      return Container();
      
    }
  }

  Widget _buildMonthBody(BuildContext context) {
  //  print("this month:");
  //  print(thisMonthObject);
  //  return _buildMonthList(context, thisMonthObject);
    return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection('ThisMonth').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return LinearProgressIndicator();

      return _buildMonthList(context, snapshot.data.documents);
    },
  );
 }

//  Widget _buildMonthList(BuildContext context, List<Map> snapshot) {
  Widget _buildMonthList(BuildContext context, List<DocumentSnapshot> snapshot) {
   return ListView(
     padding: const EdgeInsets.only(top: 20.0),
     children: snapshot.map((data) => _buildMonthListItem(context, data)).toList(),
   );
 }

//  Widget _buildMonthListItem(BuildContext context, Map data) {
  Widget _buildMonthListItem(BuildContext context, DocumentSnapshot data) {
  //  final recordMonth = RecordMonth.fromMap(data);
  final recordMonth = RecordMonth.fromSnapshot(data);

   return Padding(
    //  key: ValueKey(recordMonth.goalNameMonth),
     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Container(
       decoration: BoxDecoration(
         border: Border.all(
           color: _getBorderColor(context, data),
           width: 3
           ),
         borderRadius: BorderRadius.circular(5.0),
       ),
       child: new Dismissible(
         background: Container(color: Color(0xffee6e57)),
          key: new Key(recordMonth.goalNameMonth.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {
            _deleteMonth(data);
            setState(() {
              this.setState(() {});
            });
          },
          resizeDuration: null,
          dismissThresholds: _dismissThresholds(),
          // background: new LeaveBehindView(),
       child: ListTile(
        //  title: Text("Wow"),
        leading: _getListIcon(context, data),
         title: Text(recordMonth.goalNameMonth), //trailing
         subtitle: Text(recordMonth.typeMonth.toString()),
         onTap: () => print(recordMonth),
         
       ),
     ),
     )
   );
 }

}

_deleteMonth(DocumentSnapshot data) {
  // final recordMonth = RecordMonth.fromSnapshot(data);
  // print(data.documentID);
  Firestore.instance.collection('ThisMonth').document(data.documentID).delete();
  
}

class RecordMonth {
  final String goalNameMonth;
  final String typeMonth;
  final bool completedMonth;
  // final int usedAmount;
  // final bool storeForMonth;
  final DocumentReference reference;
  // if()
  RecordMonth.fromMap(Map<String, dynamic> map, {this.reference})
      // : assert(map['goalNameMonth'] != null),
      //   assert(map['typeMonth'] != null),
      : assert(map['GoalName'] != null),
        assert(map['Type'] != null),
        assert(map['completed']!= null),
        // assert(map['AmountUsed'] != null),
        // assert(map['thisMonth'] != null),
        // goalNameMonth = map['goalNameMonth'],
        // typeMonth = map['typeMonth'];
        goalNameMonth = map['GoalName'],
        typeMonth = map['Type'],
        completedMonth = map['completed'];
        // usedAmount = map['AmountUsed'],
        // storeForMonth = map['thisMonth'];

  RecordMonth.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "RecordMonth<$goalNameMonth:$typeMonth>";
}