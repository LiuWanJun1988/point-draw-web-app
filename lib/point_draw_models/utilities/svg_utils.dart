import 'package:flutter/material.dart';


String offsetToString(Offset offset){
  return "${offset.dx} ${offset.dy}";
}

String strokePaintToString(Paint? paint){
  if(paint == null){
    return "stroke=none";
  }
  return "stroke=\"\" "
      "stroke-width=\"\"";
}

String fillPaintToString(Paint paint){
  return "";
}