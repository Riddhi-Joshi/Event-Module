import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

enum FileTypes { CANCEL, CAMERA, GALLERY }

class FilePickerDialog extends StatelessWidget {
  final bool isSelected;
  final bool showCameraVideo;

  FilePickerDialog({this.isSelected = false, this.showCameraVideo = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingItemWidget(
            title: 'Remove Image',
            titleTextStyle: primaryTextStyle(),
            leading: Icon(Icons.close, color: context.iconColor),
            onTap: () {
              finish(context, FileTypes.CANCEL);
            },
          ).visible(!isSelected),
          SettingItemWidget(
            title: 'Camera',
            titleTextStyle: primaryTextStyle(),
            leading: Icon(LineIcons.camera, color: context.iconColor),
            onTap: () {
              finish(context, FileTypes.CAMERA);
            },
          ),
          SettingItemWidget(
            title: 'Gallery',
            titleTextStyle: primaryTextStyle(),
            leading: Icon(LineIcons.image_1, color: context.iconColor),
            onTap: () {
              finish(context, FileTypes.GALLERY);
            },
          ),
        ],
      ),
    );
  }
}
