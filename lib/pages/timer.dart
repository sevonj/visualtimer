import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualtimer/main.dart';
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
    switch (TimerApp.timerModeNotifier.value) {
      case TimerMode.minutes:
        return _counter.toDouble() - _timer.elapsed.inMilliseconds / 60 / 1000;
      case TimerMode.seconds:
        return _counter.toDouble() - _timer.elapsed.inMilliseconds / 1000;
    }
  }

  void _vibrate() async {
    if (!await Vibrate.canVibrate) return;
    if (!TimerApp.vibrateNotifier.value) return;
    Vibrate.vibrate();
  }

  void _setMode(TimerMode mode) async {
    TimerApp.timerModeNotifier.value = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("timerMode", mode.toString());
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
    double size = clampDouble(
        min(screenWidth * .9, screenHeight * .7 - 64), 230, double.infinity);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: _menuButton(),
      body: Center(
        child: SizedBox(
          // Height limit to keep the stuff centered.
          // Height = ring size + approx. everything else.
          height: size + 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 8),
              _timerRing(size: size),
              _timerOptions(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timerRing({required double size}) {
    return Expanded(
      //width: size,
      child: Center(
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: _timer.isRunning
                    ? "${_getTimeLeft().toInt()} ${TimerApp.timerModeNotifier.value == TimerMode.minutes ? "minutes" : "seconds"} left."
                    : "Timer set to $_counter ${TimerApp.timerModeNotifier.value == TimerMode.minutes ? "minutes" : "seconds"}.",
                child: CustomPaint(
                  foregroundPainter: TimerPainter(
                    minutes:
                        _timer.isRunning ? _getTimeLeft() : _counter.toDouble(),
                    colorScheme: Theme.of(context).colorScheme,
                  ),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    _timer.isRunning ? Icons.stop : Icons.play_arrow,
                    size: size * .315,
                    semanticLabel: _timer.isRunning ? "Stop" : "Start timer",
                  ),
                  onPressed: _counter <= 0 ? null : () => _togglePlay(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerOptions() {
    return SizedBox(
      width: 400,
      child: AnimatedSize(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 200),
        child: Visibility(
          visible: !_timer.isRunning,
          child: Column(children: [
            const SizedBox(height: 16),
            _timeSetter(),
            const SizedBox(height: 16),
            _modeSetter(),
          ]),
        ),
      ),
    );
  }

  Widget? _menuButton() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _timer.isRunning
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
              child: const Icon(
                Icons.menu,
                semanticLabel: "Preferences",
              ),
            ),
          );
  }

  Widget _timeSetter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.remove,
            semanticLabel: "Subtract 5",
          ),
          onPressed: _counter <= 0 ? null : () => _decrementTime(),
        ),
        Text(
          '${_timer.isRunning ? _getTimeLeft().toInt() : _counter}',
          style: Theme.of(context).textTheme.headlineLarge,
          semanticsLabel:
              "Timer set to $_counter ${TimerApp.timerModeNotifier.value == TimerMode.minutes ? "minutes" : "seconds"}",
        ),
        IconButton(
          icon: const Icon(
            Icons.add,
            semanticLabel: "Add 5",
          ),
          onPressed: _counter >= 60 ? null : () => _incrementTime(),
        ),
      ],
    );
  }

  Widget _modeSetter() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return CupertinoSlidingSegmentedControl(
      backgroundColor: colorScheme.surface,
      thumbColor: colorScheme.surfaceVariant,
      groupValue: TimerApp.timerModeNotifier.value,
      onValueChanged: (TimerMode? value) {
        setState(() {
          if (value != null) _setMode(value);
        });
      },
      children: const <TimerMode, Widget>{
        TimerMode.seconds: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Seconds',
              textScaler: TextScaler.linear(1.2),
              semanticsLabel: "Set mode: Seconds"),
        ),
        TimerMode.minutes: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Minutes',
              textScaler: TextScaler.linear(1.2),
              semanticsLabel: "Set mode: Minutes"),
        ),
      },
    );
  }
}
