import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui';
import 'dart:math' show pi;

import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/matrices.dart' show dotProduct;
import 'package:pointdraw/point_draw_models/effects_parameters.dart';

const double _defaultInterpolatingGapWidth = 0.6;

const double _toleranceWidth = 0.9;

enum SplineEffects{irregular, taper, normal, wavy}

class SplinePath{

  List<Offset> points;

  double tension;

  Path splinePath = Path();

  bool get isNotEmpty => points.isNotEmpty;

  bool drawEnd = false;

  SplinePath(this.points, {this.tension = 0})
      : assert(tension <= 1.0 && tension >= 0),
      super();

  SplinePath.generate(this.points, {this.tension = 0})
      : assert(tension <= 1.0 && tension >= 0),
        super(){
    if(points.length <= 3){
      splinePath.addPolygon(points, false);
    } else {
      CatmullRomSpline cmrc = CatmullRomSpline.precompute(points, tension: tension,);
      List<Curve2DSample> sampleList = cmrc.generateSamples().toList(growable: false);
      splinePath.moveTo(sampleList.first.value.dx, sampleList.first.value.dy);
      for(Curve2DSample p in sampleList){
        splinePath.lineTo(p.value.dx, p.value.dy);
      }
    }
  }

  void generate(List<Offset> pts, {bool firstIteration = false, Offset? startHandle}){
    assert(pts.length > 3);
    if(firstIteration || (pts.last - _lastDrawnPoint!).distanceSquared > 9){
      Iterable<Curve2DSample> sampleList = CatmullRomSpline.precompute(pts.sublist(pts.length - 4), tension: tension).generateSamples(tolerance: 1e-4);
      Iterable<Curve2DSample> lastSegmentSample = sampleList;
      List<Curve2DSample> lastSegmentSampleList;
      if(firstIteration) {
        splinePath.moveTo(sampleList.first.value.dx, sampleList.first.value.dy);
        lastSegmentSampleList = lastSegmentSample.toList(growable: false);
      } else {
        lastSegmentSampleList = lastSegmentSample.where((element) => element.t > 0.58).toList(growable: false);
      }
      for(int i = 1; i < lastSegmentSampleList.length; i++){
        splinePath.lineTo(lastSegmentSampleList[i].value.dx, lastSegmentSampleList[i].value.dy);
      }
      _lastDrawnPoint = pts.last;
    }
  }

  Offset? _lastDrawnPoint;

  void addSingleStartPoint(Offset p){
    assert(points.isEmpty, "Points list is not empty.");
    points.add(p);
  }

  void addSinglePoint(Offset p, {double tolerance = _defaultInterpolatingGapWidth}){
    points.add(p);
    if (points.length >= 4){
      generate(points, firstIteration: points.length == 4);
    }
  }

  void shiftSplinePath(Offset delta){
    // for quick shift
    splinePath = splinePath.shift(delta);
  }

  void shiftPoints(Offset delta){
    for(int i = 0; i < points.length; i++){
      points[i] += delta;
    }
  }

  void closeSpline(){
    splinePath.close();
  }

  List<double> _sampleSplineNormal(List<Offset> points, List<Curve2DSample> sample, List<int> criticalPointIndices, {double tolerance = _toleranceWidth}){
    List<double> normals = [];
    int lastNearbySampleIndex = 0;
    for(int i = 1; i < points.length - 1; i++){
      List<Offset> nearbyPoints = [];
      for(int j = lastNearbySampleIndex; j < sample.length; j++){
        if(Rect.fromCenter(center: sample[j].value, width: tolerance, height: tolerance).contains(points[i])){
          nearbyPoints.add(sample[j].value);
          lastNearbySampleIndex = j;
          if(nearbyPoints.length == 3){
            break;
          }
        }
      }
      double d1, d2, d3;
      if(criticalPointIndices.contains(i)){
        d1 = (points[i + 1] - points[i]).direction;
        d2 = (points[i] - points[i - 1]).direction;
        normals.add((d1 + d2) / 2 + pi / 2);
        continue;
      }
      if(nearbyPoints.length < 3){
        if(lastNearbySampleIndex == 0){
          d1 = (sample[lastNearbySampleIndex + 1].value - sample[lastNearbySampleIndex].value).direction;
          d2 = (sample[lastNearbySampleIndex + 2].value - sample[lastNearbySampleIndex + 1].value).direction;
          d3 = (sample[lastNearbySampleIndex + 2].value - sample[lastNearbySampleIndex].value).direction;
        } else if (lastNearbySampleIndex == sample.length - 1){
          d1 = (sample[lastNearbySampleIndex].value - sample[lastNearbySampleIndex - 1].value).direction;
          d2 = (sample[lastNearbySampleIndex - 1].value - sample[lastNearbySampleIndex - 2].value).direction;
          d3 = (sample[lastNearbySampleIndex].value - sample[lastNearbySampleIndex - 2].value).direction;
        } else {
          d1 = (sample[lastNearbySampleIndex].value - sample[lastNearbySampleIndex - 1].value).direction;
          d2 = (sample[lastNearbySampleIndex + 1].value - sample[lastNearbySampleIndex].value).direction;
          d3 = (sample[lastNearbySampleIndex + 1].value - sample[lastNearbySampleIndex - 1].value).direction;
        }
        normals.add((d1 + d2 + d3) / 3 + pi / 2);
        continue;
      }
      if(nearbyPoints.length == 3){
        d1 = (nearbyPoints[1] - nearbyPoints[0]).direction;
        d2 = (nearbyPoints[2] - nearbyPoints[1]).direction;
        d3 = (nearbyPoints.last - nearbyPoints.first).direction;
        normals.add((d1 + d2 + d3) / 3 + pi / 2);
      }
    }
    // np
    return normals;
  }

  void endDraw(){
    drawEnd = true;
  }

  void resetPath(){
    splinePath.reset();
    points.clear();
  }

  List<int> criticalPointIndices = [];

  PathMetric computePathMetric(){
    return splinePath.computeMetrics().first;
  }

  List<Offset> filteredPoints = [];

  void filterPoints(double pointsGap, {bool overwrite = true}){
    List<Offset> finalPoints = [points.first];
    for(int i = 1; i < points.length - 1; i++){
      if((points[i] - finalPoints.last).distance > pointsGap){
        // Spacing final points
        finalPoints.add(points[i]);
      }
    }
    finalPoints.add(points.last);
    if(overwrite){
      points = finalPoints;
      filteredPoints = [];
    } else {
      filteredPoints = finalPoints;
    }
  }

  void computeCriticalPoints(List<Offset> offsets){
    for(int i = 1; i < offsets.length - 1; i++){
      if(dotProduct(offsets[i] - offsets[i - 1], offsets[i + 1] - offsets[i]) < 0){
        // Identifying critical points
        criticalPointIndices.add(i);
      }
    }
  }

  void enGenerate({SplineEffects effect = SplineEffects.normal, EffectsParameters? effectsParams, bool filter = true, bool computeMetric = false, bool overwrite = false}){
    double pointsGap = 8;
    if(computeMetric){
      PathMetric metric = computePathMetric();
      if(effectsParams != null){
        pointsGap = (metric.length / 4 * effectsParams.pointsGapCoefficient / 100).floorToDouble();
      }
    }
    criticalPointIndices.clear();
    if(filter){
      filterPoints(pointsGap, overwrite: overwrite);
      if(overwrite){
        computeCriticalPoints(points);
      }else{
        computeCriticalPoints(filteredPoints);
      }
    } else {
      computeCriticalPoints(points);
    }
    if(points.length >= 4 || filter && !overwrite && filteredPoints.length >= 4) {
      List<Curve2DSample> sample = CatmullRomSpline(filter && !overwrite ? filteredPoints : points).generateSamples(tolerance: 1e-12).toList();
      effectsParams ??= EffectsParameters();
      switch(effect){
        case SplineEffects.normal:
          splinePath = Path()..moveTo(sample.first.value.dx, sample.first.value.dy);
          for(int i = 0; i < sample.length; i++){
            splinePath.lineTo(sample[i].value.dx, sample[i].value.dy);
          }
          break;
        case SplineEffects.irregular:
          splinePath = irregularThicken(sample, maxWidth: effectsParams.maxWidth, variance: effectsParams.variance);
          break;
        case SplineEffects.taper:
          splinePath = taper(sample, maxWidth: effectsParams.maxWidth, endWidth: effectsParams.endWidth);
          break;
        case SplineEffects.wavy:
          splinePath = wavify(sample, maxWidth: effectsParams.maxWidth, variance: effectsParams.variance);
          break;
        default:
          throw UnimplementedError("Spline effects not implements");
      }
    }
  }

  Path wavify(List<Curve2DSample> sample, {double maxWidth = 5, double variance = 2}){
    List<double> normals = _sampleSplineNormal(points, sample.toList(), criticalPointIndices, tolerance: 2);
    List<Offset> irregularPoints = <Offset>[points.first];
    List<Offset> irregularMirrorPoints = <Offset>[points.first];
    int length = points.length;
    for(int i = 1; i < length - 1; i++){
      variance = i % 4 - 1.5;
      irregularPoints.add(points[i] + Offset.fromDirection(normals[i - 1], (maxWidth - variance) + variance * rand.nextDouble()));
      irregularMirrorPoints.add(points[i] + Offset.fromDirection(normals[i - 1] - pi, (maxWidth - variance) + variance * rand.nextDouble()));
    }
    irregularPoints.add(points.last);
    Path wavyPath = getCMRPath(irregularPoints + irregularMirrorPoints.reversed.toList(), close: true);
    return wavyPath;
  }

  Path irregularThicken(List<Curve2DSample> sample, {double maxWidth = 5, double variance = 2}){
    List<double> normals = _sampleSplineNormal(points, sample.toList(), criticalPointIndices, tolerance: 2);
    List<Offset> irregularPoints = <Offset>[points.first];
    List<Offset> irregularMirrorPoints = <Offset>[points.first];
    int length = points.length;
    for(int i = 1; i < length - 1; i++){
      irregularPoints.add(points[i] + Offset.fromDirection(normals[i - 1], (maxWidth - variance) + variance * rand.nextDouble()));
      irregularMirrorPoints.add(points[i] + Offset.fromDirection(normals[i - 1] - pi, (maxWidth - variance) + variance * rand.nextDouble()));
    }
    // Path path1 = Path();
    // Path path2 = Path();
    // for(int i = 1; i < length - 1; i++){
    //   Offset p1 = Offset.fromDirection(normals[i - 1], (maxWidth - variance) + variance * rand.nextDouble());
    //   Offset p2 = Offset.fromDirection(normals[i - 1] - pi, (maxWidth - variance) + variance * rand.nextDouble());
    //   irregularPoints.add(p1);
    //   path1.addPath(
    //     Path()
    //       ..moveTo(points[i].dx, points[i].dy)
    //       ..relativeLineTo(p1.dx, p1.dy),
    //     Offset.zero,
    //   );
    //   path2.addPath(
    //     Path()
    //       ..moveTo(points[i].dx, points[i].dy)
    //       ..relativeLineTo(p2.dx, p2.dy),
    //     Offset.zero,
    //   );
    // }
    // return [path1, path2];
    irregularPoints.add(points.last);
    List<Offset> finalPoints = irregularPoints + irregularMirrorPoints.reversed.toList();
    Path thickPath = getCMRPath(finalPoints, startHandle: finalPoints[finalPoints.length - 2], endHandle: finalPoints[1]);
    return thickPath;
  }

  Path taper(List<Curve2DSample> sample, {double maxWidth = 5, double endWidth : 0}){
    List<double> normals = _sampleSplineNormal(points, sample.toList(), criticalPointIndices, tolerance: 2);
    List<Offset> taperPoints = <Offset>[points.first];
    List<Offset> taperMirrorPoints = <Offset>[points.first];
    int length = points.length;
    double width = maxWidth - endWidth;
    for(int i = 1; i < length - 1; i++){
      taperPoints.add(points[i] + Offset.fromDirection(normals[i - 1], maxWidth - (i * (width)) / length));
      taperMirrorPoints.add(points[i] + Offset.fromDirection(normals[i - 1] - pi, maxWidth - (i * (width)) / length));
    }
    taperPoints.add(points.last);
    Path taperPath = getCMRPath(taperPoints + taperMirrorPoints.reversed.toList(), close: true);
    return taperPath;
  }

  void getTangent(){
    var metrics = splinePath.computeMetrics();
    var metric = metrics.first;
    metric.length;
  }

  void recalculateSplinePoints(double pointsGap){

  }
}
