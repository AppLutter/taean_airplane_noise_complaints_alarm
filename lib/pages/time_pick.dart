import 'package:flutter/material.dart';
import 'package:taeancomplaints/pages/complaints_analysis.dart';

DateTime currentDate = DateTime.now();

String dayAdjust() {
  if (currentDate.day.toString().length == 1) {
    return '0${currentDate.day.toString()}';
  } else {
    return currentDate.day.toString();
  }
}

class TimePick extends StatefulWidget {
  @override
  _TimePickState createState() => _TimePickState();
}

class _TimePickState extends State<TimePick> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "날짜 선택",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              chooseDate,
              style: const TextStyle(fontSize: 30.0),
            ),
            const SizedBox(
              height: 40.0,
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text(
                '날짜 선택',
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, chooseDate),
              child: const Text(
                '선택 완료',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
        chooseDate =
            '${currentDate.year.toString()}-${currentDate.month.toString()}-${dayAdjust()}';
      });
    }
  }
}
