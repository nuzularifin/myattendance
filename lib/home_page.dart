import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/core/core_function.dart';
import 'package:flutter_attendance/presentation/attendance_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double myLatitude = 0;
  double myLongitude = 0;
  String address = "";
  bool isFindingLocation = false;

  GoogleMapController? _googleMapController;
  Marker? _myMarkerLocation;

  @override
  void initState() {
    super.initState();
  }

  void addMarkers(LatLng pos) async {
    String mapLocation =
        await CoreFunctions().getAddress(pos.latitude, pos.longitude);
    setState(() {
      _myMarkerLocation = Marker(
          markerId: MarkerId('mylocation'),
          infoWindow: InfoWindow(title: 'My Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          position: pos);
      myLatitude = pos.latitude;
      myLongitude = pos.longitude;
      address = mapLocation;
    });
  }

  dismissLoading() {
    setState(() {
      isFindingLocation = false;
    });
  }

  showLoading() {
    setState(() {
      isFindingLocation = true;
    });
  }

  getCurrentMyLocation() async {
    late Position position;
    try {
      showLoading();
      await CoreFunctions().determinePosition().then((value) {
        position = value;
      });
    } catch (e) {
      dismissLoading();
      return BotToast.showText(text: '${e.toString()}');
    }

    setState(() {
      myLatitude = position.latitude;
      myLongitude = position.longitude;

      _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.4)));
      addMarkers(LatLng(myLatitude, myLongitude));
      isFindingLocation = false;
    });

    String mapLocation =
        await CoreFunctions().getAddress(myLatitude, myLongitude);
    setState(() {
      address = mapLocation;
    });
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.2601012, 106.7675102),
                zoom: 14.4746,
              ),
              onTap: addMarkers,
              onMapCreated: (controller) {
                _googleMapController = controller;
              },
              markers: {if (_myMarkerLocation != null) _myMarkerLocation!},
            )),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'My Current Location',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  spacerVertical(4),
                  Text('Tap or Click on map to set your attendance',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  spacerVertical(12),
                  Text(
                    myLatitude != 0 && myLongitude != 0
                        ? address
                        : 'Empty Address',
                    textAlign: TextAlign.center,
                  ),
                  spacerVertical(8),
                  Text(
                    myLatitude != 0 && myLongitude != 0
                        ? '$myLatitude,  $myLongitude'
                        : '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                  spacerVertical(8),
                  !isFindingLocation
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                getCurrentMyLocation();
                              },
                              child: Text('Tag my Location')),
                        )
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator()),
                          ),
                        ),
                  spacerVertical(8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          if (myLatitude != 0 && myLongitude != 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AttendancePage(
                                          masterLatitude: myLatitude,
                                          masterLongitude: myLongitude,
                                        )));
                          } else {
                            BotToast.showText(text: 'Pin your location first');
                          }
                        },
                        child: Text('Added Attendance')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

Widget spacerVertical(double height) {
  return SizedBox(
    height: height,
  );
}
