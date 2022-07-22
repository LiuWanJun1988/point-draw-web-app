import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:pointdraw/point_draw_models/point_draw_composite_path.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';

class Line2D extends Curve2D{

  const Line2D(this._controlPoints) :
      assert(_controlPoints.length == 2, "Exactly 2 control points needed to define a line");
      // _controlPoints = controlPoints;

  final List<Offset> _controlPoints;

  double get length => (_controlPoints[1] - _controlPoints[0]).distance;

  double get direction => (_controlPoints[1] - _controlPoints[0]).direction;

  @override
  Iterable<Curve2DSample> generateSamples ({double start = 0.0,
    double end = 1.0,
    double tolerance = 1e-6,}){
    assert(end > start);

    final math.Random rand = math.Random(samplingSeed);

    final Curve2DSample first = Curve2DSample(start, transform(start));
    final Curve2DSample last = Curve2DSample(end, transform(end));

    final List<Curve2DSample> samples = <Curve2DSample>[first];
    void sample(Curve2DSample p, Curve2DSample q, {bool forceSubdivide = false}) {
      // Pick a random point somewhat near the center, which avoids aliasing
      // problems with periodic curves.
      if((p.t - q.t).abs() < tolerance && !forceSubdivide){
        samples.add(q);
        return;
      }
      final double t = p.t + (0.45 + 0.1 * rand.nextDouble()) * (q.t - p.t);
      final Curve2DSample r = Curve2DSample(t, transform(t));
      sample(p, r);
      sample(r, q);
    }

    // If the curve starts and ends on the same point, then we force it to
    // subdivide at least once, because otherwise it will terminate immediately.
    sample(
      first,
      last,
      forceSubdivide: (first.value.dx - last.value.dx).abs() < tolerance && (first.value.dy - last.value.dy).abs() < tolerance,
    );
    return samples;
  }

  @override
  Offset transformInternal(double t) {
    return _controlPoints.first + Offset.fromDirection(direction, t * length);
  }
}

class PolygonalLine2D extends Curve2D {

  late List<Line2D> _lineSegments;

  final List<Offset> _internalControlPoints;

  PolygonalLine2D(this._internalControlPoints) :
      assert(_internalControlPoints.length >= 2),
      _lineSegments = computeLineSegment(_internalControlPoints);

  static List<Line2D> computeLineSegment(List<Offset> points){
    List<Line2D> lines = <Line2D>[];
    for(int i = 0; i < points.length - 1; i++){
      lines.add(Line2D([points[i], points[i + 1]]));
    }
    return lines;
  }

  double get length => _lineSegments.fold(0, (prev, line) => prev + line.length);

  @override
  Offset transformInternal(double t) {
    double dist = t * length;
    double cumulativeDist = 0;
    for(int i = 0; i < _lineSegments.length; i++){
      double len = _lineSegments[i].length;
      if(cumulativeDist + len > dist){
        return _lineSegments[i].transform((dist - cumulativeDist) / len);
      }
      cumulativeDist += len;
    }
    throw FlutterError("Cannot find segment for $t");
  }
}

class QuadraticBezierCurve2D extends Curve2D {

  final List<Offset> _controlPoints;

  QuadraticBezierCurve2D(this._controlPoints) :
      assert(_controlPoints.length == 3, "Exactly 3 control points needed for quadratic bezier curve.");

  @override
  Offset transformInternal(double t) {
    return _controlPoints[0] * (1 - t) * (1 - t) + _controlPoints[1] * 2 * t * (1 - t) + _controlPoints[2] * t * t;
  }
}

class ChainedQuadraticBezierCurve2D extends Curve2D {

  final List<Offset> _controlPoints;

  ChainedQuadraticBezierCurve2D(this._controlPoints) :
      assert(_controlPoints.length >= 3 && _controlPoints.length % 3 == 0, "Multiples of 3 control points for well-defined chained quadratic bezier curve"),
      _bezierCurves = List<QuadraticBezierCurve2D>.generate(_controlPoints.length ~/ 3, (ind){
        return QuadraticBezierCurve2D([_controlPoints[ind * 3], _controlPoints[ind * 3 + 1], _controlPoints[ind * 3 + 2]]);
      });

  late List<QuadraticBezierCurve2D> _bezierCurves;

  int get chains => _controlPoints.length ~/ 3;

  @override
  Offset transformInternal(double t){
    int chainIndex = (t * chains).floor();
    return _bezierCurves[chainIndex].transform((t * chains) % 1);
  }

}

class CubicBezierCurve2D extends Curve2D {

  final List<Offset> _controlPoints;

  CubicBezierCurve2D(this._controlPoints) :
        assert(_controlPoints.length == 4, "Exactly 4 control points needed for cubic bezier curve.");

  @override
  Offset transformInternal(double t) {
    return _controlPoints[0] * math.pow((1 - t), 3).toDouble() + _controlPoints[1] * 3 * t * (1 - t) * (1 - t) + _controlPoints[2] * 3 * t * t * (1 - t) + _controlPoints[3] * math.pow(t, 3).toDouble();
  }
}

class ChainedCubicBezierCurve2D extends Curve2D {

  final List<Offset> _controlPoints;

  ChainedCubicBezierCurve2D(this._controlPoints) :
        assert(_controlPoints.length >= 4 && _controlPoints.length % 4 == 0, "Multiples of 4 control points for well-defined chained cubic bezier curve"),
        _bezierCurves = List<CubicBezierCurve2D>.generate(_controlPoints.length ~/ 4, (ind){
          return CubicBezierCurve2D([_controlPoints[ind * 4], _controlPoints[ind * 4 + 1], _controlPoints[ind * 4 + 2], _controlPoints[ind * 4 + 3]]);
        });

  late List<CubicBezierCurve2D> _bezierCurves;

  int get chains => _controlPoints.length ~/ 4;

  @override
  Offset transformInternal(double t){
    int chainIndex = (t * chains).floor();
    return _bezierCurves[chainIndex].transform((t * chains) % 1);
  }

}

class CompositeCurve2D extends Curve2D {

  final PointDrawComposite _composite;

  CompositeCurve2D(this._composite) :
      assert(_composite.composites.isNotEmpty),
      assert(_composite.composites.every((element) => element.hasPath)),
      _curve2Ds = List<Curve2D>.generate(_composite.composites.length, (ind){
        if(_composite.composites[ind].mode == EditingMode.line){
          return PolygonalLine2D(_composite.composites[ind].points);
        } else if (_composite.composites[ind].mode == EditingMode.splineCurve){
          return CatmullRomSpline(_composite.composites[ind].points);
        } else if (_composite.composites[ind].mode == EditingMode.quadraticBezier){
          return ChainedQuadraticBezierCurve2D(_composite.composites[ind].points);
        } else if (_composite.composites[ind].mode == EditingMode.cubicBezier){
          return ChainedCubicBezierCurve2D(_composite.composites[ind].points);
        } else {
          throw UnimplementedError("Composite ${_composite.composites[ind].mode} not implemented.");
        }
      });

  late List<Curve2D> _curve2Ds;

  // Call this method before constructing a composite curve 2D object
  static bool validateComposites(PointDrawComposite composite){
    var composites = composite.composites;
    return composites.every((element) => validateComposite(element));
  }

  static bool validateComposite(compositable){
    switch(compositable){
      case PointDrawCompositableLine:
        return compositable.points.length >= 2;
      case PointDrawCompositableSplineCurve:
        return compositable.points.length >= 4;
      case PointDrawCompositableQuadraticBezier:
        return compositable.hasPath && compositable.points.length % 3 == 0;
      case PointDrawCompositableCubicBezier:
        return compositable.hasPath && compositable.points.length % 4 == 0;
      default:
        return false;
    }
  }

  int get parts => _composite.composites.length;

  @override
  Offset transformInternal(double t){
    int partsIndex = (t * parts).floor();
    return _curve2Ds[partsIndex].transform((t * parts) % 1);
  }

}

