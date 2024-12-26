import '../models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirebase {
  Future<List<Note>> getNotes() async {
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

  Future<void> addNote(Note note) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(note.title)
        .set(note.toMap());
  }
}
