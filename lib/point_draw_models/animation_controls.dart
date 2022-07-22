import 'package:flutter/material.dart';

import 'dart:math' show max, min;

class AnimationControls extends ChangeNotifier{

  double panelLocationDy = 0;
  double panelLocationDx = 0;

  bool repeat = true;
  bool paused = false;
  Duration animationDuration = const Duration(seconds: 1);
  double? _lastElapsedValue;

  AnimationController animationController;

  AnimationControls(this.animationController){

    animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        notifyListeners();
      }
    });
    animationController.stop();
  }

  Curve _curve = Curves.linear;

  set curve(Curve newCurve) => _curve = newCurve;

  bool get playOn => animationController.isAnimating;

  bool get isPaused => !playOn && _lastElapsedValue != null;

  bool get stopped => !playOn && _lastElapsedValue == null;

  AnimationController get controller => animationController;

  void updatePanelLocation(Offset delta, Size size){
    Offset newOffset = Offset(panelLocationDx, panelLocationDy) + delta;
    panelLocationDx = min(max(newOffset.dx, 0), size.width - 300);
    panelLocationDy = min(max(newOffset.dy, 0), size.height - 36);
    notifyListeners();
  }

  void turnOnAnimation(){
    if(repeat){
      animationController.repeat(reverse: true, period: animationDuration);
    } else {
      animationController.forward(from: _lastElapsedValue ?? animationController.lowerBound);
    }
    notifyListeners();
  }

  void stopAnimation(){
    animationController.stop();
    _lastElapsedValue = null;
    notifyListeners();
  }

  void pauseAnimation(){
    _lastElapsedValue = animationController.value;
    animationController.stop(canceled: false);
    notifyListeners();
  }

  void resetAnimation(){
    animationController.reset();
    if(repeat){
      animationController.repeat(reverse: true, period: animationDuration);
    } else {
      animationController.forward();
    }
    notifyListeners();
  }

  set setController(AnimationController controller){
    animationController = controller;
    animationController.duration = animationDuration;
    if(repeat){
      animationController.repeat(reverse: true, period: animationDuration);
    }
  }

  void toggleRepeatAnimation(){
    repeat = !repeat;
    if(repeat){
      animationController.repeat(reverse: true, period: animationDuration);
    } else {
      animationController.repeat(min: 0, max:0, reverse: false);
    }
    notifyListeners();
  }

  void incrementDuration(){
    animationDuration = Duration(seconds: animationDuration.inSeconds + 1);
    notifyListeners();
  }

  void decrementDuration(){
    animationDuration = Duration(seconds: max(animationDuration.inSeconds - 1, 1));
  }

  void getStats(){
    animationController;
  }

  @override
  void dispose(){
    // animationController.dispose();
    super.dispose();
  }
}