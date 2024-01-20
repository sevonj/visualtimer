import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visualtimer/pages/settings.dart';
import 'package:visualtimer/pages/timer/timer_ring.dart';
import 'package:visualtimer/util/platform.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _minutes = 0;
  Timer? _updateTimer;
  final Stopwatch _timer = Stopwatch();

  void _incrementTime() {
    setState(() {
      _minutes += 5;
      _minutes -= _minutes % 5;
    });
  }

  void _decrementTime() {
    setState(() {
      _minutes -= 1;
      _minutes -= _minutes % 5;
    });
  }

  void _start() {
    setState(() {
      if (PlatformUtility.type == PlatformType.mobile) {
        // Enable fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
      _timer.start();
    });
  }

  void _stop(int minutes) {
    setState(() {
      if (PlatformUtility.type == PlatformType.mobile) {
        // Disable fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      _updateTimer = null;

      _timer.stop();
      _timer.reset();
      _minutes = minutes;
    });
  }

  void _togglePlay() {
    if (_timer.isRunning) {
      _stop((_timeLeft() + .5).toInt());
    } else {
      _start();
    }
  }

  double _timeLeft() {
    return _minutes.toDouble() - _timer.elapsed.inMilliseconds / 60 / 1000;
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        // Time Out
        if (_timer.isRunning && _timeLeft() <= 0.0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Done!",
            textAlign: TextAlign.center,
          )));
          _stop(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double width = min(screenWidth * .9, screenHeight * .7);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: _timer.isRunning
          ? null
          : Container(
              margin: const EdgeInsets.only(top: 16),
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage())),
                foregroundColor: colorScheme.onSurfaceVariant,
                backgroundColor: colorScheme.surfaceVariant,
                child: const Icon(Icons.menu),
              ),
            ),
      body: Center(
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: .9,
                    child: CustomPaint(
                      foregroundPainter: TimerPainter(
                        minutes: _timer.isRunning
                            ? _timeLeft()
                            : _minutes.toDouble(),
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: .9,
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                            _timer.isRunning ? Icons.stop : Icons.play_arrow,
                            size: width * .315),
                        onPressed: _minutes <= 0 ? null : () => _togglePlay(),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: !_timer.isRunning,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              _minutes <= 0 ? null : () => _decrementTime(),
                        ),
                        Text(
                          '${_timer.isRunning ? _timeLeft().toInt() : _minutes}',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              _minutes >= 60 ? null : () => _incrementTime(),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
