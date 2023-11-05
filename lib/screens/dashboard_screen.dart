import 'package:events/main.dart';
import 'package:events/model/event_model.dart';
import 'package:events/screens/add_event_screen.dart';
import 'package:events/screens/event_detail_screen.dart';
import 'package:events/utils/sql_helper.dart';
import 'package:events/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<EventModel> eventList = [];

  Future<void> getEvents() async {
    appStore.setLoading(true);
    Iterable it = await SQLHelper.getItems();

    eventList.clear();

    eventList = it.map((e) => EventModel.fromJson(e)).toList();
    setState(() {});

    appStore.setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              const AddEventScreen().launch(context).then((value) {
                if (value ?? false) getEvents();
              });
            },
            icon: const Icon(Icons.add_circle_outline),
          )
        ],
      ),
      body: Stack(
        children: [
          if (eventList.isEmpty)
            Text('No Data', style: primaryTextStyle()).center()
          else
            ListView.builder(
              itemCount: eventList.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(16),
              itemBuilder: (ctx, index) {
                EventModel event = eventList[index];
                DateTime tempDate = new DateFormat("MM/dd/yyyy").parse(event.date.validate());

                log('tempDate ------ ${event.time.splitBefore(':')}');

                return InkWell(
                  onTap: () {
                    EventDetailScreen(event: event).launch(context).then((value) {
                      if (value ?? false) getEvents();
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: radius(32), border: Border.all(color: context.primaryColor)),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          child: Utility.imageFromBase64String(event.image.validate() ?? ""),
                          width: context.width() - 32,
                        ).cornerRadiusWithClipRRectOnly(topLeft: 32, topRight: 32),
                        10.height,
                        Text(event.title.validate()),
                        Container(
                          child: CountdownTimer(
                            endTime: DateTime(
                              tempDate.year,
                              tempDate.month,
                              tempDate.day,
                              event.time.splitBefore(':').toInt(),
                              event.time.splitAfter(':').toInt(),
                              00,
                            ).millisecondsSinceEpoch,
                            textStyle: boldTextStyle(),
                          ),
                        ),
                        10.height,
                      ],
                    ),
                  ),
                );
              },
            ),
          Observer(builder: (_) {
            return appStore.isLoading ? Loader() : Offstage();
          })
        ],
      ),
    );
  }
}
