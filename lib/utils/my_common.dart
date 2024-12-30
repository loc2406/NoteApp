import 'package:flutter/material.dart';

class MyCommon {
  static const Color mainColor = Colors.green;

  static const TextStyle appBarTitleStyle = TextStyle(
      color: MyCommon.mainColor, fontWeight: FontWeight.bold, fontSize: 24);
  static const TextStyle dialogTitleStyle = TextStyle(
      color: MyCommon.mainColor, fontWeight: FontWeight.bold, fontSize: 18);
  static const TextStyle fieldLabelStyle = TextStyle(
      color: MyCommon.mainColor, fontWeight: FontWeight.bold, fontSize: 16);

  static const fieldBorderStyle = OutlineInputBorder(borderSide: BorderSide(color: MyCommon.mainColor, style: BorderStyle.solid), borderRadius: BorderRadius.all(Radius.circular(10)));

  static const itemGridBorder = Border(
    left: BorderSide(color: mainColor),
    top: BorderSide(color: mainColor),
    right: BorderSide(color: mainColor),
    bottom: BorderSide(color: mainColor),
  );

  static SimpleDialog getSelectNoteTypesDialog(void Function(String type) typeClicked){
    return SimpleDialog(
      title: const Text('Select Note Type:', style: MyCommon.dialogTitleStyle, textAlign: TextAlign.center,),
      children: [
        SimpleDialogOption(
          onPressed: () => typeClicked.call('text'),
          child: const Row(
          children: [
            Icon(Icons.text_snippet, color: Colors.red,),
            SizedBox(width: 10,),
            Text('Text Note')
          ],
        ),),
        SimpleDialogOption(
          onPressed: () => typeClicked.call('image'),
          child: Row(
          children: [
            Icon(Icons.image, color: Colors.yellow[500],),
            const SizedBox(width: 10,),
            const Text('Image Note')
          ],
        ),),
         SimpleDialogOption(
          onPressed: () => typeClicked.call('checklist'),
          child: const Row(
          children: [
            Icon(Icons.checklist, color: Colors.orange,),
            SizedBox(width: 10,),
            Text('Checklist Note')
          ],
        ),),
         SimpleDialogOption(
           onPressed: () => typeClicked.call('notification'),
           child: const Row(
          children: [
            Icon(Icons.notifications_on, color: Colors.blue,),
            SizedBox(width: 10,),
            Text('Notification Note')
          ],
        ),)
      ],
    );
  }

  static Widget getCustomProgressDialog(String title) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: mainColor),
            SizedBox(height: 15),
            Text(title, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
