import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

import 'dart:math';
import 'dart:html';

import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart';
import 'package:pointdraw/point_draw_models/utilities/spline_path.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/matrices.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart'
    show controlPointSize;
import 'package:pointdraw/point_draw_models/app_components/action_button.dart';
import 'package:pointdraw/point_draw_models/app_components/icon_sketch.dart';
import 'package:pointdraw/point_draw_models/app_components/user_input_widget.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/point_draw_state_notifier.dart';
import 'package:pointdraw/point_draw_models/animation_parameters.dart';
import 'package:pointdraw/point_draw_models/svg/svg_builder.dart';
import 'package:pointdraw/point_draw_models/effects_parameters.dart';

import 'package:pointdraw/point_draw_models/point_draw_one_dimensional.dart';
import 'package:pointdraw/point_draw_models/point_draw_two_dimensional.dart';
import 'package:pointdraw/point_draw_models/point_draw_collection.dart';
import 'package:pointdraw/point_draw_models/point_draw_composite_path.dart';
import 'package:pointdraw/point_draw_models/point_draw_picture.dart';

export 'package:pointdraw/point_draw_models/point_draw_one_dimensional.dart';
export 'package:pointdraw/point_draw_models/point_draw_two_dimensional.dart';
export 'package:pointdraw/point_draw_models/point_draw_collection.dart';
export 'package:pointdraw/point_draw_models/point_draw_composite_path.dart';
export 'package:pointdraw/point_draw_models/point_draw_picture.dart';

Paint fillPaint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.fill;

Paint dataPaint = Paint()
  ..color = Colors.green
  ..style = PaintingStyle.fill;

// One base unit of drawing, corresponding to one EditingMode construct
abstract class PointDrawObject extends PointDrawStateNotifier {
  final ObjectKey key;

  PointDrawObject.fromDocument(
      this.mode, DocumentSnapshot<Map<String, dynamic>?> snapshot,
      {required this.key}) {
    Map<String, dynamic>? data = snapshot.data();
    if (data != null) {
      List<Map<String, double>> cpData = [
        for (Map o in data[controlPointsKey]) Map.from(o)
      ];
      List<Map<String, double>> rcpData = [
        for (Map o in data[restrictedControlPointsKey]) Map.from(o)
      ];
      List<Map<String, double>> dcpData = [
        for (Map o in data[dataControlPointsKey]) Map.from(o)
      ];
      for (int i = 0; i < cpData.length; i++) {
        points += [
          Offset(cpData[i][xCoordinateKey]!, cpData[i][yCoordinateKey]!)
        ];
      }
      for (int i = 0; i < rcpData.length; i++) {
        rPoints += [
          Offset(rcpData[i][xCoordinateKey]!, rcpData[i][yCoordinateKey]!)
        ];
      }
      for (int i = 0; i < dcpData.length; i++) {
        dPoints += [
          Offset(dcpData[i][xCoordinateKey]!, dcpData[i][yCoordinateKey]!)
        ];
      }
      sPaint.strokeWidth = data[strokeWidthKey];
      var strokeColor = data[strokeColorKey];
      sPaint.color = Color.fromARGB(strokeColor[0] as int,
          strokeColor[1] as int, strokeColor[2] as int, strokeColor[3] as int);
      var fillColor = data[fillColorKey];
      fPaint.color = Color.fromARGB(fillColor[0] as int, fillColor[1] as int,
          fillColor[2] as int, fillColor[3] as int);
      shaderParam = data[shaderKey] != null
          ? ShaderParameters.fromData(data[shaderKey])
          : null;
      filled = data[filledKey];
      outlined = data[outlinedKey];
      if (shaderParam != null) {
        fPaint.shader = shaderParam!.build();
      }
      // supplementaryPropertiesModifiers.add(getToggleAnimateButton);
    }
  }

  PointDrawObject({this.mode = EditingMode.object, required this.key}) {
    // supplementaryPropertiesModifiers.add(getToggleAnimateButton);
  }

  PointDrawObject.from(PointDrawObject object,
      {this.mode = EditingMode.object,
      required this.key,
      Offset displacement = const Offset(5, 5)}) {
    mode = object.mode;
    points = List<Offset>.generate(
        object.points.length, (ind) => object.points[ind] + displacement);
    rPoints = List<Offset>.generate(
        object.rPoints.length, (ind) => object.rPoints[ind] + displacement);
    dPoints = List<Offset>.generate(
        object.dPoints.length, (ind) => object.dPoints[ind] + displacement);
    sPaint = Paint()
      ..strokeWidth = object.sPaint.strokeWidth
      ..color = object.sPaint.color
      ..style = PaintingStyle.stroke;
    outlined = object.outlined;
    shaderParam = object.shaderParam?.copy(displacement: displacement);
    filled = object.filled;
    boundingRect = Rect.fromPoints(object.boundingRect.topLeft + displacement,
        object.boundingRect.bottomRight + displacement);
    fPaint = Paint()
      ..color = object.fPaint.color
      ..style = PaintingStyle.fill
      ..shader = shaderParam?.build(boundingRect: boundingRect);
    clips = object.clips;
    // supplementaryPropertiesModifiers.add(getToggleAnimateButton);
  }

  // Editing mode of this odk path
  EditingMode mode;

  // Also known as control points of the currently editing curve.
  // Active path points are free to move around any where in the canvas.
  List<Offset> points = <Offset>[];

  // Also known as restricted control points of the currently editing curve.
  // Active restricted path points movements are restricted by the type of curve
  // it is and the control points of the curve. Both restricted and unrestricted
  // control points are points which falls on the path of the curve, and
  // therefore can be transformed globally.
  List<Offset> rPoints = <Offset>[];

  // Data control points are free to be placed any where, but cannot be
  // transformed like control points because of distortion. Data points are
  // in place to enable quick determination of parameters like size of the objects.
  // During transformation, the parameters of the curve will determine the location of data
  // points, unlike control points and restricted control points.
  List<Offset> dPoints = <Offset>[];

  // Paint for outline of the shape using stroke painting style.
  Paint sPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // Records whether to draw the outline of the object
  bool outlined = true;

  // Paint for the interior of the object using fill painting style.
  // Any shader values are also encoded within this property
  Paint fPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

  // Records whether to fill the object's interior
  bool filled = false;

  // The bounding rectangle of this path
  Rect boundingRect = Rect.zero;

  // The method called before passing the object to the web cloud storage. For
  // individual objects to override with specific implementations of different
  // paths.

  Map<Path, PointDrawObject> clips = {};

  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = {
      editingModeKey: mode.name,
      filledKey: filled,
      fillColorKey: [
        fPaint.color.alpha,
        fPaint.color.red,
        fPaint.color.green,
        fPaint.color.blue
      ],
      outlinedKey: outlined,
      strokeColorKey: [
        sPaint.color.alpha,
        sPaint.color.red,
        sPaint.color.green,
        sPaint.color.blue
      ],
      strokeWidthKey: sPaint.strokeWidth,
      shaderKey: fPaint.shader != null ? shaderParam?.toJson() : null,
      clipKey: [for (PointDrawObject obj in clips.values) obj.toJson()],
    };
    if (parsePoints) {
      List<Map<String, double>> controlPoints = [
        for (Offset p in points) {xCoordinateKey: p.dx, yCoordinateKey: p.dy}
      ];
      List<Map<String, double>> restrictedPoints = [
        for (Offset p in rPoints) {xCoordinateKey: p.dx, yCoordinateKey: p.dy}
      ];
      List<Map<String, double>> dataPoints = [
        for (Offset p in dPoints) {xCoordinateKey: p.dx, yCoordinateKey: p.dy}
      ];
      data[controlPointsKey] = controlPoints;
      data[restrictedControlPointsKey] = restrictedPoints;
      data[dataControlPointsKey] = dataPoints;
    }
    return data;
  }

  // The method called to restore the object format of this path when received
  // from the cloud.
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    mode = getEditingMode(data[editingModeKey]);
    if (parsePoints) {
      List<Map<String, double>> cpData = [
        for (Map o in data[controlPointsKey]) Map.from(o)
      ];
      for (int i = 0; i < cpData.length; i++) {
        points += [
          Offset(cpData[i][xCoordinateKey]!, cpData[i][yCoordinateKey]!)
        ];
      }
      List<Map<String, double>> rcpData = [
        for (Map o in data[restrictedControlPointsKey]) Map.from(o)
      ];
      for (int i = 0; i < rcpData.length; i++) {
        rPoints += [
          Offset(rcpData[i][xCoordinateKey]!, rcpData[i][yCoordinateKey]!)
        ];
      }
      List<Map<String, double>> dcpData = [
        for (Map o in data[dataControlPointsKey]) Map.from(o)
      ];
      for (int i = 0; i < dcpData.length; i++) {
        dPoints += [
          Offset(dcpData[i][xCoordinateKey]!, dcpData[i][yCoordinateKey]!)
        ];
      }
    }
    outlined = data[outlinedKey];
    filled = data[filledKey];
    sPaint = Paint()
      ..color = Color.fromARGB(data[strokeColorKey][0], data[strokeColorKey][1],
          data[strokeColorKey][2], data[strokeColorKey][3])
      ..strokeWidth = data[strokeWidthKey]
      ..style = PaintingStyle.stroke;
    fPaint = Paint()
      ..color = Color.fromARGB(data[fillColorKey][0], data[fillColorKey][1],
          data[fillColorKey][2], data[fillColorKey][3])
      ..style = PaintingStyle.fill;
    shaderParam = data[shaderKey] != null
        ? ShaderParameters.fromData(data[shaderKey])
        : null;
    if (shaderParam != null) {
      fPaint.shader = shaderParam!.build();
    }
    List<Map<String, dynamic>> clipObjects = [
      for (Map obj in data[clipKey]) Map.from(obj)
    ];
    for (int i = 0; i < clipObjects.length; i++) {
      EditingMode mode = getEditingMode(clipObjects[i][editingModeKey]);
      var pdo = getNewPointDrawObject(mode)..toObject(clipObjects[i]);
      clips.addAll({(pdo as PointDrawPath).getPath(): pdo});
    }
  }

  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes);

  void initialize(Offset firstPoint, Offset secondPoint);

  void updateStrokePaint(
      {double? strokeWidth,
      Color? color,
      bool? isOutlined,
      bool notify = true}) {
    if (isOutlined != null) {
      outlined = isOutlined;
    }
    if (strokeWidth != null) {
      sPaint.strokeWidth = strokeWidth;
    }
    if (color != null) {
      sPaint.color = color;
    }
    if (notify) {
      notifyListeners();
    }
  }

  ShaderParameters? shaderParam;

  List<Offset?> get sPoints => [
        shaderParam?.center,
        shaderParam?.from,
        shaderParam?.to,
        shaderParam?.focal
      ];

  void updateFillPaint(Matrix4 zoomTransform,
      {ShaderParameters? shaderParameters,
      bool? useShader,
      Color? color,
      bool? isFilled,
      bool notify = true}) {
    if (isFilled != null) {
      filled = isFilled;
    }
    if (useShader != null) {
      shaderParam ??= ShaderParameters(boundingRect: boundingRect);
      fPaint.shader =
          useShader ? shaderParam!.build(zoomTransform: zoomTransform) : null;
    }
    if (shaderParameters != null) {
      shaderParam = shaderParameters;
      fPaint.shader = shaderParam!
          .build(boundingRect: boundingRect, zoomTransform: zoomTransform);
    }
    if (color != null) {
      fPaint.color = color;
    }
    if (notify) {
      notifyListeners();
    }
  }

  bool get useShader => fPaint.shader != null && shaderParam != null;

  ShaderType get shaderType =>
      shaderParam != null ? shaderParam!.type : ShaderType.linear;

  void updateShaderParams(
    Matrix4 zoomTransform, {
    ShaderType? shaderType,
    Offset? centerOffset,
    Offset? fromOffset,
    Offset? toOffset,
    List<Color>? colorsList,
    int? removeIndex,
    double? insertStop,
    int? insertIndex,
    List<double>? stopsList,
    TileMode? mode,
    double? radialMultiplier,
    Offset? focalOffset,
    double? fRadius,
    double? start,
    double? end,
    bool rebuild = true,
    bool notify = true,
  }) {
    if (removeIndex != null) {
      shaderParam?.removeColorStop(removeIndex);
    } else if (insertStop != null && insertIndex != null) {
      shaderParam?.insertStop(insertStop, insertIndex);
    } else {
      shaderParam?.updateShader(
        shaderType: shaderType,
        centerOffset: centerOffset,
        fromOffset: fromOffset,
        toOffset: toOffset,
        colorsList: colorsList,
        stopsList: stopsList,
        mode: mode,
        r: radialMultiplier != null
            ? (radialMultiplier * boundingRect.shortestSide)
            : null,
        focalOffset: focalOffset,
        fRadius: fRadius,
        start: start,
        end: end,
        boundingRect: boundingRect,
        notify: notify,
      );
    }
    if (rebuild) {
      fPaint.shader = shaderParam?.build(
          boundingRect: boundingRect, zoomTransform: zoomTransform);
    }
    if (notify) {
      notifyListeners();
    }
  }

  List<Widget Function()> supplementaryPropertiesModifiers = [];

  bool get isInitialized;

  bool get validNewPoint;

  void draw(Canvas canvas, double ticker, {Matrix4? zoomTransform});

  bool? _markForRemoval;

  set markForRemoval(bool val) => _markForRemoval = val;

  bool get markForRemoval => _markForRemoval != null && _markForRemoval!;

  void addClip(Path clipPath, PointDrawObject object) {
    clips.addAll({clipPath: object});
    notifyListeners();
  }

  void removeClip(Path clipPath) {
    clips.remove(clipPath);
    notifyListeners();
  }

  void autoInitializeControlPoints() {
    return;
  }

  bool enableDeleteControlPoint = false;

  void deleteControlPoint(int index, {bool notify = true}) {
    points.removeAt(index);
    if (notify) {
      notifyListeners();
    }
  }

  void addControlPoint(Offset newPoint) {
    points.add(newPoint);
    autoInitializeControlPoints();
    notifyListeners();
  }

  void addRestrictedControlPoint(Offset newPoint) {
    rPoints.add(newPoint);
    notifyListeners();
  }

  @override
  void updateObject(Function(PointDrawObject) updatingCall,
      {bool executeAll = true, List<StateSetter> exclusion = const []}) {
    updatingCall.call(this);
    notifyListeners();
  }

  @override
  void dispose() {
    shaderParam?.dispose();
    super.dispose();
  }

  // Transformation functions
  @mustCallSuper
  PointDrawObject moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    points[index] = newPosition;
    return this;
  }

  @mustCallSuper
  PointDrawObject updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    shaderParam?.updateShaderOffsetWhenCPMoved(args: args);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  PointDrawObject moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    return rPoints.isNotEmpty
        ? throw UnimplementedError(runtimeType.toString() +
            " did not implement moveRestrictedControlPoint")
        : this;
  }

  PointDrawObject moveDataControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    dPoints[index] = newPosition;
    return this;
  }

  PointDrawObject transformByTranslate(
      double dx, double dy, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length, (ind) => points[ind] + Offset(dx, dy));
    rPoints = List<Offset>.generate(
        rPoints.length, (ind) => rPoints[ind] + Offset(dx, dy));
    dPoints = List<Offset>.generate(
        dPoints.length, (ind) => dPoints[ind] + Offset(dx, dy));
    Map<Path, PointDrawObject> transformedClips = {};
    for (Path clipPath in clips.keys) {
      transformedClips[clipPath
              .transform(Matrix4.translationValues(dx, dy, 0).storage)] =
          clips[clipPath]!.transformByTranslate(dx, dy, zoomTransform,
              groupControlPoints: groupControlPoints);
    }
    clips = transformedClips;
    shaderParam = shaderParam?.transformByTranslate(dx, dy);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  PointDrawObject transformByRotate(
      Offset center, double angle, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length, (ind) => rotate(points[ind], center, angle));
    rPoints = List<Offset>.generate(
        rPoints.length, (ind) => rotate(rPoints[ind], center, angle));
    dPoints = List<Offset>.generate(
        dPoints.length, (ind) => rotate(dPoints[ind], center, angle));
    Map<Path, PointDrawObject> transformedClips = {};
    for (Path clipPath in clips.keys) {
      transformedClips[
              clipPath.transform(rotateZAbout(angle, center).storage)] =
          clips[clipPath]!.transformByRotate(center, angle, zoomTransform,
              groupControlPoints: groupControlPoints);
    }
    clips = transformedClips;
    shaderParam = shaderParam?.transformByRotate(center, angle);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  PointDrawObject transformByHorizontalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                stationary.dx + (points[ind].dx - stationary.dx) * scaleFactor,
                points[ind].dy));
    rPoints = List<Offset>.generate(
        rPoints.length,
        (ind) => Offset(
            stationary.dx + (rPoints[ind].dx - stationary.dx) * scaleFactor,
            rPoints[ind].dy));
    dPoints = List<Offset>.generate(
        dPoints.length,
        (ind) => Offset(
            stationary.dx + (dPoints[ind].dx - stationary.dx) * scaleFactor,
            dPoints[ind].dy));
    Map<Path, PointDrawObject> transformedClips = {};
    for (Path clipPath in clips.keys) {
      transformedClips[
              clipPath.transform(scalingX(scaleFactor, stationary).storage)] =
          clips[clipPath]!.transformByHorizontalScale(
              stationary, scaleFactor, zoomTransform,
              groupControlPoints: groupControlPoints);
    }
    clips = transformedClips;
    shaderParam =
        shaderParam?.transformByHorizontalScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  PointDrawObject transformByVerticalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                points[ind].dx,
                stationary.dy +
                    (points[ind].dy - stationary.dy) * scaleFactor));
    rPoints = List<Offset>.generate(
        rPoints.length,
        (ind) => Offset(rPoints[ind].dx,
            stationary.dy + (rPoints[ind].dy - stationary.dy) * scaleFactor));
    dPoints = List<Offset>.generate(
        dPoints.length,
        (ind) => Offset(dPoints[ind].dx,
            stationary.dy + (dPoints[ind].dy - stationary.dy) * scaleFactor));
    Map<Path, PointDrawObject> transformedClips = {};
    for (Path clipPath in clips.keys) {
      transformedClips[
              clipPath.transform(scalingY(scaleFactor, stationary).storage)] =
          clips[clipPath]!.transformByVerticalScale(
              stationary, scaleFactor, zoomTransform,
              groupControlPoints: groupControlPoints);
    }
    clips = transformedClips;
    shaderParam =
        shaderParam?.transformByVerticalScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  PointDrawObject transformByScale(
      Offset stationary, Offset scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                stationary.dx +
                    (points[ind].dx - stationary.dx) * scaleFactor.dx,
                stationary.dy +
                    (points[ind].dy - stationary.dy) * scaleFactor.dy));
    rPoints = List<Offset>.generate(
        rPoints.length,
        (ind) => Offset(
            stationary.dx + (rPoints[ind].dx - stationary.dx) * scaleFactor.dx,
            stationary.dy +
                (rPoints[ind].dy - stationary.dy) * scaleFactor.dy));
    dPoints = List<Offset>.generate(
        dPoints.length,
        (ind) => Offset(
            stationary.dx + (dPoints[ind].dx - stationary.dx) * scaleFactor.dx,
            stationary.dy +
                (dPoints[ind].dy - stationary.dy) * scaleFactor.dy));
    Map<Path, PointDrawObject> transformedClips = {};
    for (Path clipPath in clips.keys) {
      transformedClips[
              clipPath.transform(scalingXY(scaleFactor, stationary).storage)] =
          clips[clipPath]!.transformByScale(
              stationary, scaleFactor, zoomTransform,
              groupControlPoints: groupControlPoints);
    }
    clips = transformedClips;
    shaderParam = shaderParam?.transformByScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  void flipHorizontal(Matrix4 zoomTransform, {Offset? center}) {
    if (boundingRect != Rect.zero) {
      center ??= boundingRect.center;
      points = List<Offset>.generate(
          points.length,
          (ind) => Offset(
              center!.dx + (center.dx - points[ind].dx), points[ind].dy));
      rPoints = List<Offset>.generate(
          rPoints.length,
          (ind) => Offset(
              center!.dx + (center.dx - rPoints[ind].dx), rPoints[ind].dy));
      dPoints = List<Offset>.generate(
          dPoints.length,
          (ind) => Offset(
              center!.dx + (center.dx - dPoints[ind].dx), dPoints[ind].dy));
      Map<Path, PointDrawObject> transformedClips = {};
      for (Path clipPath in clips.keys) {
        PointDrawObject obj = clips[clipPath]!;
        obj.flipHorizontal(zoomTransform);
        transformedClips[clipPath.transform(horizontalFlip(center).storage)] =
            obj;
      }
      clips = transformedClips;
      shaderParam = shaderParam?.flipHorizontal(center);
      fPaint.shader = fPaint.shader != null
          ? shaderParam?.build(
              boundingRect: boundingRect, zoomTransform: zoomTransform)
          : null;
      notifyListeners();
    }
  }

  void flipVertical(Matrix4 zoomTransform, {Offset? center}) {
    if (boundingRect != Rect.zero) {
      center ??= boundingRect.center;
      points = List<Offset>.generate(
          points.length,
          (ind) => Offset(
              points[ind].dx, center!.dy + (center.dy - points[ind].dy)));
      rPoints = List<Offset>.generate(
          rPoints.length,
          (ind) => Offset(
              rPoints[ind].dx, center!.dy + (center.dy - rPoints[ind].dy)));
      dPoints = List<Offset>.generate(
          dPoints.length,
          (ind) => Offset(
              dPoints[ind].dx, center!.dy + (center.dy - dPoints[ind].dy)));
      Map<Path, PointDrawObject> transformedClips = {};
      for (Path clipPath in clips.keys) {
        PointDrawObject obj = clips[clipPath]!;
        obj.flipVertical(zoomTransform);
        transformedClips[clipPath.transform(verticalFlip(center).storage)] =
            obj;
      }
      clips = transformedClips;
      shaderParam = shaderParam?.flipVertical(center);
      fPaint.shader = fPaint.shader != null
          ? shaderParam?.build(
              boundingRect: boundingRect, zoomTransform: zoomTransform)
          : null;
      notifyListeners();
    }
  }

  PointDrawObject duplicate({Offset? center}) {
    throw UnimplementedError("Subclasses must override this method");
  }

  // Animation
  AnimationParams animationParams = AnimationParams();

  void toggleAnimate() {
    animationParams.toggleAnimateEnable();
    notifyListeners();
  }

  Widget getToggleAnimateButton() {
    return ActionButton(
      EditingMode.none,
      animationParams.enableAnimate,
      displayWidget: const Icon(Icons.animation, size: 20, color: Colors.white),
      onPressed: toggleAnimate,
      toolTipMessage: "Enable animate",
      enabled: getAnimationEnabledMode(mode),
    );
  }

  @override
  String toString() => "Object";

  String? getHint() {
    if (!isInitialized) {
      return "Hold ctrl and click to add a control point";
    }
    if (!boundingRect.isEmpty) {
      return "Click and drag a control point to edit.";
    }
    return null;
  }
}

class FreeDraw extends PointDrawPath {
  SplinePath splinePath = SplinePath([]);

  double coarseness = 1.0;

  double tension = 0.0;

  bool _readyToShift = false;

  FreeDraw.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.freeDraw, key: key) {
    tension = snapshot.get(tensionKey) as double;
    coarseness = snapshot.get(coarsenessKey) as double;
    _drawEnd = snapshot.get(drawEndKey) as bool;
    closed = snapshot.get(closedKey) as bool;
    splinePath.tension = tension;
    supplementaryPropertiesModifiers.addAll([
      getReadyToShiftToggleButton,
      getToggleCloseButton,
      getSplineEffectMenuButton,
      getToggleShowControlPoints
    ]);
  }

  FreeDraw(
    this.splinePath, {
    this.closed = false,
    this.coarseness = 1.0,
    this.tension = 0.0,
    required ObjectKey key,
  }) : super(mode: EditingMode.freeDraw, key: key) {
    supplementaryPropertiesModifiers.addAll([
      getReadyToShiftToggleButton,
      getToggleCloseButton,
      getSplineEffectMenuButton,
      getToggleShowControlPoints
    ]);
    sPaint.strokeCap = StrokeCap.round;
    sPaint.strokeJoin = StrokeJoin.round;
  }

  FreeDraw.from(FreeDraw object,
      {required ObjectKey key, Offset displacement = const Offset(5, 5)})
      : super.from(object, mode: EditingMode.freeDraw, key: key) {
    closed = object.closed;
    _drawEnd = object.drawEnd;
    coarseness = object.coarseness;
    tension = object.tension;
    splinePath = SplinePath.generate(
      List<Offset>.generate(object.splinePath.points.length,
          (index) => object.splinePath.points[index] + displacement),
      tension: tension,
    );
    supplementaryPropertiesModifiers.addAll([
      getReadyToShiftToggleButton,
      getToggleCloseButton,
      getSplineEffectMenuButton,
      getToggleShowControlPoints
    ]);
  }

  bool get readyToShift => _readyToShift;

  // Records whether this path is a closed path
  bool closed = false;

  // Records whether drawing ended for this spline path
  bool get drawEnd => _drawEnd;

  bool _drawEnd = false;

  set drawEnd(bool end) {
    _drawEnd = end;
    splinePath.enGenerate();
  }

  @override
  bool get isInitialized => splinePath.isNotEmpty;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    return;
  }

  @override
  bool get validNewPoint => false;

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data.addAll({
      editingModeKey: mode.name,
      closedKey: closed,
      drawEndKey: _drawEnd,
      tensionKey: splinePath.tension,
    });
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: true);
    splinePath = SplinePath.generate(points, tension: data[tensionKey]);
    splinePath.endDraw();
    tension = data[tensionKey];
    _drawEnd = data[drawEndKey];
    closed = data[closedKey];
    _drawEnd = data[drawEndKey];
  }

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO:
    return const SVGPointDrawElement(svgContent: "");
  }

  @override
  void updateFillPaint(Matrix4 zoomTransform,
      {ShaderParameters? shaderParameters,
      bool? useShader,
      Color? color,
      bool? isFilled,
      bool notify = true}) {
    updateStrokePaint(color: color, notify: false);
    super.updateFillPaint(zoomTransform, color: color);
  }

  @override
  void updateStrokePaint(
      {double? strokeWidth,
      Color? color,
      bool? isOutlined,
      bool notify = true,
      Matrix4? zoomTransform}) {
    if (strokeWidth != null) {
      sPaint.strokeWidth = strokeWidth;
    }
    if (color != null) {
      sPaint.color = color;
      updateFillPaint(zoomTransform ?? Matrix4.identity(),
          color: color, notify: false);
    }
    if (notify) {
      notifyListeners();
    }
  }

  @override
  Path getPath() {
    Path path = splinePath.splinePath;
    // for(Offset pt in splinePath.points){
    //   path.addOval(Rect.fromCenter(center: pt, width: 6.0, height: 6.0));
    // }
    return path;
  }

  @override
  Path getAnimatedPath(double ticker) {
    return splinePath.splinePath;
  }

  @override
  List<Offset> getAnimatedPoints(double ticker) {
    return [];
  }

  @override
  List<Offset> getAnimatedRPoints(double ticker) {
    return [];
  }

  @override
  List<Offset> getAnimatedDPoints(double ticker) {
    return [];
  }

  @override
  Path draw(Canvas canvas, double ticker, {Matrix4? zoomTransform}) {
    Path path = getPath();
    boundingRect = path.getBounds();
    if (zoomTransform != null) {
      path = path.transform(zoomTransform.storage);
    }
    if (clips.isNotEmpty) {
      canvas.save();
      for (Path path in clips.keys) {
        canvas.clipPath(path);
      }
      if (effectsParams.type == SplineEffects.normal) {
        canvas.drawPath(path, sPaint);
        // drawCriticalPoints(canvas);
      } else if (effectsParams.type != SplineEffects.normal) {
        canvas.drawPath(path, fPaint);
      }
      canvas.restore();
    } else {
      if (effectsParams.type == SplineEffects.normal) {
        canvas.drawPath(path, sPaint);
        // drawCriticalPoints(canvas);
      } else if (effectsParams.type != SplineEffects.normal) {
        canvas.drawPath(path, fPaint);
      }
    }
    return path;
  }

  void drawCriticalPoints(Canvas canvas) {
    if (splinePath.criticalPointIndices.isNotEmpty) {
      for (int ind in splinePath.criticalPointIndices) {
        canvas.drawOval(
          Rect.fromCenter(
              center: splinePath.points[ind], width: 4.0, height: 4.0),
          Paint()
            ..color = Colors.red
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  FreeDraw updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    super.updateRDSCPWhenCPMoved(zoomTransform);
    return this;
  }

  EffectsParameters effectsParams = EffectsParameters();

  void updateEffectsParams(
      {double? maxWidth,
      double? variance,
      double? endWidth,
      double? pointsGapCoefficient,
      bool notify = true}) {
    if (maxWidth != null) {
      effectsParams.maxWidth = maxWidth;
      effectsParams.variance =
          min(effectsParams.variance, effectsParams.maxWidth);
      effectsParams.endWidth =
          min(effectsParams.endWidth, effectsParams.maxWidth);
    }
    if (variance != null) {
      effectsParams.variance = variance;
    }
    if (endWidth != null) {
      effectsParams.endWidth = endWidth;
    }
    if (pointsGapCoefficient != null) {
      effectsParams.pointsGapCoefficient = pointsGapCoefficient;
      splinePath.recalculateSplinePoints(effectsParams.pointsGapCoefficient);
    }
    if (notify) {
      notifyListeners();
    }
  }

  void regenerateSpline({bool filter = false, bool computeMetric = false}) {
    splinePath.enGenerate(
        effect: effectsParams.type,
        effectsParams: effectsParams,
        filter: filter,
        computeMetric: computeMetric);
    notifyListeners();
  }

  Widget getReadyToShiftToggleButton() {
    return ActionButton(
      mode,
      _readyToShift,
      displayWidget: const ReadyToShiftIcon(widthSize: 28),
      onPressed: () {
        _readyToShift = !_readyToShift;
        notifyListeners();
      },
      toolTipMessage: "Toggle ready to shift",
    );
  }

  @override
  FreeDraw duplicate({Offset? center}) {
    if (center != null) {
      return FreeDraw.from(this,
          displacement: (center - boundingRect.center),
          key: ObjectKey("FreeDraw: ${generateAutoID()}"));
    } else {
      return FreeDraw.from(this,
          key: ObjectKey("FreeDraw: ${generateAutoID()}"));
    }
  }

  Widget getSplineEffectMenuButton() {
    return PopupMenuButton<SplineEffects>(
      itemBuilder: (context) {
        return [
          for (SplineEffects effect in SplineEffects.values)
            PopupMenuItem(
              value: effect,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(effect.name,
                  style: const TextStyle(fontSize: 14, color: Colors.white)),
            ),
        ];
      },
      onSelected: (SplineEffects val) {
        effectsParams.type = val;
        splinePath.enGenerate(
            effect: val, filter: false, effectsParams: effectsParams);
        notifyListeners();
      },
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        ),
        elevation: 4.0,
        color: Colors.black,
        child: Container(
            width: 80,
            height: 28,
            alignment: Alignment.center,
            child: Text(effectsParams.type.name,
                style: const TextStyle(fontSize: 14, color: Colors.white))),
      ),
      tooltip: "Effects",
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9.0),
      ),
      color: Colors.black,
    );
  }

  Widget getToggleCloseButton() {
    return ActionButton(
      mode,
      closed,
      displayWidget: const CloseCurveIcon(
        widthSize: 28,
      ),
      onPressed: () {
        closed = !closed;
        notifyListeners();
      },
      toolTipMessage: "Toggle close curve",
    );
  }

  bool showControlPoints = false;

  Widget getToggleShowControlPoints() {
    return ActionButton(
      mode,
      showControlPoints,
      displayWidget: const ShowControlPointsIcon(
        widthSize: 28,
      ),
      onPressed: () {
        showControlPoints = !showControlPoints;
        if (showControlPoints) {
          points = splinePath.filteredPoints.isNotEmpty
              ? splinePath.filteredPoints
              : splinePath.points;
        } else {
          points = [];
        }
        notifyListeners();
      },
      toolTipMessage: "Toggle show control points",
    );
  }

  @override
  String toString() => "Free draw";

  @override
  String getHint() {
    if (splinePath.isNotEmpty) {
      return "To move free draw object, select 'ready to shift' button in the layer panel.";
    }
    return "Click and drag to draw using free hand";
  }
}

abstract class PointDrawPath extends PointDrawObject {
  PointDrawPath({EditingMode mode = EditingMode.path, required ObjectKey key})
      : super(mode: mode, key: key);

  PointDrawPath.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {EditingMode mode = EditingMode.path, required ObjectKey key})
      : super.fromDocument(mode, snapshot, key: key);

  PointDrawPath.from(PointDrawPath object,
      {mode = EditingMode.path,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key);

  // Use this when animate is disabled
  Path getPath();

  // Use this when animate is enabled
  Path getAnimatedPath(double ticker);

  // Return animated control points
  List<Offset> getAnimatedPoints(double ticker) {
    List<Offset> animatedPoints = List<Offset>.generate(points.length, (ind) {
      if (animationParams.animatedControlPoints.keys.contains(ind)) {
        return points[ind] +
            animationParams.animatedControlPoints[ind]!.begin! * ticker +
            animationParams.animatedControlPoints[ind]!.end! * (1 - ticker);
      } else {
        return points[ind];
      }
    });
    return animatedPoints;
  }

  // Return animated restricted control points
  List<Offset> getAnimatedRPoints(double ticker) {
    // Defaults to no animation
    return rPoints;
  }

  // Return animated data control points
  List<Offset> getAnimatedDPoints(double ticker) {
    // Defaults to no animation
    return dPoints;
  }

  @override
  Path draw(Canvas canvas, double ticker, {Matrix4? zoomTransform}) {
    Path path;
    if (animationParams.enableAnimate) {
      path = getAnimatedPath(ticker);
    } else {
      path = getPath();
    }
    boundingRect = path.getBounds();
    if (zoomTransform != null) {
      path = path.transform(zoomTransform.storage);
    }
    if (clips.isNotEmpty) {
      canvas.save();
      for (Path path in clips.keys) {
        canvas.clipPath(path);
      }
      if (outlined) {
        canvas.drawPath(path, sPaint);
      }
      if (filled) {
        fPaint.shader = fPaint.shader != null
            ? shaderParam?.build(
                boundingRect: boundingRect, zoomTransform: zoomTransform)
            : null;
        canvas.drawPath(path, fPaint);
      }
      canvas.restore();
    } else {
      if (outlined) {
        canvas.drawPath(path, sPaint);
      }
      if (filled) {
        fPaint.shader = fPaint.shader != null
            ? shaderParam?.build(
                boundingRect: boundingRect, zoomTransform: zoomTransform)
            : null;
        canvas.drawPath(path, fPaint);
      }
    }
    return path;
  }
}

// Shapes point draw objects (or two dimensional point draws)

class PointDrawDirectedLine extends PointDrawPath {
  PointDrawDirectedLine.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.directedLine, key: key);

  PointDrawDirectedLine({required ObjectKey key})
      : super(mode: EditingMode.directedLine, key: key);

  PointDrawDirectedLine.from(PointDrawDirectedLine object,
      {required ObjectKey key, Offset displacement = const Offset(5, 5)})
      : super.from(object,
            displacement: displacement,
            mode: EditingMode.directedLine,
            key: key);

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    if (points.length >= 2) {
      Offset start = points[0];
      Offset pointer = points[1];
      double direction = (pointer - start).direction;
      Offset arrowPoint1 = pointer + Offset.fromDirection(direction, 6);
      Offset arrowPoint2 =
          pointer + Offset.fromDirection(direction + (2 * pi / 3), 6);
      Offset arrowPoint3 =
          pointer + Offset.fromDirection(direction + (4 * pi / 3), 6);

      String viewPort = "<svg height=\"500\" width=\"800\">";
      String lineSVG =
          "<line x1=\"${points[0].dx}\" y1=\"${points[0].dy}\" x2=\"${points[1].dx}\" y2=\"${points[1].dy}\" style=\"stroke:rgb(${fPaint.color.red},${fPaint.color.green},${fPaint.color.blue});stroke-width:${strokePaint.strokeWidth}\" />";
      String arrowSVG = "<polygon points=\"${arrowPoint1.dx},${arrowPoint1.dy} ${arrowPoint2.dx},${arrowPoint2.dy} ${arrowPoint3.dx},${arrowPoint3.dy}\" />";
      String svgContent = "$viewPort\n$lineSVG\n$arrowSVG\n</svg>";
      print(svgContent);
      return SVGPointDrawElement(svgContent: svgContent);
    }

    return const SVGPointDrawElement(svgContent: "Not Enough Control Points");
  }

  @override
  bool get isInitialized => points.length == 2;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
  }

  @override
  Path getPath() {
    Path directedLine = Path();
    if (points.length == 2) {
      Offset start = points[0];
      Offset pointer = points[1];
      directedLine.moveTo(start.dx, start.dy);
      directedLine.lineTo(pointer.dx, pointer.dy);
      double direction = (pointer - start).direction;
      directedLine.addPolygon([
        pointer + Offset.fromDirection(direction, 6),
        pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
        pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
      ], true);
    }
    return directedLine;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedDirectedLine = Path();
    if (points.length == 2) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      Offset start = animatedPoints[0];
      Offset pointer = animatedPoints[1];
      animatedDirectedLine.moveTo(start.dx, start.dy);
      animatedDirectedLine.lineTo(pointer.dx, pointer.dy);
      double direction = (pointer - start).direction;
      animatedDirectedLine.addPolygon([
        pointer + Offset.fromDirection(direction, 6),
        pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
        pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
      ], true);
    }
    return animatedDirectedLine;
  }

  @override
  Path draw(Canvas canvas, double ticker, {Matrix4? zoomTransform}) {
    Path path = super.draw(canvas, ticker, zoomTransform: zoomTransform);
    if (points.length == 2) {
      double direction = (points[1] - points[0]).direction;
      Path arrowHead = Path()
        ..addPolygon([
          points[1] + Offset.fromDirection(direction, 6),
          points[1] + Offset.fromDirection(direction + (2 * pi / 3), 6),
          points[1] + Offset.fromDirection(direction + (4 * pi / 3), 6),
        ], true);
      if (zoomTransform != null) {
        arrowHead = arrowHead.transform(zoomTransform.storage);
      }
      if (clips.isNotEmpty) {
        canvas.save();
        for (Path clipPath in clips.keys) {
          canvas.clipPath(clipPath);
        }
        canvas.drawPath(arrowHead, fillPaint);
        path.addPath(arrowHead, Offset.zero);
        canvas.restore();
      } else {
        canvas.drawPath(arrowHead, fillPaint);
        path.addPath(arrowHead, Offset.zero);
      }
    }
    return path;
  }

  @override
  PointDrawDirectedLine duplicate({Offset? center}) {
    return PointDrawDirectedLine.from(this,
        key: ObjectKey("DirectedLine:" + generateAutoID()));
  }

  @override
  String toString() => "D. line";
}

class PointDrawCurvedDirectedLine extends PointDrawPath {
  PointDrawCurvedDirectedLine.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot,
            mode: EditingMode.curvedDirectedLine, key: key);

  PointDrawCurvedDirectedLine({required ObjectKey key})
      : super(mode: EditingMode.curvedDirectedLine, key: key);

  PointDrawCurvedDirectedLine.from(PointDrawCurvedDirectedLine object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement,
            mode: EditingMode.curvedDirectedLine,
            key: key);

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO:
    return const SVGPointDrawElement(svgContent: "");
  }

  @override
  bool get isInitialized => points.length == 2;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
  }

  @override
  Path getPath() {
    Path curveDirectedLine = Path();
    if (points.length == 2) {
      Offset start = points[0];
      Offset pointer = points[1];
      double direction = (pointer - start).direction;
      double gap = (pointer - start).distance * 0.2;
      Offset controlPoint1 = start +
          ((pointer - start) / 3) +
          Offset.fromDirection(direction + pi / 2, gap);
      Offset controlPoint2 = start +
          ((pointer - start) * 2 / 3) +
          Offset.fromDirection(direction - pi / 2, gap);
      curveDirectedLine.moveTo(start.dx, start.dy);
      curveDirectedLine.cubicTo(controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy, pointer.dx, pointer.dy);
      curveDirectedLine.addPolygon([
        pointer + Offset.fromDirection(direction, 6),
        pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
        pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
      ], true);
    }
    return curveDirectedLine;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedCurvedDirectedLine = Path();
    if (points.length == 2) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      Offset start = animatedPoints[0];
      Offset pointer = animatedPoints[1];
      double direction = (pointer - start).direction;
      double gap = (pointer - start).distance * 0.2;
      Offset controlPoint1 = start +
          ((pointer - start) / 3) +
          Offset.fromDirection(direction + pi / 2, gap);
      Offset controlPoint2 = start +
          ((pointer - start) * 2 / 3) +
          Offset.fromDirection(direction - pi / 2, gap);
      animatedCurvedDirectedLine.moveTo(start.dx, start.dy);
      animatedCurvedDirectedLine.cubicTo(controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy, pointer.dx, pointer.dy);
      animatedCurvedDirectedLine.addPolygon([
        pointer + Offset.fromDirection(direction, 6),
        pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
        pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
      ], true);
    }
    return animatedCurvedDirectedLine;
  }

  @override
  Path draw(Canvas canvas, double ticker, {Matrix4? zoomTransform}) {
    Path path = super.draw(canvas, ticker, zoomTransform: zoomTransform);
    double direction = (points[1] - points[0]).direction;
    if (points.length == 2) {
      Path arrowHead = Path()
        ..addPolygon([
          points[1] + Offset.fromDirection(direction, 6),
          points[1] + Offset.fromDirection(direction + (2 * pi / 3), 6),
          points[1] + Offset.fromDirection(direction + (4 * pi / 3), 6),
        ], true);
      if (zoomTransform != null) {
        arrowHead = arrowHead.transform(zoomTransform.storage);
      }
      if (clips.isNotEmpty) {
        canvas.save();
        for (Path clipPath in clips.keys) {
          canvas.clipPath(clipPath);
        }
        canvas.drawPath(arrowHead, fillPaint);
        path.addPath(arrowHead, Offset.zero);
        canvas.restore();
      } else {
        canvas.drawPath(arrowHead, fillPaint);
        path.addPath(arrowHead, Offset.zero);
      }
    }
    return path;
  }

  @override
  PointDrawCurvedDirectedLine duplicate({Offset? center}) {
    return PointDrawCurvedDirectedLine.from(this,
        key: ObjectKey("CurvedDirectedLine:" + generateAutoID()));
  }

  @override
  String toString() => "C. D. line";
}

class PointDrawGroup extends PointDrawPath {
  List<PointDrawObject> group = [];

  PointDrawGroup.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.group, key: key);

  PointDrawGroup(this.group, {required ObjectKey key})
      : super(mode: EditingMode.group, key: key) {
    Path rect = Path();
    for (PointDrawObject pdo in group) {
      points.addAll(pdo.points);
      rPoints.addAll(pdo.rPoints);
      dPoints.addAll(pdo.dPoints);
      rect.addRect(pdo.boundingRect);
    }
    boundingRect = rect.getBounds();
  }

  PointDrawGroup.from(PointDrawGroup object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.group, key: key) {
    for (dynamic pdo in object.group) {
      group.add(pdo.duplicate());
    }
  }

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO:
    return const SVGPointDrawElement(svgContent: "");
  }

  @override
  bool get validNewPoint => false;

  @override
  bool get isInitialized => group.isNotEmpty;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    return;
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: false);
    data[groupKey] = [];
    for (var obj in group) {
      data[groupKey].add(obj.toJson());
    }
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {parsePoints = true}) {
    super.toObject(data, parsePoints: false);
    List groupData = data[groupKey];
    group = List.generate(
        groupData.length,
        (ind) => getNewPointDrawObject(
            getEditingMode(groupData[ind][editingModeKey]))
          ..toObject(groupData[ind]));
    for (int i = 0; i < group.length; i++) {
      points.addAll(group[i].points);
      rPoints.addAll(group[i].rPoints);
      dPoints.addAll(group[i].dPoints);
    }
  }

  @override
  Path getPath() {
    Path path = Path();
    for (PointDrawObject pdo in group) {
      if (pdo is PointDrawPath) {
        path.addPath(pdo.getPath(), Offset.zero);
      }
    }
    return path;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedPath = Path();
    for (PointDrawObject pdo in group) {
      if (pdo is PointDrawPath) {
        animatedPath.addPath(pdo.getAnimatedPath(ticker), Offset.zero);
      }
    }
    return animatedPath;
  }

  @override
  Path draw(Canvas canvas, double ticker, {Matrix4? zoomTransform}) {
    Path combinedBoundingRect = Path();
    Path path = Path();
    for (PointDrawObject pdo in group) {
      if (pdo is PointDrawPath) {
        if (clips.isNotEmpty) {
          canvas.save();
          for (Path clipPath in clips.keys) {
            canvas.clipPath(clipPath);
          }
          path.addPath(pdo.draw(canvas, ticker, zoomTransform: zoomTransform),
              Offset.zero);
          canvas.restore();
        } else {
          path.addPath(pdo.draw(canvas, ticker, zoomTransform: zoomTransform),
              Offset.zero);
        }
      } else if (pdo is PointDrawText) {
        if (clips.isNotEmpty) {
          canvas.save();
          for (Path clipPath in clips.keys) {
            canvas.clipPath(clipPath);
          }
          pdo.draw(canvas, ticker,
              zoomTransform: zoomTransform, drawText: false);
          canvas.restore();
        } else {
          pdo.draw(canvas, ticker,
              zoomTransform: zoomTransform, drawText: false);
        }
      }
      combinedBoundingRect.addRect(pdo.boundingRect);
    }
    boundingRect = combinedBoundingRect.getBounds();
    return path;
  }

  @override
  void updateStrokePaint(
      {double? strokeWidth,
      Color? color,
      bool? isOutlined,
      bool notify = true}) {
    for (PointDrawObject pdo in group) {
      pdo.updateStrokePaint(
          strokeWidth: strokeWidth,
          color: color,
          isOutlined: isOutlined,
          notify: false);
    }
    super.updateStrokePaint(
        strokeWidth: strokeWidth,
        color: color,
        isOutlined: isOutlined,
        notify: false);
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void updateFillPaint(Matrix4 zoomTransform,
      {bool? useShader,
      ShaderParameters? shaderParameters,
      Color? color,
      bool? isFilled,
      bool notify = true}) {
    for (PointDrawObject pdo in group) {
      pdo.updateFillPaint(zoomTransform,
          useShader: useShader,
          shaderParameters: shaderParameters,
          color: color,
          isFilled: isFilled,
          notify: false);
    }
    super.updateFillPaint(zoomTransform,
        shaderParameters: shaderParameters,
        useShader: useShader,
        color: color,
        isFilled: isFilled,
        notify: false);
    if (notify) {
      notifyListeners();
    }
  }

  Map<String, dynamic> curveFinderFunction(
      {num? cpIndex, num? rcpIndex, num? dcpIndex}) {
    assert(
        cpIndex != null ||
            rcpIndex != null ||
            !(cpIndex != null && rcpIndex != null),
        "Either control point index or restricted control point index must be given, but not both");
    num sumOfControlPoints = -1;
    num sumOfRestrictedPoints = -1;
    num sumOfDataPoints = -1;
    if (cpIndex != null) {
      for (int k = 0; k < group.length; k++) {
        PointDrawObject pdo = group[k];
        if (sumOfControlPoints + pdo.points.length >= cpIndex) {
          if (pdo.mode != EditingMode.group) {
            return {
              "from": sumOfControlPoints + 1,
              "to": sumOfControlPoints + pdo.points.length + 1,
              "restricted_from": sumOfRestrictedPoints + 1,
              "restricted_to": sumOfRestrictedPoints + pdo.rPoints.length + 1,
              "data_from": sumOfDataPoints + 1,
              "data_to": sumOfDataPoints + pdo.dPoints.length + 1,
              "path": k.toString(),
              "curve": pdo,
            };
          } else {
            PointDrawGroup groupPDO = pdo as PointDrawGroup;
            Map<String, dynamic> result = groupPDO.curveFinderFunction(
                cpIndex: cpIndex - sumOfControlPoints - 1);
            result["path"] = "$k/" + result["path"];
            result["from"] += (sumOfControlPoints + 1);
            result["to"] += (sumOfControlPoints + 1);
            result["data_from"] += (sumOfDataPoints + 1);
            result["data_to"] += (sumOfDataPoints + 1);
            result["restricted_from"] += (sumOfRestrictedPoints + 1);
            result["restricted_to"] += (sumOfRestrictedPoints + 1);
            return result;
          }
        }
        sumOfControlPoints = sumOfControlPoints + pdo.points.length;
        sumOfRestrictedPoints = sumOfRestrictedPoints + pdo.rPoints.length;
        sumOfDataPoints = sumOfDataPoints + pdo.dPoints.length;
      }
      throw Exception("Path not found from curve finder function");
    } else if (rcpIndex != null) {
      for (int k = 0; k < group.length; k++) {
        PointDrawObject pdo = group[k];
        if (sumOfRestrictedPoints + pdo.rPoints.length >= rcpIndex) {
          if (pdo.mode != EditingMode.group) {
            return {
              "from": sumOfControlPoints + 1,
              "to": sumOfControlPoints + pdo.points.length + 1,
              "restricted_from": sumOfRestrictedPoints + 1,
              "restricted_to": sumOfRestrictedPoints + pdo.rPoints.length + 1,
              "data_from": sumOfDataPoints + 1,
              "data_to": sumOfDataPoints + pdo.dPoints.length + 1,
              "path": k.toString(),
              "curve": pdo,
            };
          } else {
            PointDrawGroup groupPDO = pdo as PointDrawGroup;
            Map<String, dynamic> result = groupPDO.curveFinderFunction(
                rcpIndex: rcpIndex - sumOfRestrictedPoints - 1);
            result["path"] = "$k/" + result["path"];
            result["from"] += (sumOfControlPoints + 1);
            result["to"] += (sumOfControlPoints + 1);
            result["restricted_from"] += (sumOfRestrictedPoints + 1);
            result["restricted_to"] += (sumOfRestrictedPoints + 1);
            result["data_from"] += (sumOfDataPoints + 1);
            result["data_to"] += (sumOfDataPoints + 1);
            return result;
          }
        }
        sumOfControlPoints = sumOfControlPoints + pdo.points.length;
        sumOfRestrictedPoints = sumOfRestrictedPoints + pdo.rPoints.length;
        sumOfDataPoints = sumOfDataPoints + pdo.dPoints.length;
      }
      throw Exception("Path not found from curve finder function");
    } else if (dcpIndex != null) {
      for (int k = 0; k < group.length; k++) {
        PointDrawObject pdo = group[k];
        if (sumOfRestrictedPoints + pdo.dPoints.length >= dcpIndex) {
          if (pdo.mode != EditingMode.group) {
            return {
              "from": sumOfControlPoints + 1,
              "to": sumOfControlPoints + pdo.points.length + 1,
              "restricted_from": sumOfRestrictedPoints + 1,
              "restricted_to": sumOfRestrictedPoints + pdo.rPoints.length + 1,
              "data_from": sumOfDataPoints + 1,
              "data_to": sumOfDataPoints + pdo.dPoints.length + 1,
              "path": k.toString(),
              "curve": pdo,
            };
          } else {
            PointDrawGroup groupPDO = pdo as PointDrawGroup;
            Map<String, dynamic> result = groupPDO.curveFinderFunction(
                dcpIndex: dcpIndex - sumOfDataPoints - 1);
            result["path"] = "$k/" + result["path"];
            result["from"] += (sumOfControlPoints + 1);
            result["to"] += (sumOfControlPoints + 1);
            result["restricted_from"] += (sumOfRestrictedPoints + 1);
            result["restricted_to"] += (sumOfRestrictedPoints + 1);
            result["data_from"] += (sumOfDataPoints + 1);
            result["data_to"] += (sumOfDataPoints + 1);
            return result;
          }
        }
        sumOfControlPoints = sumOfControlPoints + pdo.points.length;
        sumOfRestrictedPoints = sumOfRestrictedPoints + pdo.rPoints.length;
        sumOfDataPoints = sumOfDataPoints + pdo.dPoints.length;
      }
      throw Exception("Path not found from curve finder function");
    } else {
      throw Exception("Path not found from curve finder function");
    }
  }

  Map<String, dynamic> Function({num? cpIndex, num? rcpIndex})
      curveFinderGetter(List<PointDrawObject> objects) {
    return curveFinderFunction;
  }

  @override
  void deleteControlPoint(int index, {bool notify = true}) {
    super.deleteControlPoint(index, notify: false);
    int cpFrom = 0;
    int cpLen;
    for (int i = 0; i < group.length; i++) {
      cpLen = group[i].points.length;
      if (index < cpFrom + cpLen) {
        group[i].deleteControlPoint(index - cpFrom, notify: false);
        break;
      }
      cpFrom += cpLen;
    }
    if (notify) {
      notifyListeners();
    }
  }

  @override
  PointDrawGroup moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    int cpFrom = 0;
    int rcpFrom = 0;
    int dcpFrom = 0;
    int cpLen, rcpLen, dcpLen;
    for (int i = 0; i < group.length; i++) {
      cpLen = group[i].points.length;
      rcpLen = group[i].rPoints.length;
      dcpLen = group[i].dPoints.length;
      if (index < cpFrom + cpLen) {
        group[i] =
            group[i].moveControlPoint(newPosition, index - cpFrom, args: args);
        for (int j = rcpFrom; j < rcpFrom + rcpLen; j++) {
          rPoints[j] = group[i].rPoints[j - rcpFrom];
        }
        for (int k = dcpFrom; k < dcpFrom + dcpLen; k++) {
          dPoints[k] = group[i].dPoints[k - dcpFrom];
        }
        break;
      }
      cpFrom += cpLen;
      rcpFrom += rcpLen;
    }
    return this;
  }

  @override
  PointDrawGroup moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    int from = 0;
    int len;
    for (int i = 0; i < group.length; i++) {
      len = group[i].rPoints.length;
      if (index < from + len) {
        group[i] = group[i].moveRestrictedControlPoint(
            localPosition, index - from,
            args: args);
        for (int j = from; j < from + len; j++) {
          rPoints[j] = group[i].rPoints[j - from];
        }
        break;
      }
      from += len;
    }
    return this;
  }

  @override
  PointDrawGroup moveDataControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveDataControlPoint(newPosition, index, args: args);
    int from = 0;
    int rcpFrom = 0;
    int len, rcpLen;
    for (int i = 0; i < group.length; i++) {
      len = group[i].dPoints.length;
      rcpLen = group[i].rPoints.length;
      if (index < from + len) {
        group[i] = group[i]
            .moveDataControlPoint(newPosition, index - from, args: args);
        for (int j = rcpFrom; j < rcpFrom + rcpLen; j++) {
          rPoints[j] = group[i].rPoints[j - rcpFrom];
        }
        for (int k = from; k < from + len; k++) {
          dPoints[k] = group[i].dPoints[k - from];
        }
        break;
      }
      from += len;
      rcpFrom += rcpLen;
    }
    return this;
  }

  void refreshPoints() {
    int cpFrom = 0;
    int rcpFrom = 0;
    int dcpFrom = 0;
    int cpLen, rcpLen, dcpLen;
    for (int i = 0; i < group.length; i++) {
      cpLen = group[i].points.length;
      rcpLen = group[i].rPoints.length;
      dcpLen = group[i].dPoints.length;
      group[i].points = points.sublist(cpFrom, cpFrom + cpLen);
      group[i].rPoints = rPoints.sublist(rcpFrom, rcpFrom + rcpLen);
      group[i].dPoints = dPoints.sublist(dcpFrom, dcpFrom + dcpLen);
      cpFrom += cpLen;
      rcpFrom += rcpLen;
      dcpFrom += dcpLen;
    }
    notifyListeners();
  }

  @override
  PointDrawGroup flipHorizontal(Matrix4 zoomTransform, {Offset? center}) {
    super.flipHorizontal(zoomTransform, center: center);
    refreshPoints();
    return this;
  }

  @override
  PointDrawGroup flipVertical(Matrix4 zoomTransform, {Offset? center}) {
    super.flipVertical(zoomTransform, center: center);
    refreshPoints();
    return this;
  }

  @override
  PointDrawGroup duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawGroup.from(this,
          displacement: displacement,
          key: ObjectKey("Group:" + generateAutoID()));
    } else {
      return PointDrawGroup.from(this,
          key: ObjectKey("Group:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Group";
}

class PointDrawText extends PointDrawObject {
  String content = "";

  double fontSize = 16.0;

  TextAlign align = TextAlign.left;

  double width = 150;

  double height = 66;

  double? radius;

  int linesCount = 3;

  TextDirection textDirection = TextDirection.ltr;

  String? fontFamily;

  FontWeight weight = FontWeight.normal;

  bool roundedRectangleChatBoxBorder = false;

  double gap = _arrowGap;

  PointDrawText.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(EditingMode.text, snapshot, key: key) {
    fPaint.color = Colors.white;
    fPaint.shader = null;
    sPaint.strokeJoin = StrokeJoin.miter;
    filled = true;
    supplementaryPropertiesModifiers.addAll([
      getIncrementFontButton,
      getDecrementFontButton,
      getAlignLeftButton,
      getAlignCenterButton,
      getAlignRightButton,
      getToggleBoldButton,
      getToggleRoundedRectangleBorderButton,
      getFontFamilySelection
    ]);
  }

  PointDrawText(
      {this.content = "",
      this.fontSize = 16.0,
      this.align = TextAlign.left,
      this.width = 150.0,
      this.height = 66.0,
      this.linesCount = 3,
      this.textDirection = TextDirection.ltr,
      required ObjectKey key})
      : super(mode: EditingMode.text, key: key) {
    fPaint.color = Colors.white;
    fPaint.shader = null;
    sPaint.strokeJoin = StrokeJoin.miter;
    filled = true;
    supplementaryPropertiesModifiers.addAll([
      getIncrementFontButton,
      getDecrementFontButton,
      getAlignLeftButton,
      getAlignCenterButton,
      getAlignRightButton,
      getToggleBoldButton,
      getToggleRoundedRectangleBorderButton,
      getFontFamilySelection
    ]);
  }

  PointDrawText.from(PointDrawText object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.text, key: key) {
    content = object.content;
    fontSize = object.fontSize;
    align = object.align;
    width = object.width;
    height = object.height;
    linesCount = object.linesCount;
    textDirection = object.textDirection;
    fontFamily = object.fontFamily;
    weight = object.weight;
    roundedRectangleChatBoxBorder = object.roundedRectangleChatBoxBorder;
    gap = object.gap;
    radius = object.radius;
    fPaint.color = Colors.white;
    fPaint.shader = null;
    sPaint.strokeJoin = StrokeJoin.miter;
    filled = true;
    supplementaryPropertiesModifiers.addAll([
      getIncrementFontButton,
      getDecrementFontButton,
      getAlignLeftButton,
      getAlignCenterButton,
      getAlignRightButton,
      getToggleBoldButton,
      getToggleRoundedRectangleBorderButton,
      getFontFamilySelection
    ]);
  }

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO:
    return const SVGPointDrawElement(svgContent: "");
  }

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint];
    Rect rect = Rect.fromPoints(firstPoint, secondPoint);
    width = rect.width;
    height = rect.height;
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[contentKey] = content;
    data[fontSizeKey] = fontSize;
    data[textBoxWidthKey] = width;
    data[textBoxHeightKey] = height;
    data[textDirectionKey] = textDirection.name;
    data[fontFamilyKey] = fontFamily;
    data[textAlignKey] = align.name;
    data[fontWeightKey] = weight.index;
    data[lineCountKey] = linesCount;
    data[radiusKey] = radius;
    data[gapKey] = gap;
    data[roundedRectangleChatBoxBorderKey] = roundedRectangleChatBoxBorder;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    content = data[contentKey];
    fontSize = data[fontSizeKey];
    width = data[textBoxWidthKey];
    height = data[textBoxHeightKey];
    textDirection = getTextDirection(data[textDirectionKey]);
    align = getTextAlign(data[textAlignKey]);
    fontFamily = data[fontFamilyKey];
    linesCount = data[lineCountKey];
    weight = getFontWeight(data[fontWeightKey]);
    if (data.containsKey(gapKey)) {
      gap = data[gapKey];
    }
    if (data.containsKey(radiusKey)) {
      radius = data[radiusKey];
    }
    if (data.containsKey(roundedRectangleChatBoxBorderKey)) {
      roundedRectangleChatBoxBorder = data[roundedRectangleChatBoxBorderKey];
    }
  }

  @override
  bool get validNewPoint => false;

  @override
  bool get isInitialized => points.isNotEmpty;

  Rect drawBorder(Canvas canvas, {Matrix4? zoomTransform}) {
    Path roundedRectPath = Path();
    if (points.length == 3 && rPoints.isNotEmpty) {
      radius = (points.first - rPoints.first).distance;
      roundedRectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromPoints(points.first, points[1]),
          Radius.circular(radius ?? 0)));
    }
    Path arrowPath = Path()
      ..addPolygon([
        rPoints.last + const Offset(-_arrowGap, -1),
        points.last,
        rPoints.last + const Offset(_arrowGap, -1),
      ], false);
    if (zoomTransform != null) {
      roundedRectPath = roundedRectPath.transform(zoomTransform.storage);
      arrowPath = arrowPath.transform(zoomTransform.storage);
    }
    canvas.drawPath(roundedRectPath, sPaint);
    sPaint.strokeMiterLimit = sPaint.strokeWidth * 10;
    canvas.drawPath(arrowPath, sPaint);
    canvas.drawPath(roundedRectPath, fPaint);
    canvas.drawPath(arrowPath, fPaint);
    roundedRectPath.addPath(arrowPath, Offset.zero);
    return roundedRectPath.getBounds();
  }

  @override
  void draw(Canvas canvas, double ticker,
      {Matrix4? zoomTransform, bool drawText = true}) {
    Rect? borderRect;
    zoomTransform ??= Matrix4.identity();
    if (roundedRectangleChatBoxBorder) {
      borderRect = drawBorder(canvas, zoomTransform: zoomTransform);
    }
    if (points.isNotEmpty) {
      Offset topLeft, bottomRight;
      topLeft = matrixApply(zoomTransform, points.first);
      bottomRight =
          matrixApply(zoomTransform, points.first + Offset(width, height));
      if (drawText) {
        TextPainter textPainter =
            buildTextPainter(factor: zoomTransform.storage[0]);
        Offset adjustment;
        if (radius != null) {
          adjustment = Offset(radius! / 2, radius! / 2);
        } else {
          adjustment = const Offset(4, 0);
        }
        Offset offset = points.first + adjustment;
        offset = matrixApply(zoomTransform, offset);
        if (clips.isNotEmpty) {
          canvas.save();
          for (Path clipPath in clips.keys) {
            canvas.clipPath(clipPath);
          }
          textPainter.paint(canvas, offset);
          canvas.restore();
        } else {
          textPainter.paint(canvas, offset);
        }
      }
      boundingRect =
          borderRect ?? getTextEditingArea(topLeft, bottomRight).getBounds();
    }
  }

  TextPainter buildTextPainter({factor = 1.0}) {
    TextStyle textStyle = TextStyle(
        color: sPaint.color,
        fontSize: fontSize * factor,
        fontFamily: fontFamily,
        fontWeight: weight);
    TextPainter textPainter = TextPainter(
        text: TextSpan(style: textStyle, text: content, onEnter: (event) {}),
        textAlign: align,
        textDirection: textDirection,
        maxLines: linesCount,
        strutStyle: StrutStyle.fromTextStyle(textStyle));
    double maxWidth = width * factor - (radius ?? 0);
    double minWidth = width * factor - (radius ?? 10);
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }

  Offset getTextBoxLocation(Matrix4 transformationMatrix) {
    if (points.isEmpty) {
      return Offset.zero;
    } else {
      return matrixApply(transformationMatrix, points.first);
    }
  }

  Path getTextEditingArea(Offset topLeft, Offset bottomRight) {
    return Path()..addRect(Rect.fromPoints(topLeft, bottomRight));
  }

  UserInputWidget getInputController(
      TextEditingController controller, double zoomFactor) {
    return UserInputWidget(
      editingController: controller,
      onEditingComplete: null,
      hintText: "Enter text here",
      contentPadding: const EdgeInsets.only(left: 2.0, top: 3.0),
      overallSize: Size(width, height) * zoomFactor,
      minLines: max(3, linesCount + 1),
      fontSize: fontSize * zoomFactor,
      align: align,
      weight: weight,
      fontFamily: fontFamily,
      onChanged: (val) {
        content = val;
      },
      textColor: sPaint.color,
    );
  }

  @override
  PointDrawText moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    if (roundedRectangleChatBoxBorder) {
      width = (points[1].dx - points.first.dx).abs();
      height = (points[1].dy - points.first.dy).abs();
      updateRDSCPWhenCPMoved(args!["zoom_transform"], args: args);
    }
    return this;
  }

  @override
  PointDrawText updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    super.updateRDSCPWhenCPMoved(zoomTransform);
    radius = min(radius ?? 0, (points.first - points.last).dy.abs() / 2);
    Rect rect = Rect.fromPoints(points.first, points[1]);
    rPoints[0] = rect.topLeft + Offset.fromDirection(pi / 2, radius!);
    rPoints[1] = rect.bottomRight + Offset(-gap, 0);
    return this;
  }

  @override
  PointDrawText moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    assert(roundedRectangleChatBoxBorder,
        "Text box should only enable restricted control point when using rounded rectangle chat box border");
    if (index == 0) {
      double maxRadius = (points.last - points.first).dy.abs() / 2;
      radius = max(min((localPosition - points.first).dy, maxRadius), 2.0);
      Offset computedPoint =
          points.first + Offset.fromDirection(pi / 2, radius!);
      if (boundingRect.inflate(controlPointSize).contains(computedPoint)) {
        rPoints[index] = computedPoint;
      }
    } else if (index == 1) {
      Rect rect = Rect.fromPoints(points.first, points[1]);
      gap = max(
          min(rect.bottomRight.dx - localPosition.dx,
              rect.width - radius! - 10),
          radius! + _arrowGap);
      Offset computedPoint =
          Offset(rect.bottomRight.dx - gap, rect.bottomRight.dy);
      if (boundingRect.inflate(controlPointSize).contains(computedPoint)) {
        rPoints[index] = computedPoint;
      }
    }
    return this;
  }

  @override
  PointDrawText transformByRotate(
      Offset center, double angle, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    if (roundedRectangleChatBoxBorder) {
      points = groupControlPoints ??
          List<Offset>.generate(
              points.length, (ind) => rotate(points[ind], center, angle));
      Rect rect = Rect.fromPoints(points.first, points.last);
      radius = max(5.0, (rect.topLeft - rPoints.first).distance);
      gap =
          max(radius! + _arrowGap, min(rect.width - radius! - _arrowGap, gap));
      rPoints = [
        rect.topLeft + Offset.fromDirection(pi / 2, radius!),
        rect.bottomRight + Offset(-gap, 0)
      ];
      shaderParam = shaderParam?.transformByRotate(center, angle);
      fPaint.shader = fPaint.shader != null
          ? shaderParam?.build(
              boundingRect: boundingRect, zoomTransform: zoomTransform)
          : null;
    }
    return this;
  }

  @override
  PointDrawText transformByHorizontalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ?? points;
    width = width * scaleFactor;
    return this;
  }

  @override
  PointDrawText transformByVerticalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ?? points;
    height = height * scaleFactor;
    return this;
  }

  @override
  PointDrawText transformByScale(
      Offset stationary, Offset scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ?? points;
    width = width * scaleFactor.dx;
    height = height * scaleFactor.dy;
    return this;
  }

  Widget getIncrementFontButton() {
    return ActionButton(
      mode,
      false,
      displayWidget: const UpFontSizeIcon(
        widthSize: 28,
      ),
      onPressed: () {
        fontSize++;
        notifyListeners();
      },
      toolTipMessage: "Increase font size",
    );
  }

  Widget getDecrementFontButton() {
    return ActionButton(
      mode,
      false,
      displayWidget: const DownFontSizeIcon(
        widthSize: 28,
      ),
      onPressed: () {
        if (fontSize > 0) {
          fontSize--;
          notifyListeners();
        }
      },
      toolTipMessage: "Decrease font size",
    );
  }

  Widget getAlignLeftButton() {
    return ActionButton(
      mode,
      align == TextAlign.left,
      displayWidget: const Icon(Icons.align_horizontal_left,
          size: 16, color: Colors.white),
      onPressed: () {
        align = TextAlign.left;
        notifyListeners();
      },
      toolTipMessage: "Align left",
    );
  }

  Widget getAlignCenterButton() {
    return ActionButton(
      mode,
      align == TextAlign.center,
      displayWidget: const Icon(Icons.align_horizontal_center,
          size: 16, color: Colors.white),
      onPressed: () {
        align = TextAlign.center;
        notifyListeners();
      },
      toolTipMessage: "Align center",
    );
  }

  Widget getAlignRightButton() {
    return ActionButton(
      mode,
      align == TextAlign.right,
      displayWidget: const Icon(Icons.align_horizontal_right,
          size: 16, color: Colors.white),
      onPressed: () {
        align = TextAlign.right;
        notifyListeners();
      },
      toolTipMessage: "Align right",
    );
  }

  Widget getToggleBoldButton() {
    return ActionButton(
      mode,
      weight == FontWeight.bold,
      displayWidget:
          const Icon(Icons.format_bold, size: 16, color: Colors.white),
      onPressed: () {
        if (weight == FontWeight.bold) {
          weight = FontWeight.normal;
        } else {
          weight = FontWeight.bold;
        }
        notifyListeners();
      },
      toolTipMessage: "Bold",
    );
  }

  Widget getFontFamilySelection() {
    List<String> fontFamilies = [
      "Karla",
      "Rubik",
      "Parisienne",
      "Great Vibes",
      "Playfair",
      "Quicksand"
    ];
    return SizedBox(
      width: 280,
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 60,
              height: 24,
              alignment: Alignment.centerLeft,
              child: const Text("Font",
                  style: TextStyle(fontSize: 14, color: Colors.black))),
          Expanded(
            child: PopupMenuButton<String>(
                itemBuilder: (context) {
                  return [
                    for (String font in fontFamilies)
                      PopupMenuItem(
                        value: font,
                        child: Text(font,
                            style: TextStyle(fontSize: 14, fontFamily: font)),
                      ),
                  ];
                },
                onSelected: (val) {
                  fontFamily = val;
                  notifyListeners();
                },
                child: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(fontFamily ?? "Default font",
                          style: const TextStyle(fontSize: 14)),
                    ))),
          ),
        ],
      ),
    );
  }

  Widget getToggleRoundedRectangleBorderButton() {
    return ActionButton(
      mode,
      roundedRectangleChatBoxBorder,
      displayWidget: const RoundedRectangleChatBoxIcon(widthSize: 24),
      onPressed: () {
        roundedRectangleChatBoxBorder = !roundedRectangleChatBoxBorder;
        if (roundedRectangleChatBoxBorder) {
          if (points.length == 1) {
            points.add(points.first + Offset(width, height));
            Rect rect = Rect.fromPoints(points.first, points.last);
            points[0] = rect.topLeft;
            points[1] = rect.bottomRight;
            points.add(rect.bottomRight + Offset(0, rect.height * 0.33));
            radius = min(15.0, (rect.bottomLeft - rect.topLeft).distance / 2);
            gap = max(
                min(rect.width * 0.25 + radius! + _arrowGap,
                    rect.width - radius! - _arrowGap),
                radius! + _arrowGap);
            rPoints = [
              rect.topLeft + Offset.fromDirection(pi / 2, radius!),
              rect.bottomRight - Offset(gap, 0)
            ];
          }
        } else {
          points = [points.first];
          rPoints = [];
          gap = _arrowGap;
          radius = null;
        }
        notifyListeners();
      },
      toolTipMessage: "Chat box border",
      enabled: isInitialized,
    );
  }

  @override
  void flipHorizontal(Matrix4 zoomTransform, {Offset? center}) {
    return;
  }

  @override
  void flipVertical(Matrix4 zoomTransform, {Offset? center}) {
    return;
  }

  @override
  PointDrawText duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawText.from(this,
          displacement: displacement,
          key: ObjectKey("Text:" + generateAutoID()));
    } else {
      return PointDrawText.from(this,
          key: ObjectKey("Text:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Text";
}

const double _arrowGap = 15.0;

class PointDrawPathOp extends PointDrawPath {
  PointDrawPath? firstPathObject;

  PointDrawPath? secondPathObject;

  PathOperation op;

  PointDrawPathOp.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      this.firstPathObject, this.secondPathObject, this.op,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.pathOp, key: key);

  PointDrawPathOp(this.firstPathObject, this.secondPathObject,
      {this.op = PathOperation.union, required ObjectKey key})
      : super(mode: EditingMode.pathOp, key: key) {
    // points.addAll(firstPathObject?.points ?? []);
    // rPoints.addAll(firstPathObject?.rPoints ?? []);
    // dPoints.addAll(firstPathObject?.dPoints ?? []);
    // points.addAll(secondPathObject?.points ?? []);
    // rPoints.addAll(secondPathObject?.rPoints ?? []);
    // dPoints.addAll(secondPathObject?.dPoints ?? []);
    Path combinedRect = Path()
      ..addRect(firstPathObject?.boundingRect ?? Rect.zero)
      ..addRect(secondPathObject?.boundingRect ?? Rect.zero);
    boundingRect = combinedRect.getBounds();
  }

  PointDrawPathOp.from(PointDrawPathOp object,
      {this.firstPathObject,
      this.secondPathObject,
      this.op = PathOperation.union,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.pathOp, key: key) {
    firstPathObject = object.firstPathObject!.duplicate() as PointDrawPath;
    secondPathObject = object.secondPathObject!.duplicate() as PointDrawPath;
    op = object.op;
  }

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO:
    return const SVGPointDrawElement(svgContent: "");
  }

  @override
  bool get validNewPoint => false;

  @override
  bool get isInitialized => firstPathObject != null && secondPathObject != null;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    return;
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: false);
    data[firstPathObjectKey] = firstPathObject?.toJson();
    data[secondPathObjectKey] = secondPathObject?.toJson();
    data[pathOperationKey] = op.name;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {parsePoints = true}) {
    super.toObject(data, parsePoints: false);
    EditingMode firstPathObjectMode =
        getEditingMode(data[firstPathObjectKey][editingModeKey]);
    EditingMode secondPathObjectMode =
        getEditingMode(data[secondPathObjectKey][editingModeKey]);
    firstPathObject = getNewPointDrawObject(firstPathObjectMode);
    secondPathObject = getNewPointDrawObject(secondPathObjectMode);
    firstPathObject!.toObject(data[firstPathObjectKey]);
    secondPathObject!.toObject(data[secondPathObjectKey]);
    op = getPathOperation(data[pathOperationKey]);
  }

  @override
  Path getPath() {
    Path path = Path();
    if (isInitialized) {
      path = Path.combine(
          op, firstPathObject!.getPath(), secondPathObject!.getPath());
    }
    return path;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedPath = Path();

    return animatedPath;
  }

  @override
  PointDrawPathOp transformByTranslate(
      double dx, double dy, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    super.transformByTranslate(dx, dy, zoomTransform,
        groupControlPoints: groupControlPoints);
    firstPathObject?.transformByTranslate(dx, dy, zoomTransform,
        groupControlPoints: groupControlPoints);
    secondPathObject?.transformByTranslate(dx, dy, zoomTransform,
        groupControlPoints: groupControlPoints);
    return this;
  }

  @override
  PointDrawObject transformByRotate(
      Offset center, double angle, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    super.transformByRotate(center, angle, zoomTransform,
        groupControlPoints: groupControlPoints);
    firstPathObject?.transformByRotate(center, angle, zoomTransform,
        groupControlPoints: groupControlPoints);
    secondPathObject?.transformByRotate(center, angle, zoomTransform,
        groupControlPoints: groupControlPoints);
    return this;
  }

  @override
  PointDrawObject transformByHorizontalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    super.transformByHorizontalScale(stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    firstPathObject?.transformByHorizontalScale(
        stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    secondPathObject?.transformByHorizontalScale(
        stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    return this;
  }

  @override
  PointDrawObject transformByVerticalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    super.transformByVerticalScale(stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    firstPathObject?.transformByVerticalScale(
        stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    secondPathObject?.transformByVerticalScale(
        stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    return this;
  }

  @override
  PointDrawObject transformByScale(
      Offset stationary, Offset scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    super.transformByScale(stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    firstPathObject?.transformByScale(stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    secondPathObject?.transformByScale(stationary, scaleFactor, zoomTransform,
        groupControlPoints: groupControlPoints);
    return this;
  }

  @override
  void flipHorizontal(Matrix4 zoomTransform, {Offset? center}) {
    if (boundingRect != Rect.zero) {
      center = boundingRect.center;
      firstPathObject?.flipHorizontal(zoomTransform, center: center);
      secondPathObject?.flipHorizontal(zoomTransform, center: center);
      super.flipHorizontal(zoomTransform, center: center);
    }
  }

  @override
  void flipVertical(Matrix4 zoomTransform, {Offset? center}) {
    if (boundingRect != Rect.zero) {
      center = boundingRect.center;
      firstPathObject?.flipVertical(zoomTransform, center: center);
      secondPathObject?.flipVertical(zoomTransform, center: center);
      super.flipVertical(zoomTransform, center: center);
    }
  }

  @override
  PointDrawPathOp duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawPathOp.from(this,
          displacement: displacement,
          key: ObjectKey("Path op:" + generateAutoID()));
    } else {
      return PointDrawPathOp.from(this,
          key: ObjectKey("Path op:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Path op";
}
