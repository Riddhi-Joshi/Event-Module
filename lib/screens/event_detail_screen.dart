import 'package:events/main.dart';
import 'package:events/model/event_model.dart';
import 'package:events/screens/add_event_screen.dart';
import 'package:events/utils/sql_helper.dart';
import 'package:events/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventModel event = EventModel();
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> getEvent() async {
    appStore.setLoading(true);
    Iterable it = await SQLHelper.getItem(event.id.validate());

    event = it.map((e) => EventModel.fromJson(e)).toList().first;
    setState(() {});

    appStore.setLoading(false);

    setState(() {});
  }

  void init() {
    event = widget.event;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DateTime tempDate = new DateFormat("MM/dd/yyyy").parse(event.date.validate());

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title.validate(), style: primaryTextStyle()),
        leading: BackButton(
          onPressed: () {
            finish(context, isChange);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              AddEventScreen(event: event).launch(context).then((value) {
                if (value ?? false) {
                  isChange = true;
                  getEvent();
                }
              });
            },
            icon: const Icon(Icons.edit),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Utility.imageFromBase64String(event.image.validate() ?? ""),
              width: context.width() - 32,
            ).cornerRadiusWithClipRRect(32),
            10.height,
            Text('Description:', style: primaryTextStyle()),
            Text(event.description.validate(), style: secondaryTextStyle()),
            16.height,
            if (event.isFeatured.validate() == 1)
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Text('Featured Event', style: primaryTextStyle()),
                ],
              ),
            10.height,
          ],
        ).paddingAll(16),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius()),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        child: CountdownTimer(
          endTime: DateTime(
            tempDate.year,
            tempDate.month,
            tempDate.day,
            event.time.splitBefore(':').toInt(),
            event.time.splitAfter(':').toInt(),
            00,
          ).millisecondsSinceEpoch,
          textStyle: boldTextStyle(color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
