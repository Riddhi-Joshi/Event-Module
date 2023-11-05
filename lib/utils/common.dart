import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

InputDecoration inputDecoration(
  BuildContext context, {
  String? hint,
  String? label,
  TextStyle? hintStyle,
  TextStyle? labelStyle,
  Widget? prefix,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    contentPadding: contentPadding,
    labelText: label,
    hintText: hint,
    hintStyle: hintStyle ?? secondaryTextStyle(),
    labelStyle: labelStyle ?? secondaryTextStyle(),
    prefix: prefix,
    prefixIcon: prefixIcon,
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF1F1F1))),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    border: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
  );
}

Future<File?> getImageSource({bool isCamera = true}) async {
  final picker = ImagePicker();

  XFile? pickedImage;
  pickedImage = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);

  log('pickedImage--------------------- $pickedImage');

  return File(pickedImage!.path);
}
