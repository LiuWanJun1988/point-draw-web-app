import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FastDrawStatelessWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final void Function(Canvas, Size) drawer;
  final void Function(Canvas, Size)? frontDrawer;
  final Widget? child;

  const FastDrawStatelessWidget({required this.drawer, this.frontDrawer, this.width, this.height, this.constraints, this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      child: CustomPaint(
          foregroundPainter: frontDrawer != null ? FastDraw(
            drawer: frontDrawer!,
            shouldRedraw: true,
          ) : null,
          painter: FastDraw(
            drawer: drawer,
            shouldRedraw: true,
          ),
          child: child,
      ),
    );
  }
}

class FastDrawWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final void Function(Canvas, Size) drawer;
  final void Function(Canvas, Size)? frontDrawer;
  final bool shouldRedraw;
  const FastDrawWidget({required this.drawer, this.frontDrawer, this.width, this.height, this.constraints, this.shouldRedraw = false, Key? key}) : super(key: key);

  @override
  _FastDrawWidgetState createState() => _FastDrawWidgetState();
}

class _FastDrawWidgetState extends State<FastDrawWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      constraints: widget.constraints,
      child: CustomPaint(
        foregroundPainter: widget.frontDrawer != null ? FastDraw(
          drawer: widget.frontDrawer!,
          shouldRedraw: true,
        ) : null,
        painter: FastDraw(
          drawer: widget.drawer,
          shouldRedraw: widget.shouldRedraw,
        )
      ),
    );
  }
}


class FastDraw extends CustomPainter{
  final bool shouldRedraw;
  final void Function(Canvas, Size) drawer;
  final Map<String, dynamic>? args;
  const FastDraw({required this.drawer, required this.shouldRedraw, this.args});

  @override
  void paint(Canvas canvas, Size size){
    drawer(canvas, size);
  }

  @override
  bool shouldRepaint(old) => shouldRedraw;
}

