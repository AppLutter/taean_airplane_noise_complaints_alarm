import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';

import 'package:taeancomplaints/data/constants_and_statics.dart';
import 'package:taeancomplaints/pages/time_pick.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

String chooseDate = ' ';
String timeChoose = ' ';

class ComplaintsAnalysis extends StatefulWidget {
  @override
  _ComplaintsAnalysisState createState() => _ComplaintsAnalysisState();
}

class _ComplaintsAnalysisState extends State<ComplaintsAnalysis> {
  late FirebaseMessaging messaging;
  TextEditingController timeController = TextEditingController();
  String? loadDataString = ' ';

  final formKey = GlobalKey<FormState>();

  int jan = 0;
  int feb = 0;
  int mar = 0;
  int apr = 0;
  int may = 0;
  int jun = 0;
  int jul = 0;
  int aug = 0;
  int sep = 0;
  int oct = 0;
  int nov = 0;
  int dec = 0;
  int monthSum = 0;
  int weekSum = 0;

  int mon = 0;
  int tue = 0;
  int wed = 0;
  int thu = 0;
  int fri = 0;
  int sat = 0;
  int sun = 0;

  int nine = 0;
  int oneZe = 0;
  int oneOn = 0;
  int oneTw = 0;
  int oneTh = 0;
  int oneFo = 0;
  int oneFi = 0;
  int oneSi = 0;
  int oneSe = 0;
  int hourSum = 0;

  int yearOneEi = 0;
  int yearOneNi = 0;
  int yearTwoZe = 0;
  int yearTwoOn = 0;
  int yearTwoTw = 0;

  String timeAdjust() {
    if (timeController.text.length == 1) {
      return '0${timeController.text}';
    } else {
      return timeController.text;
    }
  }

  int yearChoose() {
    if (mainDropdownValue == '2018') {
      return yearOneEi;
    } else if (mainDropdownValue == '2019') {
      return yearOneNi;
    }
    if (mainDropdownValue == '2020') {
      return yearTwoZe;
    }
    if (mainDropdownValue == '2021') {
      return yearTwoOn;
    } else {
      return yearTwoTw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('taean_data').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        allDataClear();

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        } else {
          for (var doc in snapshot.data!.docs) {
            yearCal(doc);
            monthCal(doc);
            dayCal(doc);
            hourCal(doc);
            yearChoose();
            addAddressList.add(doc['address']);
            addDateList.add(doc['date']);
            addTimeList.add(doc['time']);
            addLatList.add(doc['lat']);
            addLngList.add(doc['lon']);
          }
        }
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        context: context,
                        backgroundColor: const Color(0xFFACFFEF),
                        builder: (context) {
                          return ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading:
                                    const Icon(Icons.text_snippet_outlined),
                                title: Text(
                                  addAddressList[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                    '${addDateList[index]} / ${addTimeList[index]}'),
                                trailing: GestureDetector(
                                    onTap: () {
                                      FirebaseFirestore.instance
                                          .collection('taean_data')
                                          .where('date',
                                              isEqualTo: addDateList[index])
                                          .where('time',
                                              isEqualTo: addTimeList[index])
                                          .where('lat',
                                              isEqualTo: addLatList[index])
                                          .where('lon',
                                              isEqualTo: addLngList[index])
                                          .get()
                                          .then((value) {
                                        addDateList.removeAt(index);
                                        addTimeList.removeAt(index);
                                        addLatList.removeAt(index);
                                        addLngList.removeAt(index);

                                        for (var element in value.docs) {
                                          FirebaseFirestore.instance
                                              .collection("taean_data")
                                              .doc(element.id)
                                              .delete();
                                        }
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Icon(Icons.remove)),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                            itemCount: yearChoose(), //연도에 맞게 쌓인 데이터 수
                          );
                        });
                  },
                  child: const Text(
                    '삭제',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: () {
                    setState(() {
                      timeController.clear();
                      addAddressResult = ' ';
                      chooseDate = ' ';
                    });

                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                const Text(
                                  '주소 검색',
                                  style: TextStyle(
                                    fontSize: 35.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                GestureDetector(
                                  onTap: showSearchDialog,
                                  child: Container(
                                    color: Colors.greenAccent,
                                    width: 350,
                                    height: 60,
                                    child: const Center(
                                      child: Text(
                                        '주소(터치 시 검색)',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  addAddressResult,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Divider(
                                    height: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TimePick(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: Colors.greenAccent,
                                    width: 350,
                                    height: 60,
                                    child: const Center(
                                      child: Text(
                                        '날짜 및 시간(터치 시 검색)',
                                        style: TextStyle(
                                            backgroundColor: Colors.greenAccent,
                                            color: Colors.black,
                                            fontSize: 30.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  chooseDate,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 20.0),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Divider(
                                    height: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  color: Colors.greenAccent,
                                  width: 350,
                                  height: 60,
                                  child: const Center(
                                    child: Text(
                                      '시각 (단위 : 24시간)',
                                      style: TextStyle(
                                          backgroundColor: Colors.greenAccent,
                                          color: Colors.black,
                                          fontSize: 30.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                TextField(
                                  textAlign: TextAlign.center,
                                  controller: timeController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection('taean_data')
                                        .add(
                                      {
                                        'address': addAddressResult,
                                        'lat': addLat,
                                        'lon': addLng,
                                        'time': '${timeAdjust()}시 00분',
                                        'year': currentDate.year.toString(),
                                        'month': currentDate.month.toString(),
                                        'day': dayAdjust(),
                                        'hour': timeAdjust(),
                                        'date': DateFormat('yyyy-MM-dd')
                                            .format(currentDate),
                                        'weekday': DateFormat('EE')
                                            .format(currentDate),
                                      },
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    '저장하기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: const Text(
                    '추가',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              backgroundColor: Colors.indigo,
              centerTitle: true,
              title: const Text(
                '분석 페이지',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 25),
                    alignment: Alignment.centerRight,
                    child: DropdownButton(
                      value: mainDropdownValue,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          mainDropdownValue = newValue;
                        });
                      },
                      style: const TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      items: <String>['2018', '2019', '2020', '2021', '2022']
                          .map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            child: Text('$value년'),
                            value: value,
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                      child: const Text(
                        '월 별 발생 현황  (단위 : 건)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                  Text('평균 ${(monthSum / 12).toStringAsFixed(1)}건'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          monthGraph(
                              monthNum: 1, count: jan, color: Colors.blue),
                          monthGraph(
                              monthNum: 2, count: feb, color: Colors.blue),
                          monthGraph(
                              monthNum: 3, count: mar, color: Colors.blue),
                          monthGraph(
                              monthNum: 4, count: apr, color: Colors.blue),
                          monthGraph(
                              monthNum: 5, count: may, color: Colors.blue),
                          monthGraph(
                              monthNum: 6, count: jun, color: Colors.blue),
                          monthGraph(
                              monthNum: 7, count: jul, color: Colors.blue),
                          monthGraph(
                              monthNum: 8, count: aug, color: Colors.blue),
                          monthGraph(
                              monthNum: 9, count: sep, color: Colors.blue),
                          monthGraph(
                              monthNum: 10, count: oct, color: Colors.blue),
                          monthGraph(
                              monthNum: 11, count: nov, color: Colors.blue),
                          monthGraph(
                              monthNum: 12, count: dec, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2.0,
                    color: Colors.indigo,
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                      child: const Text(
                        '요일 별 발생 현황',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          weekGraph(
                              day: '월', count: mon, color: Colors.greenAccent),
                          weekGraph(
                              day: '화', count: tue, color: Colors.greenAccent),
                          weekGraph(
                              day: '수', count: wed, color: Colors.greenAccent),
                          weekGraph(
                              day: '목', count: thu, color: Colors.greenAccent),
                          weekGraph(
                              day: '금', count: fri, color: Colors.greenAccent),
                          weekGraph(
                              day: '토', count: sat, color: Colors.greenAccent),
                          weekGraph(
                              day: '일', count: sun, color: Colors.greenAccent),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2.0,
                    color: Colors.indigo,
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                      child: const Text(
                        '시간 별 발생 현황',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        hourGraph(hour: 9, count: nine, color: Colors.orange),
                        hourGraph(hour: 10, count: oneZe, color: Colors.orange),
                        hourGraph(hour: 11, count: oneOn, color: Colors.orange),
                        hourGraph(hour: 12, count: oneTw, color: Colors.orange),
                        hourGraph(hour: 13, count: oneTh, color: Colors.orange),
                        hourGraph(hour: 14, count: oneFo, color: Colors.orange),
                        hourGraph(hour: 15, count: oneFi, color: Colors.orange),
                        hourGraph(hour: 16, count: oneSi, color: Colors.orange),
                        hourGraph(hour: 17, count: oneSe, color: Colors.orange),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void allDataClear() {
    jan = 0;
    feb = 0;
    mar = 0;
    apr = 0;
    may = 0;
    jun = 0;
    jul = 0;
    aug = 0;
    sep = 0;
    oct = 0;
    nov = 0;
    dec = 0;
    dec = 0;
    monthSum = 0;

    mon = 0;
    tue = 0;
    wed = 0;
    thu = 0;
    fri = 0;
    sat = 0;
    sun = 0;
    weekSum = 0;

    nine = 0;
    oneZe = 0;
    oneOn = 0;
    oneTw = 0;
    oneTh = 0;
    oneFo = 0;
    oneFi = 0;
    oneSi = 0;
    oneSe = 0;
    hourSum = 0;

    yearOneEi = 0;
    yearOneNi = 0;
    yearTwoZe = 0;
    yearTwoOn = 0;
    yearTwoTw = 0;

    addAddressList.clear();
    addDateList.clear();
    addTimeList.clear();
    addLatList.clear();
    addLngList.clear();
  }

  void hourCal(QueryDocumentSnapshot<Object?> doc) {
    if (mainDropdownValue == doc['year']) {
      if ('9' == doc['hour']) {
        nine++;
        hourSum++;
      } else if ('10' == doc['hour']) {
        oneZe++;
        hourSum++;
      } else if ('11' == doc['hour']) {
        oneOn++;
        hourSum++;
      } else if ('12' == doc['hour']) {
        oneTw++;
        hourSum++;
      } else if ('13' == doc['hour']) {
        oneTh++;
        hourSum++;
      } else if ('14' == doc['hour']) {
        oneFo++;
        hourSum++;
      } else if ('15' == doc['hour']) {
        oneFi++;
        hourSum++;
      } else if ('16' == doc['hour']) {
        oneSi++;
        hourSum++;
      } else if ('17' == doc['hour']) {
        oneSe++;
        hourSum++;
      }
    }
  }

  void dayCal(QueryDocumentSnapshot<Object?> doc) {
    if (mainDropdownValue == doc['year']) {
      if ('Mon' == doc['weekday']) {
        mon++;
        weekSum++;
      } else if ('Tue' == doc['weekday']) {
        tue++;
        weekSum++;
      } else if ('Wed' == doc['weekday']) {
        wed++;
        weekSum++;
      } else if ('Thu' == doc['weekday']) {
        thu++;
        weekSum++;
      } else if ('Fri' == doc['weekday']) {
        fri++;
        weekSum++;
      } else if ('Sat' == doc['weekday']) {
        sat++;
        weekSum++;
      } else if ('Sun' == doc['weekday']) {
        sun++;
        weekSum++;
      }
    }
  }

  void monthCal(QueryDocumentSnapshot<Object?> doc) {
    if (mainDropdownValue == doc['year']) {
      if (1 == int.parse(doc['month'])) {
        jan++;
        monthSum++;
      } else if (2 == int.parse(doc['month'])) {
        feb++;
        monthSum++;
      } else if (3 == int.parse(doc['month'])) {
        mar++;
        monthSum++;
      } else if (4 == int.parse(doc['month'])) {
        apr++;
        monthSum++;
      } else if (5 == int.parse(doc['month'])) {
        may++;
        monthSum++;
      } else if (6 == int.parse(doc['month'])) {
        jun++;
        monthSum++;
      } else if (7 == int.parse(doc['month'])) {
        jul++;
        monthSum++;
      } else if (8 == int.parse(doc['month'])) {
        aug++;
        monthSum++;
      } else if (9 == int.parse(doc['month'])) {
        sep++;
        monthSum++;
      } else if (10 == int.parse(doc['month'])) {
        oct++;
        monthSum++;
      } else if (11 == int.parse(doc['month'])) {
        nov++;
        monthSum++;
      } else if (12 == int.parse(doc['month'])) {
        dec++;
        monthSum++;
      }
    }
  }

  void yearCal(QueryDocumentSnapshot<Object?> doc) {
    if ('2018' == doc['year']) {
      yearOneEi += 1;
    } else if ('2019' == doc['year']) {
      yearOneNi += 1;
    } else if ('2020' == doc['year']) {
      yearTwoZe += 1;
    } else if ('2021' == doc['year']) {
      yearTwoOn += 1;
    } else if ('2022' == doc['year']) {
      yearTwoTw += 1;
    }
  }

  renderTextFormField({
    @required String? label,
    @required FormFieldSetter? onSaved,
    @required FormFieldValidator? validator,
  }) {
    assert(onSaved != null);
    assert(validator != null);

    return Column(
      children: [
        Row(
          children: [
            Text(
              '$label',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        TextFormField(
          onSaved: onSaved,
          validator: validator,
        ),
        Container(
          height: 10.0,
        ),
      ],
    );
  }

  Future<void> showSearchDialog() async {
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
      // apiHeaders: await GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse addDetail =
        await _places.getDetailsByPlaceId(placeId, language: 'ko');
    setState(() {
      splitResult = addDetail.result.formattedAddress!.split(' ');
      addLat = addDetail.result.geometry!.location.lat.toStringAsFixed(6);
      addLng = addDetail.result.geometry!.location.lng.toStringAsFixed(6);
      processingResult = splitResult.sublist(2);
      addAddressResult = processingResult.join(' ');
    });
  }

  Widget monthGraph(
      {required int monthNum, required int count, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(count == 0 ? ' ' : '$count'),
        Container(
          width: 15.0,
          height: count * 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
              topLeft: Radius.circular(3),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text('$monthNum'),
      ],
    );
  }

  Widget weekGraph(
      {required String day, required int count, required Color color}) {
    weekSum == 0 ? weekSum = 1 : weekSum;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(count == 0
            ? ' '
            : '${((count / weekSum) * 100).toStringAsFixed(0)}%'),
        Container(
          width: 15.0,
          height: (count / weekSum) * 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
              topLeft: Radius.circular(3),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(day),
      ],
    );
  }

  Widget hourGraph(
      {required int hour, required int count, required Color color}) {
    hourSum == 0 ? hourSum = 1 : hourSum;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(count == 0
            ? ' '
            : '${((count / hourSum) * 100).toStringAsFixed(0)}%'),
        Container(
          width: 15.0,
          height: (count / hourSum) * 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
              topLeft: Radius.circular(3),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text('$hour'),
      ],
    );
  }
}
