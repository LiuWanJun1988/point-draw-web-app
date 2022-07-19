import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:pointdraw/point_draw_models/utilities/fast_draw.dart';

Paint fillPaint = Paint()
  ..color = Colors.blue
  ..style = PaintingStyle.fill;

Paint strokePaint = Paint()
  ..color = Colors.white
  ..strokeWidth = 1.0
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

const Color white = Colors.white;
const Color red = Color.fromARGB(255, 255, 64, 64);
const Color yellow = Color.fromARGB(255, 255, 255, 64);
const Color green = Color.fromARGB(255, 64, 224, 128);
const Color blue = Color.fromARGB(255, 64, 96, 255);
const Color cyan = Color.fromARGB(255, 64, 255, 255);
const Color magenta = Color.fromARGB(255, 255, 64, 224);
const Color brown = Color.fromARGB(255, 160, 64, 64);

enum AnchorColor{red, green, blue, alpha}

class RectangularShadesPalette extends StatelessWidget {
  final double paletteWidth;
  final double paletteHeight;
  final Color initialColor;
  const RectangularShadesPalette(this.paletteWidth, this.paletteHeight, this.initialColor, {Key? key}) : super(key: key);

  TextPainter labelPainter(){
    TextStyle textStyle = const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.normal);
    TextPainter textPainter = TextPainter(
        text: TextSpan(style: textStyle, text: "Shades", onEnter: (event){

        }),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        strutStyle: StrutStyle.fromTextStyle(textStyle)
    );
    double maxWidth = 40;
    double minWidth = 30;
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }

  @override
  Widget build(BuildContext context) {
    TextPainter textPainter = labelPainter();
    return SizedBox(
      width: paletteWidth,
      height: paletteHeight,
      child: Material(
        shape: const ContinuousRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.zero,
        ),
        color: Colors.transparent,
        child: CustomPaint(
            painter: FastDraw(
              drawer: (Canvas canvas, Size size){
                Offset center = size.center(Offset.zero);
                Paint lineGradientPaint = Paint()
                  ..shader = ui.Gradient.linear(
                    Offset(center.dx, size.height * 0.95),
                    Offset(center.dx, size.height * 0.05),
                    [Colors.black, initialColor, Colors.white],
                    [0.0, 0.5, 1.0],
                    TileMode.clamp,
                  )
                  ..style = PaintingStyle.fill;
                canvas.drawRect(Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.9), lineGradientPaint);
                textPainter.paint(canvas, Offset(center.dx - 17, -5));
              },
              shouldRedraw: false,
            )
        ),
      ),
    );
  }
}

List<double> _colorRingStops = [0.0, 0.16667, 0.33333, 0.5, 0.66667, 0.83333, 1.0];

class CircularColorPalette extends StatelessWidget {
  final double paletteWidth;
  final double paletteHeight;
  final Color initialColor;
  const CircularColorPalette(this.paletteWidth, this.paletteHeight, this.initialColor,  {Key? key}) : super(key: key);

  TextPainter labelPainter(){
    TextStyle textStyle = const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w100, fontStyle: FontStyle.normal);
    TextPainter textPainter = TextPainter(
        text: TextSpan(style: textStyle, text: "Color wheel", onEnter: (event){

        }),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        strutStyle: StrutStyle.fromTextStyle(textStyle)
    );
    double maxWidth = 60;
    double minWidth = 55;
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: paletteWidth,
      height: paletteHeight,
      child: Material(
        shape: const ContinuousRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.zero,
        ),
        color: Colors.transparent,
        child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              double length = size.height;
              Offset center = (Offset.zero & Size(length, length)).center;
              Path colorRing;
              for(double i = 0; i < length; i += length / 100){
                colorRing = Path()
                  ..addOval(Rect.fromCenter(center: center, width: length - i, height: length - i));
                Color lerpRed = Color.lerp(red, white, i / length)!;
                Color lerpYellow = Color.lerp(yellow, white, i / length)!;
                Color lerpGreen = Color.lerp(green, white, i / length)!;
                Color lerpBlue = Color.lerp(blue, white, i / length)!;
                Color lerpCyan = Color.lerp(cyan, white, i / length)!;
                Color lerpMagenta = Color.lerp(magenta, white, i / length)!;
                Paint sweepGradientPaint = Paint()
                  ..shader = ui.Gradient.sweep(
                    center,
                    [lerpRed, lerpYellow, lerpGreen, lerpBlue, lerpCyan, lerpMagenta, lerpRed],
                    _colorRingStops,
                    TileMode.clamp,
                  )
                  ..style = PaintingStyle.fill;
                colorRing.fillType = PathFillType.evenOdd;
                canvas.drawPath(colorRing, sweepGradientPaint);
                labelPainter().paint(canvas, Offset.zero);
              }
            },
            shouldRedraw: false,
          )
        ),
      ),
    );
  }
}

Color? getColorFromPalette(double t, double s){
  if( t <= -0.66667 ){
    return Color.lerp(Color.lerp(blue, cyan, (t + 1) / 0.33333), white, s);
  } else if (t <= -0.33333){
    return Color.lerp(Color.lerp(cyan, magenta, (t + 0.66667) / 0.33333), white, s);
  } else if (t <= 0.0){
    return Color.lerp(Color.lerp(magenta, red, (t + 0.33333) / 0.33333), white, s);
  } else if (t <= 0.33333){
    return Color.lerp(Color.lerp(red, yellow, (t) / 0.33333), white, s);
  } else if (t <= 0.66667){
    return Color.lerp(Color.lerp(yellow, green, (t - 0.33333) / 0.33333), white, s);
  } else {
    return Color.lerp(Color.lerp(green, blue, (t - 0.66667) / 0.33333), white, s);
  }
}

Color? getGradientColor(Color initialColor, double t){
  if( t <= 0.5 ){
    return Color.lerp(Colors.white, initialColor, t * 2);
  } else {
    return Color.lerp(initialColor, Colors.black, (t - 0.5) * 2) ;
  }
}

class ThreeDimColorPalette extends StatelessWidget {
  final double paletteWidth;
  final double paletteHeight;
  final AnchorColor anchorColor;
  final int anchorColorValue;
  final int alpha;
  const ThreeDimColorPalette(this.paletteWidth, this.paletteHeight, this.anchorColor, this.anchorColorValue, this.alpha, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: paletteWidth,
      height: paletteHeight,
      child: Material(
        child: CustomPaint(
            painter: FastDraw(
              drawer: (Canvas canvas, Size size){
                switch(anchorColor){
                  case AnchorColor.red:
                    for(int i = 0; i < 256; i++){
                      Paint lineGradientPaint = Paint()
                        ..shader = ui.Gradient.linear(
                          Offset(0, i / 1),
                          Offset(255, i / 1),
                          [Color.fromARGB(alpha, anchorColorValue, i, 0), Color.fromARGB(alpha, anchorColorValue, i, 255)],
                          [0.0, 1.0],
                          TileMode.clamp,
                        )
                        ..style = PaintingStyle.fill;
                      canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, i / 1), width: size.width, height: 1), lineGradientPaint);
                    }
                    break;
                  case AnchorColor.green:
                    for(int i = 0; i < 256; i++){
                      Paint lineGradientPaint = Paint()
                        ..shader = ui.Gradient.linear(
                          Offset(20, i / 1),
                          Offset(275, i / 1),
                          [Color.fromARGB(alpha, i, anchorColorValue, 0), Color.fromARGB(alpha, i, anchorColorValue, 255)],
                          [0.0, 1.0],
                          TileMode.clamp,
                        )
                        ..style = PaintingStyle.fill;
                      canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, i / 1), width: size.width, height: 1), lineGradientPaint);
                    }
                    break;
                  case AnchorColor.blue:
                    for(int i = 0; i < 256; i++){
                      Paint lineGradientPaint = Paint()
                        ..shader = ui.Gradient.linear(
                          Offset(20, i / 1),
                          Offset(275, i / 1),
                          [Color.fromARGB(alpha, i, 0, anchorColorValue), Color.fromARGB(alpha, i, 255, anchorColorValue)],
                          [0.0, 1.0],
                          TileMode.clamp,
                        )
                        ..style = PaintingStyle.fill;
                      canvas.drawRect(Rect.fromCenter(center: Offset(size.width / 2, i / 1), width: size.width, height: 1), lineGradientPaint);
                    }
                    break;
                  default:
                    break;
                }
              },
              shouldRedraw: true,
            )
        ),
      ),
    );
  }
}

class AlphaBar extends StatelessWidget {
  final double barWidth;
  final double barHeight;
  final Color barTrackColor;
  const AlphaBar(this.barWidth, this.barHeight, this.barTrackColor, {Key? key}) : super(key: key);

  TextPainter labelPainter(){
    TextStyle textStyle = const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.normal);
    TextPainter textPainter = TextPainter(
        text: TextSpan(style: textStyle, text: "Alpha", onEnter: (event){

        }),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        strutStyle: StrutStyle.fromTextStyle(textStyle)
    );
    double maxWidth = 30;
    double minWidth = 25;
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }

  @override
  Widget build(BuildContext context) {
    Paint barTrackPaint = Paint()
      ..color = barTrackColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    TextPainter textPainter = labelPainter();
    return SizedBox(
      width: barWidth,
      height: barHeight,
      child: Material(
        shape: const ContinuousRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.zero,
        ),
        color: Colors.transparent,
        child: CustomPaint(
            painter: FastDraw(
              drawer: (Canvas canvas, Size size){
                Path bar = Path();
                bar.moveTo(0, size.height * 0.05);
                bar.lineTo(size.width, size.height * 0.05);
                bar.moveTo(size.width * 0.5, size.height * 0.05);
                bar.lineTo(size.width * 0.5, size.height * 0.95);
                bar.moveTo(0, size.height * 0.95);
                bar.lineTo(size.width, size.height * 0.95);
                canvas.drawPath(bar, barTrackPaint);
                textPainter.paint(canvas, Offset(size.width * 0.5 - 14, -5));
              },
              shouldRedraw: true,
            )
        ),
      ),
    );
  }
}


