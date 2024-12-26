import 'package:flutter/material.dart';

class MyCommon {
  static const Color mainColor = Colors.green;

  static const TextStyle appBarTitleStyle = TextStyle(
      color: MyCommon.mainColor, fontWeight: FontWeight.bold, fontSize: 24);

  static const itemGridBorder = Border(
    left: BorderSide(color: mainColor),
    top: BorderSide(color: mainColor),
    right: BorderSide(color: mainColor),
    bottom: BorderSide(color: mainColor),
  );

  static SimpleDialog getSelectNoteTypesDialog(VoidCallback typeClicked){
    return const SimpleDialog(
      children: [
        SimpleDialogOption(child: Row(
          children: [
            Icon(Icons.text_snippet, color: Colors.red,),
            Text('Text Note')
          ],
        ),),
        SimpleDialogOption(child: Row(
          children: [
            Icon(Icons.image, color: Colors.yellowAccent,),
            Text('Image Note')
          ],
        ),),
        SimpleDialogOption(child: Row(
          children: [
            Icon(Icons.checklist, color: Colors.orange,),
            Text('Checklist Note')
          ],
        ),),
        SimpleDialogOption(child: Row(
          children: [
            Icon(Icons.notifications_on, color: Colors.blue,),
            Text('Notification Note')
          ],
        ),)
      ],
    );
  }
}
