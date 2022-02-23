import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/core/core_function.dart';
import 'package:flutter_attendance/data/model/attendace.dart';
import 'package:flutter_attendance/home_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DialogAddAttendance extends StatefulWidget {
  const DialogAddAttendance(
      {Key? key, this.masterLatitude, this.masterLongitude})
      : super(key: key);

  final masterLatitude;
  final masterLongitude;

  @override
  State<DialogAddAttendance> createState() => _DialogAddAttendanceState();
}

class _DialogAddAttendanceState extends State<DialogAddAttendance> {
  bool isLoading = false;

  checkingDistance(BuildContext context) async {
    showLoading();
    try {
      await CoreFunctions().determinePosition().then((position) {
        double distance = Geolocator.distanceBetween(widget.masterLatitude,
            widget.masterLongitude, position.latitude, position.longitude);

        if (distance > 50) {
          BotToast.showText(
              text:
                  'Your location now more than 50 M, Please make sure your location under 50 M');
          // print('Distance master with selected location => $distance');
        } else {
          // print('Distance master with selected location => $distance');
          Attendance attendance = Attendance(
              latitude: position.latitude,
              longitude: position.longitude,
              distance: distance.toStringAsFixed(2));
          Navigator.pop(context, attendance);
        }
        dismissLoading();
      });
    } catch (e) {
      dismissLoading();
      return BotToast.showText(text: e.toString());
    }
  }

  showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  dismissLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
              height: 250,
              width: 250,
              child: GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.masterLatitude,
                    widget.masterLongitude,
                  ),
                  zoom: 14.4746,
                ),
                onMapCreated: (controller) {
                  controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: LatLng(
                              widget.masterLatitude, widget.masterLongitude),
                          zoom: 14.4746)));
                },
                markers: {
                  Marker(
                      markerId: MarkerId('mylocation'),
                      infoWindow: InfoWindow(
                          title: 'Location',
                          snippet:
                              '${widget.masterLatitude} - ${widget.masterLongitude}'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueOrange),
                      position:
                          LatLng(widget.masterLatitude, widget.masterLongitude))
                },
              )),
          spacerVertical(12),
          !isLoading
              ? ElevatedButton(
                  onPressed: () {
                    checkingDistance(context);
                  },
                  child: const Text('Add Attendance'))
              : const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                )
        ]),
      ),
    );
  }
}
