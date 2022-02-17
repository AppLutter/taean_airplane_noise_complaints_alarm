import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class Constants {
  static const String apiKey = "AIzaSyC4-fUqKaZTLr2jomeIUcS1AdsghCRdnJA";
}

int currentBottomBarIndex = 0;
int markerVisible = 0;
Set<Marker> markers = {};
List<String?> splitResult = [];
List<String?> processingResult = [];
String addressResult = '';
String addAddressResult = '';
String addLat = '';
String addLng = '';
String? mainDropdownValue = '2021';
int itemCounts = 0;
List addAddressList = [];
List addDateList = [];
List addTimeList = [];
List addLatList = [];
List addLngList = [];
