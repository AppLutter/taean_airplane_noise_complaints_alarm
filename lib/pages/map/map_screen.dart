import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taeancomplaints/services/location_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:taeancomplaints/data/static.dart';
import 'package:firebase_core/firebase_core.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng currentLocation = _initialCameraPosition2.target;

  bool _visible = false;
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => addValue());
  }

  void addValue() {
    setState(() {
      _counter++;
    });
  }

  static final CameraPosition _initialCameraPosition2 = CameraPosition(
    target: LatLng(
      36.8198,
      126.1630,
    ),
    zoom: 10.0,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('taean_data').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          markers.clear();
          for (var doc in snapshot.data!.docs) {
            if (doc['minute'] == DateFormat('mm').format(DateTime.now())) {
              Marker newMarker = Marker(
                markerId: MarkerId(Random().nextInt(50000).toString()),
                icon: BitmapDescriptor.defaultMarker,
                // icon: _locationIcon,
                position: LatLng(
                  double.parse(doc['lat']),
                  double.parse(doc['lon']),
                ),
                infoWindow: InfoWindow(
                  title: doc['address'],
                  snippet: "${doc['time']} 발생",
                ),
              );
              markers.add(newMarker);
            }
          }
        }

        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('민원 지역'),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                initialCameraPosition: _initialCameraPosition2,
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
                onCameraMove: (e) => currentLocation = e.target,
                markers: markers,
              ),
              Visibility(
                visible: _visible,
                child: AbsorbPointer(
                  absorbing: true,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.airplanemode_active,
                        color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      primary: Colors.red, // <-- Button color
                    ),
                  ),
                ),
              )
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'view_btn1',
                  onPressed: () => _getMyLocation(),
                  child: const Icon(Icons.gps_fixed),
                ),
                const SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  heroTag: 'view_btn2',
                  onPressed: () {
                    setState(() {
                      _visible = _visible ? false : true;
                    });
                  },
                  child: const Icon(Icons.airplanemode_active),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getMyLocation() async {
    LocationData _myLocation = await LocationService().getLocation();
    _animateCamera(
      LatLng(
        _myLocation.latitude!,
        _myLocation.longitude!,
      ),
    );
  }

  Future<void> _animateCamera(LatLng _location) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition _cameraPosition = CameraPosition(
      target: _location,
      zoom: 10.50,
    );
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        _cameraPosition,
      ),
    );
  }
}

Future<void> _getMarker() async {
  FirebaseFirestore.instance
      .collection('taean_data')
      .get()
      .then((QuerySnapshot querySnapshot) {
    for (var doc in querySnapshot.docs) {
      if (doc['date'] == DateFormat('yyyy.MM.dd').format(DateTime.now())) {
        Marker newMarker = Marker(
          markerId: MarkerId(Random().nextInt(500).toString()),
          icon: BitmapDescriptor.defaultMarker,
          // icon: _locationIcon,
          position: LatLng(
            double.parse(doc['lat']),
            double.parse(doc['lon']),
          ),
          infoWindow: InfoWindow(
            title: doc['address'],
            snippet: "${doc['time']} 발생",
          ),
        );
        markers.add(newMarker);
      }
    }
  });
}
