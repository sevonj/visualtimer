import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visualtimer/pages/timer/timerPaint.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _minutes = 0;
  Timer? _update_timer;
  Stopwatch _timer = Stopwatch();

  double _size = 200;
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
      _timer.start();
    });
  }

  void _stop(int minutes) {
    setState(() {
      _update_timer = null;

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
    _update_timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if (_timer.isRunning && _timeLeft() <= 0.0) {
          _stop(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: _size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    height: _size * 1.2,
                    width: _size,
                    child: CustomPaint(
                      foregroundPainter: TimerPainter(
                        minutes: _timer.isRunning
                            ? _timeLeft()
                            : _minutes.toDouble(),
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _size * 1.2,
                    width: _size,
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                            _timer.isRunning ? Icons.stop : Icons.play_arrow,
                            size: _size * .315),
                        onPressed: _minutes <= 0 ? null : () => _togglePlay(),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: _timer.isRunning ? 0 : _size / 3,
                  child: Visibility(
                    visible: !_timer.isRunning,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.remove, size: _size / 4),
                            onPressed:
                                _minutes <= 0 ? null : () => _decrementTime(),
                          ),
                          Text(
                            '${_timer.isRunning ? _timeLeft().toInt() : _minutes}',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: _size / 4),
                            onPressed:
                                _minutes >= 60 ? null : () => _incrementTime(),
                          ),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
