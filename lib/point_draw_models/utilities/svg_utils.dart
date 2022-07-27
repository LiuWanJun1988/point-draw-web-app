import 'package:flutter/material.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';

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

String strokePaintToString(Paint? paint){
  if(paint == null){
    return "stroke:none";
  }
  return "stroke:rgb(${paint.color.red},${paint.color.green},${paint.color.blue});stroke-width:${paint.strokeWidth}";
}

String fillPaintToString(Paint? paint) {
  if(paint == null){
    return "fill:none";
  }

  if (paint.shader == null) {
    return "fill:rgb(${paint.color.red},${paint.color.green},${paint.color.blue})";
  }

  return "";
}

String colorToRGB(Color? color) {
  return "rgb(${color?.red},${color?.green},${color?.blue})";
}

String shaderParamToString(ShaderParameters? shaderParameters, String id) {
  String shader = "<defs>\n";
  if (shaderParameters?.type == ShaderType.linear) {
    String linearGradient = "<linearGradient id=\"$id\">";
    String stops = "";
    for (int i = 0; i < (shaderParameters?.stops.length)!; i ++) {
      stops += "\n<stop offset=\"${(shaderParameters?.stops[i])! * 100.0}%\" style=\"stop-color:${colorToRGB(shaderParameters?.colors[i])};stop-opacity:${shaderParameters?.colors[i].opacity}\" />";
    }
    shader += "$linearGradient$stops\n</linearGradient>";
  } else if (shaderParameters?.type == ShaderType.radial) {
    String radialGradient = "<radialGradient id=\"$id\" cx=\"${shaderParameters?.center?.dx}\" cy=\"${shaderParameters?.center?.dy}\" r=\"${shaderParameters?.radius}\" >";
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