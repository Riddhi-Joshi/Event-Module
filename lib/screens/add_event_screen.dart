import 'dart:io';
import 'package:events/main.dart';
import 'package:events/model/event_model.dart';
import 'package:events/utils/common.dart';
import 'package:events/utils/file_picker_dialog_component.dart';
import 'package:events/utils/sql_helper.dart';
import 'package:events/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event;

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  String time = '';
  String hour = '';
  String minute = '';
  String eventImage = '';
  File? selectedImage;

  TextEditingController nameCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  TextEditingController dateCont = TextEditingController();
  TextEditingController timeCont = TextEditingController();

  bool isFeatured = false;

  FocusNode nameFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode imageFocus = FocusNode();
  FocusNode dateFocus = FocusNode();
  FocusNode timeFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      nameCont.text = widget.event!.title.validate();
      descriptionCont.text = widget.event!.description.validate();
      dateCont.text = widget.event!.date.validate();
      timeCont.text = widget.event!.time.validate();
      isFeatured = widget.event!.isFeatured.validate() != 0;
      eventImage = widget.event!.image.validate();
      setState(() {});
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, initialDatePickerMode: DatePickerMode.day, firstDate: DateTime(2015), lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        dateCont.text = DateFormat.yMd().format(selectedDate);
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;

        hour = selectedTime.hour.toString();
        minute = selectedTime.minute.toString();
        time = hour + ' : ' + minute;
        timeCont.text = time;
      });
  }

  Future<void> _addItem() async {
    EventModel event = EventModel(
      id: widget.event != null ? widget.event!.id : null,
      title: nameCont.text.trim(),
      date: dateCont.text,
      description: descriptionCont.text.trim(),
      isFeatured: isFeatured ? 1 : 0,
      time: timeCont.text,
      image: selectedImage != null
          ? Utility.base64String(await selectedImage!.readAsBytes())
          : eventImage.isNotEmpty
              ? eventImage
              : null,
      createdAt: widget.event != null ? widget.event!.createdAt : null,
    );

    if (widget.event != null) {
      await SQLHelper.updateItem(event);
    } else {
      await SQLHelper.createItem(event);
    }
    finish(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.event != null)
            IconButton(
              onPressed: () {
                showConfirmDialogCustom(
                  context,
                  onAccept: (c) async {
                    await SQLHelper.deleteItem(widget.event!.id.validate());
                    finish(context);
                    finish(context, true);
                  },
                  dialogType: DialogType.DELETE,
                  title: 'Are you sure, you want to delete this event?',
                  positiveText: 'Delete',
                );
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (eventImage.isEmpty && selectedImage == null)
              SizedBox(
                child: DottedBorderWidget(
                  radius: defaultAppButtonRadius,
                  dotsWidth: 8,
                  child: TextButton(
                    onPressed: () async {
                      if (!appStore.isLoading) {
                        FileTypes? file = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          title: Text('Choose an Action', style: boldTextStyle()),
                          builder: (p0) {
                            return FilePickerDialog(isSelected: true);
                          },
                        );

                        if (file != null) {
                          if (file == FileTypes.CANCEL) {
                            //
                          } else {
                            selectedImage = await getImageSource(isCamera: file == FileTypes.CAMERA ? true : false);
                            setState(() {});
                            appStore.setLoading(false);
                          }
                        }
                      }
                    },
                    child: Text(
                      '+ Add Event Image',
                      style: primaryTextStyle(color: context.primaryColor),
                    ).center(),
                  ),
                ).paddingAll(16),
                height: 200,
              )
            else
              SizedBox(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (eventImage.isNotEmpty && selectedImage == null)
                      SizedBox(
                        width: context.width() - 32,
                        child: Utility.imageFromBase64String(eventImage.validate() ?? ""),
                      ).cornerRadiusWithClipRRect(32)
                    else if (selectedImage != null)
                      Image.file(
                        File(selectedImage!.path.validate()),
                        width: context.width(),
                        height: 200,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(32),
                    Positioned(
                      right: 10,
                      bottom: 8,
                      child: GestureDetector(
                        onTap: () async {
                          FileTypes? file = await showInDialog(
                            context,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                            title: Text('Choose an Action', style: boldTextStyle()),
                            builder: (p0) {
                              return FilePickerDialog(isSelected: true);
                            },
                          );

                          if (file != null) {
                            if (file == FileTypes.CANCEL) {
                              selectedImage = null;
                              eventImage = '';
                            } else {
                              selectedImage = await getImageSource(isCamera: file == FileTypes.CAMERA ? true : false);
                              setState(() {});
                              appStore.setLoading(false);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(100)),
                          child: Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                height: 200,
              ).paddingAll(16),
            AppTextField(
              controller: nameCont,
              nextFocus: descriptionFocus,
              focus: nameFocus,
              textFieldType: TextFieldType.NAME,
              textStyle: boldTextStyle(),
              decoration: inputDecoration(
                context,
                label: 'Event Name',
                labelStyle: secondaryTextStyle(weight: FontWeight.w600),
              ),
            ).paddingSymmetric(horizontal: 16),
            AppTextField(
              controller: descriptionCont,
              nextFocus: dateFocus,
              focus: descriptionFocus,
              textFieldType: TextFieldType.MULTILINE,
              maxLines: 5,
              textStyle: boldTextStyle(),
              decoration: inputDecoration(
                context,
                label: 'Description',
                labelStyle: secondaryTextStyle(weight: FontWeight.w600),
              ),
            ).paddingSymmetric(horizontal: 16),
            AppTextField(
              controller: dateCont,
              nextFocus: timeFocus,
              focus: dateFocus,
              readOnly: true,
              textFieldType: TextFieldType.OTHER,
              textStyle: boldTextStyle(),
              decoration: inputDecoration(
                context,
                label: 'Date',
                labelStyle: secondaryTextStyle(weight: FontWeight.w600),
              ),
              onTap: () {
                _selectDate(context);
              },
            ).paddingSymmetric(horizontal: 16),
            AppTextField(
              controller: timeCont,
              focus: timeFocus,
              readOnly: true,
              textFieldType: TextFieldType.OTHER,
              textStyle: boldTextStyle(),
              decoration: inputDecoration(
                context,
                label: 'Time',
                labelStyle: secondaryTextStyle(weight: FontWeight.w600),
              ),
              onTap: () {
                _selectTime(context);
              },
            ).paddingSymmetric(horizontal: 16),
            16.height,
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(borderRadius: radius(2)),
                  activeColor: context.primaryColor,
                  value: isFeatured,
                  onChanged: (val) {
                    isFeatured = !isFeatured;
                    setState(() {});
                  },
                ),
                Text('Featured Event', style: secondaryTextStyle()).onTap(() {
                  isFeatured = !isFeatured;
                  setState(() {});
                }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppButton(
        shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius)),
        text: widget.event != null ? 'Update Event' : 'Add Event',
        textStyle: boldTextStyle(color: Colors.white),
        onTap: () {
          _addItem();
        },
        elevation: 0,
        color: context.primaryColor,
        width: context.width() - 32,
      ).paddingAll(16),
    );
  }
}
