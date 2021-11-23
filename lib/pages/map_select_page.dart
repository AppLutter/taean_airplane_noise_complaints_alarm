import 'package:flutter/material.dart';
import 'package:taeancomplaints/pages/map_add_complaints.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:taeancomplaints/data/constants_and_statics.dart';
import 'package:taeancomplaints/pages/complaints_analysis.dart';

class MapSelectPage extends StatefulWidget {
  const MapSelectPage({Key? key}) : super(key: key);

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  int pageChoice() {
    if (currentBottomBarIndex == 0 || currentBottomBarIndex == 1) {
      return 0;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [
          MapAddComplaints(),
          ComplaintsAnalysis(),
        ],
        index: pageChoice(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1 || index == 2) {
            if (currentBottomBarIndex == 1 || currentBottomBarIndex == 2) {
              setState(() {
                currentBottomBarIndex = index;
              });
            } else {
              screenLock(
                  context: context,
                  correctString: '1234',
                  cancelButton: const Text('취소'),
                  title: const Text('비밀번호를 입력하세요'),
                  didError: (int value) {
                    setState(() {
                      currentBottomBarIndex = 0;
                    });
                  });
            }
            setState(() {
              currentBottomBarIndex = index;
            });
          } else {
            setState(() {
              currentBottomBarIndex = index;
            });
          }
        },
        currentIndex: currentBottomBarIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: '지도 보기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            label: '민원 추가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '민원 분석',
          ),
        ],
      ),
    );
  }
}
