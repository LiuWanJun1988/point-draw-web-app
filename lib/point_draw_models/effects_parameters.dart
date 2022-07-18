import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'dart:math' show pi, min, max;

import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart';
import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/utilities/spline_path.dart';

class EffectsParameters extends ChangeNotifier{

  SplineEffects type = SplineEffects.normal;
  double pointsGapCoefficient = 0.0;
  double maxWidth = 5.0;
  double variance = 2.0;
  double endWidth = 0.0;

  EffectsParameters(
      {
        this.type = SplineEffects.normal,
        this.maxWidth = 5.0,
        this.variance = 2.0,
        this.endWidth = 0.0,
        this.pointsGapCoefficient = 0.0,
      });

  EffectsParameters.fromData(Map<String, dynamic> data){
    type = getSplineEffect(data[splineEffectKey]);
    pointsGapCoefficient = data[pointsGapCoefficientKey];
    maxWidth = data[effectsMaxWidthKey];
    variance = data[effectsVarianceKey];
    endWidth = data[endWidthKey];
  }

  EffectsParameters copy(){
    return EffectsParameters(
      type: type,
      maxWidth: maxWidth,
      variance: variance,
      endWidth: endWidth,
      pointsGapCoefficient: pointsGapCoefficient
    );
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = {
      splineEffectKey: type.name,
      effectsMaxWidthKey: maxWidth,
      effectsVarianceKey: variance,
      endWidthKey: endWidth,
      pointsGapCoefficientKey: pointsGapCoefficient,
    };
    return data;
  }

  void build({Rect? boundingRect, Matrix4? zoomTransform}){
    switch(type){
      case SplineEffects.normal:
        break;
      default:
        throw UnimplementedError("Building shader of type: $type not implemented");
    }
  }

  void reset(){
    type = SplineEffects.normal;
    pointsGapCoefficient = 0.0;
    maxWidth = 5.0;
    variance = 2.0;
    endWidth = 0.0;
    notifyListeners();
  }
}