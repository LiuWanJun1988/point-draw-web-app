import 'dart:math';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

Matrix4 rotateXAbout(double radian, Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.rotationX(radian)).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 rotateYAbout(double radian, Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.rotationY(radian)).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 rotateZAbout(double radian, Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.rotationZ(radian)).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 skewAlongX(double factor, Offset xAxis){
  return(Matrix4.translationValues(0, xAxis.dy, 0)).multiplied(Matrix4.identity()
    ..setEntry(0, 1, factor)).multiplied(Matrix4.translationValues(0, -xAxis.dy, 0));
}

Matrix4 skewAlongY(double factor, Offset yAxis){
  return(Matrix4.translationValues(yAxis.dx, 0, 0)).multiplied(Matrix4.identity()
    ..setEntry(0, 1, factor)).multiplied(Matrix4.translationValues(-yAxis.dy, 0, 0));
}

Matrix4 scaling(double factor){
  return Matrix4.identity() * factor;
}

Matrix4 translate(Offset offset){
  return Matrix4.translationValues(offset.dx, offset.dy, 0);
}

Matrix4 translateXY(double dx, double dy){
  return Matrix4.translationValues(dx, dy, 0);
}

Matrix4 scalingX(double factor, Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.diagonal3(Vector3(factor, 1, 1))).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 scalingY(double factor, Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.diagonal3(Vector3(1, factor, 1))).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 scalingXY(Offset factor, Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.diagonal3(Vector3(factor.dx, factor.dy, 1))).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 scaleThenTranslate(double factor, Offset offset){
  return Matrix4.translationValues(offset.dx, offset.dy, 0).multiplied((Matrix4.identity() * factor));
}

Matrix4 horizontalFlip(Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.identity()..setEntry(0, 0, -1)).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Matrix4 verticalFlip(Offset center){
  return (Matrix4.translationValues(center.dx, center.dy, 0)).multiplied(Matrix4.identity()..setEntry(1, 1, -1)).multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
}

Offset matrixApply(Matrix4 mat, Offset offset){
  Vector2 result = mat.transform(Vector4(offset.dx, offset.dy, 0, 1)).xy;
  return Offset(result.x, result.y);
}

double lengthOfProjection(Offset point, double direction, Offset positionVector){
  Offset disp = point - positionVector;
  Vector3 p = Vector3(disp.dx, disp.dy, 0);
  Vector3 d = Vector3(cos(direction), sin(direction), 0);
  return p.dot(d).abs();
}

double distanceFromLine(Offset point, double direction, Offset positionVector){
  Offset disp = point - positionVector;
  Vector3 p = Vector3(disp.dx, disp.dy, 0);
  Vector3 d = Vector3(cos(direction), sin(direction), 0);
  return p.distanceTo(d);
}

double determinant(Offset p1, Offset p2){
  return p1.dx * p2.dy - p1.dy * p2.dx;
}

double determinate(Offset p1, Offset p2){
  return determinant(p1, p2).sign;
}

double dotProduct(Offset p1, Offset p2){
  return p1.dx * p2.dx + p1.dy * p2.dy;
}

double dotProductSign(Offset p1, Offset p2){
  return dotProduct(p1, p2).sign;
}