import '../models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirebase {
  static Future<List<Note>> getNotes() async {
    final List<Note> result = [];

    await FirebaseFirestore.instance
        .collection('notes')
        .get()
        .then((snapshots) {
      for (var snapshot in snapshots.docs) {
        var data = snapshot.data();
        var note = Note.fromMap(data);
        result.add(note);
      }
    });

    return result;
  }

  static Future<void> addNote(Note note) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(note.title)
        .set(note.toMap());
  }

  static Future<bool> editNote(Map<String, dynamic> map) async {
    try{
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(map['title'])
          .set(map);
      return true;
    }catch(e){
      return false;
    }
  }

  static Future<bool> deleteNote(String noteTittle) async {
    try{
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(noteTittle)
          .delete();
      return true;
    }catch(e){
      return false;
    }
  }
}
