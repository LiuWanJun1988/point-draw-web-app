import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'dart:math' show Random, pi, min, max;
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/utilities/error_handling.dart';
import 'package:pointdraw/point_draw_models/point_draw_collection.dart';

enum OutputArea{usePath, entireCanvas, asBackgroundImage}

class PatternFactory {

  PointDrawObject? repUnit;

  PatternFactory([this.masterSeed = 0]){
    rand = Random(masterSeed);
    distributionPattern = DistributionPattern(style: DistributionStyle.array, rand: rand);
  }

  OutputArea outputArea = OutputArea.entireCanvas;

  List<Variation> variations = [];

  int masterSeed;

  late Random rand;

  void setRand(int seed){
    masterSeed = seed;
    rand = Random(masterSeed);
    distributionPattern.rand = rand;
  }

  void addVariationPoint(int index, DirectionVariation variation, Offset pivot, {required Map<String, dynamic> args}){
    // switch(variation){
    //   case DirectionVariation.unidirectional:
    //     variablePoints.addAll({
    //       index: PointVariation.unidirectional(pivot: pivot, direction: args[directionKey])
    //     });
    //     break;
    //   case DirectionVariation.bidirectional:
    //     variablePoints.addAll({
    //       index: PointVariation.bidirectional(pivot: pivot, direction: args[directionKey])
    //     });
    //     break;
    //   case DirectionVariation.sweep:
    //     variablePoints.addAll({
    //       index: PointVariation.sweep(pivot: pivot, maximumDistance: args[maximumDistanceKey], startAngle: args[startAngleKey], sweepAngle: args[sweepAngleKey],)
    //     });
    //     break;
    //   case DirectionVariation.omnidirectional:
    //     variablePoints.addAll({
    //       index: PointVariation.radial(pivot: pivot, maximumDistance: args[maximumDistanceKey])
    //     });
    //     break;
    //   default:
    //     variablePoints.addAll({
    //       index: PointVariation(pivot)
    //     });
    //     break;
    // }
  }

  void addPaintVariation(int index, PaintVariation paintVariation,){

  }

  late DistributionPattern distributionPattern;

  FutureOr<List<PointDrawObject>> _build(PointDrawObject repUnit){
    switch(distributionPattern.style){
      case DistributionStyle.random:
        return distributionPattern.buildRandomPattern(repUnit);
      case DistributionStyle.radial:
        return distributionPattern.buildRadialPattern(repUnit);
      case DistributionStyle.sweep:
        return distributionPattern.buildSweepPattern(repUnit);
      case DistributionStyle.array:
        return distributionPattern.buildArrayPattern(repUnit);
      case DistributionStyle.linear:
        return distributionPattern.buildLinearPattern(repUnit);
      default:
        return [];
    }
  }

  Future<List<PointDrawObject>?> generateObjects(Rect canvasRect) async {
    if(repUnit != null){
      return await compute(_build, repUnit!);
    } else {
      throw ErrorDescription("Base object not selected.");
    }
  }

  Future<void> buildPattern(BuildContext context, Rect canvasRect, {Canvas? canvas, bool cacheImage = false, Matrix4? zoomTransform}) async {
    try {
      List<PointDrawObject>? generatedObjects = await generateObjects(canvasRect);
      if(generatedObjects != null){
        if(outputArea != OutputArea.asBackgroundImage){
          context.read<PointDrawCollection>().cachePattern(patternObjects: generatedObjects);
        } else {
          ui.PictureRecorder recorder = ui.PictureRecorder();
          canvas ??= Canvas(recorder, canvasRect);
          canvas.clipPath(distributionPattern._boundary);
          drawGeneratedObjects(generatedObjects, canvas, zoomTransform: zoomTransform);
          ui.Picture pic = recorder.endRecording();
          ui.Image img = await pic.toImage(canvasRect.width ~/ 1, canvasRect.height ~/ 1);
          if (cacheImage){
            context.read<PointDrawCollection>().cachePattern(patternImage: img);
          }
        }
      }
    } catch (error){
      debugPrint("Error: $error");
      showErrorMessage(context, "Cannot generate pattern. Try again.", []);
    }
  }

  void drawGeneratedObjects(List<PointDrawObject> generatedObjects, Canvas canvas, {Matrix4? zoomTransform}){
    for(PointDrawObject object in generatedObjects){
      object.draw(canvas, 0.0, zoomTransform: zoomTransform);
    }
  }
}

enum DirectionVariation{unidirectional, bidirectional, sweep, omnidirectional, none}

class Variation {
  final ObjectKey key;

  Variation(this.key);
}

class PointVariation {
  Offset pivot = Offset.zero;

  Offset? direction;

  DirectionVariation variation = DirectionVariation.none;

  double variance = 0.5;

  double? maximumDistance;

  PointVariation.unidirectional({required this.pivot, required this.direction, this.variance = 0.5}){
    assert(direction != null, "Direction cannot be null in unidirectional variation");
    variation = DirectionVariation.unidirectional;
  }

  PointVariation.bidirectional({required this.pivot, required this.direction, this.variance = 0.5}){
    assert(direction != null, "Direction cannot be null in bidirectional variation");
    variation = DirectionVariation.bidirectional;
  }

  double? startAngle;

  double? sweepAngle;

  PointVariation.sweep({required this.pivot, required this.startAngle, required this.sweepAngle, this.variance = 0.5, this.maximumDistance = 30}){
    assert(startAngle != null && sweepAngle != null && maximumDistance != null, "Start angle, sweep angle and maximum distance cannot be null in sweep variation");
    variation = DirectionVariation.sweep;
  }

  PointVariation.radial({required this.pivot, this.variance = 0.5, this.maximumDistance = 30}){
    assert(maximumDistance != null, "Maximum distance cannot be null in radial variation");
    variation = DirectionVariation.omnidirectional;
  }

  PointVariation(this.pivot){
    variation = DirectionVariation.none;
  }

  Offset generate(Random rand){
    switch(variation){
      case DirectionVariation.unidirectional:
        return pivot + Offset.fromDirection(direction!.direction, direction!.distance * variance * rand.nextDouble());
      case DirectionVariation.bidirectional:
        if(rand.nextBool()){
          return pivot + Offset.fromDirection(direction!.direction, direction!.distance * variance * rand.nextDouble());
        } else {
          return pivot - Offset.fromDirection(direction!.direction, direction!.distance * variance * rand.nextDouble());
        }
      case DirectionVariation.omnidirectional:
        return pivot + Offset.fromDirection(2 * pi * rand.nextDouble(), maximumDistance! * variance * rand.nextDouble());
      case DirectionVariation.sweep:
        double variableDirection = startAngle! + sweepAngle! * rand.nextDouble();
        return pivot + Offset.fromDirection(variableDirection, maximumDistance! * variance * rand.nextDouble());
      default:
        return pivot;
    }
  }
}

class PaintVariation {
  final Paint paintFrom;

  final bool useShader;

  PaintVariation(
      {
        required this.paintFrom,
        this.useShader = false,
        this.shaderParamFrom,
        this.shaderParamTo,
        this.colorTo,
        this.masterSeed
      }){
    assert(!useShader || (shaderParamTo != null && shaderParamFrom != null), "Using shader must be provided with shaderParamFrom and shaderParamTo");
    rand = Random(masterSeed ?? (DateTime.now().microsecondsSinceEpoch % 10000));
    colorTo ??= paintFrom.color;
  }

  Color? colorTo;

  int? masterSeed;

  late Random rand;

  ShaderParameters? shaderParamFrom;

  ShaderParameters? shaderParamTo;

  Paint generate(){
    Paint randPaint = Paint();
    if(useShader){
      randPaint.shader = ShaderParameters.lerp(shaderParamFrom!, shaderParamTo!);
    } else {
      randPaint.color = Color.lerp(paintFrom.color, colorTo!, rand.nextDouble()) ?? paintFrom.color;
    }
    return randPaint;
  }

}

enum DistributionStyle{array, radial, sweep, random, linear}

class DistributionPattern {
  DistributionStyle style;

  double? horizontalSpacing;

  double? verticalSpacing;

  double? spacing;

  double? radialSpacing;

  Curve? curve;

  Offset? center;

  double? startAngle;

  double? sweepAngle;

  int? totalCount;

  bool? enableOverlap;

  Path _boundary = Path();

  Offset? linearStart;

  Offset? linearEnd;

  Random rand;

  DistributionPattern({required this.rand, this.style = DistributionStyle.array}){
    initialize();
  }

  set boundary(Path boundaryPath) => _boundary = boundaryPath;

  void initialize(){
    clearParameters();
    switch(style){
      case DistributionStyle.random:
        initializeRandomParameters();
        break;
      case DistributionStyle.array:
        initializeArrayParameters();
        break;
      case DistributionStyle.radial:
        initializeRadialParameters();
        break;
      case DistributionStyle.linear:
        initializeLinearParameters();
        break;
      case DistributionStyle.sweep:
        initializeSweepParameters();
        break;
      default:
        break;
    }
  }

  void clearParameters(){
    horizontalSpacing = null;
    verticalSpacing = null;
    spacing = null;
    curve = null;
    center = null;
    startAngle = null;
    sweepAngle = null;
    totalCount = null;
    enableOverlap = null;
  }

  void initializeArrayParameters(){
    horizontalSpacing = 0.0;
    verticalSpacing = 0.0;
  }

  void initializeRadialParameters(){
    center = Offset.zero;
    spacing = 0.0;
    radialSpacing = 0.0;
  }

  void initializeSweepParameters(){
    center = Offset.zero;
    spacing = 0.0;
    radialSpacing = 0.0;
    startAngle = 0.0;
    sweepAngle = pi / 2;
  }

  void initializeRandomParameters(){
    totalCount = 1;
    enableOverlap = false;
  }

  void initializeLinearParameters(){
    linearStart = Offset.zero;
    linearEnd = Offset.zero;
    spacing = 0.0;
  }

  List<PointDrawObject> buildArrayPattern(PointDrawObject baseUnit){
    List<PointDrawObject> generatedObjects = [];

    Rect baseRect = baseUnit.boundingRect;
    if(horizontalSpacing != 0.0 || verticalSpacing != 0.0){
      baseRect = Rect.fromCenter(center: baseRect.center, width: baseRect.width + horizontalSpacing! * 2, height: baseRect.height + verticalSpacing! * 2);
    }
    Rect outputRect = _boundary.getBounds();
    Offset initialOffset = outputRect.topLeft + (baseRect.center - baseRect.topLeft);
    Offset movingOffset = initialOffset;
    while(outputRect.contains(movingOffset)){
      generatedObjects.add(baseUnit.duplicate(center: movingOffset));
      if(outputRect.contains(movingOffset + Offset(baseRect.width, 0))){
        movingOffset = movingOffset + Offset(baseRect.width, 0);
      } else {
        movingOffset = Offset(initialOffset.dx, movingOffset.dy + baseRect.height);
      }
    }
    return generatedObjects;
  }

  List<PointDrawObject> buildRadialPattern(PointDrawObject baseUnit){
    List<PointDrawObject> generatedObjects = [];
    Rect baseRect = baseUnit.boundingRect;
    Rect outputRect = _boundary.getBounds();
    Offset movingOffset = center!;
    generatedObjects.add(baseUnit.duplicate(center: movingOffset));
    double diameter = (baseRect.topLeft - baseRect.bottomRight).distance;
    int layer = 0;
    while(outputRect.contains(movingOffset)){
      double theta = rand.nextDouble() * 2 * pi;
      layer++;
      movingOffset = center! + Offset.fromDirection(theta, (diameter + spacing!) * layer);
      double delta = 2 * pi / (2 * layer * pi * diameter / (diameter + 2 * radialSpacing!)).floor();
      double rotation = theta + 2 * pi;
      while(theta < rotation){
        generatedObjects.add(baseUnit.duplicate(center: movingOffset));
        theta += delta;
        movingOffset = center! + Offset.fromDirection(theta, (diameter + spacing!) * layer);
      }
    }
    return generatedObjects;
  }

  List<PointDrawObject> buildSweepPattern(PointDrawObject baseUnit){
    List<PointDrawObject> generatedObjects = [];
    Rect baseRect = baseUnit.boundingRect;
    Rect outputRect = _boundary.getBounds();
    Offset movingOffset = center!;
    generatedObjects.add(baseUnit.duplicate(center: movingOffset));
    double diameter = (baseRect.topLeft - baseRect.bottomRight).distance;
    int layer = 0;
    while(outputRect.contains(movingOffset)){
      double theta = startAngle!;
      layer++;
      movingOffset = center! + Offset.fromDirection(theta, (diameter + spacing!) * layer);
      double delta = sweepAngle! / (sweepAngle! * layer * diameter / (diameter + 2 * radialSpacing!)).floor();
      double rotation = theta + 2 * pi;
      while(theta < rotation){
        generatedObjects.add(baseUnit.duplicate(center: movingOffset));
        theta += delta;
        movingOffset = center! + Offset.fromDirection(theta, (diameter + spacing!) * layer);
      }
    }
    return generatedObjects;
  }

  List<PointDrawObject> buildRandomPattern(PointDrawObject baseUnit){
    List<PointDrawObject> generatedObjects = [];
    Rect baseRect = baseUnit.boundingRect;
    Rect outputRect = _boundary.getBounds();
    Path currentPath = Path();
    Offset movingOffset = const Offset(double.infinity, double.infinity);
    bool overlap(Offset offset, Path path){
      Rect rect = Rect.fromCenter(center: offset, width: baseRect.width, height: baseRect.height);
      return path.contains(rect.topLeft) || path.contains(rect.topRight) || path.contains(rect.bottomLeft) || path.contains(rect.bottomRight);
    }
    for(int i = 0; i < totalCount!; i++){
      while((!enableOverlap! && overlap(movingOffset, currentPath)) || !outputRect.contains(movingOffset)){
        movingOffset = Offset(outputRect.topLeft.dx + rand.nextDouble() * outputRect.width, outputRect.topLeft.dy + rand.nextDouble() * outputRect.height);
      }
      PointDrawObject object = baseUnit.duplicate(center: movingOffset);
      currentPath.addRect(object.boundingRect);
      generatedObjects.add(object);
      movingOffset = const Offset(double.infinity, double.infinity);
    }
    return generatedObjects;
  }

  List<PointDrawObject> buildLinearPattern(PointDrawObject baseUnit){
    List<PointDrawObject> generatedObjects = [];
    Rect baseRect = baseUnit.boundingRect;
    Rect outputRect = _boundary.getBounds();
    Offset initialOffset = linearStart!;
    Offset movingOffset = initialOffset;
    double direction = (linearEnd! - linearStart!).direction;
    int count = 0;
    while(outputRect.contains(movingOffset) && movingOffset.dx <= max(linearStart!.dx, linearEnd!.dx) && movingOffset.dx >= min(linearStart!.dx, linearEnd!.dx)){
      generatedObjects.add(baseUnit.duplicate(center: movingOffset));
      count++;
      movingOffset = movingOffset + Offset.fromDirection(direction, baseRect.width + 2 * spacing!);
    }
    return generatedObjects;
  }

}