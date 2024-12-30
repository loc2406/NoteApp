import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/firebase/my_firebase.dart';
import 'package:note_app/utils/my_common.dart';

import '../models/note.dart';
import '../utils/custom_checkbox_tile.dart';
import 'package:intl/intl.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  bool isFavorite = false;
  List<Widget> imageWidgets = [];
  List<String> imageLocalPaths = [];
  List<String> imageCloudinaryPaths = [];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<Map<String, dynamic>> descriptionChecklist = [];
  bool isSelectedChecklist = false;
  bool isShowNotification = false;
  bool isNotify = false;
  Color selectedColor = Colors.black;
  String selectedTag = 'None';
  int scheduleYear = 0;
  int scheduleMonth = 0;
  int scheduleDay = 0;
  int scheduleHour = 0;
  int scheduleMinute = 0;
  DateTime scheduleDateTime = DateTime(0);
  String timeFormatted = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageWidgets.add(DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      color: MyCommon.mainColor,
      strokeWidth: 1,
      child: Container(
        alignment: Alignment.center,
        child: IconButton(
            alignment: Alignment.center,
            onPressed: handleAddNewImage,
            icon: const Icon(
              Icons.cloud_upload_outlined,
              color: MyCommon.mainColor,
              size: 35,
            )),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty ||
                  descriptionController.text.isNotEmpty) {
                
                showDialog(context: context, builder: (context) => MyCommon.getCustomProgressDialog());

                scheduleNotification();
                
                for (String localPath in imageLocalPaths) {
                  await uploadImgOnCloudinary(localPath);
                }

                await MyFirebase.addNote(Note(
                    title: titleController.text,
                    description: descriptionController.text,
                    imgs: imageCloudinaryPaths,
                    createdDate: timeFormatted,
                    color: colorToHex(selectedColor),
                    tag: selectedTag,
                    isFavorite: isFavorite,
                    isCheckList: isSelectedChecklist,
                    isNotify: isNotify));

                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Add new note successfully!')));
                  Navigator.pop(context);
                  Navigator.pop(this.context, 'isAdded');
                }
              }else{
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: MyCommon.mainColor,
            )),
        title: const Text(
          'Add note',
          style: MyCommon.appBarTitleStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showColorPickerDialog();
            },
            icon: Icon(Icons.circle, color: selectedColor),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                color: Colors.red),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                isNotify = !isNotify;
              });

              if (isNotify){
                final selectedNotificationTime = TimeOfDay.now();
                final pickedTime = await showTimePicker(context: context, initialTime: selectedNotificationTime);
                if (pickedTime != null && pickedTime != selectedNotificationTime){
                  handlePickedTime(pickedTime);
                  timeFormatted = DateFormat('HH:mm dd/MM/yyyy').format(scheduleDateTime);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set schedule notification at $timeFormatted successful!')));
                }
              }

            },
            icon: Icon(
                isNotify ? Icons.notifications_on : Icons.notifications,
                color: Colors.pink),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: _buildAddNoteBody(),
    );
  }

  Widget _buildAddNoteBody() {
    return SingleChildScrollView(child: Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [..._buildDescriptionWidget(), _buildImageWidget()],
      ),
    ),);
  }

  List<Widget> _buildDescriptionWidget() {
    return [
      TextFormField(
        controller: titleController,
        cursorColor: Colors.black,
        decoration: const InputDecoration(
          label: Text('Title'),
          labelStyle: MyCommon.fieldLabelStyle,
          enabledBorder: MyCommon.fieldBorderStyle,
          focusedBorder: MyCommon.fieldBorderStyle,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      _buildDropDownTagWidget(),
      const SizedBox(
        height: 10,
      ),
      Row(
        children: [
          IconButton(onPressed: (){
            setState(() {
              if (!isSelectedChecklist) {
                descriptionChecklist = [];
                List<String> splitResult =
                descriptionController.text.toString().split('\n');
                for (var string in splitResult) {
                  descriptionChecklist
                      .add({'description': string, 'isChecked': false});
                }
              }
              isSelectedChecklist = !isSelectedChecklist;
            });
          }, icon: Icon(isSelectedChecklist ? Icons.radio_button_checked : Icons.radio_button_unchecked),  color: MyCommon.mainColor,),
          const Text('Show checklist style')
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      isSelectedChecklist
          ? Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: MyCommon.mainColor,
                ),
              ),
              child: ListView.builder(
                  itemCount: descriptionChecklist.length,
                  itemBuilder: (context, index) => CustomCheckboxListTile(
                        description: descriptionChecklist[index]['description'],
                        isChecked: descriptionChecklist[index]['isChecked'],
                        onChanged: (value) {
                          setState(() {
                            descriptionChecklist[index]['isChecked'] = value;
                          });
                        },
                        onSubmitted: () {
                          setState(() {
                            descriptionChecklist
                                .add({'description': '', 'isChecked': false});
                            debugPrint(descriptionChecklist.toString());
                          });
                        },
                      )))
          : TextFormField(
              maxLines: 6,
              controller: descriptionController,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                label: Text('Description'),
                labelStyle: MyCommon.fieldLabelStyle,
                enabledBorder: MyCommon.fieldBorderStyle,
                focusedBorder: MyCommon.fieldBorderStyle,
              ),
            ),
      const SizedBox(
        height: 20,
      ),
    ];
  }

  Widget _buildImageWidget() {
    return Container(
      height: 300,
      child: GridView.builder(
          itemCount: imageWidgets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 10, crossAxisSpacing: 10, crossAxisCount: 3),
          itemBuilder: (context, index) => imageWidgets[index]),
    );
  }

  Future<void> handleAddNewImage() async {
    final imageFile = await getImageFromGallery();

    if (imageFile != null) {
      final widget = Container(
        decoration: BoxDecoration(
            border: Border.all(color: MyCommon.mainColor),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Image.file(imageFile),
      );
      setState(() {
        imageWidgets.add(widget);
        imageLocalPaths.add(imageFile.path);
      });
    }
  }

  Future<File?> getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('ERROR ===== getImage(): $e');
    }
    return null;
  }

  Future<void> uploadImgOnCloudinary(String localPath) async {
    final cloudinary = Cloudinary.signedConfig(
      apiKey: '237291759617564',
      apiSecret: 'w3H3_xG5FLMGtuz8apla9eG2PcU',
      cloudName: 'toeiclearning',
    );

    final response = await cloudinary.upload(
      file: localPath,
      resourceType: CloudinaryResourceType.image,
    );

    if (response.isSuccessful) {
      imageCloudinaryPaths.add(response.url ?? '');
    } else {
      debugPrint('Error: ${response.error}');
    }
  }

  void showColorPickerDialog() {
    Color currentColor = selectedColor;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: IntrinsicHeight(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 25,
                ),
                ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    currentColor = color;
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedColor = currentColor;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Select color',
                    style: TextStyle(color: MyCommon.mainColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropDownTagWidget() {
    return DropdownButtonFormField2<String>(
        style: MyCommon.fieldLabelStyle,
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: MyCommon.mainColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: MyCommon.mainColor))
        ),
        value: selectedTag,
        items: const [
          DropdownMenuItem<String>(value: 'None', child: Text('None')),
          DropdownMenuItem<String>(value: 'Family', child: Text('Family')),
          DropdownMenuItem<String>(value: 'Work', child: Text('Work')),
          DropdownMenuItem<String>(value: 'Study', child: Text('Study')),
        ],
        onChanged: (value) {
          setState(() {
            selectedTag = value!;
          });
        });
  }

  void handlePickedTime(TimeOfDay pickedTime) {
    final currentDateTime =DateTime.now();
    final currentTimeOfDay =TimeOfDay.now();
    final comparison = compareTimes(pickedTime, currentTimeOfDay);
    scheduleYear = currentDateTime.year;
    scheduleMonth = currentDateTime.month;
    scheduleDay = comparison < 0 ? currentDateTime.day + 1 : currentDateTime.day;
    scheduleHour = pickedTime.hour;
    scheduleMinute = pickedTime.minute;
    scheduleDateTime = DateTime(scheduleYear, scheduleMonth, scheduleDay, scheduleHour, scheduleMinute);
  }

  int compareTimes(TimeOfDay t1, TimeOfDay t2) {
    if (t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute)) {
      return -1;
    } else if (t1.hour > t2.hour || (t1.hour == t2.hour && t1.minute > t2.minute)) {
      return 1;
    } else {
      return 0;
    }
  }

  void scheduleNotification(){
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }else{
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'This is notification for ${titleController.text}',
            actionType: ActionType.Default,
            body: 'Title: ${titleController.text}, description: ${descriptionController.text}',
          ),
          schedule: NotificationCalendar(
            year: scheduleYear,
            month: scheduleMonth,
            day: scheduleDay,
            hour: scheduleHour,
            minute: scheduleMinute,
            repeats: false,
          ),
        );
      }
    });
  }
}
