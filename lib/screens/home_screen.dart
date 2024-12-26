import 'package:flutter/material.dart';
import 'package:note_app/utils/my_common.dart';

import '../firebase/my_firebase.dart';
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
          itemBuilder: (context, index) => Container(
            decoration: const BoxDecoration(border: MyCommon.itemGridBorder, borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notes[index].content),
                    Column(
                      children: [
                        Text(notes[index].title),
                        Text(notes[index].createdDate),
                      ],
                    )
                  ],
                ),
          )),
    );
  }

  Future<void> handleAddNote() async {
    // await MyFirebase.addNote(Note(
    //   title: 'Note 1',
    //   content: 'Content 1',
    //   img: '',
    //   createdDate: '01/01/2025',
    //   color: '',
    //   type: '',
    // ));
    // await MyFirebase.addNote(Note(
    //   title: 'Note 2',
    //   content: 'Content 2',
    //   img: '',
    //   createdDate: '01/01/2025',
    //   color: '',
    //   type: '',
    // ));
    // await fetchNotes();

    showDialog(context: context, builder:(context) => MyCommon.getSelectNoteTypesDialog((){}));
  }
}
