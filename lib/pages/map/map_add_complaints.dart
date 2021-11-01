import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taeancomplaints/data/constants.dart';
import 'package:taeancomplaints/Services/location_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taeancomplaints/data_model.dart';
import 'package:intl/intl.dart';
import 'package:taeancomplaints/data/static.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class MapAddComplaints extends StatefulWidget {
  @override
  _MapAddComplaintsState createState() => _MapAddComplaintsState();
}

class _MapAddComplaintsState extends State<MapAddComplaints> {
  Completer<GoogleMapController> _controller = Completer();

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

  bool _visible = true;
  bool isLoading = false;
  Map<String, DataModel> responseData = {};
  final database = FirebaseDatabase.instance.reference();
  int number = 0;

  static final CameraPosition _initialCameraPosition1 = CameraPosition(
    target: LatLng(36.5943, 126.2941),
    zoom: 10.0,
  );

  LatLng currentLocation = _initialCameraPosition1.target;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('taean_data').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          markers.clear(); //일단 데이터 변화가 있으면 마커 초기화

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
            backgroundColor: Colors.indigo,
            centerTitle: true,
            title: const Text(
              '민원 지역 검색',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: _showSearchDialog,
                icon: const Icon(Icons.search),
              )
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: GoogleMap(
                  initialCameraPosition: _initialCameraPosition1,
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  onCameraMove: (e) => currentLocation = e.target,
                  markers: markers,
                ),
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
                  heroTag: 'setup_btn1',
                  onPressed: () {
                    _setMarker();
                  },
                  child: const Icon(Icons.location_on),
                ),
                const SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  heroTag: 'setup_btn2',
                  onPressed: () => _getMyLocation(),
                  child: const Icon(Icons.gps_fixed),
                ),
                const SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  heroTag: 'setup_btn3',
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

  void _setMarker() {
    FirebaseFirestore.instance.collection('taean_data').add(
      {
        'address': addressResult,
        'lat': currentLocation.latitude.toStringAsFixed(6),
        'lon': currentLocation.longitude.toStringAsFixed(6),
        'time': DateFormat('kk시 mm분').format(DateTime.now()),
        'month': DateFormat('M').format(DateTime.now()),
        'day': DateFormat('d').format(DateTime.now()),
        'year': DateFormat('yy').format(DateTime.now()),
        'date': DateFormat('yyyy.MM.dd').format(DateTime.now()),
        'minute': DateFormat('mm').format(DateTime.now())
      },
    );

    FirebaseFirestore.instance
        .collection('taean_data')
        .get()
        .then((QuerySnapshot querySnapshot) {
      markers.clear();
      for (var doc in querySnapshot.docs) {
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
    });
  }

  Future<void> _showSearchDialog() async {
    var p = await PlacesAutocomplete.show(
        context: context,
        apiKey: Constants.apiKey,
        mode: Mode.fullscreen,
        language: "kr",
        region: "kr",
        offset: 0,
        hint: "여기에 입력하세요..",
        radius: 1000,
        types: [],
        strictbounds: false,
        components: [Component(Component.country, "kr")]);
    _getLocationFromPlaceId(p!.placeId!);
  }

  Future<void> _getLocationFromPlaceId(String placeId) async {
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: Constants.apiKey,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(placeId, language: 'ko');
    splitResult = detail.result.formattedAddress!.split(' ');
    processingResult = splitResult.sublist(2);
    addressResult = processingResult.join(' ');

    _animateCamera(LatLng(detail.result.geometry!.location.lat,
        detail.result.geometry!.location.lng));
  }

  Future<void> _getMyLocation() async {
    LocationData _myLocation = await LocationService().getLocation();
    _animateCamera(LatLng(_myLocation.latitude!, _myLocation.longitude!));
  }

  Future<void> _animateCamera(LatLng _location) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition _cameraPosition = CameraPosition(
      target: _location,
      zoom: 10.50,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }
}
