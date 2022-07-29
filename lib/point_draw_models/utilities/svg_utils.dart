import 'package:flutter/material.dart';
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';

bool requireCSS(PointDrawObject object) {

  if (object.shaderType == ShaderType.sweep) {
    return true;
  }
  // TODO: add the other
  return false;
}
String offsetToString(Offset offset) {
  return "${offset.dx},${offset.dy}";
}

String offsetListToString(List<Offset> offsets){
  String offsetsString = "";
  for (Offset offset in offsets) {
    offsetsString += "${offset.dx},${offset.dy} ";
  }
  return offsetsString;
}

String strokePaintToString(bool outlined, Paint? paint, {Map<String, dynamic>? args}){
  if(paint == null || !outlined){
    return "stroke:none";
  }
  if(args?.containsKey("stroke_cap") ?? false){
    // TODO: encode stroke caps
  }
  return "stroke:rgb(${paint.color.red},${paint.color.green},${paint.color.blue});stroke-width:${paint.strokeWidth}";
}

String fillPaintToString(bool filled, Paint? paint, {Map<String, dynamic>? args}) {
  if(paint == null || !filled){
    return "fill:none";
  }
  if (paint.shader == null) {
    return "fill:rgb(${paint.color.red},${paint.color.green},${paint.color.blue})";
  } else {
    return "fill:url('#${args!["shader_id"]}')\" />";
  }
}

String colorToRGB(Color? color) {
  return "rgb(${color?.red},${color?.green},${color?.blue})";
}

String shaderParamToString(ShaderParameters? shaderParameters, String id) {
  String shader = "<defs>\n";
  if (shaderParameters?.type == ShaderType.linear) {
    String linearGradient = "<linearGradient id=\"$id\" gradientUnits=\"userSpaceOnUse\" x1=\"${shaderParameters?.from?.dx}\" y1=\"${shaderParameters?.from?.dy}\" x2=\"${shaderParameters?.to?.dx}\" y2=\"${shaderParameters?.to?.dy}\">";
    String stops = "";
    for (int i = 0; i < (shaderParameters?.stops.length)!; i ++) {
      stops += "\n<stop offset=\"${(shaderParameters?.stops[i])! * 100.0}%\" style=\"stop-color:${colorToRGB(shaderParameters?.colors[i])};stop-opacity:${shaderParameters?.colors[i].opacity}\" />";
    }
    shader += "$linearGradient$stops\n</linearGradient>";
  } else if (shaderParameters?.type == ShaderType.radial) {

    String radialGradient = "<radialGradient id=\"$id\" gradientUnits=\"userSpaceOnUse\" cx=\"${shaderParameters?.center?.dx}\" cy=\"${shaderParameters?.center?.dy}\" r=\"${shaderParameters?.radius}\" >";
    String stops = "";
    for (int i = 0; i < (shaderParameters?.stops.length)!; i ++) {
      stops += "\n<stop offset=\"${(shaderParameters?.stops[i])! * 100.0}%\" style=\"stop-color:${colorToRGB(shaderParameters?.colors[i])};stop-opacity:${shaderParameters?.colors[i].opacity}\" />";
    }
    shader += "$radialGradient$stops\n</radialGradient>";
  } else if (shaderParameters?.type == ShaderType.sweep) {

  }
  shader += "\n</defs>";
  return shader;
}

String rectToString(Rect rect) {
  return "x=\"${rect.topLeft.dx}\" y=\"${rect.topLeft.dy}\" width=\"${rect.width}\" height=\"${rect.height}\"";
}

String generateConicString(Offset center, double width, double height) {
  return "cx=\"${center.dx}\" cy=\"${center.dy}\" rx=\"$width\" ry=\"$height\"";
}