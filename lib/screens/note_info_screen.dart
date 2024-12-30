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

class NoteInfoScreen extends StatefulWidget {
  const NoteInfoScreen({super.key});

  @override
  State<NoteInfoScreen> createState() => _NoteInfoScreenState();
}

class _NoteInfoScreenState extends State<NoteInfoScreen> {
  bool isInitialize = false;
  late bool allowEdit;
  late Note note;
  bool isFavorite = false;
  List<Widget> imageWidgets = [];
  List<String> imageLocalPaths = [];
  List<String> imageCloudinaryPaths = [];
  final descriptionController = TextEditingController();
  final tagController = TextEditingController();
  List<Map<String, dynamic>> descriptionChecklist = [];
  bool isSelectedChecklist = false;
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
  bool isEditted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    allowEdit = argument['allowEdit'];
    note = argument['note'];
    if (!isInitialize) {
      initNoteData();
      isInitialize = true;
    }
  }

  void initNoteData() {
    if (allowEdit) {
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

    isFavorite = note.isFavorite;

    if (note.imgs.isNotEmpty) {
      for (String imgUrl in note.imgs) {
        imageWidgets.add(buildItemImgWidget(imgUrl));
        imageCloudinaryPaths.add(imgUrl);
      }
    }

    descriptionController.text = note.description;
    tagController.text = note.tag;

    isSelectedChecklist = note.isCheckList;
    isNotify = note.isNotify;
    selectedColor = colorFromHex(note.color)!;
    selectedTag = note.tag;
    timeFormatted = note.createdDate;
    final format = DateFormat('HH:mm dd/MM/yyyy');
    scheduleDateTime = format.parse(timeFormatted);
    scheduleYear = scheduleDateTime.year;
    scheduleMonth = scheduleDateTime.month;
    scheduleDay = scheduleDateTime.day;
    scheduleHour = scheduleDateTime.hour;
    scheduleMinute = scheduleDateTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              await handleBackPressed();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: MyCommon.mainColor,
            )),
        title: Text(
          allowEdit ? 'Edit note' : 'Note info',
          style: MyCommon.appBarTitleStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (allowEdit) showColorPickerDialog();
            },
            icon: Icon(Icons.circle, color: selectedColor),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (allowEdit) isFavorite = !isFavorite;
              });
            },
            icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                color: Colors.red),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                if (allowEdit) isNotify = !isNotify;
              });

              if (isNotify) {
                final selectedNotificationTime = TimeOfDay.now();
                final pickedTime = await showTimePicker(
                    context: context, initialTime: selectedNotificationTime);
                if (pickedTime != null &&
                    pickedTime != selectedNotificationTime) {
                  handlePickedTime(pickedTime);
                  timeFormatted =
                      DateFormat('HH:mm dd/MM/yyyy').format(scheduleDateTime);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Set schedule notification at $timeFormatted successful!')));
                }
              }
            },
            icon: Icon(isNotify ? Icons.notifications_on : Icons.notifications,
                color: Colors.pink),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: _buildNoteInfoBody(),
    );
  }

  Widget _buildNoteInfoBody() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [..._buildDescriptionWidget(), _buildImageWidget()],
        ),
      ),
    );
  }

  List<Widget> _buildDescriptionWidget() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MyCommon.mainColor)),
        child: Text(note.title),
      ),
      const SizedBox(
        height: 20,
      ),
      _buildDropDownTagWidget(),
      const SizedBox(
        height: 10,
      ),
      allowEdit
          ? Row(
              children: [
                IconButton(
                  onPressed: () {
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
                  },
                  icon: Icon(isSelectedChecklist
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
                  color: MyCommon.mainColor,
                ),
                const Text('Set checklist style')
              ],
            )
          : const SizedBox(),
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
    return SizedBox(
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
    return allowEdit
        ? DropdownButtonFormField2<String>(
            style: MyCommon.fieldLabelStyle,
            decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: MyCommon.mainColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: MyCommon.mainColor))),
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
            })
        : TextFormField(
            enabled: false,
            controller: tagController,
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              labelStyle: MyCommon.fieldLabelStyle,
              border: MyCommon.fieldBorderStyle,
              focusedBorder: MyCommon.fieldBorderStyle,
            ),
          );
  }

  void handlePickedTime(TimeOfDay pickedTime) {
    final currentDateTime = DateTime.now();
    final currentTimeOfDay = TimeOfDay.now();
    final comparison = compareTimes(pickedTime, currentTimeOfDay);
    scheduleYear = currentDateTime.year;
    scheduleMonth = currentDateTime.month;
    scheduleDay =
        comparison < 0 ? currentDateTime.day + 1 : currentDateTime.day;
    scheduleHour = pickedTime.hour;
    scheduleMinute = pickedTime.minute;
    scheduleDateTime = DateTime(
        scheduleYear, scheduleMonth, scheduleDay, scheduleHour, scheduleMinute);
  }

  int compareTimes(TimeOfDay t1, TimeOfDay t2) {
    if (t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute)) {
      return -1;
    } else if (t1.hour > t2.hour ||
        (t1.hour == t2.hour && t1.minute > t2.minute)) {
      return 1;
    } else {
      return 0;
    }
  }

  void scheduleNotification() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'This is notification for ${note.title}',
          actionType: ActionType.Default,
          body:
              'Title: ${note.title}, description: ${descriptionController.text}',
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
    });
  }

  Widget buildItemImgWidget(String imgUrl) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: MyCommon.mainColor),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Image.network(imgUrl),
    );
  }

  Future<void> handleBackPressed() async {
    if (allowEdit && isEditedInfo()) {
      showDialog(
          context: context,
          builder: (context) =>
              MyCommon.getCustomProgressDialog('Editting note...'));

      scheduleNotification();

      for (String localPath in imageLocalPaths) {
        await uploadImgOnCloudinary(localPath);
      }

      await MyFirebase.editNote({
        'title': note.title,
        'description': descriptionController.text,
        'imgs': imageCloudinaryPaths,
        'createdDate': timeFormatted,
        'color': colorToHex(selectedColor),
        'tag': selectedTag,
        'isFavorite': isFavorite,
        'isCheckList': isSelectedChecklist,
        'isNotify': isNotify
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit new note successfully!')));
        Navigator.pop(context);
        Navigator.pop(context, 'isEdited');
      }
    } else {
      Navigator.pop(context);
    }
  }

  bool isEditedInfo() {
    return (selectedTag != note.tag ||
        isSelectedChecklist != note.isCheckList ||
        descriptionController.text != note.description ||
        imageCloudinaryPaths != note.imgs ||
        colorToHex(selectedColor) != note.color ||
        isFavorite != note.isFavorite ||
        isNotify != note.isNotify ||
        timeFormatted != note.createdDate);
  }
}
