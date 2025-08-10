import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TimeBox extends StatefulWidget {
  final Duration initialTime;
  final VoidCallback? onFinish;

  const TimeBox({Key? key, required this.initialTime, this.onFinish})
    : super(key: key);

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightBlue : AppColors.lightRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'packages/dataspikemobilesdk/assets/images/timer.svg',
            height: 13.5,
            width: 13.5,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              isActive ? AppColors.accent : AppColors.red,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Time left:',
            style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.red,
              fontFamily: 'Mont',
              package: 'dataspikemobilesdk',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _format(_timeLeft),
            style: TextStyle(
              fontFamily: 'Mont',
              package: 'dataspikemobilesdk',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: isActive ? AppColors.accent : AppColors.red,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
