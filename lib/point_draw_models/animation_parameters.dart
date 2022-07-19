import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'dart:math' show pi, min, max;

import 'package:pointdraw/point_draw_models/utilities/matrices.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart';

enum AnimatedProperty{controlPoint, restrictedControlPoint, dataControlPoint, strokeColor, fillColor, double}

class AnimationParams extends ChangeNotifier{

  bool enableAnimate = false;

  static Tween<Offset> offsetTween = Tween<Offset>(begin: Offset.zero, end: const Offset(50, 50));
  static Tween<Color> colorTween = Tween<Color>(begin: Colors.white, end: Colors.black);
  static Tween<double> doubleTween = Tween<double>();

  AnimationParams();

  Map<int, Tween<Offset>> animatedControlPoints = const {};

  Map<int, Tween<Offset>> animatedRestrictedControlPoints = const {};

  Map<int, Tween<Offset>> animatedDataControlPoints = const {};

  Tween? animatedStrokeColor;

  Tween? animatedFillColor;

  void toggleAnimateEnable(){
    enableAnimate = !enableAnimate;
    notifyListeners();
  }

  void addAnimatedControlPoint(int index, {Tween<Offset>? tween}){
    tween ??= Tween<Offset>(begin: Offset.zero, end: const Offset(50, 50));
    if(!animatedControlPoints.keys.contains(index)){
      animatedControlPoints = Map.from({
        index: tween,
        for(var kv in animatedControlPoints.entries)
          kv.key: kv.value,
      });
    }
    notifyListeners();
  }

  void removeAnimatedControlPoint(int index){
    animatedControlPoints.remove(index);
    notifyListeners();
  }

  void addAnimatedRestrictedControlPoint(int index, {Tween<Offset>? tween}){
    tween ??= Tween<Offset>();
    if(!animatedRestrictedControlPoints.keys.contains(index)){
      animatedRestrictedControlPoints.addAll({
        index: tween
      });
    }
    notifyListeners();
  }

  void removeAnimatedRestrictedControlPoint(int index){
    animatedRestrictedControlPoints.remove(index);
    notifyListeners();
  }

  void addAnimatedDataControlPoint(int index, {Tween<Offset>? tween}){
    tween ??= Tween<Offset>();
    if(!animatedDataControlPoints.keys.contains(index)){
      animatedDataControlPoints.addAll({
        index: tween
      });
    }
    notifyListeners();
  }

  void removeAnimatedDataControlPoint(int index){
    animatedDataControlPoints.remove(index);
    notifyListeners();
  }

  set setAnimateStrokeColor(Tween<Color> tween) => animatedStrokeColor = tween;

  set setAnimateFillColor(Tween<Color> tween) => animatedFillColor = tween;

}