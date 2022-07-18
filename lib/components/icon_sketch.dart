import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:ui' as ui;

import 'package:pointdraw/point_draw_models/utilities/fast_draw.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart';

Paint objectPaint = Paint()
  ..color = Colors.white
  ..style = PaintingStyle.fill;

Paint fillPaint = Paint()
  ..color = Colors.white
  ..style = PaintingStyle.fill;

Paint strokePaint = Paint()
  ..color = Colors.white
  ..strokeWidth = 1.0
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

class CatmullRomCurveIcon extends StatelessWidget {
  final double? widthSize;
  const CatmullRomCurveIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 4.0;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
        painter: FastDraw(
          drawer: (canvas, size){
            Offset center = size.center(Offset.zero);
            Offset topRightCenter = Offset(size.width * 0.7, size.height * 0.25);
            Offset bottomLeftCenter = Offset(size.width * 0.25, size.height * 0.75);
            Offset controlPoint = center + Offset(size.width * 0.15, size.width * 0.15);
            Path curveArc = Path();
            curveArc.moveTo(bottomLeftCenter.dx, bottomLeftCenter.dy);
            curveArc.quadraticBezierTo(controlPoint.dx, controlPoint.dy, topRightCenter.dx, topRightCenter.dy);
            canvas.drawPath(curveArc, strokePaint);
            canvas.drawRect(Rect.fromCenter(center: center + Offset(size.width * 0.08, size.width * 0.08), width: markerSize, height: markerSize), fillPaint);
            canvas.drawRect(Rect.fromCenter(center: bottomLeftCenter, width: markerSize, height: markerSize), fillPaint);
            canvas.drawRect(Rect.fromCenter(center: topRightCenter, width: markerSize, height: markerSize), fillPaint);
          },
          shouldRedraw: false,
        ),
        child: Container(
          width: iconSize,
          height: iconSize,
          padding: EdgeInsets.fromLTRB(3,3,0,0),
          child: Text("CR", style: TextStyle(fontSize: 8, color: Colors.white),),
        ),
      )
    );
  }
}

class QuadraticBezierCurveIcon extends StatelessWidget {
  final double? widthSize;
  const QuadraticBezierCurveIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 4.0;
    return Container(
        width: iconSize,
        height: iconSize,
        padding: EdgeInsets.zero,
        alignment: Alignment.topLeft,
        child: CustomPaint(
          painter: FastDraw(
            drawer: (canvas, size){
              Offset center = size.center(Offset.zero);
              Offset topRightCenter = Offset(size.width * 0.7, size.height * 0.25);
              Offset bottomLeftCenter = Offset(size.width * 0.25, size.height * 0.75);
              Offset controlPoint = center + Offset(size.width * 0.15, size.width * 0.15);
              Path curveArc = Path();
              curveArc.moveTo(bottomLeftCenter.dx, bottomLeftCenter.dy);
              curveArc.quadraticBezierTo(controlPoint.dx, controlPoint.dy, topRightCenter.dx, topRightCenter.dy);
              canvas.drawPath(curveArc, strokePaint);
              canvas.drawRect(Rect.fromCenter(center: center + Offset(size.width * 0.08, size.width * 0.08), width: markerSize, height: markerSize), fillPaint);
              canvas.drawRect(Rect.fromCenter(center: bottomLeftCenter, width: markerSize, height: markerSize), fillPaint);
              canvas.drawRect(Rect.fromCenter(center: topRightCenter, width: markerSize, height: markerSize), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: Container(
            width: iconSize,
            height: iconSize,
            padding: const EdgeInsets.fromLTRB(3,3,0,0),
            child: const Text("QB", style: TextStyle(fontSize: 8, color: Colors.white),),
          ),
        )
    );
  }
}

class CubicBezierCurveIcon extends StatelessWidget {
  final double? widthSize;
  const CubicBezierCurveIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 4.0;
    return Container(
        width: iconSize,
        height: iconSize,
        padding: EdgeInsets.zero,
        alignment: Alignment.topLeft,
        child: CustomPaint(
          painter: FastDraw(
            drawer: (canvas, size){
              Offset center = size.center(Offset.zero);
              Offset topRightCenter = Offset(size.width * 0.7, size.height * 0.25);
              Offset bottomLeftCenter = Offset(size.width * 0.25, size.height * 0.75);
              Offset controlPoint = center + Offset(size.width * 0.15, size.width * 0.15);
              Path curveArc = Path();
              curveArc.moveTo(bottomLeftCenter.dx, bottomLeftCenter.dy);
              curveArc.quadraticBezierTo(controlPoint.dx, controlPoint.dy, topRightCenter.dx, topRightCenter.dy);
              canvas.drawPath(curveArc, strokePaint);
              canvas.drawRect(Rect.fromCenter(center: center + Offset(size.width * 0.08, size.width * 0.08), width: markerSize, height: markerSize), fillPaint);
              canvas.drawRect(Rect.fromCenter(center: bottomLeftCenter, width: markerSize, height: markerSize), fillPaint);
              canvas.drawRect(Rect.fromCenter(center: topRightCenter, width: markerSize, height: markerSize), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: Container(
            width: iconSize,
            height: iconSize,
            padding: const EdgeInsets.fromLTRB(3,3,0,0),
            child: const Text("CB", style: TextStyle(fontSize: 8, color: Colors.white),),
          ),
        )
    );
  }
}

class LineIcon extends StatelessWidget {
  final double? widthSize;
  const LineIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 4.0;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset start = Offset(size.width * 0.25, size.height * 0.75);
              Offset end = Offset(size.width * 0.75, size.height * 0.25);
              Path line = Path();
              line.moveTo(start.dx, start.dy);
              line.lineTo(end.dx, end.dy);
              canvas.drawPath(line, strokePaint);
              canvas.drawRect(Rect.fromCenter(center: start, width: markerSize, height: markerSize), fillPaint);
              canvas.drawRect(Rect.fromCenter(center: end, width: markerSize, height: markerSize), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ArcIcon extends StatelessWidget {
  final double? widthSize;
  const ArcIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 4.0;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset start = Offset(size.width * 0.2, size.height * 0.5);
              Offset end = Offset(size.width * 0.8, size.height * 0.5);
              Path arc = Path();
              arc.moveTo(start.dx, start.dy);
              arc.arcToPoint(end, radius: Radius.circular(size.width * 0.3), rotation: pi);
              canvas.drawPath(arc, strokePaint);
              canvas.drawRect(Rect.fromCenter(center: start, width: markerSize, height: markerSize), fillPaint);
              canvas.drawRect(Rect.fromCenter(center: end, width: markerSize, height: markerSize), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class RectangleIcon extends StatelessWidget {
  final double? widthSize;
  const RectangleIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
        width: iconSize,
        height: iconSize,
        padding: EdgeInsets.zero,
        alignment: Alignment.topLeft,
        child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              canvas.drawRect(Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.4), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
        ),
    );
  }
}

class RoundedRectangleIcon extends StatelessWidget {
  final double? widthSize;
  const RoundedRectangleIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              canvas.drawRRect(
                  RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.4), Radius.circular(3.0)) , fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class RoundedRectangleChatBoxIcon extends StatelessWidget {
  final double? widthSize;
  const RoundedRectangleChatBoxIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              Rect rect = Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.4);
              canvas.drawRRect(
                  RRect.fromRectAndRadius(rect, const Radius.circular(3.0)) , fillPaint);
              canvas.drawPath(
                  Path()..addPolygon(
                      [
                        rect.bottomRight - Offset(size.width * 0.36, 2),
                        rect.bottomRight + Offset(0, size.height * 0.12),
                        rect.bottomRight - Offset(size.width * 0.06, 2),
                      ], true), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class TriangleIcon extends StatelessWidget {
  final double? widthSize;
  const TriangleIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              // Offset center = size.center(Offset.zero);
              Path polygon = Path();
              polygon.addPolygon(
                  [
                    Offset(size.width * 0.5, size.height * 0.2),
                    Offset(size.width * 0.2, size.height * 0.7),
                    Offset(size.width * 0.8, size.height * 0.7),
                  ],
                true
              );
              canvas.drawPath(polygon, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class PentagonIcon extends StatelessWidget {
  final double? widthSize;
  const PentagonIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path polygon = Path();
              polygon.addPolygon(
                  [
                    Offset(size.width * 0.5, size.height * 0.2),
                    Offset(size.width * 0.8, size.height * 0.45),
                    Offset(size.width * 0.65, size.height * 0.75),
                    Offset(size.width * 0.35, size.height * 0.75),
                    Offset(size.width * 0.2, size.height * 0.45),
                  ],
                  true
              );
              canvas.drawPath(polygon, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class PolygonIcon extends StatelessWidget {
  final double? widthSize;
  const PolygonIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path polygon = Path();
              polygon.addPolygon(
                  [
                    Offset(size.width * 0.2, size.height * 0.4),
                    Offset(size.width * 0.5, size.height * 0.6),
                    Offset(size.width * 0.8, size.height * 0.2),
                    Offset(size.width * 0.8, size.height * 0.8),
                    Offset(size.width * 0.2, size.height * 0.8),
                  ],
                  true
              );
              canvas.drawPath(polygon, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ConicIcon extends StatelessWidget {
  final double? widthSize;
  const ConicIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path conic = Path();
              conic.addOval(Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 0.6, height: size.height * 0.6));
              canvas.drawPath(conic, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class StarIcon extends StatelessWidget {
  final double? widthSize;
  const StarIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path star = Path();
              Offset center = size.center(Offset.zero);
              List<Offset> vertices = [];
              double outerRadius = (Offset.zero & size).shortestSide / 2;
              double innerRadius = outerRadius * sin(pi / 10) / sin(7 * pi / 10);
              double startAngleOuter = 3 * pi / 2;
              double startAngleInner = 17 * pi / 10;
              for(int i = 0; i < 5; i++){
                vertices.add(center + Offset.fromDirection(startAngleOuter + i * (2 * pi / 5), outerRadius));
                vertices.add(center + Offset.fromDirection(startAngleInner + i * (2 * pi / 5), innerRadius));
              }
              star.addPolygon(vertices, true);
              canvas.drawPath(star, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class HeartIcon extends StatelessWidget {
  final double? widthSize;
  const HeartIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Rect upperRect = Offset(size.width * 0.1, size.height * 0.2) & Size(size.width * 0.8, size.height * 0.5);
              Rect lowerRect = Offset(size.width * 0.1, size.height * 0.44) & Size(size.width * 0.8, size.height * 0.45);
              Path heart = Path();
              double adjuster = 4.0;
              Offset blControlPoint = lowerRect.bottomLeft + Offset.fromDirection(7 * pi / 4, adjuster);
              Offset brControlPoint = lowerRect.bottomRight + Offset.fromDirection(5 * pi / 4, adjuster);
              heart.addArc(Rect.fromPoints(upperRect.topLeft, upperRect.bottomCenter), pi, pi);
              heart.addArc(Rect.fromPoints(upperRect.topRight, upperRect.bottomCenter), pi, pi);
              heart.quadraticBezierTo(brControlPoint.dx, brControlPoint.dy, lowerRect.bottomCenter.dx, lowerRect.bottomCenter.dy);
              heart.quadraticBezierTo(blControlPoint.dx, blControlPoint.dy, lowerRect.topLeft.dx, lowerRect.topLeft.dy);
              canvas.drawPath(heart, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ArrowIcon extends StatelessWidget {
  final double? widthSize;
  const ArrowIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Rect rightRect = Offset(size.width * 0.55, size.height * 0.2) & Size(size.width * 0.3, size.height * 0.6);
              Path triangle = Path();
              triangle.addPolygon(
                  [
                    rightRect.topLeft,
                    rightRect.centerRight,
                    rightRect.bottomLeft,
                  ], true);
              canvas.drawRect(Offset(size.width * 0.2, size.height * 0.35) & Size(size.width * 0.45, size.height * 0.3), fillPaint);
              canvas.drawPath(triangle, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class LoopIcon extends StatelessWidget {
  final double? widthSize;
  const LoopIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              List<Offset> loopPoints = [
                Offset(size.width * 0.2, size.height * 0.2),
                Offset(size.width * 0.55, size.height * 0.2),
                Offset(size.width * 0.8, size.height * 0.75),
                Offset(size.width * 0.45, size.height * 0.75),
                Offset(size.width * 0.17, size.height * 0.22),
                Offset(size.width * 0.2, size.height * 0.2),
              ];
              canvas.drawPath(getCMRPath(loopPoints, close: true), strokePaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class BlobIcon extends StatelessWidget {
  final double? widthSize;
  const BlobIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              List<Offset> loopPoints = [
                Offset(size.width * 0.3, size.height * 0.25),
                Offset(size.width * 0.5, size.height * 0.2),
                Offset(size.width * 0.65, size.height * 0.2),
                Offset(size.width * 0.75, size.height * 0.5),
                Offset(size.width * 0.65, size.height * 0.8),
                Offset(size.width * 0.4, size.height * 0.85),
                Offset(size.width * 0.2, size.height * 0.7),
                Offset(size.width * 0.3, size.height * 0.5),
                Offset(size.width * 0.3, size.height * 0.25),
              ];
              canvas.drawPath(getLoopedCMRPath(loopPoints), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class LeafIcon extends StatelessWidget {
  final double? widthSize;
  const LeafIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path leaf = Path();
              leaf.moveTo(size.width * 0.2, size.height * 0.2);
              leaf.cubicTo(size.width * 0.6, size.height * 0.1, size.width * 0.7, size.height * 0.5, size.width * 0.8, size.height * 0.8);
              leaf.cubicTo(size.width * 0.6, size.height * 0.7, size.width * 0.3, size.height * 0.9, size.width * 0.2, size.height * 0.2);
              leaf.close();
              canvas.drawPath(leaf, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class SymmetryIcon extends StatelessWidget {
  final double? widthSize;
  const SymmetryIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path middleLine = Path();
              double y = size.height * 0.15;
              while (y < size.height * 0.95){
                middleLine.moveTo(size.width * 0.5, y);
                y += size.height * 0.1;
                middleLine.lineTo(size.width * 0.5, y);
                y += size.height * 0.1;
              }
              canvas.drawPath(middleLine, strokePaint);
              canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.25, size.height * 0.5), width: size.width * 0.2, height: size.height * 0.2), fillPaint);
              canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.75, size.height * 0.5), width: size.width * 0.2, height: size.height * 0.2), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class SymmetryIcon2 extends StatelessWidget {
  final double? widthSize;
  const SymmetryIcon2({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path middleLine = Path();
              double x = size.width * 0.15;
              while (x < size.width * 0.95){
                middleLine.moveTo(x, size.height * 0.5);
                x += size.width * 0.1;
                middleLine.lineTo(x, size.height * 0.5);
                x += size.width * 0.1;
              }
              canvas.drawPath(middleLine, strokePaint);
              canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.25), width: size.width * 0.2, height: size.height * 0.2), fillPaint);
              canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.75), width: size.width * 0.2, height: size.height * 0.2), fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class DirectedLineIcon extends StatelessWidget {
  final double? widthSize;
  const DirectedLineIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 6.0;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset start = Offset(size.width * 0.25, size.height * 0.75);
              Offset pointer = start + Offset.fromDirection(7 * pi / 4, size.width * 0.5);
              Path dLine = Path();
              dLine.moveTo(start.dx, start.dy);
              dLine.lineTo(pointer.dx, pointer.dy);
              canvas.drawPath(dLine, strokePaint);
              Path endArrow = Path();
              double topRightDirection = 7 * pi / 4;
              endArrow.addPolygon(
                  [
                    pointer + Offset.fromDirection(topRightDirection, markerSize),
                    pointer + Offset.fromDirection(topRightDirection + (2 * pi / 3), markerSize),
                    pointer + Offset.fromDirection(topRightDirection + (4 * pi / 3), markerSize),
                  ], true);
              canvas.drawPath(endArrow, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class CurveDirectedLineIcon extends StatelessWidget {
  final double? widthSize;
  const CurveDirectedLineIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 6.0;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset start = Offset(size.width * 0.25, size.height * 0.75);
              Offset pointer = start + Offset.fromDirection(7 * pi / 4, size.width * 0.5);
              Path cLine = Path();
              cLine.moveTo(start.dx, start.dy);
              cLine.cubicTo(size.width * 0.35, size.height * 0.35, size.width * 0.65, size.height * 0.65, pointer.dx, pointer.dy);
              canvas.drawPath(cLine, strokePaint);
              Path endArrow = Path();
              double topRightDirection = 7 * pi / 4;
              endArrow.addPolygon(
                  [
                    pointer + Offset.fromDirection(topRightDirection, markerSize),
                    pointer + Offset.fromDirection(topRightDirection + (2 * pi / 3), markerSize),
                    pointer + Offset.fromDirection(topRightDirection + (4 * pi / 3), markerSize),
                  ], true);
              canvas.drawPath(endArrow, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class FlipVerticalIcon extends StatelessWidget {
  final double? widthSize;
  const FlipVerticalIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path shape = Path();
              shape.addPolygon(
                  [
                    Offset(size.width * 0.3, size.height * 0.2),
                    Offset(size.width * 0.3, size.height * 0.4),
                    Offset(size.width * 0.9, size.height * 0.4),
                  ], true);
              shape.addPolygon(
                  [
                    Offset(size.width * 0.3, size.height * 0.6),
                    Offset(size.width * 0.3, size.height * 0.8),
                    Offset(size.width * 0.9, size.height * 0.6),
                  ], true);
              canvas.drawPath(shape, objectPaint);
              Path dottedLine = Path();
              double x = size.width * 0.3;
              double y = size.height * 0.5;
              double gap = size.width * 0.1;
              while(x < size.width * 0.9){
                dottedLine.moveTo(x, y);
                dottedLine.lineTo(x + gap, y);
                x += gap * 2;
              }
              canvas.drawPath(dottedLine, strokePaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class FlipHorizontalIcon extends StatelessWidget {
  final double? widthSize;
  const FlipHorizontalIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path shape = Path();
              shape.addPolygon(
                  [
                    Offset(size.width * 0.4, size.height * 0.1),
                    Offset(size.width * 0.4, size.height * 0.7),
                    Offset(size.width * 0.2, size.height * 0.7),
                  ], true);
              shape.addPolygon(
                  [
                    Offset(size.width * 0.6, size.height * 0.1),
                    Offset(size.width * 0.8, size.height * 0.7),
                    Offset(size.width * 0.6, size.height * 0.7),
                  ], true);
              canvas.drawPath(shape, objectPaint);
              Path dottedLine = Path();
              double x = size.width * 0.5;
              double y = size.height * 0.2;
              double gap = size.height * 0.1;
              while(y < size.height * 0.8){
                dottedLine.moveTo(x, y);
                dottedLine.lineTo(x, y + gap);
                y += gap * 2;
              }
              canvas.drawPath(dottedLine, strokePaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ShadowIcon extends StatelessWidget {
  final double? widthSize;
  const ShadowIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Paint shadowPaint = Paint()
                ..shader = ui.Gradient.radial(
                  size.center(Offset.zero),
                  size.width * 0.4,
                  [Colors.white, Colors.black]
                )
                ..style = PaintingStyle.fill;
              canvas.drawOval(Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 0.8, height: size.height * 0.8), shadowPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ReadyToShiftIcon extends StatelessWidget {
  final double? widthSize;
  const ReadyToShiftIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    double markerSize = 2.5;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset start = Offset(size.width * 0.3, size.height * 0.7);
              Offset pointer = start + Offset.fromDirection(7 * pi / 4, size.width * 0.3);
              Path dLine = Path();
              dLine.moveTo(start.dx, start.dy);
              dLine.lineTo(pointer.dx, pointer.dy);
              canvas.drawPath(dLine, strokePaint);
              canvas.drawRect(Rect.fromCenter(center: start, width: size.width * 0.25, height: size.height * 0.25), strokePaint);
              Path endArrow = Path();
              double topRightDirection = 7 * pi / 4;
              endArrow.addPolygon(
                  [
                    pointer + Offset.fromDirection(topRightDirection, markerSize),
                    pointer + Offset.fromDirection(topRightDirection + (2 * pi / 3), markerSize),
                    pointer + Offset.fromDirection(topRightDirection + (4 * pi / 3), markerSize),
                  ], true);
              canvas.drawRect(Rect.fromCenter(center: start + Offset.fromDirection(7 * pi / 4, size.width * 0.5), width: size.width * 0.25, height: size.height * 0.25), fillPaint);
              canvas.drawPath(endArrow, fillPaint..color = Colors.white);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class FillIcon extends StatelessWidget {
  final double? widthSize;
  const FillIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    // double markerSize = 2.5;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path paintBucket = Path();
              Offset center = size.center(Offset.zero);
              Offset p1 = Offset(size.width * 0.2, size.height * 0.3);
              Offset p2 = Offset(size.width * 0.8, size.height * 0.3);
              Offset p3 = Offset(size.width * 0.7, size.height * 0.8);
              Offset p4 = Offset(size.width * 0.3, size.height * 0.8);
              paintBucket.addPolygon(
                  [
                    rotate(p1, center, -pi / 4),
                    rotate(p2, center, -pi / 4),
                    rotate(p3, center, -pi / 4),
                    rotate(p4, center, -pi / 4)
                  ], true);
              canvas.drawPath(paintBucket, fillPaint..color = Colors.white);
              Path arc = Path();
              Offset arcCenter = rotate(Offset(size.width * 0.5, size.height * 0.3), center, -pi / 4);
              Paint paint = Paint()
                  ..color = Colors.black
                  ..strokeWidth = 1.0
                  ..style = PaintingStyle.stroke;
              arc.addArc(Rect.fromCenter(center: arcCenter, width: size.width * 0.6, height: size.width * 0.6), -pi / 4, pi);
              canvas.drawPath(arc, paint);
              Path bluePaintPath = getCMRPath([arcCenter, Offset(size.width * 0.1, size.height * 0.4), Offset(size.width * 0.05, size.height * 0.5), arcCenter]);
              canvas.drawPath(bluePaintPath, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ShaderIcon extends StatelessWidget {
  final double? widthSize;
  const ShaderIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    // double markerSize = 2.5;
    Color red = const Color.fromARGB(255, 255, 64, 64);
    Color yellow = const Color.fromARGB(255, 255, 255, 64);
    Color green = const Color.fromARGB(255, 64, 224, 128);
    Color blue = const Color.fromARGB(255, 64, 96, 255);
    Color cyan = const Color.fromARGB(255, 64, 255, 255);
    Color magenta = const Color.fromARGB(255, 255, 64, 224);
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              Paint sweepGradientPaint = Paint()
                ..shader = ui.Gradient.sweep(
                  center,
                  [red, yellow, green, blue, cyan, magenta, red],
                  [0.0, 0.16667, 0.33333, 0.5, 0.66667, 0.83333, 1.0],
                  TileMode.clamp,
                )
                ..style = PaintingStyle.fill;
              canvas.drawOval(Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.6), sweepGradientPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class FreeDrawIcon extends StatelessWidget {
  final double? widthSize;
  const FreeDrawIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Paint paint = Paint()
                  ..color = Colors.white
                  ..strokeWidth = 3.0
                  ..style = PaintingStyle.stroke;
              canvas.drawPath(getCMRPath(
                [
                  Offset(size.width * 0.2, size.height * 0.65),
                  Offset(size.width * 0.5, size.height * 0.2),
                  Offset(size.width * 0.35, size.height * 0.75),
                  Offset(size.width * 0.75, size.height * 0.3),
                  Offset(size.width * 0.65, size.height * 0.8),
                ]
              ), paint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class SmoothenIcon extends StatelessWidget {
  final double? widthSize;
  const SmoothenIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path linePath = Path();
              linePath.moveTo(size.width * 0.2, size.height * 0.75);
              linePath.lineTo(size.width * 0.25, size.height * 0.65);
              linePath.lineTo(size.width * 0.35, size.height * 0.5);
              linePath.lineTo(size.width * 0.45, size.height * 0.65);
              linePath.lineTo(size.width * 0.5, size.height * 0.5);
              linePath.quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width * 0.8, size.height * 0.2);
              canvas.drawPath(linePath, strokePaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class CloseCurveIcon extends StatelessWidget {
  final double? widthSize;
  const CloseCurveIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path curvePath = getCMRPath(
                  [
                    Offset(size.width * 0.3, size.height * 0.7),
                    Offset(size.width * 0.35, size.height * 0.5),
                    Offset(size.width * 0.55, size.height * 0.2),
                    Offset(size.width * 0.75, size.height * 0.55),
                    Offset(size.width * 0.6, size.height * 0.7),
                  ]);
              curvePath.close();
              canvas.drawPath(curvePath, strokePaint);
              Path marks = Path();
              marks.addOval(Rect.fromCenter(center: Offset(size.width * 0.3, size.height * 0.7), width: 3, height: 3));
              marks.addOval(Rect.fromCenter(center: Offset(size.width * 0.6, size.height * 0.7), width: 3, height: 3));
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ShowControlPointsIcon extends StatelessWidget {
  final double? widthSize;
  const ShowControlPointsIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path curvePath = getCMRPath(
                  [
                    Offset(size.width * 0.2, size.height * 0.75),
                    Offset(size.width * 0.35, size.height * 0.55),
                    Offset(size.width * 0.55, size.height * 0.35),
                    Offset(size.width * 0.75, size.height * 0.3),
                    Offset(size.width * 0.8, size.height * 0.25),
                  ]);
              canvas.drawPath(curvePath, strokePaint);
              Path marks = Path();
              marks.addOval(Rect.fromCenter(center: Offset(size.width * 0.55, size.height * 0.35), width: 3, height: 3));
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class SquareStrokeCapIcon extends StatelessWidget {
  final double? widthSize;
  const SquareStrokeCapIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              strokePaint.strokeCap = StrokeCap.square;
              strokePaint.strokeWidth = 3.0;
              canvas.drawArc(
                Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 0.6, height: size.height * 0.6),
                pi / 4,
                3 * pi / 2,
                false,
                strokePaint
              );
              strokePaint.strokeCap = StrokeCap.round;
              strokePaint.strokeWidth = 1.0;
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class OpenCurveIcon extends StatelessWidget {
  final double? widthSize;
  const OpenCurveIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path curvePath = getCMRPath(
                  [
                    Offset(size.width * 0.3, size.height * 0.7),
                    Offset(size.width * 0.35, size.height * 0.5),
                    Offset(size.width * 0.55, size.height * 0.2),
                    Offset(size.width * 0.75, size.height * 0.55),
                    Offset(size.width * 0.6, size.height * 0.7),
                  ]);
              canvas.drawPath(curvePath, strokePaint);
              Path marks = Path();
              marks.addOval(Rect.fromCenter(center: Offset(size.width * 0.3, size.height * 0.7), width: 3, height: 3));
              marks.addOval(Rect.fromCenter(center: Offset(size.width * 0.6, size.height * 0.7), width: 3, height: 3));
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class PolygonalLineIcon extends StatelessWidget {
  final double? widthSize;
  const PolygonalLineIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              List<Offset> vertices = [
                Offset(size.width * 0.2, size.height * 0.8),
                Offset(size.width * 0.35, size.height * 0.4),
                Offset(size.width * 0.55, size.height * 0.6),
                Offset(size.width * 0.75, size.height * 0.2),
              ];
              Path polygonalPath = Path();
              polygonalPath.addPolygon(vertices, false);
              canvas.drawPath(polygonalPath, strokePaint);
              Path marks = Path();
              for(Offset point in vertices){
                marks.addOval(Rect.fromCenter(center: point, width: 3, height: 3));
              }
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ExtendCompositeIcon extends StatelessWidget {
  final double? widthSize;
  const ExtendCompositeIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              List<Offset> vertices = [
                Offset(size.width * 0.2, size.height * 0.8),
                Offset(size.width * 0.35, size.height * 0.4),
                Offset(size.width * 0.55, size.height * 0.6),
                Offset(size.width * 0.75, size.height * 0.2),
              ];
              Path compositeExtensionPath = Path();
              compositeExtensionPath.moveTo(vertices[0].dx, vertices[0].dy);
              compositeExtensionPath.lineTo(vertices[1].dx, vertices[1].dy);
              compositeExtensionPath.quadraticBezierTo(vertices[2].dx, vertices[2].dy, vertices[3].dx, vertices[3].dy);
              canvas.drawPath(compositeExtensionPath, strokePaint);
              Path marks = Path();
              for(Offset point in vertices){
                marks.addOval(Rect.fromCenter(center: point, width: 3, height: 3));
              }
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class ChainBezierIcon extends StatelessWidget {
  final double? widthSize;
  const ChainBezierIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              List<Offset> vertices = [
                Offset(size.width * 0.2, size.height * 0.8),
                Offset(size.width * 0.35, size.height * 0.4),
                Offset(size.width * 0.55, size.height * 0.6),
                Offset(size.width * 0.75, size.height * 0.2),
              ];
              Path chainBezierPath = Path();
              chainBezierPath.moveTo(size.width * 0.2, size.height * 0.8);
              chainBezierPath.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.35, size.height * 0.4);
              chainBezierPath.quadraticBezierTo(size.width * 0.35, size.height * 0.5, size.width * 0.55, size.height * 0.6);
              chainBezierPath.quadraticBezierTo(size.width * 0.55, size.height * 0.4, size.width * 0.75, size.height * 0.2);
              canvas.drawPath(chainBezierPath, strokePaint);
              Path marks = Path();
              for(Offset point in vertices){
                marks.addOval(Rect.fromCenter(center: point, width: 3, height: 3));
              }
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class SmoothChainBezierIcon extends StatelessWidget {
  final double? widthSize;
  const SmoothChainBezierIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              List<Offset> vertices = [
                Offset(size.width * 0.2, size.height * 0.8),
                Offset(size.width * 0.35, size.height * 0.4),
                Offset(size.width * 0.55, size.height * 0.6),
                Offset(size.width * 0.75, size.height * 0.2),
              ];
              Path smoothChainBezierPath = Path();
              smoothChainBezierPath.moveTo(vertices.first.dx, vertices.first.dy);
              smoothChainBezierPath.cubicTo(vertices[1].dx, vertices[1].dy, vertices[2].dx, vertices[2].dy, vertices.last.dx, vertices.last.dy);
              canvas.drawPath(smoothChainBezierPath, strokePaint);
              Path marks = Path();
              marks.addOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: 3, height: 3));
              canvas.drawPath(marks, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class GroupIcon extends StatelessWidget {
  final double? widthSize;
  const GroupIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Paint localFill = Paint()
                  ..color = fillPaint.color
                  ..style = fillPaint.style;
              canvas.drawRect(Rect.fromPoints(Offset(size.width * 0.25, size.height * 0.2), Offset(size.width * 0.7, size.height * 0.55)), localFill);
              localFill.color = Colors.grey;
              canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.6, size.height * 0.6), width: size.width * 0.35, height: size.width * 0.35), localFill);
              Path triangle = Path();
              triangle.addPolygon(
                  [
                    Offset(size.width * 0.1, size.height * 0.75),
                    Offset(size.width * 0.35, size.height * 0.35),
                    Offset(size.width * 0.6, size.height * 0.75),
                  ], true);
              localFill.color = Colors.grey[600]!;
              canvas.drawPath(triangle, localFill);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class UngroupIcon extends StatelessWidget {
  final double? widthSize;
  const UngroupIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Paint localFill = Paint()
                ..color = fillPaint.color
                ..style = fillPaint.style;
              canvas.drawRect(Rect.fromPoints(Offset(size.width * 0.35, size.height * 0.1), Offset(size.width * 0.65, size.height * 0.4)), localFill);
              localFill.color = Colors.grey;
              canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.65, size.height * 0.65), width: size.width * 0.3, height: size.width * 0.3), localFill);
              Path triangle = Path();
              triangle.addPolygon(
                  [
                    Offset(size.width * 0.1, size.height * 0.8),
                    Offset(size.width * 0.3, size.height * 0.45),
                    Offset(size.width * 0.5, size.height * 0.8),
                  ], true);
              localFill.color = Colors.grey[600]!;
              canvas.drawPath(triangle, localFill);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class TextIcon extends StatelessWidget {
  final double? widthSize;
  const TextIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: const Text(
        "T",
        style: TextStyle(
            fontSize: 18,
          color: Colors.white,
          fontFamily: "Playfair"
        ),
        textAlign: TextAlign.center,),
    );
  }
}

class IrregEnthickenIcon extends StatelessWidget {
  final double? widthSize;
  const IrregEnthickenIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path curvePath = Path();
              curvePath.moveTo(size.width * 0.1, size.height * 0.4);
              curvePath.cubicTo(size.width * 0.4, size.height * 0.05, size.width * 0.65, size.height * 0.65, size.width * 0.9, size.height * 0.35);
              curvePath.lineTo(size.width * 0.9, size.height * 0.65);
              curvePath.cubicTo(size.width * 0.65, size.height * 0.75, size.width * 0.4, size.height * 0.55, size.width * 0.1, size.height * 0.7);
              curvePath.close();
              fillPaint.color = Colors.white;
              canvas.drawPath(curvePath, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class TaperIcon extends StatelessWidget {
  final double? widthSize;
  const TaperIcon({this.widthSize, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path taperPath = Path();
              taperPath.addPolygon(
                  [
                    Offset(size.width * 0.2, size.height * 0.25),
                    Offset(size.width * 0.8, size.height * 0.4),
                    Offset(size.width * 0.8, size.height * 0.6),
                    Offset(size.width * 0.2, size.height * 0.75),
                  ], true);
              fillPaint.color = Colors.white;
              canvas.drawPath(taperPath, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class MaximizeSelectionAreaIcon extends StatelessWidget {
  final double? widthSize;
  const MaximizeSelectionAreaIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              Path line = Path();
              Rect outerSquare = Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.6);
              Rect innerSquare = Rect.fromCenter(center: center, width: size.width * 0.4, height: size.height * 0.4);
              line.moveTo(innerSquare.topLeft.dx, innerSquare.topLeft.dy);
              line.lineTo(outerSquare.topLeft.dx, outerSquare.topLeft.dy);
              line.moveTo(innerSquare.topRight.dx, innerSquare.topRight.dy);
              line.lineTo(outerSquare.topRight.dx, outerSquare.topRight.dy);
              line.moveTo(innerSquare.bottomLeft.dx, innerSquare.bottomLeft.dy);
              line.lineTo(outerSquare.bottomLeft.dx, outerSquare.bottomLeft.dy);
              line.moveTo(innerSquare.bottomRight.dx, innerSquare.bottomRight.dy);
              line.lineTo(outerSquare.bottomRight.dx, outerSquare.bottomRight.dy);
              canvas.drawPath(line, strokePaint);
              Path triangle = Path();
              triangle.addPolygon(
                  [
                    outerSquare.topLeft,
                    center + Offset.fromDirection(5 * pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(5 * pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              triangle.addPolygon(
                  [
                    outerSquare.topRight,
                    center + Offset.fromDirection(7 * pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(7 * pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              triangle.addPolygon(
                  [
                    outerSquare.bottomLeft,
                    center + Offset.fromDirection(3 * pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(3 * pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              triangle.addPolygon(
                  [
                    outerSquare.bottomRight,
                    center + Offset.fromDirection(pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              canvas.drawPath(triangle, Paint()
                ..color = Colors.white
                ..style = PaintingStyle.fill
              );
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class RegulariseIcon extends StatelessWidget {
  final double? widthSize;
  const RegulariseIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              Path line = Path();
              Rect square = Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.6);
              line.moveTo(center.dx, center.dy);
              line.lineTo(square.topLeft.dx, square.topLeft.dy);
              line.moveTo(center.dx, center.dy);
              line.lineTo(square.topRight.dx, square.topRight.dy);
              line.moveTo(center.dx, center.dy);
              line.lineTo(square.bottomLeft.dx, square.bottomLeft.dy);
              line.moveTo(center.dx, center.dy);
              line.lineTo(square.bottomRight.dx, square.bottomRight.dy);
              line.addRect(square);
              canvas.drawPath(line, strokePaint);
              Path triangle = Path();
              triangle.addPolygon(
                  [
                    square.topLeft,
                    center + Offset.fromDirection(5 * pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(5 * pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              triangle.addPolygon(
                  [
                    square.topRight,
                    center + Offset.fromDirection(7 * pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(7 * pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              triangle.addPolygon(
                  [
                    square.bottomLeft,
                    center + Offset.fromDirection(3 * pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(3 * pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              triangle.addPolygon(
                  [
                    square.bottomRight,
                    center + Offset.fromDirection(pi / 4 + 0.3, 0.6 * sqrt2 * size.width * 0.3),
                    center + Offset.fromDirection(pi / 4 - 0.3, 0.6 * sqrt2 * size.width * 0.3),
                  ],
                  true);
              canvas.drawPath(triangle, Paint()
                  ..color = Colors.white
                  ..style = PaintingStyle.fill
              );
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class RoundCornerIcon extends StatelessWidget {
  final double? widthSize;
  const RoundCornerIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Offset center = size.center(Offset.zero);
              Path roundedLine = Path();
              Rect square = Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.6);
              roundedLine.moveTo(size.width * 0.1, size.height * 0.7);
              roundedLine.lineTo(size.width * 0.4, size.height * 0.4);
              roundedLine.arcTo(
                Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: size.width * 0.2, height: size.width * 0.2), -3 * pi / 4, pi / 2, true);
              roundedLine.lineTo(size.width * 0.9, size.height * 0.7);
              canvas.drawPath(roundedLine, strokePaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class WaveIcon extends StatelessWidget {
  final double? widthSize;
  const WaveIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              Path wavePath = getCMRPath(
                [
                  Offset(size.width * 0.1, size.height * 0.7),
                  Offset(size.width * 0.25, size.height * 0.3),
                  Offset(size.width * 0.4, size.height * 0.7),
                  Offset(size.width * 0.55, size.height * 0.3),
                  Offset(size.width * 0.7, size.height * 0.7),
                  Offset(size.width * 0.85, size.height * 0.3)
                ]
              );
              canvas.drawPath(wavePath, strokePaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class UpFontSizeIcon extends StatelessWidget {
  final double? widthSize;
  const UpFontSizeIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              TextPainter tp = TextPainter(
                text: TextSpan(text: "A", style: TextStyle(fontSize: size.height * 0.6, color: Colors.white),),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
              );
              tp.layout();
              tp.paint(canvas, Offset(size.width * 0.25, size.height * 0.15));
              Path upArrow = Path()
                  ..addPolygon([
                    Offset(size.width * 0.5, size.height * 0.3),
                    Offset(size.width * 0.8, size.height * 0.3),
                    Offset(size.width * 0.65, size.height * 0.1),
                  ], true);
              canvas.drawPath(upArrow, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}

class DownFontSizeIcon extends StatelessWidget {
  final double? widthSize;
  const DownFontSizeIcon({this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 24;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.topLeft,
      child: CustomPaint(
          painter: FastDraw(
            drawer: (Canvas canvas, Size size){
              TextPainter tp = TextPainter(
                text: TextSpan(text: "A", style: TextStyle(fontSize: size.height * 0.6, color: Colors.white),),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
              );
              tp.layout();
              tp.paint(canvas, Offset(size.width * 0.25, size.height * 0.15));
              Path upArrow = Path()
                ..addPolygon([
                  Offset(size.width * 0.5, size.height * 0.1),
                  Offset(size.width * 0.8, size.height * 0.1),
                  Offset(size.width * 0.65, size.height * 0.3),
                ], true);
              canvas.drawPath(upArrow, fillPaint);
            },
            shouldRedraw: false,
          ),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
          )
      ),
    );
  }
}