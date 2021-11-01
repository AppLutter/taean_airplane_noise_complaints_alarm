import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taeancomplaints/pages/map/map_screen.dart';
import 'package:taeancomplaints/pages/map/map_add_complaints.dart';
import 'package:flutter_screen_lock/functions.dart';

class MapSelectPage extends StatefulWidget {
  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MapScreen(),
          MapAddComplaints(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            if (_currentIndex == 1) {
              setState(() {
                _currentIndex = index;
              });
            } else {
              screenLock(
                  context: context,
                  correctString: '1234',
                  cancelButton: const Text('취소'),
                  title: const Text('비밀번호를 입력하세요'),
                  didError: (int value) {
                    setState(() {
                      _currentIndex = 0;
                    });
                  });
            }
            setState(() {
              _currentIndex = index;
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: '지도 보기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            label: '민원 추가',
          ),
        ],
      ),
    );
  }
}
