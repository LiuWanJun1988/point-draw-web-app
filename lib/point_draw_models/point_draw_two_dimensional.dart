import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

import 'dart:math';

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/svg/svg_builder.dart';
import 'package:pointdraw/point_draw_models/utilities/svg_utils.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart'
    show getBasicAngle, getClockwiseSweepingDirection;
import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/app_components/action_button.dart';
import 'package:pointdraw/point_draw_models/app_components/icon_sketch.dart';
import 'package:pointdraw/point_draw_models/app_components/property_controller.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart'
    show controlPointSize;
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart'
    show rotate;
import 'package:pointdraw/point_draw_models/utilities/matrices.dart';

abstract class PointDrawTwoDimensional extends PointDrawPath {
  double glowRadius = 0.0;

  BlurStyle blurStyle = BlurStyle.normal;

  PointDrawTwoDimensional(
      {this.glowRadius = 0.0,
      EditingMode mode = EditingMode.path,
      required ObjectKey key})
      : super(mode: mode, key: key) {
    supplementaryPropertiesModifiers.add(getToggleGlowButton);
    outlined = false;
    filled = true;
  }

  PointDrawTwoDimensional.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {EditingMode mode = EditingMode.path,
      required ObjectKey key})
      : super.fromDocument(snapshot, key: key) {
    glowRadius = snapshot.get(glowRadiusKey);
    supplementaryPropertiesModifiers.add(getToggleGlowButton);
  }

  PointDrawTwoDimensional.from(PointDrawTwoDimensional object,
      {EditingMode mode = EditingMode.path,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key) {
    glowRadius = object.glowRadius;
    supplementaryPropertiesModifiers.add(getToggleGlowButton);
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[glowRadiusKey] = glowRadius;
    data[blurStyleKey] = blurStyle.name;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    glowRadius = data[glowRadiusKey];
    blurStyle = getBlurStyle(data[blurStyleKey]);
  }

  void updateGlowRadius(double ratio) {
    glowRadius = ratio * boundingRect.longestSide / 2;
    notifyListeners();
  }

  void updateBlurStyle(BlurStyle style) {
    blurStyle = style;
    notifyListeners();
  }

  double get glowRatio =>
      boundingRect.isEmpty ? 0.0 : glowRadius / (boundingRect.longestSide / 2);

  @override
  Path getAnimatedPath(double ticker) {
    throw UnimplementedError("Subclass should override this method");
  }

  @override
  Path getPath() {
    throw UnimplementedError("Subclass should override this method");
  }

  @override
  bool get validNewPoint => throw UnimplementedError();

  void drawGlow(Canvas canvas, Path path, {Matrix4? zoomTransform}) {
    Paint glowPaint = Paint()
      ..color = fPaint.color
      ..maskFilter =
          MaskFilter.blur(blurStyle, Shadow.convertRadiusToSigma(glowRadius));
    canvas.drawPath(path, glowPaint);
  }

  @override
  Path draw(Canvas canvas, double ticker, {Matrix4? zoomTransform}) {
    Path path = super.draw(canvas, ticker, zoomTransform: zoomTransform);
    if (glowRadius > 0) {
      if (clips.isNotEmpty) {
        canvas.save();
        for (Path clipPath in clips.keys) {
          canvas.clipPath(clipPath);
        }
        drawGlow(canvas, path, zoomTransform: zoomTransform);
        canvas.restore();
      } else {
        drawGlow(canvas, path, zoomTransform: zoomTransform);
      }
    }
    return path;
  }

  Widget getToggleGlowButton() {
    return ActionButton(
      mode,
      glowRadius != 0.0,
      displayWidget: const ShadowIcon(
        widthSize: 28,
      ),
      onPressed: () {
        if (glowRadius == 0.0) {
          glowRadius = 5.0;
        } else {
          glowRadius = 0.0;
        }
        notifyListeners();
      },
      toolTipMessage: "Toggle glow effect",
    );
  }
}

abstract class PointDrawStraightEdgedShape extends PointDrawTwoDimensional {
  bool roundCorners = false;

  double roundingRadius = 5.0;

  PointDrawStraightEdgedShape.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.roundCorners = false,
      this.roundingRadius = 5.0,
      EditingMode mode = EditingMode.shape,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: mode, key: key) {
    roundCorners = snapshot.get(roundCornersKey);
    roundingRadius = snapshot.get(roundingRadiusKey);
    supplementaryPropertiesModifiers
        .addAll([getToggleRegulariseButton, getToggleRoundCornersButton]);
  }

  PointDrawStraightEdgedShape(
      {this.roundCorners = false,
      this.roundingRadius = 5.0,
      EditingMode mode = EditingMode.shape,
      required ObjectKey key})
      : super(mode: mode, key: key) {
    supplementaryPropertiesModifiers
        .addAll([getToggleRegulariseButton, getToggleRoundCornersButton]);
  }

  PointDrawStraightEdgedShape.from(PointDrawStraightEdgedShape object,
      {EditingMode mode = EditingMode.shape,
      this.roundCorners = false,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key) {
    roundCorners = object.roundCorners;
    roundingRadius = object.roundingRadius;
    supplementaryPropertiesModifiers
        .addAll([getToggleRegulariseButton, getToggleRoundCornersButton]);
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[roundCornersKey] = roundCorners;
    data[roundingRadiusKey] = roundingRadius;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    if (data.containsKey(roundCornersKey)) {
      roundCorners = data[roundCornersKey];
    }
    if (data.containsKey(roundingRadiusKey)) {
      roundingRadius = data[roundingRadiusKey];
    }
  }

  void initializeRoundingCenters() {
    rPoints.clear();
    Path polygon = Path()..addPolygon(points, true);
    for (int i = 0; i < points.length; i++) {
      rPoints.add(getRoundingCenter(i, polygon));
    }
  }

  @override
  void autoInitializeControlPoints() {
    super.autoInitializeControlPoints();
    if (roundCorners) {
      initializeRoundingCenters();
    }
  }

  double get maxRoundingRadius {
    double maxRadius = double.infinity;
    for (int i = 0; i < points.length; i++) {
      Offset nextPoint;
      if (i == points.length - 1) {
        nextPoint = points.first;
      } else {
        nextPoint = points[i + 1];
      }
      double r = (points[i] - nextPoint).distance / 2;
      if (maxRadius > r) {
        maxRadius = r;
      }
    }
    return maxRadius;
  }

  double get roundingFactor => roundingRadius / maxRoundingRadius;

  void updateRoundingRadius(double factor) {
    roundingRadius = max(0, min(factor, 1)) * maxRoundingRadius;
    notifyListeners();
  }

  Offset getRoundingCenter(int index, Path polygon) {
    Offset start, corner, end;
    if (index == 0) {
      start = points.last;
    } else {
      start = points[index - 1];
    }
    if (index == points.length - 1) {
      end = points.first;
    } else {
      end = points[index + 1];
    }
    corner = points[index];
    double startAngle = (corner - start).direction + pi / 2;
    double endAngle = (corner - end).direction - pi / 2;
    Offset centerArrow = Offset.fromDirection(
        ((start - corner).direction + (end - corner).direction) / 2, 1);
    Offset center;
    if (polygon.contains(corner + centerArrow)) {
      center = corner +
          centerArrow *
              roundingRadius /
              cos(getBasicAngle((endAngle - startAngle) / 2));
    } else {
      center = corner -
          centerArrow *
              roundingRadius /
              cos(getBasicAngle((endAngle - startAngle) / 2));
    }
    return center;
  }

  Path getRoundedCorner(
      Offset start, Offset corner, Offset end, Offset roundingCenter) {
    double startAngle = (corner - start).direction + pi / 2;
    double endAngle = (corner - end).direction - pi / 2;
    Rect arcRect = Rect.fromCenter(
        center: roundingCenter,
        width: roundingRadius * 2,
        height: roundingRadius * 2);
    Offset startOffset =
        roundingCenter + Offset.fromDirection(startAngle, roundingRadius);
    Path roundedPath = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(startOffset.dx, startOffset.dy)
      ..arcTo(arcRect, startAngle, endAngle - startAngle, false)
      ..lineTo(end.dx, end.dy);
    return roundedPath;
  }

  List<Offset> getRegularisedPoints() {
    if (points.length >= 2) {
      Offset center = getPath().getBounds().center;
      double initialDirection = (points.first - center).direction;
      double dist = (points.first - center).distance;
      double sweepingAngle = 2 * pi / points.length;
      List<Offset> regularisedPoints = [points[0]];
      for (int i = 1; i < points.length; i++) {
        regularisedPoints.add(center +
            Offset.fromDirection(initialDirection + i * sweepingAngle, dist));
      }
      return regularisedPoints;
    }
    return points;
  }

  Widget getToggleRegulariseButton() {
    return ActionButton(
      mode,
      false,
      displayWidget: const RegulariseIcon(widthSize: 28),
      onPressed: () {
        points = getRegularisedPoints();
        notifyListeners();
      },
      toolTipMessage: "Toggle regular shape",
    );
  }

  Widget getToggleRoundCornersButton() {
    return ActionButton(
      mode,
      roundCorners,
      displayWidget: const RoundCornerIcon(widthSize: 28),
      onPressed: () {
        roundCorners = !roundCorners;
        notifyListeners();
      },
      toolTipMessage: "Toggle round corners",
    );
  }
}

class PointDrawPolygon extends PointDrawStraightEdgedShape {
  int? sides;

  PointDrawPolygon.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {EditingMode mode = EditingMode.polygon, required ObjectKey key})
      : super.fromDocument(snapshot, mode: mode, key: key) {
    sides = snapshot.get(sidesKey);
    enableDeleteControlPoint = true;
  }

  PointDrawPolygon(
      {this.sides, mode = EditingMode.polygon, required ObjectKey key})
      : super(mode: mode, key: key) {
    enableDeleteControlPoint = true;
  }

  PointDrawPolygon.from(PointDrawPolygon object,
      {EditingMode mode = EditingMode.polygon,
      this.sides,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key) {
    sides = object.sides;
    enableDeleteControlPoint = true;
  }

  @override
  bool get isInitialized => points.isNotEmpty;

  @override
  bool get validNewPoint => sides != null ? (points.length < sides!) : true;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[sidesKey] = sides;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    sides = data[sidesKey];
  }

  @override
  Path getPath() {
    Path polygon = Path();
    if (points.length >= 3) {
      if (roundCorners) {
        Path interior = Path()..addPolygon(points, true);
        for (int i = 0; i < points.length; i++) {
          Offset start = (points[i] + points[(i + 1) % points.length]) / 2;
          Offset end = (points[(i + 1) % points.length] +
                  points[(i + 2) % points.length]) /
              2;
          polygon.extendWithPath(
              getRoundedCorner(start, points[(i + 1) % points.length], end,
                  getRoundingCenter((i + 1) % points.length, interior)),
              Offset.zero);
        }
      } else {
        polygon.addPolygon(points, true);
      }
      polygon.close();
    }
    return polygon;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedPolygon = Path();
    if (points.length >= 3) {
      animatedPolygon.addPolygon(getAnimatedPoints(ticker), true);
    }
    return animatedPolygon;
  }

  @override
  void autoInitializeControlPoints() {
    if (mode == EditingMode.rectangle && points.length == 2) {
      points.insert(1, Offset(points.first.dx, points.last.dy));
      points.add(Offset(points.last.dx, points.first.dy));
    }
    if (mode == EditingMode.triangle && points.length == 2) {
      Offset displacement = points.first - points.last;
      points.add((points.first + points.last) / 2 +
          Offset.fromDirection(
              displacement.direction + pi / 2, displacement.distance / 2));
    }
    if (mode == EditingMode.pentagon && points.length == 2) {
      Rect rect = Rect.fromPoints(points.first, points.last);
      Offset displacement = points.first - points.last;
      double width = displacement.distance / 2;
      points = [
        rect.center + Offset.fromDirection(displacement.direction, width),
        rect.center +
            Offset.fromDirection(displacement.direction - 2 * pi / 5, width),
        rect.center +
            Offset.fromDirection(displacement.direction - 4 * pi / 5, width),
        rect.center +
            Offset.fromDirection(displacement.direction - 6 * pi / 5, width),
        rect.center +
            Offset.fromDirection(displacement.direction - 8 * pi / 5, width),
      ];
    }
    if (mode == EditingMode.polygon && points.length == 2) {
      Offset displacement = points[1] - points[0];
      double direction = displacement.direction + pi / 2;
      double gap = displacement.distance / 2;
      points.insert(
          1,
          (points.first + points.last) / 2 +
              Offset.fromDirection(direction, gap));
    }
    super.autoInitializeControlPoints();
  }

  @override
  void addControlPoint(Offset newPoint) {
    for (int i = 0; i < points.length; i++) {
      Offset firstPoint = points[i];
      Offset secondPoint = points[(i + 1) % points.length];
      if (Rect.fromCenter(
              center: (firstPoint + secondPoint) * 0.5,
              width: max((firstPoint.dx - secondPoint.dx).abs(), 10),
              height: max((firstPoint.dy - secondPoint.dy).abs(), 10))
          .contains(newPoint)) {
        points.insert(i + 1, newPoint);
        rPoints.insert(
            i + 1, getRoundingCenter(i + 1, Path()..addPolygon(points, true)));
        return;
      }
    }
  }

  @override
  PointDrawPolygon duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawPolygon.from(this,
          displacement: displacement,
          mode: mode,
          key: ObjectKey("Polygon:" + generateAutoID()));
    } else {
      return PointDrawPolygon.from(this,
          mode: mode, key: ObjectKey("Polygon:" + generateAutoID()));
    }
  }

  @override
  String toString() =>
      toProper(mode.name.substring(0, min(mode.name.length, 10)));

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    String polygonSVG = "", svgContent = "";
    if (requireCSS(this)) {
      return SVGPointDrawElement(svgContent: svgContent);
    }

    if (fPaint.shader != null) {
      attributes["shader_id"] = "shader-$id";
      polygonSVG += shaderParamToString(shaderParam, attributes["shader_id"]);
    }
    polygonSVG +=
        "<polygon points=\"${offsetListToString(points)}\" style=\"${strokePaintToString(outlined, sPaint)};${fillPaintToString(filled, fPaint, args: attributes)}\" />";
    svgContent = "<g id=\"$id\">\n$polygonSVG\n</g>";
    debugPrint(svgContent);
    return SVGPointDrawElement(svgContent: svgContent);
  }
}

class PointDrawRoundedRectangle extends PointDrawPolygon {
  double radius;

  PointDrawRoundedRectangle.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.radius = 15.0,
      EditingMode mode = EditingMode.roundedRectangle,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: mode, key: key) {
    sides = 4;
    radius = snapshot.get(roundedRectangleRadiusKey);
  }

  PointDrawRoundedRectangle(
      {this.radius = 15.0,
      EditingMode mode = EditingMode.roundedRectangle,
      required ObjectKey key})
      : super(mode: mode, key: key) {
    sides = 4;
  }

  PointDrawRoundedRectangle.from(PointDrawRoundedRectangle object,
      {this.radius = 15.0,
      Offset displacement = const Offset(5, 5),
      EditingMode mode = EditingMode.roundedRectangle,
      required ObjectKey key})
      : super.from(object, displacement: displacement, mode: mode, key: key) {
    radius = object.radius;
    sides = 4;
  }

  @override
  bool get isInitialized => points.length == 2;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[sidesKey] = sides;
    data[radiusKey] = radius;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    sides = data[sidesKey];
    radius = data[radiusKey];
  }

  @override
  Path getPath() {
    autoInitializeControlPoints();
    if (points.length == 2 && rPoints.isNotEmpty) {
      radius = (points.first - rPoints.first).distance;
      return Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromPoints(points.first, points.last),
            Radius.circular(radius)));
    }
    return Path();
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedPath = Path();
    if (points.length == 2 && rPoints.isNotEmpty) {
      // Current code does not animate. When animating, consider updating rdscp when cp moved.
      radius = (points.first - rPoints.first).distance;
      animatedPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromPoints(points.first, points.last), Radius.circular(radius)));
    }
    return animatedPath;
  }

  @override
  void autoInitializeControlPoints() {
    if (points.length == 2 && rPoints.isEmpty) {
      Rect rect = Rect.fromPoints(points.first, points.last);
      points[0] = rect.topLeft;
      points[1] = rect.bottomRight;
      radius = min(15.0, (rect.bottomLeft - rect.topLeft).distance / 2);
      rPoints = [rect.topLeft + Offset.fromDirection(pi / 2, radius)];
    }

    super.autoInitializeControlPoints();
  }

  @override
  PointDrawRoundedRectangle moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    updateRDSCPWhenCPMoved(args!["zoom_transform"], args: args);
    return this;
  }

  @override
  PointDrawRoundedRectangle updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    super.updateRDSCPWhenCPMoved(zoomTransform);
    radius = min(radius, (points.first - points.last).dy.abs() / 2);
    rPoints[0] = points.first + Offset.fromDirection(pi / 2, radius);
    return this;
  }

  @override
  PointDrawRoundedRectangle moveRestrictedControlPoint(
      Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    double maxRadius = (points.last - points.first).dy.abs() / 2;
    radius = max(min((localPosition - points.first).dy, maxRadius), 2.0);
    Offset computedPoint = points.first + Offset.fromDirection(pi / 2, radius);
    if (boundingRect.inflate(controlPointSize).contains(computedPoint)) {
      rPoints[index] = computedPoint;
    }
    return this;
  }

  @override
  PointDrawRoundedRectangle transformByRotate(
      Offset center, double angle, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length, (ind) => rotate(points[ind], center, angle));
    Offset topLeft = Rect.fromPoints(points.first, points.last).topLeft;
    double radius = max(5.0, (topLeft - rPoints.first).distance);
    rPoints = [topLeft + Offset.fromDirection(pi / 2, radius)];
    shaderParam = shaderParam?.transformByRotate(center, angle);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawRoundedRectangle flipVertical(Matrix4 zoomTransform,
      {Offset? center}) {
    return this;
  }

  @override
  PointDrawRoundedRectangle flipHorizontal(Matrix4 zoomTransform,
      {Offset? center}) {
    return this;
  }

  @override
  PointDrawRoundedRectangle duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawRoundedRectangle.from(this,
          displacement: displacement,
          key: ObjectKey("RoundedRectangle:" + generateAutoID()));
    } else {
      return PointDrawRoundedRectangle.from(this,
          key: ObjectKey("RoundedRectangle:" + generateAutoID()));
    }
  }

  @override
  String toString() => "R. rect";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    String roundedRectSVG = "", svgContent = "";
    if (requireCSS(this)) {
      return SVGPointDrawElement(svgContent: svgContent);
    }

    if (fPaint.shader != null) {
      attributes["shader_id"] = "shader-$id";
      roundedRectSVG +=
          shaderParamToString(shaderParam, attributes["shader_id"]);
    }
    roundedRectSVG +=
        "<rect ${rectToString(boundingRect)} rx=\"$radius\" style=\"${strokePaintToString(outlined, sPaint)};${fillPaintToString(filled, fPaint, args: attributes)}\" />";
    svgContent = "<g id=\"$id\">\n$roundedRectSVG\n</g>";
    debugPrint(svgContent);
    return SVGPointDrawElement(svgContent: svgContent);
  }
}

class PointDrawConic extends PointDrawTwoDimensional {
  double width;

  double height;

  double _orientation = 0.0;

  bool axialLock;

  PointDrawConic.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    this.width = 100,
    this.height = 100,
    this.axialLock = false,
    required ObjectKey key,
  }) : super.fromDocument(snapshot, mode: EditingMode.conic, key: key);

  PointDrawConic({
    this.width = 100,
    this.height = 100,
    this.axialLock = false,
    required ObjectKey key,
  }) : super(mode: EditingMode.conic, key: key);

  PointDrawConic.from(PointDrawConic object,
      {this.width = 100,
      this.height = 100,
      this.axialLock = false,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            mode: EditingMode.conic, displacement: displacement, key: key) {
    width = object.width;
    height = object.height;
    axialLock = object.axialLock;
  }

  @override
  bool get isInitialized =>
      points.isNotEmpty && dPoints.isNotEmpty && rPoints.isNotEmpty;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [(firstPoint + secondPoint) / 2];
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[conicWidthKey] = width;
    data[conicHeightKey] = height;
    data[orientationKey] = _orientation;
    data[axialLockKey] = axialLock;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    width = data[conicWidthKey];
    height = data[conicHeightKey];
    _orientation = data[orientationKey];
    axialLock = data[axialLockKey];
  }

  @override
  Path getPath() {
    Path conic = Path();
    autoInitializeControlPoints();
    if (points.length == 1) {
      conic.addOval(
          Rect.fromCenter(center: points[0], width: width, height: height));
      return conic.transform(
          rotateZAbout((rPoints.first - points[0]).direction, points[0])
              .storage);
    }
    return conic;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedConic = Path();
    if (points.length == 1) {
      animatedConic.addOval(
          Rect.fromCenter(center: points[0], width: width, height: height));
      return animatedConic.transform(
          rotateZAbout((rPoints.first - points[0]).direction, points[0])
              .storage);
    }
    return animatedConic;
  }

  @override
  void autoInitializeControlPoints() {
    if (points.length == 1 && rPoints.isEmpty) {
      Rect rect = Rect.fromCenter(center: points[0], width: 100, height: 100);
      rPoints = [
        points[0] +
            Offset.fromDirection(0, (rect.center - rect.bottomRight).distance)
      ];
      dPoints = [rect.bottomRight];
    }
    super.autoInitializeControlPoints();
  }

  @override
  PointDrawConic moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    args!["translate"] = newPosition - points.first;
    super.moveControlPoint(newPosition, index, args: args);
    updateRDSCPWhenCPMoved(args["zoom_transform"], args: args);
    return this;
  }

  @override
  PointDrawConic updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic>? args}) {
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    rPoints[0] = rect.center +
        Offset.fromDirection(
            _orientation, (rect.bottomRight - rect.center).distance);
    dPoints[0] = rect.bottomRight;
    super.updateRDSCPWhenCPMoved(zoomTransform, args: args ?? {});
    return this;
  }

  @override
  PointDrawConic moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    _orientation = (localPosition - rect.center).direction;
    rPoints[index] = rect.center +
        Offset.fromDirection(
            _orientation, (rect.center - rect.bottomRight).distance);
    return this;
  }

  @override
  PointDrawConic moveDataControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveDataControlPoint(newPosition, index);
    width = 2 * (dPoints[index] - points[0]).dx.abs();
    height = 2 * (dPoints[index] - points[0]).dy.abs();
    Rect rect =
        Rect.fromCenter(center: points[0], width: width, height: height);
    double rotationAdjustedAngle = (rPoints[0] - rect.center).direction;
    Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    rPoints[0] = matrixApply(
        rotationMatrix,
        points[0] +
            Offset.fromDirection(0, (rect.bottomRight - rect.center).distance));
    return this;
  }

  @override
  PointDrawConic transformByRotate(
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
  PointDrawConic transformByHorizontalScale(
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
    rPoints[0] = points[0] +
        Offset.fromDirection(
            (Offset(
                        stationary.dx +
                            (rPoints[0].dx - stationary.dx) * scaleFactor,
                        rPoints[0].dy) -
                    points[0])
                .direction,
            (rect.center - rect.bottomRight).distance);
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
  PointDrawConic transformByVerticalScale(
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
    rPoints[0] = points[0] +
        Offset.fromDirection(
            (Offset(
                        rPoints[0].dx,
                        stationary.dy +
                            (rPoints[0].dy - stationary.dy) * scaleFactor) -
                    points[0])
                .direction,
            (rect.center - rect.bottomRight).distance);
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
  PointDrawConic transformByScale(
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
    rPoints[0] = points[0] +
        Offset.fromDirection(
            (Offset(
                        stationary.dx +
                            (rPoints[0].dx - stationary.dx) * scaleFactor.dx,
                        stationary.dy +
                            (rPoints[0].dy - stationary.dy) * scaleFactor.dy) -
                    points[0])
                .direction,
            (rect.center - rect.bottomRight).distance);
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
  PointDrawConic duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawConic.from(this,
          displacement: displacement,
          key: ObjectKey("Conic:" + generateAutoID()));
    } else {
      return PointDrawConic.from(this,
          key: ObjectKey("Conic:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Conic";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    String conicSVG = "", svgContent = "";
    if (requireCSS(this)) {
      return SVGPointDrawElement(svgContent: svgContent);
    }

    if (fPaint.shader != null) {
      attributes["shader_id"] = "shader-$id";
      conicSVG +=
          shaderParamToString(shaderParam, attributes["shader_id"]);
    }
    conicSVG +=
    "<ellipse ${generateConicString(points[0], width, height)} style=\"${strokePaintToString(outlined, sPaint)};${fillPaintToString(filled, fPaint, args: attributes)}\"/>";
    svgContent = "<g id=\"$id\">\n$conicSVG\n</g>";
    debugPrint(svgContent);
    return SVGPointDrawElement(svgContent: svgContent);
  }
}

class PointDrawHeart extends PointDrawStraightEdgedShape {
  double orientation = 0.0;

  double width = 100;

  double height = 100;

  Offset curvatureOffset = Offset.zero;

  PointDrawHeart.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.heart, key: key);

  PointDrawHeart({this.orientation = 0.0, required ObjectKey key})
      : super(mode: EditingMode.heart, key: key);

  PointDrawHeart.from(PointDrawHeart object,
      {Offset displacement = const Offset(5, 5), required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.heart, key: key) {
    orientation = object.orientation;
    width = object.width;
    height = object.height;
    curvatureOffset = object.curvatureOffset;
  }

  @override
  bool get isInitialized => points.isNotEmpty && rPoints.isNotEmpty;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [(firstPoint + secondPoint) * 0.5];
    width = (secondPoint.dx - firstPoint.dx).abs();
    height = (secondPoint.dy - firstPoint.dy).abs();
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[orientationKey] = orientation;
    data[conicWidthKey] = width;
    data[conicHeightKey] = height;
    data[curvatureOffsetXKey] = curvatureOffset.dx;
    data[curvatureOffsetYKey] = curvatureOffset.dy;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    orientation = data[orientationKey];
    width = data[conicWidthKey];
    height = data[conicHeightKey];
    curvatureOffset =
        Offset(data[curvatureOffsetXKey], data[curvatureOffsetYKey]);
  }

  @override
  Path getPath() {
    Path heartShapePath = Path();
    autoInitializeControlPoints();
    if (isInitialized) {
      Rect rect =
          Rect.fromCenter(center: points.first, width: width, height: height);
      Rect upperRect = rect.topLeft & Size(rect.width, rect.height * 0.6);
      Rect lowerRect = (rect.centerLeft + Offset(0, -rect.height * 0.2)) &
          Size(rect.width, rect.height * 0.7);
      Offset blControlPoint = points.first + curvatureOffset;
      Offset brControlPoint =
          blControlPoint + Offset(2 * (rect.center.dx - blControlPoint.dx), 0);
      heartShapePath.addArc(
          Rect.fromPoints(upperRect.topLeft, upperRect.bottomCenter), pi, pi);
      heartShapePath.addArc(
          Rect.fromPoints(upperRect.topRight, upperRect.bottomCenter), pi, pi);
      heartShapePath.quadraticBezierTo(brControlPoint.dx, brControlPoint.dy,
          lowerRect.bottomCenter.dx, lowerRect.bottomCenter.dy);
      heartShapePath.quadraticBezierTo(blControlPoint.dx, blControlPoint.dy,
          lowerRect.topLeft.dx, lowerRect.topLeft.dy);
      heartShapePath = heartShapePath
          .transform(rotateZAbout(orientation, rect.center).storage);
    }

    return heartShapePath;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedHeart = Path();
    if (isInitialized) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      Rect rect = Rect.fromCenter(
          center: animatedPoints.first, width: width, height: height);
      Rect upperRect = rect.topLeft & Size(rect.width, rect.height * 0.6);
      Rect lowerRect = (rect.centerLeft + Offset(0, -rect.height * 0.2)) &
          Size(rect.width, rect.height * 0.7);
      Offset blControlPoint = animatedPoints.first + curvatureOffset;
      Offset brControlPoint =
          blControlPoint + Offset(2 * (rect.center.dx - blControlPoint.dx), 0);
      animatedHeart.addArc(
          Rect.fromPoints(upperRect.topLeft, upperRect.bottomCenter), pi, pi);
      animatedHeart.addArc(
          Rect.fromPoints(upperRect.topRight, upperRect.bottomCenter), pi, pi);
      animatedHeart.quadraticBezierTo(brControlPoint.dx, brControlPoint.dy,
          lowerRect.bottomCenter.dx, lowerRect.bottomCenter.dy);
      animatedHeart.quadraticBezierTo(blControlPoint.dx, blControlPoint.dy,
          lowerRect.topLeft.dx, lowerRect.topLeft.dy);
      animatedHeart = animatedHeart
          .transform(rotateZAbout(orientation, rect.center).storage);
    }
    return animatedHeart;
  }

  @override
  void autoInitializeControlPoints() {
    if (points.isNotEmpty) {
      rPoints.add(
          Rect.fromCenter(center: points.first, width: width, height: height)
                  .topLeft +
              Offset(0, height * 0.7));
      curvatureOffset = rPoints.first - points.first;
    }
  }

  @override
  List<Offset> getRegularisedPoints() {
    return points;
  }

  @override
  PointDrawHeart moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    args!["translate"] = newPosition - points.first;
    super.moveControlPoint(newPosition, index, args: args);
    updateRDSCPWhenCPMoved(args["zoom_transform"], args: args);
    return this;
  }

  @override
  PointDrawHeart updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    rPoints[0] =
        rotate(points.first + curvatureOffset, points.first, orientation);
    super.updateRDSCPWhenCPMoved(zoomTransform, args: args);
    return this;
  }

  @override
  PointDrawHeart moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    Rect rect =
        Rect.fromCenter(center: points.first, width: width, height: height);
    Offset pivot = rect.topLeft + Offset(0, height * 0.3);
    Offset reorientatedOffset = points.first +
        Offset.fromDirection(
            (localPosition - points.first).direction - orientation,
            (localPosition - points.first).distance);
    if ((localPosition - rect.center).distance <
            (rect.bottomLeft - rect.center).distance &&
        (reorientatedOffset - pivot).dy / (reorientatedOffset - pivot).dx >
            (rect.bottomCenter - pivot).dy / (rect.bottomCenter - pivot).dx) {
      rPoints[index] = localPosition;
      curvatureOffset =
          rotate(rPoints[index], points.first, -orientation) - points.first;
    }
    return this;
  }

  @override
  PointDrawHeart transformByRotate(
      Offset center, double angle, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length, (ind) => rotate(points[ind], center, angle));
    rPoints = List<Offset>.generate(
        rPoints.length, (ind) => rotate(rPoints[ind], center, angle));
    orientation += angle;
    shaderParam = shaderParam?.transformByRotate(center, angle);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawHeart transformByHorizontalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ?? points;
    width = width * scaleFactor;
    rPoints.first = points.first +
        Offset.fromDirection((rPoints.first - points.first).direction,
                (rPoints.first - points.first).distance) *
            scaleFactor;
    curvatureOffset =
        rotate(rPoints.first, points.first, -orientation) - points.first;
    shaderParam =
        shaderParam?.transformByHorizontalScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawHeart transformByVerticalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ?? points;
    height = height * scaleFactor;
    rPoints.first = points.first +
        Offset.fromDirection((rPoints.first - points.first).direction,
                (rPoints.first - points.first).distance) *
            scaleFactor;
    curvatureOffset =
        rotate(rPoints.first, points.first, -orientation) - points.first;
    shaderParam =
        shaderParam?.transformByVerticalScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawHeart transformByScale(
      Offset stationary, Offset scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ?? points;
    width = width * scaleFactor.dx;
    height = height * scaleFactor.dy;
    Offset scalingOffset = Offset.fromDirection(
        (rPoints.first - points.first).direction,
        (rPoints.first - points.first).distance);
    rPoints.first = points.first +
        Offset(scalingOffset.dx * scaleFactor.dx,
            scalingOffset.dy * scaleFactor.dy);
    curvatureOffset =
        rotate(rPoints.first, points.first, -orientation) - points.first;
    shaderParam = shaderParam?.transformByScale(stationary, scaleFactor);
    fPaint.shader = fPaint.shader != null
        ? shaderParam?.build(
            boundingRect: boundingRect, zoomTransform: zoomTransform)
        : null;
    return this;
  }

  @override
  PointDrawHeart duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawHeart.from(this,
          displacement: displacement,
          key: ObjectKey("Heart:" + generateAutoID()));
    } else {
      return PointDrawHeart.from(this,
          key: ObjectKey("Heart:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Heart";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawArrow extends PointDrawStraightEdgedShape {
  double directionalGap;

  double orthogonalGap;

  PointDrawArrow.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.directionalGap = 0.0,
      this.orthogonalGap = 0.0,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.arrow, key: key) {
    directionalGap = snapshot.get(directionalGapKey);
    orthogonalGap = snapshot.get(orthogonalGapKey);
  }

  PointDrawArrow(
      {this.directionalGap = 0.0,
      this.orthogonalGap = 0.0,
      required ObjectKey key})
      : super(mode: EditingMode.arrow, key: key);

  PointDrawArrow.from(PointDrawArrow object,
      {this.directionalGap = 0.0,
      this.orthogonalGap = 0.0,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.arrow, key: key) {
    directionalGap = object.directionalGap;
    orthogonalGap = object.orthogonalGap;
  }

  @override
  bool get isInitialized => points.length == 2;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[orthogonalGapKey] = orthogonalGap;
    data[directionalGapKey] = directionalGap;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    orthogonalGap = data[orthogonalGapKey];
    directionalGap = data[directionalGapKey];
  }

  @override
  Path getPath() {
    Path arrow = Path();
    if (points.length == 2 && rPoints.length == 2) {
      Offset displacement = rPoints[0] - rPoints[1];
      Offset lerpPoint = points[0] +
          Offset.fromDirection(
              (points[1] - points[0]).direction, directionalGap);
      double normal = displacement.direction;
      double dist = displacement.distance;
      arrow.addPolygon([
        points[0] + Offset.fromDirection(normal, orthogonalGap - dist),
        rPoints[1],
        rPoints[0],
        points[1],
        lerpPoint + Offset.fromDirection(normal + pi, orthogonalGap),
        lerpPoint + Offset.fromDirection(normal + pi, orthogonalGap - dist),
        points[0] + Offset.fromDirection(normal + pi, orthogonalGap - dist)
      ], true);
    }
    return arrow;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedArrow = Path();
    if (points.length == 2 && rPoints.length == 2) {
      // Current code does not animate. When animating, consider updating rdscp when cp moved.
      List<Offset> animatedPoints = points; //getAnimatedPoints(ticker);
      Offset displacement = rPoints[0] - rPoints[1];
      Offset lerpPoint = animatedPoints[0] +
          Offset.fromDirection(
              (animatedPoints[1] - animatedPoints[0]).direction,
              directionalGap);
      double normal = displacement.direction;
      double dist = displacement.distance;
      animatedArrow.addPolygon([
        animatedPoints[0] + Offset.fromDirection(normal, orthogonalGap - dist),
        rPoints[1],
        rPoints[0],
        animatedPoints[1],
        lerpPoint + Offset.fromDirection(normal + pi, orthogonalGap),
        lerpPoint + Offset.fromDirection(normal + pi, orthogonalGap - dist),
        points[0] + Offset.fromDirection(normal + pi, orthogonalGap - dist)
      ], true);
    }
    return animatedArrow;
  }

  @override
  void autoInitializeControlPoints() {
    if (points.length == 2 && rPoints.isEmpty) {
      Offset displacement = points[1] - points[0];
      double dist = displacement.distance / 4;
      double normal = displacement.direction + pi / 2;
      Offset lerpPoint = Offset.lerp(points[0], points[1], 0.66667)!;
      directionalGap = (lerpPoint - points[0]).distance;
      orthogonalGap = dist;
      rPoints = [
        lerpPoint + Offset.fromDirection(normal, dist),
        lerpPoint + Offset.fromDirection(normal, dist / 2)
      ];
    }
  }

  @override
  PointDrawArrow moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    // args!["scale"] = boundingRect;
    updateRDSCPWhenCPMoved(args!["zoom_transform"], args: args);
    return this;
  }

  @override
  PointDrawArrow updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    super.updateRDSCPWhenCPMoved(zoomTransform);
    double direction = (points[1] - points[0]).direction;
    double normal = direction + pi / 2;
    double dist = (rPoints[0] - rPoints[1]).distance;
    Offset lerpPoint =
        points[0] + Offset.fromDirection(direction, directionalGap);
    rPoints[0] = lerpPoint + Offset.fromDirection(normal, orthogonalGap);
    rPoints[1] = lerpPoint + Offset.fromDirection(normal, orthogonalGap - dist);
    return this;
  }

  @override
  PointDrawArrow moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    if (args!["restriction_index"] == 0) {
      double direction = (points[1] - points[0]).direction;
      double dist = (rPoints[1] - rPoints[0]).distance;
      directionalGap = lengthOfProjection(localPosition, direction, points[0]);
      rPoints[1] = points[0] +
          Offset.fromDirection(direction, directionalGap) +
          Offset.fromDirection(direction + pi / 2, orthogonalGap - dist);
      rPoints[index] = points[0] +
          Offset.fromDirection(direction, directionalGap) +
          Offset.fromDirection(direction + pi / 2, orthogonalGap);
    } else {
      double direction = (points[1] - points[0]).direction;
      double dist =
          distanceFromLine(localPosition, direction + pi / 2, rPoints[0]);
      rPoints[index] = points[0] +
          Offset.fromDirection(direction, directionalGap) +
          Offset.fromDirection(direction + pi / 2, orthogonalGap - dist);
    }
    return this;
  }

  @override
  PointDrawArrow transformByHorizontalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                stationary.dx + (points[ind].dx - stationary.dx) * scaleFactor,
                points[ind].dy));
    double direction = (points[1] - points[0]).direction;
    double dist = (rPoints[0] - rPoints[1]).distance;
    rPoints[0] = points[0] +
        Offset.fromDirection(direction, directionalGap) +
        Offset.fromDirection(direction + pi / 2, orthogonalGap);
    rPoints[1] = points[0] +
        Offset.fromDirection(direction, directionalGap) +
        Offset.fromDirection(direction + pi / 2, orthogonalGap - dist);
    return this;
  }

  @override
  PointDrawArrow transformByVerticalScale(
      Offset stationary, double scaleFactor, Matrix4 zoomTransform,
      {List<Offset>? groupControlPoints}) {
    points = groupControlPoints ??
        List<Offset>.generate(
            points.length,
            (ind) => Offset(
                points[ind].dx,
                stationary.dy +
                    (points[ind].dy - stationary.dy) * scaleFactor));
    double direction = (points[1] - points[0]).direction;
    double dist = (rPoints[0] - rPoints[1]).distance;
    rPoints[0] = points[0] +
        Offset.fromDirection(direction, directionalGap) +
        Offset.fromDirection(direction + pi / 2, orthogonalGap);
    rPoints[1] = points[0] +
        Offset.fromDirection(direction, directionalGap) +
        Offset.fromDirection(direction + pi / 2, orthogonalGap - dist);
    return this;
  }

  @override
  PointDrawArrow transformByScale(
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
    double direction = (points[1] - points[0]).direction;
    double dist = (rPoints[0] - rPoints[1]).distance;
    rPoints[0] = points[0] +
        Offset.fromDirection(direction, directionalGap) +
        Offset.fromDirection(direction + pi / 2, orthogonalGap);
    rPoints[1] = points[0] +
        Offset.fromDirection(direction, directionalGap) +
        Offset.fromDirection(direction + pi / 2, orthogonalGap - dist);
    return this;
  }

  @override
  PointDrawArrow duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawArrow.from(this,
          displacement: displacement,
          key: ObjectKey("Arrow:" + generateAutoID()));
    } else {
      return PointDrawArrow.from(this,
          key: ObjectKey("Arrow:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Arrow";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawStar extends PointDrawStraightEdgedShape {
  double? radius;

  int corners = 5;

  PointDrawStar.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.radius, this.corners = 5, required ObjectKey key})
      : super.fromDocument(
          snapshot,
          mode: EditingMode.star,
          key: key,
        ) {
    radius = snapshot.get(radiusKey);
    corners = snapshot.get(cornersKey);
    supplementaryPropertiesModifiers.add(getCornersModifier);
  }

  PointDrawStar({this.radius, this.corners = 5, required ObjectKey key})
      : super(mode: EditingMode.star, key: key) {
    supplementaryPropertiesModifiers.add(getCornersModifier);
  }

  PointDrawStar.from(PointDrawStar object,
      {this.radius,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.star, key: key) {
    radius = object.radius;
    corners = object.corners;
    supplementaryPropertiesModifiers.add(getCornersModifier);
  }

  @override
  bool get isInitialized => points.length == 2;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
    autoInitializeControlPoints();
  }

  @override
  void autoInitializeControlPoints() {
    radius ??=
        (points.first - points.last).distance * sin(pi / 10) / sin(7 * pi / 10);
    rPoints.add(points.first +
        Offset.fromDirection(
            (points.last - points.first).direction + (pi / corners), radius!));
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[radiusKey] = radius;
    data[cornersKey] = corners;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    radius = data[radiusKey];
    corners = data[cornersKey];
  }

  @override
  Path getPath() {
    Path star = Path();
    if (points.length == 2) {
      List<Offset> vertices = [];
      double outerRadius = (points.last - points.first).distance;
      double startAngleOuter = (points.last - points.first).direction;
      double startAngleInner = startAngleOuter + pi / corners;
      radius ??= (points.first - points.last).distance *
          sin(pi / 10) /
          sin(7 * pi / 10);
      for (int i = 0; i < corners; i++) {
        vertices.add(points.first +
            Offset.fromDirection(
                startAngleOuter + i * (2 * pi / corners), outerRadius));
        vertices.add(points.first +
            Offset.fromDirection(
                startAngleInner + i * (2 * pi / corners), radius!));
      }
      star.addPolygon(vertices, true);
    }
    return star;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedStar = Path();
    if (points.length == 2) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      Offset center = animatedPoints[0];
      Offset initialPoint = animatedPoints[1];
      List<Offset> vertices = [];
      double outerRadius = (initialPoint - center).distance;
      double innerRadius =
          radius ?? outerRadius * sin(pi / 10) / sin(7 * pi / 10);
      double startAngleOuter = (initialPoint - center).direction;
      double startAngleInner = startAngleOuter + pi / corners;
      for (int i = 0; i < corners; i++) {
        vertices.add(center +
            Offset.fromDirection(
                startAngleOuter + i * (2 * pi / corners), outerRadius));
        vertices.add(center +
            Offset.fromDirection(
                startAngleInner + i * (2 * pi / corners), innerRadius));
      }
      animatedStar.addPolygon(vertices, true);
    }
    return animatedStar;
  }

  @override
  PointDrawStar moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    updateRDSCPWhenCPMoved(args!["zoom_transform"], args: args);
    return this;
  }

  @override
  PointDrawStar updateRDSCPWhenCPMoved(Matrix4 zoomTransform,
      {Map<String, dynamic> args = const {}}) {
    rPoints[0] = points.first +
        Offset.fromDirection(
            (points.last - points.first).direction + (pi / corners), radius!);
    super.updateRDSCPWhenCPMoved(zoomTransform);
    return this;
  }

  @override
  PointDrawStar moveRestrictedControlPoint(Offset localPosition, int index,
      {Map<String, dynamic>? args}) {
    radius = min((localPosition - points.first).distance,
        (points.first - points.last).distance);
    rPoints[0] = points.first +
        Offset.fromDirection(
            (points.last - points.first).direction + (pi / corners), radius!);
    return this;
  }

  Widget getCornersModifier() {
    return IntegerController(
      "Corners",
      corners,
      onIncrement: () {
        corners++;
        notifyListeners();
      },
      onDecrement: () {
        if (corners > 3) {
          corners--;
          notifyListeners();
        }
      },
      onChanged: (String? val) {
        corners = int.parse(val ?? corners.toString());
        notifyListeners();
      },
    );
  }

  @override
  PointDrawStar duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawStar.from(this,
          displacement: displacement,
          key: ObjectKey("Star:" + generateAutoID()));
    } else {
      return PointDrawStar.from(this,
          key: ObjectKey("Star:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Star";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawLeaf extends PointDrawTwoDimensional {
  bool symmetric;

  bool orthSymmetric;

  PointDrawLeaf.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot,
      {this.symmetric = true,
      this.orthSymmetric = true,
      required ObjectKey key})
      : super.fromDocument(snapshot, mode: EditingMode.leaf, key: key) {
    symmetric = snapshot.get(symmetricKey);
    orthSymmetric = snapshot.get(orthSymmetricKey);
    supplementaryPropertiesModifiers.addAll([
      getToggleSymmetricButton,
      getToggleOrthoSymmetricButton,
    ]);
  }

  PointDrawLeaf(
      {this.symmetric = false,
      this.orthSymmetric = false,
      required ObjectKey key})
      : super(mode: EditingMode.leaf, key: key) {
    supplementaryPropertiesModifiers.addAll([
      getToggleSymmetricButton,
      getToggleOrthoSymmetricButton,
    ]);
  }

  PointDrawLeaf.from(PointDrawLeaf object,
      {this.symmetric = false,
      this.orthSymmetric = false,
      Offset displacement = const Offset(5, 5),
      required ObjectKey key})
      : super.from(object,
            displacement: displacement, mode: EditingMode.leaf, key: key) {
    symmetric = object.symmetric;
    orthSymmetric = object.orthSymmetric;
    supplementaryPropertiesModifiers.addAll([
      getToggleSymmetricButton,
      getToggleOrthoSymmetricButton,
    ]);
  }

  @override
  bool get isInitialized => points.length == 6;

  @override
  bool get validNewPoint => false;

  @override
  void initialize(Offset firstPoint, Offset secondPoint) {
    points = [firstPoint, secondPoint];
    autoInitializeControlPoints();
  }

  @override
  Map<String, dynamic> toJson({bool parsePoints = true}) {
    Map<String, dynamic> data = super.toJson(parsePoints: parsePoints);
    data[editingModeKey] = mode.name;
    data[symmetricKey] = symmetric;
    data[orthSymmetricKey] = orthSymmetric;
    return data;
  }

  @override
  void toObject(Map<String, dynamic> data, {bool parsePoints = true}) {
    super.toObject(data, parsePoints: parsePoints);
    symmetric = data[symmetricKey];
    orthSymmetric = data[orthSymmetricKey];
  }

  @override
  Path getPath() {
    // assert((points.length == 3 && symmetric && orthSymmetric) || (generatingPoints.length == 4 && symmetric) || generatingPoints.length == 6, "Requires at least 3 points for leaf paths.");
    Path leaf = Path();
    if ((points.length == 3 && symmetric && orthSymmetric) ||
        (points.length == 4 && symmetric) ||
        points.length == 6) {
      Offset cubicCP1 = points[2];
      Offset cubicCP2, cubicCP3, cubicCP4;
      if (symmetric && orthSymmetric) {
        Offset center = Rect.fromPoints(points[0], points[1]).center;
        double cp1Direction = (cubicCP1 - center).direction;
        double cp1Distance = (cubicCP1 - center).distance;
        cubicCP2 =
            center + Offset.fromDirection(cp1Direction + pi / 2, cp1Distance);
        cubicCP3 =
            center + Offset.fromDirection(cp1Direction + pi, cp1Distance);
        cubicCP4 = center +
            Offset.fromDirection(cp1Direction + 3 * pi / 2, cp1Distance);
      } else if (symmetric) {
        cubicCP2 = points[3];
        double cp3Direction = 2 * (points[0] - points[1]).direction -
            (cubicCP2 - points[1]).direction;
        double cp1Distance = (cubicCP1 - points[0]).distance;
        double cp4Direction = 2 * (points[1] - points[0]).direction -
            (cubicCP1 - points[0]).direction;
        double cp2Distance = (cubicCP2 - points[1]).distance;
        cubicCP3 = points[1] + Offset.fromDirection(cp3Direction, cp2Distance);
        cubicCP4 = points[0] + Offset.fromDirection(cp4Direction, cp1Distance);
      } else {
        cubicCP2 = points[3];
        cubicCP3 = points[4];
        cubicCP4 = points[5];
      }
      leaf.moveTo(points[0].dx, points[0].dy);
      leaf.cubicTo(cubicCP1.dx, cubicCP1.dy, cubicCP2.dx, cubicCP2.dy,
          points[1].dx, points[1].dy);
      leaf.cubicTo(cubicCP3.dx, cubicCP3.dy, cubicCP4.dx, cubicCP4.dy,
          points[0].dx, points[0].dy);
      leaf.close();
    }
    return leaf;
  }

  @override
  Path getAnimatedPath(double ticker) {
    Path animatedLeaf = Path();
    if ((points.length == 3 && symmetric && orthSymmetric) ||
        (points.length == 4 && symmetric) ||
        points.length == 6) {
      List<Offset> animatedPoints = getAnimatedPoints(ticker);
      Offset cubicCP1 = animatedPoints[2];
      Offset cubicCP2, cubicCP3, cubicCP4;
      if (symmetric && orthSymmetric) {
        Offset center =
            Rect.fromPoints(animatedPoints[0], animatedPoints[1]).center;
        double cp1Direction = (cubicCP1 - center).direction;
        double cp1Distance = (cubicCP1 - center).distance;
        cubicCP2 =
            center + Offset.fromDirection(cp1Direction + pi / 2, cp1Distance);
        cubicCP3 =
            center + Offset.fromDirection(cp1Direction + pi, cp1Distance);
        cubicCP4 = center +
            Offset.fromDirection(cp1Direction + 3 * pi / 2, cp1Distance);
      } else if (symmetric) {
        cubicCP2 = animatedPoints[3];
        double cp3Direction =
            2 * (animatedPoints[0] - animatedPoints[1]).direction -
                (cubicCP2 - animatedPoints[1]).direction;
        double cp1Distance = (cubicCP1 - animatedPoints[0]).distance;
        double cp4Direction =
            2 * (animatedPoints[1] - animatedPoints[0]).direction -
                (cubicCP1 - animatedPoints[0]).direction;
        double cp2Distance = (cubicCP2 - animatedPoints[1]).distance;
        cubicCP3 =
            animatedPoints[1] + Offset.fromDirection(cp3Direction, cp2Distance);
        cubicCP4 =
            animatedPoints[0] + Offset.fromDirection(cp4Direction, cp1Distance);
      } else {
        cubicCP2 = animatedPoints[3];
        cubicCP3 = animatedPoints[4];
        cubicCP4 = animatedPoints[5];
      }
      animatedLeaf.moveTo(animatedPoints[0].dx, animatedPoints[0].dy);
      animatedLeaf.cubicTo(cubicCP1.dx, cubicCP1.dy, cubicCP2.dx, cubicCP2.dy,
          animatedPoints[1].dx, animatedPoints[1].dy);
      animatedLeaf.cubicTo(cubicCP3.dx, cubicCP3.dy, cubicCP4.dx, cubicCP4.dy,
          animatedPoints[0].dx, animatedPoints[0].dy);
      animatedLeaf.close();
    }
    return animatedLeaf;
  }

  @override
  void autoInitializeControlPoints() {
    if (points.length == 2) {
      Offset displacement = points[1] - points[0];
      Offset center = Rect.fromPoints(points[0], points[1]).center;
      Offset cubicCP1, cubicCP2, cubicCP3, cubicCP4;
      double cp1Direction = displacement.direction - 3 * pi / 4;
      double cp1Distance = displacement.distance / 2;
      cubicCP1 = center + Offset.fromDirection(cp1Direction, cp1Distance);
      cubicCP2 =
          center + Offset.fromDirection(cp1Direction + pi / 2, cp1Distance);
      cubicCP3 = center + Offset.fromDirection(cp1Direction + pi, cp1Distance);
      cubicCP4 =
          center + Offset.fromDirection(cp1Direction + 3 * pi / 2, cp1Distance);
      points.addAll([cubicCP1, cubicCP2, cubicCP3, cubicCP4]);
    }
  }

  Widget getToggleOrthoSymmetricButton() {
    return ActionButton(
      mode,
      orthSymmetric,
      displayWidget: const SymmetryIcon2(widthSize: 28),
      onPressed: () {
        orthSymmetric = !orthSymmetric;
        notifyListeners();
      },
      toolTipMessage: "Toggle orthogonal symmetric",
    );
  }

  Widget getToggleSymmetricButton() {
    return ActionButton(
      mode,
      symmetric,
      displayWidget: const SymmetryIcon(widthSize: 28),
      onPressed: () {
        symmetric = !symmetric;
        notifyListeners();
      },
      toolTipMessage: "Toggle symmetric",
    );
  }

  @override
  PointDrawLeaf duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawLeaf.from(this,
          displacement: displacement,
          key: ObjectKey("Leaf:" + generateAutoID()));
    } else {
      return PointDrawLeaf.from(this,
          key: ObjectKey("Leaf:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Leaf";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}

class PointDrawBlob extends PointDrawTwoDimensional {
  PointDrawBlob.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    required ObjectKey key,
    EditingMode mode = EditingMode.blob,
  }) : super.fromDocument(snapshot, mode: mode, key: key) {
    enableDeleteControlPoint = true;
  }

  PointDrawBlob({required ObjectKey key, EditingMode mode = EditingMode.blob})
      : super(mode: mode, key: key) {
    enableDeleteControlPoint = true;
  }

  PointDrawBlob.from(PointDrawBlob object,
      {Offset displacement = const Offset(5, 5),
      required ObjectKey key,
      EditingMode mode = EditingMode.blob})
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
  bool get isInitialized => points.length >= 4;

  @override
  bool get validNewPoint => true;

  @override
  void addControlPoint(Offset newPoint) {
    for (int i = 0; i < points.length - 1; i++) {
      if (Rect.fromCenter(
              center: (points[i] + points[i + 1]) * 0.5,
              width: max((points[i].dx - points[i + 1].dx).abs(), 10),
              height: max((points[i].dy - points[i + 1].dy).abs(), 10))
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
  PointDrawBlob moveControlPoint(Offset newPosition, int index,
      {Map<String, dynamic>? args}) {
    super.moveControlPoint(newPosition, index, args: args);
    return this;
  }

  @override
  PointDrawBlob duplicate({Offset? center}) {
    if (center != null) {
      Offset displacement = center - boundingRect.center;
      return PointDrawBlob.from(this,
          displacement: displacement,
          key: ObjectKey("Blob:" + generateAutoID()));
    } else {
      return PointDrawBlob.from(this,
          key: ObjectKey("Blob:" + generateAutoID()));
    }
  }

  @override
  String toString() => "Blob";

  @override
  SVGPointDrawElement toSVGElement(String id, Map<String, dynamic> attributes) {
    // TODO: implement toSVGElement
    throw UnimplementedError();
  }
}
