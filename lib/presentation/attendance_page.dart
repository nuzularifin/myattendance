import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/data/model/attendace.dart';
import 'package:flutter_attendance/home_page.dart';
import 'package:flutter_attendance/presentation/components/dialog_add_attendance.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage(
      {Key? key, required this.masterLatitude, required this.masterLongitude})
      : super(key: key);
  final masterLatitude;
  final masterLongitude;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Attendance> attendanceList = [];

  openAddAttendance(context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return DialogAddAttendance(
              masterLatitude: widget.masterLatitude,
              masterLongitude: widget.masterLongitude);
        }).then((value) {
      Attendance selectedPosition = value;
      BotToast.showText(
          text:
              'selected location : ${selectedPosition.latitude} - ${selectedPosition.longitude}');
      setState(() {
        attendanceList.add(selectedPosition);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () => openAddAttendance(context),
              icon: Icon(Icons.add))
        ],
        title: const Text("My Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.all(0),
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'My current location :',
                          style: TextStyle(fontSize: 12),
                        ),
                        spacerVertical(4),
                        Text(
                          '${widget.masterLatitude} - ${widget.masterLongitude}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
            spacerVertical(12),
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            spacerVertical(12),
            attendanceList.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            attendanceList.isEmpty ? 0 : attendanceList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance ${index + 1}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              spacerVertical(4),
                              Text(
                                  'Location : ${attendanceList[index].latitude} - ${attendanceList[index].longitude}'),
                              spacerVertical(2),
                              Text(
                                  'Distance : ${attendanceList[index].distance} m'),
                              spacerVertical(6),
                              const Divider(),
                              spacerVertical(6),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: Text('Empty attendance'),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
