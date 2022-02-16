import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taeancomplaints/pages/map_select_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      title: '태안 비행 민원 알림',
      home: MapSelectPage(),
    );
  }
}
