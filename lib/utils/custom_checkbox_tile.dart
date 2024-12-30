import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_app/utils/my_common.dart';

class CustomCheckboxListTile extends StatelessWidget {
  final String description;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback onSubmitted;

  const CustomCheckboxListTile({
    required this.description,
    required this.isChecked,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(description),
      leading: GestureDetector(
        onTap: () => onChanged(!isChecked),
        child: Container(
          width: 24,
          height: 24,
          child: Icon(isChecked ? Icons.check_circle : Icons.radio_button_unchecked, color: MyCommon.mainColor, size: 24),
        ),
      ),
    );
  }
}
