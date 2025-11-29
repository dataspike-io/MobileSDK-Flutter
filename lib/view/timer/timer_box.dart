import 'dart:async';
import 'package:dataspikemobilesdk/dependencies_provider/dataspike_injector.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class TimeBox extends StatefulWidget {
  final bool isTitle;

  const TimeBox({
    super.key,
    this.isTitle = true,
  });

  @override
  State<TimeBox> createState() => _TimeLeftBoxState();
}

class _TimeLeftBoxState extends State<TimeBox> with WidgetsBindingObserver {
  late Duration _timeLeft;
  Timer? _timer;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final remaining = Duration(
      milliseconds: DataspikeInjector
          .component.verificationManager.millisecondsUntilVerificationExpired,
    );
    _timeLeft = remaining > Duration.zero ? remaining : Duration.zero;
    isActive = _timeLeft > Duration.zero;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > Duration.zero) {
        setState(() {
          _timeLeft -= const Duration(seconds: 1);
          isActive = true;
        });
      } else {
        timer.cancel();
        setState(() {
          _timeLeft = Duration.zero;
          isActive = false;
        });
      }
    });
  }

  void _recalculateFromManager() {
    final remaining = Duration(
      milliseconds: DataspikeInjector
          .component.verificationManager.millisecondsUntilVerificationExpired,
    );
    setState(() {
      _timeLeft = remaining > Duration.zero ? remaining : Duration.zero;
      isActive = _timeLeft > Duration.zero;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _recalculateFromManager();
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      'Session expires in ${_format(_timeLeft)}',
      style: TextStyle(
        color: widget.isTitle ? AppColors.darkIndigo : AppColors.royalPurple,
        fontFamily: 'Figtree',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        package: 'dataspikemobilesdk',
      ),
    );
  }
}
