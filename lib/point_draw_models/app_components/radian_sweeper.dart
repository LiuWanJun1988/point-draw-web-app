import 'package:flutter/material.dart';

import 'dart:math' show pi;

import 'package:pointdraw/point_draw_models/utilities/fast_draw.dart';

Paint tickPainter = Paint()
  ..style = PaintingStyle.stroke
  ..color = Colors.black;

Paint startPointerPainter = Paint()
  ..style = PaintingStyle.fill
  ..color = Colors.green;

Paint pointerPainter = Paint()
  ..style = PaintingStyle.fill
  ..color = Colors.black;

Paint endPointerPainter = Paint()
  ..style = PaintingStyle.fill
  ..color = Colors.red;

enum RadianType{start, end, sweep}

class RadianSweeper extends StatelessWidget {
  final Size? size;
  final double radian;
  final void Function(double)? updater;
  const RadianSweeper({required this.radian, required this.updater, this.size, Key? key}) : super(key: key);

  double reBase(double radian){
    if(radian < 0){
      return radian + 2 * pi;
    }
    return radian;
  }

  @override
  Widget build(BuildContext context) {
    Size sweeperSize = size ?? const Size(100, 100);
    Offset center = sweeperSize.center(Offset.zero);
    double radius = sweeperSize.width / 2;
    Offset radianPointer = center + Offset.fromDirection(radian, radius * 0.7);
    Size pointerSize = sweeperSize * 0.15;
    return Container(
        width: sweeperSize.width,
        height: sweeperSize.height,
        child: Stack(
          children: [
            SizedBox(
              width: sweeperSize.width,
              height: sweeperSize.height,
              child: GestureDetector(
                onPanDown: (dt){
                  updater?.call(reBase((dt.localPosition - center).direction));
                },
                onPanUpdate: (dt){
                  updater?.call(reBase((dt.localPosition - center).direction));
                },
                behavior: HitTestBehavior.opaque,
              ),
            ),
            FastDrawWidget(
              drawer: (Canvas canvas, Size size){

                double shortTick = radius * 0.1;
                double longTick = radius * 0.2;
                double direction;
                for(int div = 0; div < 360; div += 15){
                  direction = div / 360 * 2 * pi;
                  if(div % 90 != 0){
                    canvas.drawLine(center + Offset.fromDirection(direction, radius - shortTick), center + Offset.fromDirection(direction, radius), tickPainter);
                  } else {
                    canvas.drawLine(center + Offset.fromDirection(direction, radius - longTick), center + Offset.fromDirection(direction, radius), tickPainter);
                  }
                }
              },
            ),
            Positioned(
                top: radianPointer.dy - pointerSize.height / 2,
                left: radianPointer.dx - pointerSize.width / 2,
                child: SizedBox(
                  width: pointerSize.width,
                  height: pointerSize.height,
                  child: FastDrawWidget(
                    drawer: (Canvas canvas, Size size){
                      Path pointer = Path();
                      Offset pointerCenter = size.center(Offset.zero);
                      pointer.addPolygon([
                        pointerCenter + Offset.fromDirection(radian, pointerSize.width / 2),
                        pointerCenter + Offset.fromDirection(radian + 2 * pi / 3, pointerSize.width / 2),
                        pointerCenter,
                        pointerCenter + Offset.fromDirection(radian - 2 * pi / 3, pointerSize.width / 2),
                      ], true);
                      canvas.drawPath(pointer, pointerPainter);
                    },
                  ),
                )
            ),
          ],
        )
    );
  }
}

