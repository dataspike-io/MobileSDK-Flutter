import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class TimeBox extends StatefulWidget {
  final Duration initialTime;
  final VoidCallback? onFinish;
  final bool isTitle;

  const TimeBox({
    super.key,
    required this.initialTime,
    this.onFinish,
    this.isTitle = true,
  });

  @override
  State<TimeBox> createState() => _TimeLeftBoxState();
}

class _TimeLeftBoxState extends State<TimeBox> {
  late Duration _timeLeft;
  Timer? _timer;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTime;
    isActive = _timeLeft > Duration.zero;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > Duration.zero) {
        setState(() {
          _timeLeft -= const Duration(seconds: 1);
          isActive = true;
        });
      } else {
        timer.cancel();
        setState(() {
          isActive = false;
        });
        widget.onFinish?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Remaining time: ${_format(_timeLeft)}',
      style: TextStyle(
        color: widget.isTitle ? AppColors.darkIndigo : AppColors.royalPurple,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
