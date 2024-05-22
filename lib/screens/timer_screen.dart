// ignore_for_file: library_private_types_in_public_api, unnecessary_null_compariso, unnecessary_null_comparison

import 'dart:async';

import 'package:clockify/data/theme_data.dart';
import 'package:flutter/material.dart';

import '../egg_overlay.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({ Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

enum EggType { soft, hard }

class _TimerScreenState extends State<TimerScreen> {
  late EggType eggType;
  Map<EggType, int> cookPeriod = {EggType.hard: 11, EggType.soft: 6};
  late int remainingTime;
  bool counting = false;
  late Timer timer;

  @override
  void initState() {
   
    super.initState();
    eggType = EggType.soft;
    _resetRemainingTime();
  }

  _resetRemainingTime() {
    setState(() {
      remainingTime = (cookPeriod[eggType]! * 60);
    });
  }

  _twoDigits(int n) {
    return n.toString().padLeft(2, "0");
  }

  _renderClock() {
    final duration = Duration(seconds: remainingTime);
    final minutes = _twoDigits(duration.inMinutes.remainder(60));
    final seconds = _twoDigits(duration.inSeconds.remainder(60));
    return Text(
      "$minutes:$seconds",
      style: const TextStyle(fontSize: 50.0, fontFamily: 'Square'),
    );
  }

  Widget _renderEggTypeSelect() {
    return Center(
      child: DropdownButton<EggType>(
          value: eggType,
          items: [EggType.hard, EggType.soft].map((e) {
            final txt = e == EggType.hard ? 'Hard Boiled' : 'Soft Boiled';
            return DropdownMenuItem<EggType>(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    txt,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ));
          }).toList(),
          onChanged: (value) {
            setState(() {
              eggType = value!;
              _cancelTimer();
              _resetRemainingTime();
            });
          }),
    );
  }

  _renderPlayIcon() {
    var icon = Icons.play_arrow;
    if (counting) {
      icon = Icons.stop;
    }
    return Icon(
      icon,
      size: 40.0,
    );
  }

  _cancelTimer() {
    if (timer != null) {
      timer.cancel();
      timer = Timer(const Duration(milliseconds: 500),() {
        
      },);
    }
    setState(() {
      counting = false;
    });
  }

  _tick() {
    setState(() {
      remainingTime -= 1;
      if (remainingTime <= 0) {
        _cancelTimer();
        _resetRemainingTime();
      }
    });
  }

  _startTimer() {
    if (counting) {
      _cancelTimer();
      _resetRemainingTime();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _tick();
      });
      setState(() {
        counting = true;
      });
    }
  }

  Widget _renderEggImage() {
    String imgPath = 'assets/images/hard_egg.png';
    if (eggType == EggType.hard) {
      imgPath = 'assets/images/soft_egg.png';
    }

    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = Color.fromARGB(
        80, primaryColor.red, primaryColor.green, primaryColor.blue);
    final totalTime = cookPeriod[eggType]! * 60;
    final percent = remainingTime / totalTime;

    return CustomPaint(
      foregroundPainter: EggOverlay(bgColor: bgColor, percent: percent),
      child: CircleAvatar(
        radius: 150.0,
        backgroundColor: Colors.white10,
        child: Image.asset(imgPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: CustomColors.pageBackgroundColor,

      floatingActionButton: FloatingActionButton(
        onPressed: _startTimer,
        child: _renderPlayIcon(),
      ),
      appBar: AppBar(
        title: const Text("Egg Timer"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _renderEggTypeSelect(),
            const SizedBox(
              height: 30.0,
            ),
            _renderClock(),
            const SizedBox(
              height: 30.0,
            ),
            _renderEggImage()
          ],
        ),
      ),
    );
  }
}
