import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:note_app/screens/add_note_screen.dart';
import 'package:note_app/screens/note_info_screen.dart';
import 'package:note_app/utils/my_common.dart';

import '../firebase/my_firebase.dart';
import '../main.dart';
import '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isShowSearchBar = false;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: isShowSearchBar
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isShowSearchBar = false;
                  });
                },
                icon: const Icon(Icons.arrow_back_outlined),
                color: MyCommon.mainColor,
              )
            : null,
        title: isShowSearchBar
            ? const TextField(
                autofocus: true,
                cursorColor: MyCommon.mainColor,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.none)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.none)),
                    hintText: 'Find note...',
                    hintStyle: TextStyle(color: MyCommon.mainColor)),
              )
            : Text('Home ${notes.length.toString()}',
                style: MyCommon.appBarTitleStyle),
        backgroundColor: Colors.white,
        actions: [
          isShowSearchBar
              ? const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.close,
                    color: MyCommon.mainColor,
                  ))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isShowSearchBar = true;
                    });
                  },
                  icon: const Icon(Icons.search, color: MyCommon.mainColor))
        ],
      ),
      body: _buildNotesWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await handleAddNote();
        },
        backgroundColor: MyCommon.mainColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> fetchNotes() async {
    final result = await MyFirebase.getNotes();
    setState(() {
      notes = result;
    });
  }

  Widget _buildNotesWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: notes.length,
          itemBuilder: (context, index) => GestureDetector(
                onLongPress: () => handleItemGridLongPress(notes[index]),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: colorFromHex(notes[index].color),
                      border: MyCommon.itemGridBorder,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notes[index].description,  style: TextStyle(
                          color: colorFromHex(notes[index].color) ==
                              Colors.black
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold)),
                      Column(
                        children: [
                          Text(
                            notes[index].title,
                            style: TextStyle(
                                color: colorFromHex(notes[index].color) ==
                                        Colors.black
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(notes[index].createdDate,
                              style: TextStyle(
                                  color: colorFromHex(notes[index].color) ==
                                          Colors.black
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              )),
    );
  }

  Future<void> handleAddNote() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddNoteScreen()));
    if (result.toString() == 'isAdded') {
      await fetchNotes();
    }
  }

  void handleItemGridLongPress(Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Text('${note.title}'),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                handleEditNote(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.pop(context);
                await handleDeleteNote(note.title);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> handleEditNote(Note note) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (contex) => const NoteInfoScreen(), settings: RouteSettings(arguments: {
      'allowEdit': true,
      'note': note,
    })));

    if (result.toString() == 'isEdited') fetchNotes();
  }

  Future<void> handleDeleteNote(String noteTitle) async {
    final isRemoved = await MyFirebase.deleteNote(noteTitle);

    if (mounted) {
      if (isRemoved) {
        ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Remove successful')));
        fetchNotes();
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Remove failed')));
      }
    }
  }
}
