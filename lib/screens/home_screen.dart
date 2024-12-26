import 'package:flutter/material.dart';
import 'package:note_app/utils/my_common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isShowSearchBar = false;

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
            : const Text('Home', style: MyCommon.appBarTitleStyle),
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
    );
  }
}
