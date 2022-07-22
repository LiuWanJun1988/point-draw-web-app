import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:pointdraw/point_draw_models/keys_and_names.dart';

import 'dart:math' show pi, sqrt2;

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/point_draw_one_dimensional.dart';
import 'package:pointdraw/point_draw_models/point_draw_state_notifier.dart';
import 'package:pointdraw/point_draw_models/svg/svg_builder.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/matrices.dart' show rotateZAbout;
import 'package:pointdraw/point_draw_models/app_components/action_button.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart' show rotate;

class PointDrawComposite extends PointDrawOneDimensionalObject {

  List<_PointDrawCompositable> composites = [];

  bool smoothChain = false;

  PointDrawComposite.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot, {required ObjectKey key}
      ) : super.fromDocument(snapshot, mode: EditingMode.compositePath, key: key){
    enableDeleteControlPoint = true;
  }

  PointDrawComposite({required ObjectKey key}) : super(mode: EditingMode.compositePath, key: key){
    supplementaryPropertiesModifiers.add(getCompositeObjectsButton);
    enableDeleteControlPoint = true;
  }

  PointDrawComposite.from(PointDrawComposite object, {Offset displacement = const Offset(5, 5), required ObjectKey key}) : super.from(object, displacement: displacement, mode: EditingMode.compositePath, key: key){
    for(dynamic pdc in object.composites){
      composites.add(pdc.duplicate());
    }
    enableDeleteControlPoint = true;
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}){
    Map<String, dynamic> data = super.toJson(parsePoints: false);
    data[editingModeKey] = mode.name;
    data[compositesKey] = [for(var comp in composites) comp.toJson(),];
    data[smoothChainKey] = smoothChain;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}){
    super.toObject(data, parsePoints: false);
    List compositesData = data[compositesKey];
    composites = List.generate(compositesData.length, (ind) => getNewPointCompositable(getEditingMode(compositesData[ind][editingModeKey]))..toObject(compositesData[ind]));
    for(var comp in composites){
      points.addAll(comp.points);
    }
    if(data.containsKey(smoothChainKey)){
      smoothChain = data[smoothChainKey];
    }
  }

  @override
  Path getPath() {
    Path compositePath = Path();
    for(int i = 0; i < composites.length; i++){
      if(i < composites.length - 1){
        compositePath.extendWithPath(composites[i].getPath(), Offset.zero);
      } else {
        List<Offset> pts;
        if(closed){
          pts = composites.last.points + List<Offset>.filled(composites.last.pointsToFill, points.first);
        } else {
          pts = composites.last.points;
        }
        compositePath.extendWithPath(composites.last.getPath(pts: pts), Offset.zero);
      }
    }
    return compositePath;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedCompositePath = Path();
    int cpFrom = 0;
    int cpTo;
    Map<int, Tween<Offset>> animatedCPs;
    if(composites.isNotEmpty){
      cpTo = composites[0].points.length;
      animatedCPs = Map<int, Tween<Offset>>.from(animationParams.animatedControlPoints)
        ..removeWhere((k,v) => k >= cpTo);
      animatedCompositePath.addPath(composites[0].getAnimatedPath(ticker, animatedCPs), Offset.zero);
      Tween<Offset>? lastPointAnimatingTween = animatedCPs.containsKey(cpTo - 1) ? animatedCPs[cpTo - 1] : null;
      if(composites.length > 1){
        for(int i = 1; i < composites.length; i ++){
          cpFrom = cpTo;
          cpTo = cpFrom + composites[i].points.length;
          animatedCPs =
          {
            for(var kv in animationParams.animatedControlPoints.entries)
              if(kv.key >= cpFrom && kv.key < cpTo)
                kv.key - cpFrom + 1: kv.value,
          };
          if(lastPointAnimatingTween != null){
            animatedCPs.addAll({0: lastPointAnimatingTween});
          }
          animatedCompositePath.extendWithPath(composites[i].getAnimatedPath(ticker, animatedCPs), Offset.zero);
          lastPointAnimatingTween = animatedCPs.containsKey(composites[i].points.length - 1) ? animatedCPs[composites[i].points.length - 1] : null;
        }
      }
    }
    if(closed){
      animatedCompositePath.close();
    }
    return animatedCompositePath;
  }

  void updateChainedPoints(Offset newOffset, int indexMoved){
    // TODO: to implement
  }

  @override
  Path getParametrizedPath(double end, {double start = 0, Path? from}){
    Path path = from ?? Path();
    // TODO:
    return path;
  }


  @override
  bool get isInitialized => composites.isNotEmpty && composites.first.hasPath;

  @override
  void initialize(Offset firstPoint, Offset secondPoint){
    if(composites.length == 1 && !composites.last.hasPath){
      composites.last.initialize(firstPoint, secondPoint, null);
      points.addAll(composites.last.points);
    }
    if(composites.length >= 2 && !composites.last.hasPath){
      composites.last.initialize(firstPoint, secondPoint, composites[composites.length - 2].points.last);
      points.addAll(composites.last.points);
    }
  }

  @override
  bool get validNewPoint => composites.isNotEmpty && composites.last.validNewPoint;

  @override
  void addControlPoint(Offset newPoint){
    super.addControlPoint(newPoint);
    composites.last.addControlPoint(newPoint);
  }

  @override
  void deleteControlPoint(int index, {bool notify = true}){
    super.deleteControlPoint(index, notify: false);
    int cpFrom = 0;
    int cpLen;
    for(int i = 0; i < composites.length; i++){
      cpLen = composites[i].points.length;
      if(index < cpFrom + cpLen){
        composites[i].deleteControlPoint(index - cpFrom, notify: false);
        break;
      }
      cpFrom += cpLen;
    }
    if(notify){
      notifyListeners();
    }
  }

  @override
  PointDrawComposite moveControlPoint(Offset newPosition, int index, {Map<String, dynamic>? args}){
    super.moveControlPoint(newPosition, index, args: args);
    int cpFrom = 0;
    int cpLen;
    for(int i = 0; i < composites.length; i++){
      cpLen = composites[i].points.length;
      if(index < cpFrom + cpLen){
        composites[i] = composites[i].moveControlPoint(newPosition, index - cpFrom, args: args);
        if(index == cpFrom + cpLen - 1 && i < composites.length - 1){
          composites[i+1].startHandle = newPosition;
        }
        break;
      }
      cpFrom += cpLen;
    }
    return this;
  }

  void updateComposites(){
    int cpFrom = 0;
    int cpTo;
    Offset? startHandle;
    if(composites.isNotEmpty){
      cpTo = cpFrom + composites.first.points.length;
      composites[0].points = points.sublist(cpFrom, cpTo);
      cpFrom = cpTo;
      startHandle = composites.first.points.isNotEmpty ? composites.first.points.last : null;
      if(composites.length > 1){
        for(int i = 1; i < composites.length; i++){
          _PointDrawCompositable c = composites[i];
          cpTo = cpFrom + c.points.length;
          composites[i].startHandle = startHandle;
          composites[i].points = points.sublist(cpFrom, cpTo);
          cpFrom = cpTo;
          startHandle = composites[i].points.isNotEmpty ? composites[i].points.last : null;
        }
      }
    }

  }

  @override
  PointDrawComposite transformByTranslate(double dx, double dy, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    super.transformByTranslate(dx, dy, zoomTransform, groupControlPoints: groupControlPoints);
    updateComposites();
    return this;
  }

  @override
  PointDrawComposite transformByRotate(Offset center, double angle, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    super.transformByRotate(center, angle, zoomTransform, groupControlPoints: groupControlPoints);
    updateComposites();
    return this;
  }

  @override
  PointDrawComposite transformByHorizontalScale(Offset stationary, double scaleFactor, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    super.transformByHorizontalScale(stationary, scaleFactor, zoomTransform, groupControlPoints: groupControlPoints);
    updateComposites();
    return this;
  }

  @override
  PointDrawComposite transformByVerticalScale(Offset stationary, double scaleFactor, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    super.transformByVerticalScale(stationary, scaleFactor, zoomTransform, groupControlPoints: groupControlPoints);
    updateComposites();
    return this;
  }

  @override
  PointDrawComposite transformByScale(Offset stationary, Offset scaleFactor, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    super.transformByScale(stationary, scaleFactor, zoomTransform, groupControlPoints: groupControlPoints);
    updateComposites();
    return this;
  }

  @override
  void flipHorizontal(Matrix4 zoomTransform, {Offset? center}){
    super.flipHorizontal(zoomTransform, center: center);
    updateComposites();
  }

  @override
  void flipVertical(Matrix4 zoomTransform, {Offset? center}){
    super.flipVertical(zoomTransform, center: center);
    updateComposites();
  }

  @override
  PointDrawComposite duplicate({Offset? center}){
    if(center != null){
      Offset displacement = center - boundingRect.center;
      return PointDrawComposite.from(this, displacement: displacement, key: ObjectKey("Composite:" + generateAutoID()));
    } else {
      return PointDrawComposite.from(this, key: ObjectKey("Composite:" + generateAutoID()));
    }
  }

  Widget getCompositeObjectsButton(){

    void trimLastComposite(){
      if(composites.isNotEmpty){
        int lastCompositeUnusedPoints = composites.last.points.length - composites.last.usedPointsCount;
        int i = 0;
        while(i < lastCompositeUnusedPoints){
          points.removeLast();
          composites.last.points.removeLast();
          i++;
        }
        if(!composites.last.hasPath){
          composites.removeLast();
        }
      }

      assert((){
        int count = 0;
        for(var comp in composites){
          count += comp.points.length;
        }
        return count == points.length;
      }(), "");
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NewLineActionButton(stateControl: composites.isNotEmpty && composites.last.mode == EditingMode.line, onPressed: () {
          trimLastComposite();
          if(composites.isNotEmpty){
            composites.add(PointDrawCompositableLine(startHandle: composites.last.points.last));
            notifyListeners();
          } else {
            composites.add(PointDrawCompositableLine());
            notifyListeners();
          }
        }),
        NewSplineCurveActionButton(stateControl: composites.isNotEmpty && composites.last.mode == EditingMode.splineCurve, onPressed: (){
          trimLastComposite();
          if(composites.isNotEmpty){
            composites.add(PointDrawCompositableSplineCurve(startHandle: composites.last.points.last));
            notifyListeners();
          } else{
            composites.add(PointDrawCompositableSplineCurve());
            notifyListeners();
          }
        }),
        NewQuadraticBezierActionButton(stateControl: composites.isNotEmpty && composites.last.mode == EditingMode.quadraticBezier, onPressed: (){
          trimLastComposite();
          if(composites.isNotEmpty){
            composites.add(PointDrawCompositableQuadraticBezier(startHandle: composites.last.points.last));
            notifyListeners();
          } else {
            composites.add(PointDrawCompositableQuadraticBezier());
            notifyListeners();
          }
        }),
        NewCubicBezierActionButton(stateControl: composites.isNotEmpty && composites.last.mode == EditingMode.cubicBezier, onPressed: (){
          trimLastComposite();
          if(composites.isNotEmpty){
            composites.add(PointDrawCompositableCubicBezier(startHandle: composites.last.points.last));
            notifyListeners();
          } else {
            composites.add(PointDrawCompositableCubicBezier());
            notifyListeners();
          }
        }),
      ],
    );
  }

  @override
  String toString() => "Composite";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}


// This is a reduced version of a point draw object. It does not keep data on paint, shader, or animation.
// However, it has keeps record of the control points, restricted control points, data control points, and
// how these points are transformed. A compositable cannot stand alone as an object to be painted on the canvas,
// but forms part of the PointDrawComposite object, which will be the fully capable
// point draw object. Thus, it does not interface when the database or get duplicated.

abstract class _PointDrawCompositable extends PointDrawStateNotifier{

  _PointDrawCompositable({this.mode = EditingMode.compositePath, this.startHandle, this.points = const <Offset>[]});

  _PointDrawCompositable.from(_PointDrawCompositable compositable, {this.mode = EditingMode.compositePath}){
    mode = compositable.mode;
    points = List<Offset>.generate(compositable.points.length, (ind) => compositable.points[ind]);
    startHandle = compositable.startHandle;
  }

  // Editing mode of this odk path
  EditingMode mode;

  // A tracker for whether a compositable is the head of the composite object.
  // If a compositable's startHandle is null, there is no previous compositable
  // before the current, therefore it is at the head of the composite object,
  // which means it must have index 0 in the list of composites in its parent composite
  // object.

  Offset? startHandle;

  List<Offset> points = <Offset>[];

  bool get validNewPoint;

  bool get hasPath;

  int get usedPointsCount;

  int get pointsToFill;

  void initialize(Offset firstPoint, Offset secondPoint, Offset? startHandle);

  Map<String, dynamic> toJson({bool parsePoints = true}){
    Map<String, dynamic> data = {
      editingModeKey: mode.name,
      startHandleXKey: startHandle?.dx,
      startHandleYKey: startHandle?.dy,
    };
    if(parsePoints){
      List<Map<String, double>> pts = [for(Offset p in points) {xCoordinateKey: p.dx, yCoordinateKey: p.dy}];
      data[controlPointsKey] = pts;
    }
    return data;
  }

  void toObject(Map<String, dynamic> data, {bool parsePoints = true}){
    mode = getEditingMode(data[editingModeKey]);
    if(parsePoints){
      List<Map<String, double>> cpData = [for(Map o in data[controlPointsKey]) Map.from(o)];
      for(int i = 0; i < cpData.length; i++){
        points += [Offset(cpData[i][xCoordinateKey]!, cpData[i][yCoordinateKey]!)];
      }
    }
    if(data[startHandleYKey] != null && data[startHandleXKey] != null){
      startHandle = Offset(data[startHandleXKey], data[startHandleYKey]);
    }
  }

  Path getPath({List<Offset>? pts});

  // Use this when animate is enabled
  Path getAnimatedPath(double ticker, Map<int, Tween<Offset>> animatedControlPoints);

  // Return animated control points
  List<Offset> getAnimatedPoints(double ticker, Map<int, Tween<Offset>>? animatedControlPoints){
    if(startHandle != null){
      List<Offset> controlPoints = [startHandle!, ...points];
      List<Offset> animatedPoints = List<Offset>.generate(points.length + 1, (ind){
        if(animatedControlPoints?.keys.contains(ind) ?? false){
          return controlPoints[ind] + animatedControlPoints![ind]!.begin! * ticker + animatedControlPoints[ind]!.end! * (1 - ticker);
        } else {
          return controlPoints[ind];
        }
      });
      return animatedPoints;
    } else {
      List<Offset> animatedPoints = List<Offset>.generate(points.length, (ind){
        if(animatedControlPoints?.keys.contains(ind) ?? false){
          return points[ind] + animatedControlPoints![ind]!.begin! * ticker + animatedControlPoints[ind]!.end! * (1 - ticker);
        } else {
          return points[ind];
        }
      });
      return animatedPoints;
    }
  }

  void autoInitializeControlPoints(){
    return;
  }

  void addControlPoint(Offset newPoint){
    points = [...points, newPoint];
    autoInitializeControlPoints();
    notifyListeners();
  }

  void deleteControlPoint(int index, {bool notify = true}){
    points.removeAt(index);
    if(notify){
      notifyListeners();
    }
  }

  @override
  void updateObject(Function(_PointDrawCompositable) updatingCall, {bool executeAll = true, List<StateSetter> exclusion = const []}){
    updatingCall.call(this);
    notifyListeners();
  }

  // Transformation functions
  @mustCallSuper
  _PointDrawCompositable moveControlPoint(Offset newPosition, int index, {Map<String, dynamic>? args}){
    points[index] = newPosition;
    return this;
  }

  @mustCallSuper
  _PointDrawCompositable updateRDSCPWhenCPMoved(Matrix4 zoomTransform, {Map<String, dynamic> args = const {}}){
    return this;
  }

  _PointDrawCompositable transformByTranslate(double dx, double dy, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    points = groupControlPoints ?? List<Offset>.generate(points.length, (ind) => points[ind] + Offset(dx, dy));
    return this;
  }

  _PointDrawCompositable transformByRotate(Offset center, double angle, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    points = groupControlPoints ?? List<Offset>.generate(points.length, (ind) => rotate(points[ind], center, angle));
    return this;
  }

  _PointDrawCompositable transformByHorizontalScale(Offset stationary, double scaleFactor, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    points = groupControlPoints ?? List<Offset>.generate(points.length, (ind) => Offset(stationary.dx + (points[ind].dx - stationary.dx) * scaleFactor, points[ind].dy));
    return this;
  }

  _PointDrawCompositable transformByVerticalScale(Offset stationary, double scaleFactor, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    points = groupControlPoints ?? List<Offset>.generate(points.length, (ind) => Offset(points[ind].dx, stationary.dy + (points[ind].dy - stationary.dy) * scaleFactor));
    return this;
  }

  _PointDrawCompositable transformByScale(Offset stationary, Offset scaleFactor, Matrix4 zoomTransform, {List<Offset>? groupControlPoints}){
    points = groupControlPoints ?? List<Offset>.generate(points.length, (ind) => Offset(stationary.dx + (points[ind].dx - stationary.dx) * scaleFactor.dx, stationary.dy + (points[ind].dy - stationary.dy) * scaleFactor.dy));
    return this;
  }

  _PointDrawCompositable duplicate(){
    // returns a translated copy of this compositable. This will be called by duplicate of the PointDrawComposite object.
    throw UnimplementedError("Subclass should override this method");
  }
}

class PointDrawCompositableLine extends _PointDrawCompositable{

  //A compositable line is polygonal and non-closed intrinsically

  PointDrawCompositableLine({Offset? startHandle}) : super(mode: EditingMode.line, startHandle: startHandle);

  PointDrawCompositableLine.from(PointDrawCompositableLine line, {EditingMode mode = EditingMode.line}) : super.from(line);

  @override
  bool get validNewPoint => true;

  @override
  bool get hasPath => startHandle != null ? points.isNotEmpty : points.length >= 2;

  @override
  int get usedPointsCount => points.length;

  @override
  int get pointsToFill => 1;

  @override
  void initialize(Offset firstPoint, Offset secondPoint, Offset? startHandle){
    if(startHandle != null){
      startHandle = startHandle;
      points = [secondPoint];
    } else {
      points = [firstPoint, secondPoint];
    }
  }

  @override
  Path getPath({List<Offset>? pts}){
    if(startHandle != null && points.isNotEmpty){
      return Path()
        ..addPolygon([
          startHandle!,
          ...(pts ?? points)
        ], false);
    } else if (points.length >= 2){
      return Path()
        ..addPolygon(pts ?? points, false);
    }
    return Path();
  }

  @override
  Path getAnimatedPath(double ticker, Map<int, Tween<Offset>> animatedControlPoints){
    if(startHandle != null && points.isNotEmpty){
      return Path()
        ..addPolygon([
          startHandle!,
          ...getAnimatedPoints(ticker, animatedControlPoints)
        ], false);
    } else if (points.length >= 2){
      return Path()
        ..addPolygon(getAnimatedPoints(ticker, animatedControlPoints), false);
    }
    return Path();
  }

  @override
  PointDrawCompositableLine duplicate(){
    return PointDrawCompositableLine.from(this);
  }
}

class PointDrawCompositableSplineCurve extends _PointDrawCompositable {

  // Compositables are intrinsically not closed.

  PointDrawCompositableSplineCurve({Offset? startHandle}) : super(mode: EditingMode.splineCurve, startHandle: startHandle);

  PointDrawCompositableSplineCurve.from(PointDrawCompositableSplineCurve spline, {EditingMode mode = EditingMode.splineCurve}) : super.from(spline);

  @override
  void initialize(Offset firstPoint, Offset secondPoint, Offset? startHandle){
    if(startHandle != null){
      startHandle = startHandle;
      points = [firstPoint, (firstPoint + secondPoint) * 0.5, secondPoint];
    } else {
      points = [firstPoint, firstPoint * 0.67 + secondPoint * 0.33, firstPoint * 0.33 + secondPoint * 0.67, secondPoint];
    }
  }

  @override
  Path getPath({List<Offset>? pts}) {
    Path cmrPath = Path();
    if(startHandle != null && points.length >= 3){
      CatmullRomSpline cmrSpline = CatmullRomSpline([
        startHandle!,
        ...(pts ?? points),
      ]);
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      cmrPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for(Curve2DSample pt in samples){
        cmrPath.lineTo(pt.value.dx, pt.value.dy);
      }
    } else if (points.length >= 4){
      CatmullRomSpline cmrSpline = CatmullRomSpline(pts ?? points);
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      cmrPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for(Curve2DSample pt in samples){
        cmrPath.lineTo(pt.value.dx, pt.value.dy);
      }
    }
    return cmrPath;
  }

  @override
  Path getAnimatedPath(double ticker, Map<int, Tween<Offset>> animatedControlPoints){
    Path animatedCMRPath = Path();
    if((startHandle != null && points.length >= 3) || points.length >= 4){
      CatmullRomSpline cmrSpline = CatmullRomSpline(getAnimatedPoints(ticker, animatedControlPoints));
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      animatedCMRPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for(Curve2DSample pt in samples){
        animatedCMRPath.lineTo(pt.value.dx, pt.value.dy);
      }
    }
    return animatedCMRPath;
  }

  @override
  bool get hasPath => startHandle != null ? points.length >= 3 : points.length >=4;

  @override
  bool get validNewPoint => true;

  @override
  int get usedPointsCount {
    if(startHandle != null){
      return points.length > 2 ? points.length : 0;
    } else {
      return points.length > 3 ? points.length : 0;
    }
  }

  @override
  int get pointsToFill {
    if(startHandle != null){
      return points.length >= 3 ? 1 : 3 - points.length;
    } else {
      return points.length >= 4 ? 1 : 4 - points.length;
    }
  }

  @override
  PointDrawCompositableSplineCurve duplicate(){
    return PointDrawCompositableSplineCurve.from(this);
  }
}


class PointDrawCompositableQuadraticBezier extends _PointDrawCompositable {

  // Compositable beziers are intrinsically non-closed and chained

  PointDrawCompositableQuadraticBezier({Offset? startHandle}) : super(mode: EditingMode.quadraticBezier, startHandle: startHandle);

  PointDrawCompositableQuadraticBezier.from(PointDrawCompositableQuadraticBezier quadraticBezier) : super.from(quadraticBezier);

  @override
  void initialize(Offset firstPoint, Offset secondPoint, Offset? startHandle){
    if(startHandle != null){
      startHandle = startHandle;
      points = [firstPoint, secondPoint];
    } else {
      points = [firstPoint, (firstPoint + secondPoint) * 0.5, secondPoint];
    }
  }

  @override
  Path getPath({List<Offset>? pts}) {
    Path quadraticBezier = Path();
    if(pts != null){
      if(startHandle != null && pts.length >= 2){
        List<Offset> controlPoints = [startHandle!, ...pts];
        quadraticBezier.moveTo(controlPoints.first.dx, controlPoints.first.dy);
        for(int i = 1; i + 1 < controlPoints.length; i += 2){
          quadraticBezier.quadraticBezierTo(controlPoints[i].dx, controlPoints[i].dy, controlPoints[i + 1].dx, controlPoints[i + 1].dy);
        }
      } else if (pts.length >= 3){
        quadraticBezier.moveTo(points.first.dx, points.first.dy);
        for(int i = 1; i + 1 < pts.length; i += 2){
          quadraticBezier.quadraticBezierTo(pts[i].dx, pts[i].dy, pts[i + 1].dx, pts[i + 1].dy);
        }
      }
    } else {
      if(startHandle != null && points.length >= 2){
        List<Offset> controlPoints = [startHandle!, ...points];
        quadraticBezier.moveTo(controlPoints.first.dx, controlPoints.first.dy);
        for(int i = 1; i + 1 < controlPoints.length; i += 2){
          quadraticBezier.quadraticBezierTo(controlPoints[i].dx, controlPoints[i].dy, controlPoints[i + 1].dx, controlPoints[i + 1].dy);
        }
      } else if (points.length >= 3){
        quadraticBezier.moveTo(points.first.dx, points.first.dy);
        for(int i = 1; i + 1 < points.length; i += 2){
          quadraticBezier.quadraticBezierTo(points[i].dx, points[i].dy, points[i + 1].dx, points[i + 1].dy);
        }
      }
    }
    return quadraticBezier;
  }

  @override
  Path getAnimatedPath(double ticker, Map<int, Tween<Offset>> animatedControlPoints){
    Path animatedQuadraticBezier = Path();
    if((startHandle != null && points.length >= 2) || points.length >= 3){
      List<Offset> animatedPoints = getAnimatedPoints(ticker, animatedControlPoints);
      animatedQuadraticBezier.moveTo(animatedPoints.first.dx, animatedPoints.first.dy);
      for(int i = 1; i + 1 < points.length; i += 2){
        animatedQuadraticBezier.quadraticBezierTo(animatedPoints[i].dx, animatedPoints[i].dy, animatedPoints[i + 1].dx, animatedPoints[i + 1].dy);
      }
    }
    return animatedQuadraticBezier;
  }

  @override
  bool get hasPath => startHandle != null ? points.length >= 2 : points.length >= 3;

  @override
  bool get validNewPoint => true;

  @override
  int get usedPointsCount {
    if(startHandle != null){
      if (points.length >= 2 && points.length % 2 == 1){
        return points.length - 1;
      }
      if(points.length >= 2 && points.length % 2 == 0){
        return points.length;
      }
      return 0;
    } else {
      if (points.length >= 3 && points.length % 2 == 1){
        return points.length;
      }
      if(points.length >= 3 && points.length % 2 == 0){
        return points.length - 1;
      }
      return 0;
    }
  }

  @override
  int get pointsToFill {
    if(startHandle != null){
      return 2 - points.length % 2;
    } else {
      return points.length >= 3 ? points.length % 2 + 1 : 3 - points.length;
    }
  }

  @override
  PointDrawCompositableQuadraticBezier duplicate(){
    return PointDrawCompositableQuadraticBezier.from(this);
  }
}

class PointDrawCompositableCubicBezier extends _PointDrawCompositable {

  // Compositable beziers are intrinsically non-closed and chained

  PointDrawCompositableCubicBezier({Offset? startHandle}) : super(mode: EditingMode.cubicBezier, startHandle: startHandle);

  PointDrawCompositableCubicBezier.from(PointDrawCompositableCubicBezier cubicBezier) : super.from(cubicBezier);

  @override
  void initialize(Offset firstPoint, Offset secondPoint, Offset? startHandle){
    if(startHandle != null){
      startHandle = startHandle;
      points = [firstPoint, (firstPoint + secondPoint) * 0.5, secondPoint];
    } else {
      points = [firstPoint, firstPoint * 0.67 + secondPoint * 0.33, firstPoint * 0.33 + secondPoint * 0.67, secondPoint];
    }
  }

  @override
  Path getPath({List<Offset>? pts}) {
    Path cubicBezier = Path();
    if(pts != null){
      if(startHandle != null && pts.length >= 3){
        List<Offset> controlPoints = [startHandle!, ...pts];
        cubicBezier.moveTo(controlPoints.first.dx, controlPoints.first.dy);
        for(int i = 1; i + 2 < controlPoints.length; i += 3){
          cubicBezier.cubicTo(controlPoints[i].dx, controlPoints[i].dy, controlPoints[i + 1].dx, controlPoints[i + 1].dy, controlPoints[i + 2].dx, controlPoints[i + 2].dy,);
        }
      } else if(pts.length >= 4){
        cubicBezier.moveTo(pts.first.dx, pts.first.dy);
        for(int i = 1; i + 2 < pts.length; i += 3){
          cubicBezier.cubicTo(pts[i].dx, pts[i].dy, pts[i + 1].dx, pts[i + 1].dy, pts[i + 2].dx, pts[i + 2].dy,);
        }
      }
    } else {
      if(startHandle != null && points.length >= 3){
        List<Offset> controlPoints = [startHandle!, ...(pts ?? points)];
        cubicBezier.moveTo(controlPoints.first.dx, controlPoints.first.dy);
        for(int i = 1; i + 2 < controlPoints.length; i += 3){
          cubicBezier.cubicTo(controlPoints[i].dx, controlPoints[i].dy, controlPoints[i + 1].dx, controlPoints[i + 1].dy, controlPoints[i + 2].dx, controlPoints[i + 2].dy,);
        }
      } else if(points.length >= 4){
        cubicBezier.moveTo(points.first.dx, points.first.dy);
        for(int i = 1; i + 2 < points.length; i += 3){
          cubicBezier.cubicTo(points[i].dx, points[i].dy, points[i + 1].dx, points[i + 1].dy, points[i + 2].dx, points[i + 2].dy,);
        }
      }
    }
    return cubicBezier;
  }

  @override
  Path getAnimatedPath(double ticker, Map<int, Tween<Offset>> animatedControlPoints){
    Path animatedCubicBezier = Path();
    if((startHandle != null && points.length >=3) || points.length >= 4){
      List<Offset> animatedPoints = getAnimatedPoints(ticker, animatedControlPoints);
      animatedCubicBezier.moveTo(animatedPoints.first.dx, animatedPoints.first.dy);
      for(int i = 1; i + 2 < animatedPoints.length; i += 3){
        animatedCubicBezier.cubicTo(animatedPoints[i].dx, animatedPoints[i].dy, animatedPoints[i + 1].dx, animatedPoints[i + 1].dy, animatedPoints[i + 2].dx, animatedPoints[i + 2].dy,);
      }
    }
    return animatedCubicBezier;
  }

  @override
  bool get hasPath => startHandle != null ? points.length >= 3 : points.length >= 4;

  @override
  bool get validNewPoint => true;

  @override
  int get usedPointsCount {
    if(startHandle != null){
      if (points.length >= 3 && points.length % 3 == 1){
        return points.length - 1;
      }
      if(points.length >= 3 && points.length % 3 == 0){
        return points.length;
      }
      if(points.length >= 3 && points.length % 3 == 2){
        return points.length - 2;
      }
      return 0;
    } else {
      if (points.length >= 4 && points.length % 3 == 2){
        return points.length - 1;
      }
      if(points.length >= 4 && points.length % 3 == 1){
        return points.length;
      }
      if(points.length >= 4 && points.length % 3 == 0){
        return points.length - 2;
      }
      return 0;
    }
  }

  @override
  int get pointsToFill {
    if(startHandle != null){
      return 3 - points.length % 3;
    } else {
      return points.length >= 4 ? 3 - ((points.length - 1) % 3) : 4 - points.length;
    }
  }

  @override
  PointDrawCompositableCubicBezier duplicate(){
    return PointDrawCompositableCubicBezier.from(this);
  }
}

// PointDrawCompositableArc below
// class PointDrawCompositableArc extends _PointDrawCompositable{
//
//   // A compositable arc is non-closed intrinsically. The start handle of a compositable
//   // arc is the second restricted control point rPoints[1] (the end of the conic arc).
//
//   double width = 100;
//
//   double height = 100;
//
//   double _startConicAngle = 0.0;
//
//   double _sweepConicAngle = pi;
//
//   double _endCoordinateAngle = pi;
//
//   double _orientation = 0.0;
//
//   PointDrawCompositableArc({this.width = 100, this.height = 100, Offset? startHandle}) : super(mode: EditingMode.arc, startHandle: startHandle){
//     if(startHandle != null){
//       points.add(Offset(startHandle.dx + 50, startHandle.dy));
//       rPoints.add(Offset(startHandle.dx + 100, startHandle.dy));
//       rPoints.add(points.first + const Offset(50 * sqrt2, 0));
//       dPoints.add(Offset(startHandle.dx + 100, startHandle.dy + 50));
//     }
//   }
//
//   @override
//   bool get validNewPoint => points.isEmpty;
//
//   @override
//   bool get hasPath => points.isNotEmpty;
//
//
//   @override
//   Path getPath(){
//     Path arc = Path();
//     if(points.length == 1 && rPoints.length == 3){
//       // Case where startHandle is null
//       Rect rect = Rect.fromCenter(center: points[0], width: width, height: height);
//       double direction = (rPoints[2] - points[0]).direction;
//       arc.addArc(rect, _startConicAngle, _sweepConicAngle);
//       return arc.transform(rotateZAbout(direction, points[0]).storage);
//     } else if (points.length == 1 && rPoints.length == 2) {
//       Rect rect = Rect.fromCenter(center: points[0], width: width, height: height);
//       double direction = (rPoints[1] - points[0]).direction;
//       arc.addArc(rect, _startConicAngle, _sweepConicAngle);
//       return arc.transform(rotateZAbout(direction, points[0]).storage);
//     }
//     return arc;
//   }
//
//   @override
//   Path getAnimatedPath(double ticker, AnimationParams animationParams){
//     Path animatedArc = Path();
//     if(points.length == 1 && rPoints.length == 3){
//       // Current code does not animate. When animating, consider updating rdscp when cp moved;
//       // Offset cent = getAnimatedPoints(ticker).first;
//       Rect rect = Rect.fromCenter(center: points[0], width: width, height: height);
//       double direction = (rPoints[2] - points[0]).direction;
//       animatedArc.addArc(rect, _startConicAngle, _sweepConicAngle);
//       return animatedArc.transform(rotateZAbout(direction, points[0]).storage);
//     }
//     return animatedArc;
//   }
//
//   @override
//   void autoInitializeControlPoints(){
//     if(points.length == 1 && rPoints.isEmpty){
//       Rect rect = Rect.fromCenter(center: points[0], width: 100, height: 100);
//       Offset directionPoint = rect.center + Offset.fromDirection(0, sqrt2 * 50);
//       rPoints = [rect.centerRight, rect.centerLeft, directionPoint];
//       dPoints = [rect.bottomRight];
//     }
//   }
//
//   @override
//   PointDrawCompositableArc moveControlPoint(Offset newPosition, int index, {Map<String, dynamic>? args}){
//     args!["translate"] = newPosition - points.first;
//     super.moveControlPoint(newPosition, index, args: args);
//     updateRDSCPWhenCPMoved(args["zoom_transform"], args: args);
//     return this;
//   }
//
//   @override
//   PointDrawCompositableArc updateRDSCPWhenCPMoved(Matrix4 zoomTransform, {Map<String, dynamic>? args}){
//     super.updateRDSCPWhenCPMoved(zoomTransform);
//     Rect rect = Rect.fromCenter(center: points[0], width: width, height: height);
//     rPoints[0] = matrixApply(rotateZAbout(_orientation, rect.center) , getConicOffset(rect, _startConicAngle));
//     rPoints[1] = matrixApply(rotateZAbout(_orientation, rect.center) , getConicOffset(rect, getConicDirection(rect, _endCoordinateAngle)));
//     rPoints[2] = rect.center + Offset.fromDirection(_orientation, (rect.bottomRight - rect.center).distance);
//     dPoints[0] = rect.bottomRight;
//     return this;
//   }
//
//
//   @override
//   PointDrawCompositableArc copy(_PointDrawCompositable arc){
//     return PointDrawCompositableArc();
//   }
// }

dynamic getNewPointCompositable(EditingMode mode){
  switch(mode){
    case EditingMode.line:
      return PointDrawCompositableLine();
    case EditingMode.splineCurve:
      return PointDrawCompositableSplineCurve();
    case EditingMode.quadraticBezier:
      return PointDrawCompositableQuadraticBezier();
    case EditingMode.cubicBezier:
      return PointDrawCompositableCubicBezier();
    default:
      throw UnimplementedError("Creating new object for $mode not implemented");
  }
}