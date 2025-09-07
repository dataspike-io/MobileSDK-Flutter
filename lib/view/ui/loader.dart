import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class Loader extends StatefulWidget {
  const Loader({
    super.key,
    this.size = 56,
    this.color,
    this.duration = const Duration(milliseconds: 900),
    this.alignment = Alignment.center,
  });

  final double size;
  final Color? color;
  final Duration duration;
  final Alignment alignment;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        'packages/dataspikemobilesdk/assets/images/loader.svg',
        width: widget.size,
        height: widget.size,
          alignment: widget.alignment,
          colorFilter: widget.color != null
              ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
              : null,
        ),
    );
  }
}