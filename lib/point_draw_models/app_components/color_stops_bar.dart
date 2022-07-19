import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:math' show min, max;

import 'package:pointdraw/point_draw_models/utilities/fast_draw.dart';
import 'package:pointdraw/point_draw_models//point_draw_objects.dart';
import 'package:pointdraw/point_draw_models//grid_parameters.dart';

class ColorStopsBar extends StatelessWidget {
  final Size? size;
  final Color contrastingBackgroundColor;
  final List<double> stops;
  final List<Color> colors;
  final void Function(List<double>)? updater;
  final void Function(double, List<double>, List<Color>)? onCreateStop;
  const ColorStopsBar(this.contrastingBackgroundColor, {required this.stops, required this.colors, required this.updater, required this.onCreateStop, this.size, Key? key}) : super(key: key);

  List<double> computeStops(BuildContext context, List<Offset> locations, {double? newStop}){
    List<double> stops = List<double>.filled(locations.length, 0);
    for(int i = 0; i < locations.length; i++){
      stops[i] = (locations[i].dx - 15) / 240;
    }
    stops.sort();
    if(newStop != null){
      int index = stops.indexOf(newStop);
      context.read<PointDrawObject>().updateShaderParams(context.read<GridParameters>().zoomTransform, insertIndex: index, insertStop: newStop);
    }
    return stops;
  }

  List<Offset> getStopsLocation(List<double> colorStops){
    List<Offset> stopsLocation = List<Offset>.filled(colorStops.length, Offset.zero, growable: true);
    for(int i = 0; i < colorStops.length; i++){
      stopsLocation[i] = Offset(240 * colorStops[i] + 15, 10);
    }
    return stopsLocation;
  }

  @override
  Widget build(BuildContext context) {
    Size barSize = size ?? const Size(200, 35);
    List<Offset> stopsLocation = getStopsLocation(stops);
    TextStyle labelStyle = const TextStyle(fontSize: 10, );
    return Container(
      width: barSize.width,
      height: barSize.height,
      alignment: Alignment.center,
      child: Stack(
        children: [
          SizedBox(
            width: 270,
            height: 40,
            child: GestureDetector(
              onTapDown: (dt){
                double newStop = (dt.localPosition.dx - 15) / 240;
                onCreateStop?.call(newStop, stops, colors);
              },
              behavior: HitTestBehavior.opaque,
            ),
          ),
          const Positioned(
              top: 20,
              left: 15,
              child: Material(
                  color: Colors.indigo,
                  child: SizedBox(
                    width: 240,
                    height: 2.0,
                  )
              )
          ),
          Positioned(
              top: 15,
              left: 0.0,
              child: Text("0.0", style: labelStyle )
          ),
          Positioned(
            top: 15,
            right: 0.0,
            child: Text("1.0", style: labelStyle),
          ),
          for(int i = 0; i < stopsLocation.length; i++)
            Positioned(
                top: 6,
                left: stopsLocation[i].dx - 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 10,
                        height: 10,
                        child: GestureDetector(
                          onPanUpdate: (dt){
                            Offset pendingOffset = stopsLocation[i] + Offset(dt.delta.dx, 0);
                            stopsLocation[i] = Offset(max(min(pendingOffset.dx, 255), 15), 10);
                            updater?.call(stopsLocation.map((e) => (e.dx - 15) / 240).toList());
                          },
                          behavior: HitTestBehavior.opaque,
                          child: FastDrawWidget(
                            drawer: (Canvas canvas, Size size) {
                              Path pointer = Path()
                                ..addPolygon([
                                  Offset.zero,
                                  const Offset(10, 0),
                                  const Offset(5, 10),
                                ], true);
                              canvas.drawPath(
                                  pointer,
                                  Paint()
                                    ..style = PaintingStyle.fill
                                    ..color = colors[i]
                              );
                              canvas.drawPath(
                                  pointer,
                                  Paint()
                                    ..style = PaintingStyle.stroke
                                    ..color = Colors.black
                              );
                            },),
                        )
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 14,
                      child: Text(((stopsLocation[i].dx - 15)/ 240).toStringAsFixed(2), style: labelStyle),
                    )
                  ],
                )
            )
        ],
      ),
    );
  }
}
