import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/svg/svg_builder.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/parametric_objects.dart';
import 'package:pointdraw/point_draw_models/app_components/action_button.dart';
import 'package:pointdraw/point_draw_models/app_components/icon_sketch.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart'
    show getConicDirection, getConicOffset, rotate;
import 'package:pointdraw/point_draw_models/utilities/matrices.dart';

abstract class PointDrawOneDimensionalObject extends PointDrawPath {
  bool closed;

  bool squareStrokeCap;

  PointDrawOneDimensionalObject.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.closed = false,
      this.squareStrokeCap = false,
      EditingMode mode = EditingMode.oneDimensional,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: mode, key: key) {
    closed = snapshot.get(closedKey);
    squareStrokeCap = snapshot.get(squareStrokeCapKey);
    if (squareStrokeCap) {
      sPaint.strokeCap = StrokeCap.square;
    } else {
      sPaint.strokeCap = StrokeCap.round;
    }
    supplementaryPropertiesModifiers.addAll([
      getToggleCloseButton,
      getToggleSquareStrokeCap,
    ]);
  }

  PointDrawOneDimensionalObject({
    this.closed = false,
    this.squareStrokeCap = false,
    EditingMode mode = EditingMode.oneDimensional,
    required ObjectKey key,
  }) : super(mode: mode, key: key) {
    supplementaryPropertiesModifiers.addAll([
      getToggleCloseButton,
      getToggleSquareStrokeCap,
    ]);
  }

  PointDrawOneDimensionalObject.from(PointDrawOneDimensionalObject object,
      {this.closed = false,
      this.squareStrokeCap = false,
      EditingMode mode = EditingMode.oneDimensional,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, mode: mode, displacement: displacement, key: key) {
    closed = object.closed;
    squareStrokeCap = object.squareStrokeCap;
    supplementaryPropertiesModifiers.addAll([
      getToggleCloseButton,
      getToggleSquareStrokeCap,
    ]);
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data.addAll({
      editingModeKey: mode.name,
      closedKey: closed,
      squareStrokeCapKey: squareStrokeCap,
    });
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    closed = data[closedKey];
    squareStrokeCap = data[squareStrokeCapKey];
  }

  Curve2D? curve2D;

  Path getParametrizedPath(double end, {double start = 0, Path? from});

  Path regularThicken(Path path,
      {double maxWidth = 5, double tolerance = 0.8}) {
    // Path thickenedPath = path.(Offset(0, -maxWidth / 2));
    // thickenedPath.extendWithPath(path, Offset(0, maxWidth / 2));
    // thickenedPath.close();
    // return thickenedPath;
    // TODO: consider using splinePath regularThicken function here.
    return path;
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
      for (Path clipPath in clips.keys) {
        canvas.clipPath(clipPath);
      }
      if (outlined) {
        if (squareStrokeCap) {
          sPaint.strokeCap = StrokeCap.square;
        }
        canvas.drawPath(path, sPaint);
      }
      if (filled && closed) {
        fPaint.shader = fPaint.shader != null
            ? shaderParam?.build(
                boundingRect: boundingRect, zoomTransform: zoomTransform)
            : null;
        canvas.drawPath(path, fPaint);
      }
      canvas.restore();
    } else {
      if (outlined) {
        if (squareStrokeCap) {
          sPaint.strokeCap = StrokeCap.square;
        }
        canvas.drawPath(path, sPaint);
      }
      if (filled && closed) {
        fPaint.shader = fPaint.shader != null
            ? shaderParam?.build(
                boundingRect: boundingRect, zoomTransform: zoomTransform)
            : null;
        canvas.drawPath(path, fPaint);
      }
    }
    return path;
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

  Widget getToggleSquareStrokeCap() {
    return ActionButton(
      mode,
      squareStrokeCap,
      displayWidget: const SquareStrokeCapIcon(
        widthSize: 28,
      ),
      onPressed: () {
        squareStrokeCap = !squareStrokeCap;
        if (squareStrokeCap) {
          sPaint.strokeCap = StrokeCap.square;
        } else {
          sPaint.strokeCap = StrokeCap.round;
        }
        notifyListeners();
      },
      toolTipMessage: "Toggle square stroke cap",
    );
  }
}

class PointDrawLine extends PointDrawOneDimensionalObject {
  bool polygonal = false;

  PointDrawLine({this.polygonal = false, required ObjectKey key})
      : super(mode: EditingMode.line, key: key) {
    enableDeleteControlPoint = true;
    supplementaryPropertiesModifiers.add(getTogglePolygonalButton);
  }

  PointDrawLine.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.line, key: key) {
    polygonal = snapshot.get(polygonalKey) as bool;
    enableDeleteControlPoint = true;
    supplementaryPropertiesModifiers.add(getTogglePolygonalButton);
  }

  PointDrawLine.from(PointDrawLine object,
      {this.polygonal = false,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.line, key: key) {
    polygonal = object.polygonal;
    enableDeleteControlPoint = true;
    supplementaryPropertiesModifiers.add(getTogglePolygonalButton);
  }

  @override
  bool get isInitialized => points.length >= 2;

  @override
  bool get validNewPoint => polygonal;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[polygonalKey] = polygonal;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    polygonal = data[polygonalKey];
  }

  @override
  Path getPath() {
    if (points.length >= 2) {
      return Path()..addPolygon(points, closed);
    }
    return Path();
  }

  @override
  Path getAnimatedPath(double ticker) {
    if (points.length >= 2) {
      return Path()..addPolygon(getAnimatedPoints(ticker), closed);
    }
    return Path();
  }

  @override
  Path getParametrizedPath(double end, {double start = 0, Path? from}) {
    Path path = from ?? Path();
    if (points.length >= 2) {
      curve2D ??= PolygonalLine2D(points);
      Iterable<Curve2DSample> samples =
          curve2D!.generateSamples(start: start, end: end, tolerance: 1e-6);
      path.addPolygon(samples.map((e) => e.value).toList(), false);
    }
    return path;
  }

  Widget getTogglePolygonalButton() {
    return ActionButton(
      mode,
      polygonal,
      displayWidget: const PolygonalLineIcon(
        widthSize: 28,
      ),
      onPressed: () {
        polygonal = !polygonal;
        notifyListeners();
      },
      toolTipMessage: "Toggle polygonal",
    );
  }

  @override
  PointDrawLine duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawLine.from(this,
          displacement: displacement,
          key: ObjectKey("Line:${generateAutoID()}"));
    } else {
      return PointDrawLine.from(this,
          key: ObjectKey("Line:${generateAutoID()}"));
    }
  }

  @override
  String toString() => "Line";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    if (points.length >= 2) {
      String viewPort = "<svg height=\"500\" width=\"800\">";
      String lineSVG =
          "<line x1=\"${points[0].dx}\" y1=\"${points[0].dy}\" x2=\"${points[1].dx}\" y2=\"${points[1].dy}\" style=\"stroke:rgb(${fPaint.color.red},${fPaint.color.green},${fPaint.color.blue});stroke-width:${strokePaint.strokeWidth}\" />";
      String svgContent = "$viewPort\n$lineSVG\n</svg>";
      print(svgContent);
      return SVGPointDrawElement(svgContent: svgContent);
    }

    return const SVGPointDrawElement(svgContent: "Not Enough Control Points");
  }
}

abstract class PointDrawBezier extends PointDrawOneDimensionalObject {
  bool chained = false;

  bool smoothChain = true;

  PointDrawBezier.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.chained = false,
      EditingMode mode = EditingMode.bezier,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: mode, key: key) {
    chained = snapshot.get(chainedKey);
    supplementaryPropertiesModifiers
        .addAll([getToggleChainedButton, getToggleSmoothChainButton]);
    enableDeleteControlPoint = true;
  }

  PointDrawBezier(
      {this.chained = false,
      mode = EditingMode.oneDimensional,
      required ObjectKey key})
      : super(mode: mode, key: key) {
    supplementaryPropertiesModifiers
        .addAll([getToggleChainedButton, getToggleSmoothChainButton]);
    enableDeleteControlPoint = true;
  }

  PointDrawBezier.from(PointDrawBezier object,
      {EditingMode mode = EditingMode.bezier,
      this.chained = false,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key) {
    chained = object.chained;
    smoothChain = object.smoothChain;
    enableDeleteControlPoint = true;
    supplementaryPropertiesModifiers
        .addAll([getToggleChainedButton, getToggleSmoothChainButton]);
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[chainedKey] = chained;
    data[smoothChainKey] = smoothChain;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    chained = data[chainedKey];
    if (data.containsKey(smoothChainKey)) {
      smoothChain = data[smoothChainKey];
    }
  }

  @override
  PointDrawBezier moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    if (smoothChain) {
      updateChainedPoints(newPosition, index);
    }
    return this;
  }

  void updateChainedPoints(Offset newOffset, int indexMoved);

  Widget getToggleChainedButton() {
    return ActionButton(
      mode,
      chained,
      displayWidget: const ChainBezierIcon(
        widthSize: 28,
      ),
      onPressed: () {
        chained = !chained;
        notifyListeners();
      },
      toolTipMessage: "Chain curves",
    );
  }

  Widget getToggleSmoothChainButton() {
    return ActionButton(
      mode,
      smoothChain,
      displayWidget: const SmoothChainBezierIcon(
        widthSize: 28,
      ),
      onPressed: () {
        smoothChain = !smoothChain;
        notifyListeners();
      },
      toolTipMessage: "Smooth chains",
      enabled: chained,
    );
  }
}

class PointDrawArc extends PointDrawOneDimensionalObject {
  double width = 100;

  double height = 100;

  double _startConicAngle = 0.0;

  double _sweepConicAngle = pi;

  double _endCoordinateAngle = pi;

  double _orientation = 0.0;

  PointDrawArc.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.arc, key: key) {
    width = snapshot.get(arcWidthKey);
    height = snapshot.get(arcHeightKey);
  }

  PointDrawArc({this.width = 100, this.height = 100, required ObjectKey key})
      : super(mode: EditingMode.arc, key: key);

  PointDrawArc.from(PointDrawArc object,
      {this.width = 100,
      this.height = 100,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            mode: EditingMode.arc, displacement: displacement, key: key) {
    width = object.width;
    height = object.height;
  }

  @override
  bool get isInitialized => points.isNotEmpty && rPoints.length == 3;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [(firstPoint + secondPoint) / 2];
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[arcWidthKey] = width;
    data[arcHeightKey] = height;
    data[startAngleKey] = _startConicAngle;
    data[sweepAngleKey] = _sweepConicAngle;
    data[orientationKey] = _orientation;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    width = data[arcWidthKey];
    height = data[arcHeightKey];
    _startConicAngle = data[startAngleKey];
    _sweepConicAngle = data[sweepAngleKey];
    _orientation = data[orientationKey];
    if (isInitialized) {
      _endCoordinateAngle = (rPoints[1] - points[0]).direction;
    }
  }

  @override
  Path getPath() {
    Path arc = Path();
    if (points.length == 1 && rPoints.length == 3) {
      Rect rect =
          Rect.fromCenter(center: points[0], width: width, height: height);
      double direction = (rPoints[2] - points[0]).direction;
      arc.addArc(rect, _startConicAngle, _sweepConicAngle);
      if (closed) {
        arc.close();
      }
      return arc.transform(rotateZAbout(direction, points[0]).storage);
    }
    return arc;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedArc = Path();
    if (points.length == 1 && rPoints.length == 3) {
      // Current code does not animate. When animating, consider updating rdscp when cp moved;
      // Offset cent = getAnimatedPoints(ticker).first;
      Rect rect =
          Rect.fromCenter(center: points[0], width: width, height: height);
      double direction = (rPoints[2] - points[0]).direction;
      animatedArc.addArc(rect, _startConicAngle, _sweepConicAngle);
      if (closed) {
        animatedArc.close();
      }
      return animatedArc.transform(rotateZAbout(direction, points[0]).storage);
    }
    return animatedArc;
  }

  @override
  Path getParametrizedPath(double end, {double start = 0, Path? from}) {
    return from ?? Path();
  }

  @override
  void autoInitializeControlPoints() {
    if (points.length == 1 && rPoints.isEmpty) {
      Rect rect = Rect.fromCenter(center: points[0], width: 100, height: 100);
      Offset directionPoint = rect.center + Offset.fromDirection(0, sqrt2 * 50);
      rPoints = [rect.centerRight, rect.centerLeft, directionPoint];
      dPoints = [rect.bottomRight];
    }
  }

  @override
  PointDrawArc moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    args!["translate"] = newPosition - points.first;
    super.moveControlPoint(newPosition, index, args: args);
    updateRDSCPWhenCPMoved(args["zoom_transform"], args: args);
    return this;
  }

  @override
  PointDrawArc updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic>? args}) {
    super.updateRDSCPWhenCPMoved(zoomTransform);
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    rPoints[0] = matrixApply(rotateZAbout(_orientation, rect.center),
        getConicOffset(rect, _startConicAngle));
    rPoints[1] = matrixApply(rotateZAbout(_orientation, rect.center),
        getConicOffset(rect, getConicDirection(rect, _endCoordinateAngle)));
    rPoints[2] = rect.center +
        Offset.fromDirection(
            _orientation, (rect.bottomRight - rect.center).distance);
    dPoints[0] = rect.bottomRight;
    return this;
  }

  @override
  PointDrawArc moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    double direction = (localPosition - points[0]).direction;
    double rotationAdjustedAngle = (rPoints[2] - rect.center).direction;
    if (args!["restriction_index"] != 2) {
      rPoints[index] = matrixApply(
          rotateZAbout(rotationAdjustedAngle, rect.center),
          getConicOffset(
              rect,
              getConicDirection(
                  rect,
                  (localPosition - rect.center).direction -
                      rotationAdjustedAngle)));
      if (index == 1) {
        _endCoordinateAngle = direction;
      }
      _startConicAngle = getConicDirection(
          rect,
          (rPoints[0] - points[0]).direction -
              (rPoints[2] - points[0]).direction);
      _sweepConicAngle = getConicDirection(
              rect,
              (rPoints[1] - points[0]).direction -
                  (rPoints[2] - points[0]).direction) -
          _startConicAngle;
      if (_sweepConicAngle < 0) {
        _sweepConicAngle += 2 * pi;
      } else if (_sweepConicAngle > 2 * pi) {
        _sweepConicAngle -= 2 * pi;
      }
    } else {
      rPoints[0] = matrixApply(
          rotateZAbout(direction, rect.center),
          getConicOffset(
              rect,
              getConicDirection(
                  rect,
                  (rPoints[0] - rect.center).direction -
                      rotationAdjustedAngle)));
      rPoints[1] = matrixApply(
          rotateZAbout(direction, rect.center),
          getConicOffset(
              rect,
              getConicDirection(
                  rect,
                  (rPoints[1] - rect.center).direction -
                      rotationAdjustedAngle)));
      rPoints[index] = rect.center +
          Offset.fromDirection(
              direction, (rect.bottomRight - rect.center).distance);
      _orientation = direction;
    }
    return this;
  }

  @override
  PointDrawArc moveDataControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveDataControlPoint(newPosition, index, args: args);
    width = 2 * (dPoints[index] - points[0]).dx.abs();
    height = 2 * (dPoints[index] - points[0]).dy.abs();
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    Matrix4 rotationMatrix = rotateZAbout(_orientation, rect.center);
    rPoints[0] =
        matrixApply(rotationMatrix, getConicOffset(rect, _startConicAngle));
    rPoints[1] =
        matrixApply(rotationMatrix, getConicOffset(rect, _endCoordinateAngle));
    rPoints[2] = rect.center +
        Offset.fromDirection(
            _orientation, (rect.bottomRight - rect.center).distance);
    return this;
  }

  @override
  PointDrawArc transformByRotate(
      Offset center, double angle, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length, (ind) => rotate(points[ind], center, angle));
    rPoints = List<Offset>.generate(
        rPoints.length, (ind) => rotate(rPoints[ind], center, angle));
    dPoints[0] =
        Rect.fromCenter(center: points[0], width: width, height: height)
            .bottomRight;
    shaderParam = shaderParam?.transformByRotate(center, angle);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawArc transformByHorizontalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                stationary.dx + (points[ind].dx - stationary.dx) * scaleFactor,
                points[ind].dy));
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    rPoints[2] = points[0] +
        Offset.fromDirection(
            (Offset(
                        stationary.dx +
                            (rPoints[2].dx - stationary.dx) * scaleFactor,
                        rPoints[2].dy) -
                    points[0])
                .direction,
            (rect.center - rect.bottomRight).distance);
    double rotationAdjustedAngle = (rPoints[2] - rect.center).direction;
    Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    rPoints[0] = matrixApply(
        rotationMatrix,
        getConicOffset(
            rect,
            getConicDirection(rect,
                (rPoints[0] - rect.center).direction - rotationAdjustedAngle)));
    rPoints[1] = matrixApply(
        rotationMatrix,
        getConicOffset(
            rect,
            getConicDirection(rect,
                (rPoints[1] - rect.center).direction - rotationAdjustedAngle)));
    width = width * scaleFactor;
    dPoints[0] =
        Rect.fromCenter(center: points[0], width: width, height: height)
            .bottomRight;
    shaderParam =
        shaderParam?.transformByHorizontalScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawArc transformByVerticalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                points[ind].dx,
                stationary.dy +
                    (points[ind].dy - stationary.dy) * scaleFactor));
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    rPoints[2] = points[0] +
        Offset.fromDirection(
            (Offset(
                        rPoints[2].dx,
                        stationary.dy +
                            (rPoints[2].dy - stationary.dy) * scaleFactor) -
                    points[0])
                .direction,
            (rect.center - rect.bottomRight).distance);
    double rotationAdjustedAngle = (rPoints[2] - rect.center).direction;
    Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    rPoints[0] = matrixApply(
        rotationMatrix,
        getConicOffset(
            rect,
            getConicDirection(rect,
                (rPoints[0] - rect.center).direction - rotationAdjustedAngle)));
    rPoints[1] = matrixApply(
        rotationMatrix,
        getConicOffset(
            rect,
            getConicDirection(rect,
                (rPoints[1] - rect.center).direction - rotationAdjustedAngle)));
    height = height * scaleFactor;
    dPoints[0] =
        Rect.fromCenter(center: points[0], width: width, height: height)
            .bottomRight;
    shaderParam =
        shaderParam?.transformByVerticalScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawArc transformByScale(
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
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    rPoints[2] = points[0] +
        Offset.fromDirection(
            (Offset(
                        stationary.dx +
                            (rPoints[2].dx - stationary.dx) * scaleFactor.dx,
                        stationary.dy +
                            (rPoints[2].dy - stationary.dy) * scaleFactor.dy) -
                    points[0])
                .direction,
            (rect.center - rect.bottomRight).distance);
    double rotationAdjustedAngle = (rPoints[2] - rect.center).direction;
    Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    rPoints[0] = matrixApply(
        rotationMatrix,
        getConicOffset(
            rect,
            getConicDirection(rect,
                (rPoints[0] - rect.center).direction - rotationAdjustedAngle)));
    rPoints[1] = matrixApply(
        rotationMatrix,
        getConicOffset(
            rect,
            getConicDirection(rect,
                (rPoints[1] - rect.center).direction - rotationAdjustedAngle)));
    height = height * scaleFactor.dy;
    width = width * scaleFactor.dx;
    dPoints[0] =
        Rect.fromCenter(center: points[0], width: width, height: height)
            .bottomRight;
    shaderParam = shaderParam?.transformByScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawArc duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawArc.from(this,
          displacement: displacement,
          key: ObjectKey("Arc:" + generateAutoID()));
    } else {
      return PointDrawArc.from(this, key: ObjectKey("Arc:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Arc";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawSplineCurve extends PointDrawOneDimensionalObject {
  PointDrawSplineCurve.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {EditingMode mode = EditingMode.splineCurve,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: mode, key: key) {
    enableDeleteControlPoint = true;
  }

  PointDrawSplineCurve(
      {EditingMode mode = EditingMode.splineCurve, required ObjectKey key})
      : super(mode: mode, key: key) {
    enableDeleteControlPoint = true;
  }

  PointDrawSplineCurve.from(PointDrawSplineCurve object,
      {EditingMode mode = EditingMode.splineCurve,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key) {
    enableDeleteControlPoint = true;
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    return data;
  }

  @override
  bool get isInitialized => points.length >= 4;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [
      firstPoint,
      firstPoint * 0.67 + secondPoint * 0.33,
      firstPoint * 0.33 + secondPoint * 0.67,
      secondPoint
    ];
  }

  @override
  bool get validNewPoint => true;

  @override
  Path getPath() {
    Path cmrPath = Path();
    if (points.length >= 4) {
      CatmullRomSpline cmrSpline;
      if (closed) {
        cmrSpline = CatmullRomSpline(points + [points.first]);
      } else {
        cmrSpline = CatmullRomSpline(points);
      }
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      cmrPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for (Curve2DSample pt in samples) {
        cmrPath.lineTo(pt.value.dx, pt.value.dy);
      }
    }
    return cmrPath;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedCMRPath = Path();
    if (points.length >= 4) {
      CatmullRomSpline cmrSpline = CatmullRomSpline(getAnimatedPoints(ticker));
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      animatedCMRPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for (Curve2DSample pt in samples) {
        animatedCMRPath.lineTo(pt.value.dx, pt.value.dy);
      }
      if (closed) {
        animatedCMRPath.close();
      }
    }
    return animatedCMRPath;
  }

  @override
  Path getParametrizedPath(double end, {double start = 0, Path? from}) {
    Path path = from ?? Path();
    if (points.length >= 4) {
      curve2D ??= CatmullRomSpline(points);
      Iterable<Curve2DSample> samples =
          curve2D!.generateSamples(start: start, end: end);
      path.addPolygon(samples.map((e) => e.value).toList(), false);
    }
    return path;
  }

  @override
  PointDrawSplineCurve duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawSplineCurve.from(this,
          displacement: displacement,
          key: ObjectKey("SplineCurve:" + generateAutoID()));
    } else {
      return PointDrawSplineCurve.from(this,
          key: ObjectKey("SplineCurve:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Spline";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawQuadraticBezier extends PointDrawBezier {
  PointDrawQuadraticBezier.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot,
            mode: EditingMode.quadraticBezier, key: key);

  PointDrawQuadraticBezier({required ObjectKey key})
      : super(mode: EditingMode.quadraticBezier, key: key);

  PointDrawQuadraticBezier.from(PointDrawQuadraticBezier object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement,
            mode: EditingMode.quadraticBezier,
            key: key);

  @override
  bool get isInitialized => points.length >= 3;

  @override
  bool get validNewPoint => chained;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, (firstPoint + secondPoint) / 2, secondPoint];
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    return data;
  }

  @override
  Path getPath() {
    Path quadraticBezier = Path();
    if (points.length >= 3) {
      quadraticBezier.moveTo(points.first.dx, points.first.dy);
      List<Offset> bezierPoints;
      if (closed) {
        bezierPoints = points + [points.first];
      } else {
        bezierPoints = points;
      }
      for (int i = 1; i + 1 < bezierPoints.length; i += 2) {
        quadraticBezier.quadraticBezierTo(bezierPoints[i].dx,
            bezierPoints[i].dy, bezierPoints[i + 1].dx, bezierPoints[i + 1].dy);
      }
    }
    return quadraticBezier;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedQuadraticBezier = Path();
    if (points.length >= 3) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      animatedQuadraticBezier.moveTo(
          animatedPoints.first.dx, animatedPoints.first.dy);
      for (int i = 1; i + 1 < points.length; i += 2) {
        animatedQuadraticBezier.quadraticBezierTo(
            animatedPoints[i].dx,
            animatedPoints[i].dy,
            animatedPoints[i + 1].dx,
            animatedPoints[i + 1].dy);
      }
      if (closed) {
        animatedQuadraticBezier.close();
      }
    }
    return animatedQuadraticBezier;
  }

  @override
  Path getParametrizedPath(double end, {double start = 0, Path? from}) {
    Path path = from ?? Path();
    if (points.length >= 3) {
      curve2D ??= QuadraticBezierCurve2D(points);
      Iterable<Curve2DSample> samples =
          curve2D!.generateSamples(start: start, end: end);
      path.addPolygon(samples.map((e) => e.value).toList(), false);
    }
    return path;
  }

  @override
  void updateChainedPoints(Offset newOffset, int indexMoved) {
    int length = points.length;
    if (indexMoved % 2 == 1) {
      int preIndex = indexMoved - 2;
      int postIndex = indexMoved + 2;
      while (preIndex > 0) {
        double dist = (points[preIndex + 1] - points[preIndex]).distance;
        double dir = (points[preIndex + 1] - points[preIndex + 2]).direction;
        points[preIndex] =
            points[preIndex + 1] + Offset.fromDirection(dir, dist);
        preIndex = preIndex - 2;
      }
      while (postIndex < length) {
        double dist = (points[postIndex] - points[postIndex - 1]).distance;
        double dir = (points[postIndex - 1] - points[postIndex - 2]).direction;
        points[postIndex] =
            points[postIndex - 1] + Offset.fromDirection(dir, dist);
        postIndex = postIndex + 2;
      }
    }
  }

  @override
  PointDrawQuadraticBezier duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawQuadraticBezier.from(this,
          displacement: displacement,
          key: ObjectKey("QuadraticBezier:" + generateAutoID()));
    } else {
      return PointDrawQuadraticBezier.from(this,
          key: ObjectKey("QuadraticBezier:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Quad. Bezier";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawCubicBezier extends PointDrawBezier {
  PointDrawCubicBezier.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.cubicBezier, key: key);

  PointDrawCubicBezier({required ObjectKey key})
      : super(mode: EditingMode.cubicBezier, key: key);

  PointDrawCubicBezier.from(PointDrawCubicBezier object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement,
            mode: EditingMode.cubicBezier,
            key: key);

  @override
  bool get isInitialized => points.length >= 4;

  @override
  bool get validNewPoint => chained;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [
      firstPoint,
      firstPoint * 0.67 + secondPoint * 0.33,
      firstPoint * 0.33 + secondPoint * 0.67,
      secondPoint
    ];
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    return data;
  }

  @override
  Path getPath() {
    Path cubicBezier = Path();
    if (points.length >= 4) {
      cubicBezier.moveTo(points.first.dx, points.first.dy);
      List<Offset> bezierPoints;
      if (closed) {
        bezierPoints = points + [points.first];
      } else {
        bezierPoints = points;
      }
      for (int i = 1; i + 2 < bezierPoints.length; i += 3) {
        cubicBezier.cubicTo(
            bezierPoints[i].dx,
            bezierPoints[i].dy,
            bezierPoints[i + 1].dx,
            bezierPoints[i + 1].dy,
            bezierPoints[i + 2].dx,
            bezierPoints[i + 2].dy);
      }
    }
    return cubicBezier;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedCubicBezier = Path();
    if (points.length >= 4) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      animatedCubicBezier.moveTo(
          animatedPoints.first.dx, animatedPoints.first.dy);
      for (int i = 1; i + 2 < animatedPoints.length; i += 3) {
        animatedCubicBezier.cubicTo(
          animatedPoints[i].dx,
          animatedPoints[i].dy,
          animatedPoints[i + 1].dx,
          animatedPoints[i + 1].dy,
          animatedPoints[i + 2].dx,
          animatedPoints[i + 2].dy,
        );
      }
      if (closed) {
        animatedCubicBezier.close();
      }
    }
    return animatedCubicBezier;
  }

  @override
  Path getParametrizedPath(double end, {double start = 0, Path? from}) {
    Path path = from ?? Path();
    if (points.length >= 4) {
      curve2D ??= CubicBezierCurve2D(points);
      Iterable<Curve2DSample> samples =
          curve2D!.generateSamples(start: start, end: end);
      path.addPolygon(samples.map((e) => e.value).toList(), false);
    }
    return path;
  }

  @override
  void updateChainedPoints(Offset newOffset, int indexMoved) {
    int length = points.length;
    if (indexMoved % 3 == 1 && indexMoved - 2 > 0) {
      int preIndex = indexMoved - 2;
      double dist = (points[preIndex + 1] - points[preIndex]).distance;
      double dir = (points[preIndex + 1] - points[preIndex + 2]).direction;
      points[preIndex] = points[preIndex + 1] + Offset.fromDirection(dir, dist);
    } else if (indexMoved % 3 == 2 && indexMoved + 2 < length) {
      int postIndex = indexMoved + 2;
      double dist = (points[postIndex] - points[postIndex - 1]).distance;
      double dir = (points[postIndex - 1] - points[postIndex - 2]).direction;
      points[postIndex] =
          points[postIndex - 1] + Offset.fromDirection(dir, dist);
    }
  }

  @override
  PointDrawCubicBezier duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawCubicBezier.from(this,
          displacement: displacement,
          key: ObjectKey("CubicBezier:" + generateAutoID()));
    } else {
      return PointDrawCubicBezier.from(this,
          key: ObjectKey("CubicBezier:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Cubic Bezier";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawLoop extends PointDrawSplineCurve {
  PointDrawLoop.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.loop, key: key) {
    closed = true;
    enableDeleteControlPoint = true;
  }

  PointDrawLoop({required ObjectKey key})
      : super(mode: EditingMode.loop, key: key) {
    closed = true;
    enableDeleteControlPoint = true;
  }

  PointDrawLoop.from(PointDrawLoop object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.loop, key: key) {
    closed = true;
    enableDeleteControlPoint = true;
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    return data;
  }

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    Offset midPoint = (firstPoint + secondPoint) / 2;
    double direction = (secondPoint - firstPoint).direction;
    double distance = (firstPoint - midPoint).distance;
    points = [
      firstPoint,
      midPoint + Offset.fromDirection(direction + pi / 2, distance),
      secondPoint,
      midPoint + Offset.fromDirection(direction - pi / 2, distance)
    ];
    autoInitializeControlPoints();
  }

  @override
  void addControlPoint(Offset newPoint) {
    for (int i = 0; i < points.length - 1; i++) {
      if (Rect.fromCenter(
              center: (points[i] + points[i + 1]) * 0.5,
              width: max((points[i].dx - points[i + 1].dx).abs(), 20),
              height: max((points[i].dy - points[i + 1].dy).abs(), 20))
          .contains(newPoint)) {
        points.insert(i + 1, newPoint);
        return;
      }
    }
  }

  @override
  void autoInitializeControlPoints() {
    if (points.length == 4 && points.first != points.last) {
      points.add(points.first);
    }
  }

  List<Offset> ensureClosed(List<Offset> points) {
    if (points.first != points.last) {
      points.last = points.first;
    }
    return points;
  }

  @override
  Path getPath() {
    Path cmrPath = Path();
    if (points.length >= 4) {
      CatmullRomSpline cmrSpline = CatmullRomSpline.precompute(
          ensureClosed(points),
          startHandle: points[points.length - 2],
          endHandle: points[1]);
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      cmrPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for (Curve2DSample pt in samples) {
        cmrPath.lineTo(pt.value.dx, pt.value.dy);
      }
    }
    return cmrPath;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path cmrPath = Path();
    if (points.length >= 4) {
      List<Offset> animatedPoints = ensureClosed(getAnimatedPoints(ticker));
      CatmullRomSpline cmrSpline = CatmullRomSpline.precompute(animatedPoints,
          startHandle: animatedPoints[points.length - 2],
          endHandle: animatedPoints[1]);
      Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
      cmrPath.moveTo(samples.first.value.dx, samples.first.value.dy);
      for (Curve2DSample pt in samples) {
        cmrPath.lineTo(pt.value.dx, pt.value.dy);
      }
    }
    return cmrPath;
  }

  @override
  PointDrawLoop moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    return this;
  }

  @override
  PointDrawLoop duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawLoop.from(this,
          displacement: displacement,
          key: ObjectKey("Loop:" + generateAutoID()));
    } else {
      return PointDrawLoop.from(this,
          key: ObjectKey("Loop:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Loop";
}
