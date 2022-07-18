import 'package:flutter/material.dart';

import 'dart:math';

import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/matrices.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart' show textAreaWidthBuffer;
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';


Path getLoopedCMRPath(List<Offset> generatingPoints){
  return getCMRPath(generatingPoints, close: true, startHandle: generatingPoints[generatingPoints.length - 2], endHandle: generatingPoints[1]);
}

Path getCMRPath(List<Offset> generatingPoints, {bool close : false, Offset? startHandle, Offset? endHandle}){
  Path cmrPath = Path();
  CatmullRomSpline cmrSpline = CatmullRomSpline(generatingPoints, startHandle: startHandle, endHandle: endHandle);
  Iterable<Curve2DSample> samples = cmrSpline.generateSamples();
  cmrPath.moveTo(samples.first.value.dx, samples.first.value.dy);
  for(Curve2DSample pt in samples){
    cmrPath.lineTo(pt.value.dx, pt.value.dy);
  }
  if(close){
    cmrPath.close();
  }
  return cmrPath;
}

double getConicDirection(Rect rect, double coordinateDirection){
  double basic = atan(rect.width / rect.height * tan(coordinateDirection)).abs();
  if(coordinateDirection < -3 * pi / 2){
    return basic;
  } else if(coordinateDirection < -pi){
    return pi - basic;
  } else if(coordinateDirection < -pi / 2){
    return pi + basic;
  } else if(coordinateDirection < 0){
    return 2 * pi - basic;
  } else if(coordinateDirection < pi / 2){
    return basic;
  } else if(coordinateDirection < pi){
    return pi - basic;
  } else if(coordinateDirection < 3 * pi / 2){
    return pi + basic;
  } else {
    return 2 * pi - basic;
  }
}

double getBasicAngle(double angle){
  if(angle < -3 * pi / 2){
    return 2 * pi + angle;
  } else if(angle < -pi){
    return (pi + angle).abs();
  } else if(angle < -pi / 2){
    return pi + angle;
  } else if(angle < 0){
    return angle.abs();
  } else if(angle < pi / 2){
    return angle;
  } else if(angle < pi){
    return pi - angle;
  } else if(angle < 3 * pi / 2){
    return angle - pi;
  } else {
    return 2 * pi - angle;
  }
}

double getClockwiseSweepingDirection(double angle){
  return angle >= 0 ? angle : angle + 2 * pi;
}

Offset getConicOffset(Rect rect, double conicDirection){
  return rect.center + Offset(rect.width / 2 * cos(conicDirection), rect.height / 2 * sin(conicDirection));
}


Path getLeafPath(List<Offset> generatingPoints, {bool symmetric = true, bool orthSymmetric = true}) {
  assert((generatingPoints.length == 3 && symmetric && orthSymmetric) || (generatingPoints.length == 4 && symmetric) || generatingPoints.length == 6, "Requires at least 3 points for leaf paths.");
  Path leaf = Path();
  Offset cubicCP1 = generatingPoints[2];
  Offset cubicCP2, cubicCP3, cubicCP4;
  if(symmetric && orthSymmetric){
    Offset center = Rect.fromPoints(generatingPoints[0], generatingPoints[1]).center;
    double cp1Direction = (cubicCP1 - center).direction;
    double cp1Distance = (cubicCP1 - center).distance;
    cubicCP2 = center + Offset.fromDirection(cp1Direction + pi / 2, cp1Distance);
    cubicCP3 = center + Offset.fromDirection(cp1Direction + pi, cp1Distance);
    cubicCP4 = center + Offset.fromDirection(cp1Direction + 3 * pi / 2, cp1Distance);
  } else if (symmetric){
    cubicCP2 = generatingPoints[3];
    double cp3Direction = 2 * (generatingPoints[0] - generatingPoints[1]).direction - (cubicCP2 - generatingPoints[1]).direction;
    double cp1Distance = (cubicCP1 - generatingPoints[0]).distance;
    double cp4Direction = 2 * (generatingPoints[1] - generatingPoints[0]).direction - (cubicCP1 - generatingPoints[0]).direction;
    double cp2Distance = (cubicCP2 - generatingPoints[1]).distance;
    cubicCP3 = generatingPoints[1] + Offset.fromDirection(cp3Direction, cp2Distance);
    cubicCP4 = generatingPoints[0] + Offset.fromDirection(cp4Direction, cp1Distance);
  } else {
    cubicCP2 = generatingPoints[3];
    cubicCP3 = generatingPoints[4];
    cubicCP4 = generatingPoints[5];
  }
  leaf.moveTo(generatingPoints[0].dx, generatingPoints[0].dy);
  leaf.cubicTo(cubicCP1.dx, cubicCP1.dy, cubicCP2.dx, cubicCP2.dy, generatingPoints[1].dx, generatingPoints[1].dy);
  leaf.cubicTo(cubicCP3.dx, cubicCP3.dy, cubicCP4.dx, cubicCP4.dy, generatingPoints[0].dx, generatingPoints[0].dy);
  leaf.close();
  return leaf;
}


Offset rotate(Offset p, Offset center, double angle){
  return center + Offset.fromDirection((p - center).direction + angle, (p - center).distance);
}

List<Offset> getFlipHorizontal(List<Offset> points, Offset center){
  List<Offset> flippedPoints = [];
  for(Offset point in points){
    flippedPoints.add(
        Offset(center.dx + (center.dx - point.dx), point.dy)
    );
  }
  return flippedPoints;
}

List<Offset> getFlipVertical(List<Offset> points, Offset center){
  List<Offset> flippedPoints = [];
  for(Offset point in points){
    flippedPoints.add(
        Offset(point.dx, center.dy + (center.dy - point.dy))
    );
  }
  return flippedPoints;
}

List<Offset> getRotatedPoints(List<Offset> points, Offset center, double angle){
  List<Offset> rotatedPoints = [];
  for(Offset point in points){
    rotatedPoints.add(rotate(point, center, angle));
  }
  return rotatedPoints;
}

PointDrawObject getDataPointsByRotation(EditingMode mode, PointDrawObject curve, Offset center, double rotation){
  switch(mode){
    // case EditingMode.arc:
    //   curve.dPoints[0] = curve.points[0] + Offset((curve as PointDrawArc).width / 2, curve.height / 2);
    //   return curve;
    // case EditingMode.conic:
    //   curve.dPoints[0] = curve.points[0] + Offset((curve as PointDrawConic).width / 2, curve.height / 2);
    //   return curve;
    default:
      return curve;
  }
}

PointDrawObject getRestrictedPointsByRotation(EditingMode mode, PointDrawObject curve, Offset center, double rotation){
  switch(mode){
    case EditingMode.roundedRectangle:
      Offset topLeft = Rect.fromPoints(curve.points.first, curve.points.last).topLeft;
      double radius = max(5.0, (topLeft - curve.rPoints.first).distance);
      curve.rPoints = [topLeft + Offset.fromDirection(pi / 2, radius)];
      return curve;
    case EditingMode.arc:
      curve.rPoints = getRotatedPoints(curve.rPoints, center, rotation);
      return curve;
    case EditingMode.conic:
      curve.rPoints = getRotatedPoints(curve.rPoints, center, rotation);
      return curve;
    case EditingMode.arrow:
      curve.rPoints = getRotatedPoints(curve.rPoints, center, rotation);
      return curve;
    default:
      return curve;
  }
}

// PointDrawObject getShaderOffsetsByRotation(EditingMode mode, PointDrawObject curve, Offset center, double rotation){
//   if(curve.shaderParam?.center != null) {
//     curve.updateShaderParams(centerOffset: getRotatedPoints([curve.shaderParam!.center!], center, rotation).first);
//   }
//   if(curve.shaderParam?.from != null) {
//     curve.updateShaderParams(fromOffset: getRotatedPoints([curve.shaderParam!.from!], center, rotation).first);
//   }
//   if(curve.shaderParam?.to != null) {
//     curve.updateShaderParams(toOffset: getRotatedPoints([curve.shaderParam!.to!], center, rotation).first);
//   }
//   return curve;
// }

List<Offset> getTranslatedPoints(List<Offset> points, double dx, double dy){
  List<Offset> translatedPoints = [];
  for(Offset point in points){
    translatedPoints.add(point + Offset(dx, dy));
  }
  return translatedPoints;
}

// PointDrawObject getShaderOffsetsByTranslation(EditingMode mode, PointDrawObject curve, double dx, double dy){
//   if(curve.shaderParam?.center != null) {
//     curve.updateShaderParams(centerOffset: getTranslatedPoints([curve.shaderParam!.center!], dx, dy).first);
//   }
//   if(curve.shaderParam?.from != null) {
//     curve.updateShaderParams(fromOffset: getTranslatedPoints([curve.shaderParam!.from!], dx, dy).first);
//   }
//   if(curve.shaderParam?.to != null) {
//     curve.updateShaderParams(toOffset: getTranslatedPoints([curve.shaderParam!.to!], dx, dy).first);
//   }
//   return curve;
// }

PointDrawObject getDataPointsByTranslation(EditingMode mode, PointDrawObject curve, double dx, double dy){
  switch(mode){
    case EditingMode.arc:
      curve.dPoints = getTranslatedPoints(curve.dPoints, dx, dy);
      return curve;
    case EditingMode.conic:
      curve.dPoints = getTranslatedPoints(curve.dPoints, dx, dy);
      return curve;
    default:
      return curve;
  }
}

PointDrawObject getRestrictedPointsByTranslation(EditingMode mode, PointDrawObject curve, double dx, double dy){
  switch(mode){
    case EditingMode.roundedRectangle:
      curve.rPoints = getTranslatedPoints(curve.rPoints, dx, dy);
      return curve;
    case EditingMode.arc:
      curve.rPoints = getTranslatedPoints(curve.rPoints, dx, dy);
      return curve;
    case EditingMode.conic:
      curve.rPoints = getTranslatedPoints(curve.rPoints, dx, dy);
      return curve;
    case EditingMode.arrow:
      curve.rPoints = getTranslatedPoints(curve.rPoints, dx, dy);
      return curve;
    default:
      return curve;
  }
}

// PointDrawObject getShaderOffsetsByHorizontalScale(EditingMode mode, PointDrawObject curve, Offset stationary, double scaleFactor){
//   if(curve.shaderParam?.center != null) {
//     curve.updateShaderParams(centerOffset: scaleHorizontal([curve.shaderParam!.center!], stationary, scaleFactor).first);
//   }
//   if(curve.shaderParam?.from != null) {
//     curve.updateShaderParams(fromOffset: scaleHorizontal([curve.shaderParam!.from!], stationary, scaleFactor).first);
//   }
//   if(curve.shaderParam?.to != null) {
//     curve.updateShaderParams(toOffset: scaleHorizontal([curve.shaderParam!.to!], stationary, scaleFactor).first);
//   }
//   return curve;
// }

PointDrawObject getRestrictedPointsByHorizontalScale(EditingMode mode, PointDrawObject curve, Offset stationary, double scaleFactor){
  switch(mode){
    // case EditingMode.arc:
    //   Rect rect = Rect.fromCenter(center: curve.points[0], width: (curve as PointDrawArc).width, height: curve.height);
    //   curve.rPoints[2] = curve.points[0] + Offset.fromDirection((Offset(stationary.dx + (curve.rPoints[2].dx - stationary.dx) * scaleFactor, curve.rPoints[2].dy) - curve.points[0]).direction, (rect.center - rect.bottomRight).distance);
    //   double rotationAdjustedAngle = (curve.rPoints[2] - rect.center).direction;
    //   Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    //   curve.rPoints[0] = matrixApply(rotationMatrix, getConicOffset(rect, getConicDirection(rect, (curve.rPoints[0] - rect.center).direction - rotationAdjustedAngle)));
    //   curve.rPoints[1] = matrixApply(rotationMatrix, getConicOffset(rect, getConicDirection(rect, (curve.rPoints[1] - rect.center).direction - rotationAdjustedAngle)));
    //   return curve;
    // case EditingMode.conic:
    //   Rect rect = Rect.fromCenter(center: curve.points[0], width: (curve as PointDrawConic).width, height: curve.height);
    //   curve.rPoints[0] = curve.points[0] + Offset.fromDirection((Offset(stationary.dx + (curve.rPoints[0].dx - stationary.dx) * scaleFactor, curve.rPoints[0].dy) - curve.points[0]).direction, (rect.center - rect.bottomRight).distance);
    //   // curve["restricted_control_points"] = getRotatedPoints(curve["restricted_control_points"], center, rotation);
    //   return curve;
    // case EditingMode.arrow:
    //   double direction = (curve.points[1] - curve.points[0]).direction;
    //   double dist = (curve.rPoints[0] - curve.rPoints[1]).distance;
    //   // curve["directional_gap"] = curve["directional_gap"] * scaleFactor;
    //   curve.rPoints[0] = curve.points[0] + Offset.fromDirection(direction, (curve as PointDrawArrow).directionalGap) + Offset.fromDirection(direction + pi / 2, curve.orthogonalGap);
    //   curve.rPoints[1] = curve.points[0] + Offset.fromDirection(direction, curve.directionalGap) + Offset.fromDirection(direction + pi / 2, curve.orthogonalGap - dist);
    //   return curve;
    default:
      return curve;
  }
}

List<Offset> scaleHorizontal(List<Offset> points, Offset stationary, double scaleFactor){
  List<Offset> scaled = [];
  for(Offset point in points){
    scaled.add(
        Offset(stationary.dx + (point.dx - stationary.dx) * scaleFactor, point.dy)
    );
  }
  return scaled;
}

PointDrawObject getDataPointsByHorizontalScale(EditingMode mode, PointDrawObject curve, Offset stationary, double scaleFactor){
  switch(mode){
    // case EditingMode.arc:
    //   (curve as PointDrawArc).width = curve.width * scaleFactor;
    //   curve.dPoints[0] = Rect.fromCenter(center: curve.points[0], width: curve.width, height: curve.height).bottomRight;
    //   return curve;
    // case EditingMode.conic:
    //   (curve as PointDrawConic).width = curve.width * scaleFactor;
    //   curve.dPoints[0] = Rect.fromCenter(center: curve.points[0], width: curve.width, height: curve.height).bottomRight;
    //   return curve;
    case EditingMode.text:
      (curve as PointDrawText).width = curve.width * scaleFactor;
      return curve;
    default:
      return curve;
  }
}

List<Offset> scaleVertical(List<Offset> points, Offset stationary, double scaleFactor){
  List<Offset> scaled = [];
  for(Offset point in points){
    scaled.add(
        Offset(point.dx, stationary.dy + (point.dy - stationary.dy) * scaleFactor)
    );
  }
  return scaled;
}

// PointDrawObject getShaderOffsetsByVerticalScale(EditingMode mode, PointDrawObject curve, Offset stationary, double scaleFactor){
//   if(curve.shaderParam?.center != null) {
//     curve.updateShaderParams(centerOffset: scaleVertical([curve.shaderParam!.center!], stationary, scaleFactor).first);
//   }
//   if(curve.shaderParam?.from != null) {
//     curve.updateShaderParams(fromOffset: scaleVertical([curve.shaderParam!.from!], stationary, scaleFactor).first);
//   }
//   if(curve.shaderParam?.to != null) {
//     curve.updateShaderParams(toOffset: scaleVertical([curve.shaderParam!.to!], stationary, scaleFactor).first);
//   }
//   return curve;
// }

PointDrawObject getRestrictedPointsByVerticalScale(EditingMode mode, PointDrawObject curve, Offset stationary, double scaleFactor){
  switch(mode){
    // case EditingMode.arc:
    //   Rect rect = Rect.fromCenter(center: (curve as PointDrawArc).points[0], width: curve.width, height: curve.height);
    //   curve.rPoints[2] = curve.points[0] + Offset.fromDirection((Offset(curve.rPoints[2].dx, stationary.dy + (curve.rPoints[2].dy - stationary.dy) * scaleFactor) - curve.points[0]).direction, (rect.center - rect.bottomRight).distance);
    //   double rotationAdjustedAngle = (curve.rPoints[2] - rect.center).direction;
    //   Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    //   curve.rPoints[0] = matrixApply(rotationMatrix, getConicOffset(rect, getConicDirection(rect, (curve.rPoints[0] - rect.center).direction - rotationAdjustedAngle)));
    //   curve.rPoints[1] = matrixApply(rotationMatrix, getConicOffset(rect, getConicDirection(rect, (curve.rPoints[1] - rect.center).direction - rotationAdjustedAngle)));
    //   return curve;
    // case EditingMode.conic:
    //   Rect rect = Rect.fromCenter(center: (curve as PointDrawConic).points[0], width: curve.width, height: curve.height);
    //   curve.rPoints[0] = curve.points[0] + Offset.fromDirection((Offset(curve.rPoints[0].dx, stationary.dy + (curve.rPoints[0].dy - stationary.dy) * scaleFactor) - curve.points[0]).direction, (rect.center - rect.bottomRight).distance);
    //   return curve;
    default:
      return curve;
  }
}

PointDrawObject getDataPointsByVerticalScale(EditingMode mode, PointDrawObject curve, Offset stationary, double scaleFactor){
  switch(mode){
    // case EditingMode.arc:
    //   (curve as PointDrawArc).height = curve.height * scaleFactor;
    //   curve.dPoints[0] = Rect.fromCenter(center: curve.points[0], width: curve.width, height: curve.height).bottomRight;
    //   return curve;
    // case EditingMode.conic:
    //   (curve as PointDrawConic).height = curve.height * scaleFactor;
    //   curve.dPoints[0] = curve.points[0] + Offset(curve.width / 2, curve.height / 2);
    //   return curve;
    case EditingMode.text:
      (curve as PointDrawText).height = curve.height * scaleFactor;
      return curve;
    default:
      return curve;
  }
}

List<Offset> scale(List<Offset> points, Offset stationary, Offset scaleFactor){
  List<Offset> scaled = [];
  for(Offset point in points){
    scaled.add(
        Offset(stationary.dx + (point.dx - stationary.dx) * scaleFactor.dx, stationary.dy + (point.dy - stationary.dy) * scaleFactor.dy)
    );
  }
  return scaled;
}

PointDrawObject getRestrictedPointsByScale(EditingMode mode, PointDrawObject curve, Offset stationary, Offset scaleFactor){
  switch(mode){
    // case EditingMode.arc:
    //   Rect rect = Rect.fromCenter(center: (curve as PointDrawArc).points[0], width: curve.width, height: curve.height);
    //   curve.rPoints[2] = curve.points[0] + Offset.fromDirection((Offset(stationary.dx + (curve.rPoints[2].dx - stationary.dx) * scaleFactor.dx, stationary.dy + (curve.rPoints[2].dy - stationary.dy) * scaleFactor.dy) - curve.points[0]).direction, (rect.center - rect.bottomRight).distance);
    //   double rotationAdjustedAngle = (curve.rPoints[2] - rect.center).direction;
    //   Matrix4 rotationMatrix = rotateZAbout(rotationAdjustedAngle, rect.center);
    //   curve.rPoints[0] = matrixApply(rotationMatrix, getConicOffset(rect, getConicDirection(rect, (curve.rPoints[0] - rect.center).direction - rotationAdjustedAngle)));
    //   curve.rPoints[1] = matrixApply(rotationMatrix, getConicOffset(rect, getConicDirection(rect, (curve.rPoints[1] - rect.center).direction - rotationAdjustedAngle)));
    //   return curve;
    // case EditingMode.conic:
    //   Rect rect = Rect.fromCenter(center: (curve as PointDrawConic).points[0], width: curve.width, height: curve.height);
    //   curve.rPoints[0] = curve.points[0] + Offset.fromDirection((Offset(stationary.dx + (curve.rPoints[0].dx - stationary.dx) * scaleFactor.dx, stationary.dy + (curve.rPoints[0].dy - stationary.dy) * scaleFactor.dy) - curve.points[0]).direction, (rect.center - rect.bottomRight).distance);
    //   return curve;
    default:
      return curve;
  }
}

PointDrawObject getDataPointsByScale(EditingMode mode, PointDrawObject curve, Offset stationary, Offset scaleFactor){
  switch(mode){
    // case EditingMode.arc:
    //   (curve as PointDrawArc).height = curve.height * scaleFactor.dy;
    //   curve.width = curve.width * scaleFactor.dx;
    //   curve.dPoints[0] = Rect.fromCenter(center: curve.points[0], width: curve.width, height: curve.height).bottomRight;
    //   return curve;
    // case EditingMode.conic:
    //   (curve as PointDrawConic).height = curve.height * scaleFactor.dy;
    //   curve.width = curve.width * scaleFactor.dx;
    //   curve.dPoints[0] = Rect.fromCenter(center: curve.points[0], width: curve.width, height: curve.height).bottomRight;
    //   return curve;
    case EditingMode.text:
      (curve as PointDrawText).width = curve.width * scaleFactor.dx;
      curve.height = curve.height * scaleFactor.dy;
      return curve;
    default:
      return curve;
  }
}

// PointDrawObject getShaderOffsetsByScale(EditingMode mode, PointDrawObject curve, Offset stationary, Offset scaleFactor){
//   if(curve.shaderParam?.center != null) {
//     curve.updateShaderParams(centerOffset: scale([curve.shaderParam!.center!], stationary, scaleFactor).first);
//   }
//   if(curve.shaderParam?.from != null) {
//     curve.updateShaderParams(fromOffset: scale([curve.shaderParam!.from!], stationary, scaleFactor).first);
//   }
//   if(curve.shaderParam?.to != null) {
//     curve.updateShaderParams(toOffset: scale([curve.shaderParam!.to!], stationary, scaleFactor).first);
//   }
//   return curve;
// }

// Path getDirectedLinePath(List<Offset> endPoints){
//   assert(endPoints.length == 2, "Require exactly 2 points for a directed line");
//   Path directedLine = Path();
//   Offset start = endPoints[0];
//   Offset pointer = endPoints[1];
//   directedLine.moveTo(start.dx, start.dy);
//   directedLine.lineTo(pointer.dx, pointer.dy);
//   double direction = (pointer - start).direction;
//   directedLine.addPolygon(
//       [
//         pointer + Offset.fromDirection(direction, 6),
//         pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
//         pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
//       ], true);
//   return directedLine;
// }

// Path getCurveDirectedLinePath(List<Offset> controlPoints){
//   assert(controlPoints.length == 2, "Require exactly 2 points for a curve directed line");
//   Path curveDirectedLine = Path();
//   Offset start = controlPoints[0];
//   Offset pointer = controlPoints[1];
//   double direction = (pointer - start).direction;
//   double gap = (pointer - start).distance * 0.2;
//   Offset controlPoint1 = start + ((pointer - start) / 3) + Offset.fromDirection(direction + pi / 2, gap);
//   Offset controlPoint2 = start + ((pointer - start) * 2 / 3) + Offset.fromDirection(direction - pi / 2, gap);
//   curveDirectedLine.moveTo(start.dx, start.dy);
//   curveDirectedLine.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, pointer.dx, pointer.dy);
//   curveDirectedLine.addPolygon(
//       [
//         pointer + Offset.fromDirection(direction, 6),
//         pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
//         pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
//       ], true);
//   return curveDirectedLine;
// }

Path getEndArrow(List<Offset> controlPoints){
  assert(controlPoints.length == 2, "Require exactly 2 points for end arrow");
  Path curveDirectedLinePointer = Path();
  Offset start = controlPoints[0];
  Offset pointer = controlPoints[1];
  double direction = (pointer - start).direction;
  curveDirectedLinePointer.addPolygon(
      [
        pointer + Offset.fromDirection(direction, 6),
        pointer + Offset.fromDirection(direction + (2 * pi / 3), 6),
        pointer + Offset.fromDirection(direction + (4 * pi / 3), 6),
      ], true);
  return curveDirectedLinePointer;
}