import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taeancomplaints/pages/map/map_select_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '태안 비행 민원 알림',
      home: MapSelectPage(),
    );
  }
}
