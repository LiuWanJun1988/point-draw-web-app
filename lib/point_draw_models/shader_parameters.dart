import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'dart:math' show pi, min, max;

import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/drawing_paths.dart';
import 'package:pointdraw/point_draw_models/keys_and_names.dart';

enum ShaderType{linear, radial, sweep}

class ShaderParameters extends ChangeNotifier{

  ShaderType type = ShaderType.linear;
  Offset? center;
  Offset? from;
  Offset? to;

  List<Color> colors = [Colors.white, Colors.blue];
  List<double> stops = [0.0, 1.0];
  TileMode tileMode = TileMode.clamp;

  double? radius;
  Offset? focal;
  double? focalRadius;
  double? startAngle;
  double? endAngle;

  ShaderParameters({
        this.type = ShaderType.linear,
        this.center,
        this.from,
        this.to,
        this.colors = const [Colors.white, Colors.blue],
        this.stops = const [0.0, 1.0],
        this.tileMode = TileMode.clamp,
        this.radius,
        this.focal,
        this.focalRadius,
        this.startAngle,
        this.endAngle,
        Rect? boundingRect,
      }){
    if(type == ShaderType.linear && (from == null || to == null)){
      from ??= boundingRect?.centerLeft;
      to ??= boundingRect?.centerRight;
    }
    if((type == ShaderType.radial || type == ShaderType.sweep) && center == null){
      center ??= boundingRect?.center;
    }
    if(type == ShaderType.radial){
      radius ??= boundingRect?.shortestSide;
    }
    if(type == ShaderType.sweep){
      startAngle ??= 0.0;
      endAngle ??= 2 * pi;
    }
  }

  ShaderParameters.fromData(Map<String, dynamic> data){
    type = getShaderType(data[shaderTypeKey]);
    if(data[shaderCenterOffsetXKey] != null && data[shaderCenterOffsetYKey] != null){
      center = Offset(data[shaderCenterOffsetXKey], data[shaderCenterOffsetYKey]);
    }
    if(data[shaderFromOffsetXKey] != null && data[shaderFromOffsetYKey] != null){
      from = Offset(data[shaderFromOffsetXKey], data[shaderFromOffsetYKey]);
    }
    if(data[shaderToOffsetXKey] != null && data[shaderToOffsetYKey] != null){
      to = Offset(data[shaderToOffsetXKey], data[shaderToOffsetYKey]);
    }
    radius = data[shaderRadiusKey];
    List<Map<String, num>> shaderColors = [for(Map o in data[shaderColorsKey]) Map.from(o)];
    colors = [];
    for(int i = 0; i < shaderColors.length; i++){
      colors += [
        Color.fromARGB(
            shaderColors[i][shaderColorAlphaKey]! as int,
            shaderColors[i][shaderColorRedKey]! as int,
            shaderColors[i][shaderColorGreenKey]! as int,
            shaderColors[i][shaderColorBlueKey]! as int
        )
      ];
    }
    stops = List.from(data[shaderColorStopKey]);
  }

  ShaderParameters copy({Offset displacement = const Offset(5, 5)}){
    return ShaderParameters(
      type: type,
      center: center != null ? center! + displacement : null,
      from: from != null ? from! + displacement : null,
      to: to != null ? to! + displacement : null,
      colors: List<Color>.of(colors),
      stops: List<double>.of(stops),
      tileMode: tileMode,
      radius: radius,
      focal: focal != null ? focal! + displacement : null,
      focalRadius: focalRadius,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = {
      shaderTypeKey: type.name,
      shaderCenterOffsetXKey: center?.dx,
      shaderCenterOffsetYKey: center?.dy,
      shaderFromOffsetXKey: from?.dx,
      shaderFromOffsetYKey: from?.dy,
      shaderToOffsetXKey: to?.dx,
      shaderToOffsetYKey: to?.dy,
      shaderTileModeKey: tileMode.name,
      shaderRadiusKey: radius,
      shaderFocalXKey: focal?.dx,
      shaderFocalYKey: focal?.dy,
      shaderFocalRadiusKey: focalRadius,
      shaderStartAngleKey: startAngle,
      shaderEndAngleKey: endAngle,
    };
    data[shaderColorsKey] = [
      for(int i = 0; i < colors.length; i++)
        {
          shaderColorAlphaKey : colors[i].alpha,
          shaderColorRedKey : colors[i].red,
          shaderColorGreenKey : colors[i].green,
          shaderColorBlueKey : colors[i].blue,
          shaderColorStopKey : stops[i],
        },
    ];
    data[shaderColorStopKey] = stops;
    return data;
  }

  Shader build({Rect? boundingRect, Matrix4? zoomTransform}){
    switch(type){
      case ShaderType.linear:
        if(from !=null && to != null){
          return ui.Gradient.linear(from!, to!, colors, stops, tileMode, zoomTransform?.storage);
        } else if(boundingRect != null) {
          from = boundingRect.centerLeft;
          to = boundingRect.centerRight;
          center = null;
          return ui.Gradient.linear(from!, to!, colors, stops, tileMode, zoomTransform?.storage);
        } else {
          throw FlutterError("From or To offset is null when building linear shader");
        }
      case ShaderType.radial:
        if(center !=null && radius != null){
          return ui.Gradient.radial(center!, radius!, colors, stops, tileMode, zoomTransform?.storage, focal, focalRadius ?? 0.0);
        } else if(boundingRect != null) {
          center = boundingRect.center;
          from = null;
          to = null;
          radius = boundingRect.shortestSide;
          return ui.Gradient.radial(center!, radius!, colors, stops, tileMode, zoomTransform?.storage, focal, focalRadius ?? 0.0);
        } else {
          throw FlutterError("Center offset is null when building radial shader");
        }
      case ShaderType.sweep:
        if(center !=null){
          return ui.Gradient.sweep(center!, colors, stops, tileMode, startAngle ?? 0.0, endAngle ?? 2 * pi, zoomTransform?.storage);
        } else if(boundingRect != null) {
          center = boundingRect.center;
          from = null;
          to = null;
          radius = null;
          return ui.Gradient.sweep(center!, colors, stops, tileMode, startAngle ?? 0.0, endAngle ?? 2 * pi, zoomTransform?.storage);
        } else {
          throw FlutterError("Center offset is null when building sweep shader");
        }
      default:
        throw UnimplementedError("Building shader of type: $type not implemented");
    }
  }

  void reset(){
    type = ShaderType.linear;
    center = null;
    from = null;
    to = null;

    colors = [Colors.white, Colors.blue];
    stops = [0.0, 1.0];
    tileMode = TileMode.clamp;

    radius = null;
    focal = null;
    focalRadius = null;
    startAngle = null;
    endAngle = null;
    notifyListeners();
  }

  void removeColorStop(int index){
    stops = List<double>.generate(stops.length - 1, (i){
      if(i < index){
        return stops[i];
      } else {
        return stops[i + 1];
      }
    });
    colors = List<Color>.generate(colors.length - 1, (i){
      if(i < index){
        return colors[i];
      } else {
        return colors[i + 1];
      }
    });
    assert(stops.length == colors.length, "Stops and colors must have the same length");
    notifyListeners();
  }

  void insertStop(double stop, int index){
    List<double> newStops = List.filled(stops.length + 1, 0);
    for(int i = 0; i < newStops.length; i++){
      if(i < index){
        newStops[i] = stops[i];
      } else if (i == index){
        newStops[i] = stop;
      } else {
        newStops[i] = stops[i - 1];
      }
    }
    List<Color> newColors = List.filled(colors.length + 1, Colors.white);
    for(int i = 0; i < newColors.length; i++){
      if(i < index){
        newColors[i] = colors[i];
      } else if (i == index){
        newColors[i] = Colors.blue;
      } else {
        newColors[i] = colors[i - 1];
      }
    }
    colors = newColors;
    stops = newStops;
    assert(stops.length == colors.length, "Stops and colors must have the same length");
    notifyListeners();
  }

  Paint rebuildShaderPaint(Paint paint, Matrix4 zoomTransform){
    paint.shader = build();
    return paint;
  }

  void updateShaderOffsetWhenCPMoved({Rect? boundingRect, Map<String, dynamic>? args}){
    if(args != null && args.containsKey("translate")){
      Offset delta = args["translate"];
      center = center != null ? center! + delta : null;
      from = from != null ? from! + delta : null;
      to = to != null ? to! + delta : null;
    }
  }

  void updateShader({
    ShaderType? shaderType,
    Offset? centerOffset,
    Offset? fromOffset,
    Offset? toOffset,
    List<Color>? colorsList,
    List<double>? stopsList,
    TileMode? mode,
    double? r,
    Offset? focalOffset,
    double? fRadius,
    double? start,
    double? end,
    Rect? boundingRect,
    bool notify = true,
  }){
    if(shaderType != null){
      type = shaderType;
    }
    if(centerOffset != null){
      center = centerOffset;
    }
    if(fromOffset != null){
      from = fromOffset;
    }
    if(toOffset != null){
      to = toOffset;
    }
    if(colorsList != null){
      colors = colorsList;
    }
    if(stopsList != null){
      stops = stopsList;
    }
    if(mode != null){
      tileMode = mode;
    }
    if(r != null){
      radius = r;
    }
    if(focalOffset != null){
      focal = focalOffset;
    }
    if(fRadius != null){
      focalRadius = fRadius;
    }
    if(start != null){
      startAngle = min(start, endAngle ?? 2 * pi);
    }
    if(end != null){
      endAngle = max(startAngle ?? 0, end);
    }
    if(notify){
      notifyListeners();
    }
  }

  ShaderParameters transformByTranslate(double dx, double dy){
    center = center != null ? center! + Offset(dx, dy) : null;
    from = from != null ? from! + Offset(dx, dy) : null;
    to = to != null ? to! + Offset(dx, dy) : null;
    focal = focal != null ? focal! + Offset(dx, dy) : null;
    return this;
  }

  ShaderParameters transformByRotate(Offset centerOfRotation, double angle){
    center = center != null ? rotate(center!, centerOfRotation, angle) : null;
    from = from != null ? rotate(from!, centerOfRotation, angle) : null;
    to = to != null ? rotate(to!, centerOfRotation, angle) : null;
    focal = focal != null ? rotate(focal!, centerOfRotation, angle) : null;
    return this;
  }

  ShaderParameters transformByHorizontalScale(Offset stationary, double scaleFactor){
    center = center != null ? Offset(stationary.dx + (center!.dx - stationary.dx) * scaleFactor, center!.dy) : null;
    from = from != null ? Offset(stationary.dx + (from!.dx - stationary.dx) * scaleFactor, from!.dy) : null;
    to = to != null ? Offset(stationary.dx + (to!.dx - stationary.dx) * scaleFactor, to!.dy) : null;
    focal = focal != null ? Offset(stationary.dx + (focal!.dx - stationary.dx) * scaleFactor, focal!.dy) : null;
    return this;
  }

  ShaderParameters transformByVerticalScale(Offset stationary, double scaleFactor){
    center = center != null ? Offset(center!.dx, stationary.dy + (center!.dy - stationary.dy) * scaleFactor) : null;
    from = from != null ? Offset(from!.dx, stationary.dy + (from!.dy - stationary.dy) * scaleFactor) : null;
    to = to != null ? Offset(to!.dx, stationary.dy + (to!.dy - stationary.dy) * scaleFactor) : null;
    focal = focal != null ? Offset(focal!.dx, stationary.dy + (focal!.dy - stationary.dy) * scaleFactor) : null;
    return this;
  }

  ShaderParameters transformByScale(Offset stationary, Offset scaleFactor){
    center = center != null ? Offset(stationary.dx + (center!.dx - stationary.dx) * scaleFactor.dx, stationary.dy + (center!.dy - stationary.dy) * scaleFactor.dy) : null;
    from = from != null ? Offset(stationary.dx + (from!.dx - stationary.dx) * scaleFactor.dx, stationary.dy + (from!.dy - stationary.dy) * scaleFactor.dy) : null;
    to = to != null ? Offset(stationary.dx + (to!.dx - stationary.dx) * scaleFactor.dx, stationary.dy + (to!.dy - stationary.dy) * scaleFactor.dy) : null;
    focal = focal != null ? Offset(stationary.dx + (focal!.dx - stationary.dx) * scaleFactor.dx, stationary.dy + (focal!.dy - stationary.dy) * scaleFactor.dy) : null;
    return this;
  }

  ShaderParameters flipHorizontal(Offset centerOfFlip){
    center = center != null ? Offset(centerOfFlip.dx + (centerOfFlip.dx - center!.dx), center!.dy) : null;
    from = from != null ? Offset(centerOfFlip.dx + (centerOfFlip.dx - from!.dx), from!.dy) : null;
    to = to != null ? Offset(centerOfFlip.dx + (centerOfFlip.dx - to!.dx), to!.dy) : null;
    focal = focal != null ? Offset(centerOfFlip.dx + (centerOfFlip.dx - focal!.dx), focal!.dy) : null;
    return this;
  }

  ShaderParameters flipVertical(Offset centerOfFlip){
    center = center != null ? Offset(center!.dx, centerOfFlip.dy + (centerOfFlip.dy - center!.dy)) : null;
    from = from != null ? Offset(from!.dx, centerOfFlip.dy + (centerOfFlip.dy - from!.dy)) : null;
    to = to != null ? Offset(to!.dx, centerOfFlip.dy + (centerOfFlip.dy - to!.dy)) : null;
    focal = focal != null ? Offset(focal!.dx, centerOfFlip.dy + (centerOfFlip.dy - focal!.dy)) : null;
    return this;
  }

  static Shader lerp(ShaderParameters from, ShaderParameters to){
    switch(from.type) {
      case ShaderType.linear:
        return from.build();
      case ShaderType.sweep:
        return from.build();
      case ShaderType.radial:
        return from.build();
      default:
        return from.build();
    }
  }
}