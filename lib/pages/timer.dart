import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:visualtimer/pages/settings.dart';
import 'package:visualtimer/pages/timer/timer_ring.dart';
import 'package:visualtimer/util/platform.dart';

enum TimerMode { minutes, seconds }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  TimerMode _mode = TimerMode.minutes;
  int _counter = 0;
  Timer? _updateTimer;
  final Stopwatch _timer = Stopwatch();

  void _incrementTime() {
    setState(() {
      _counter += 5;
      _counter -= _counter % 5;
    });
  }

  void _decrementTime() {
    setState(() {
      _counter -= 1;
      _counter -= _counter % 5;
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
      _counter = minutes;
    });
  }

  void _togglePlay() {
    if (_timer.isRunning) {
      _stop((_getTimeLeft() + .5).toInt());
    } else {
      _start();
    }
  }

  double _getTimeLeft() {
    switch (_mode) {
      case TimerMode.minutes:
        return _counter.toDouble() - _timer.elapsed.inMilliseconds / 60 / 1000;
      case TimerMode.seconds:
        return _counter.toDouble() - _timer.elapsed.inMilliseconds / 1000;
    }
  }

  void _vibrate() async {
    if (!await Vibrate.canVibrate) return;

    Vibrate.vibrate();
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        // Time Out
        if (_timer.isRunning && _getTimeLeft() <= 0.0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Done!",
            textAlign: TextAlign.center,
          )));
          _stop(0);
          _vibrate();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double width = clampDouble(
        min(screenWidth * .9, screenHeight * .7 - 64), 230, double.infinity);

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
        child: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        foregroundPainter: TimerPainter(
                          minutes: _timer.isRunning
                              ? _getTimeLeft()
                              : _counter.toDouble(),
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                              _timer.isRunning ? Icons.stop : Icons.play_arrow,
                              size: width * .315),
                          onPressed: _counter <= 0 ? null : () => _togglePlay(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedSize(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 200),
                  child: Visibility(
                    visible: !_timer.isRunning,
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  _counter <= 0 ? null : () => _decrementTime(),
                            ),
                            Text(
                              '${_timer.isRunning ? _getTimeLeft().toInt() : _counter}',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _counter >= 60
                                  ? null
                                  : () => _incrementTime(),
                            ),
                          ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<TimerMode>(
                          segments: const [
                            ButtonSegment<TimerMode>(
                                value: TimerMode.seconds,
                                label: Text('Seconds', textScaleFactor: 1.2)),
                            ButtonSegment<TimerMode>(
                                value: TimerMode.minutes,
                                label: Text('Minutes', textScaleFactor: 1.2)),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (Set<TimerMode> newSelection) {
                            setState(() {
                              _mode = newSelection.first;
                            });
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
