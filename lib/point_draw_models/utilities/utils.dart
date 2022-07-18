import 'dart:ui' show ImageByteFormat;
import 'dart:math' show Random, max;

import 'package:flutter/cupertino.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart' show textAreaWidthBuffer;
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/utilities/spline_path.dart';

enum EditingMode{
  none, point, line, quadraticBezier, cubicBezier, arc, conic, splineCurve,
  triangle, rectangle, pentagon, polygon, freeDraw, fill, background, group,
  star, heart, arrow, leaf, directedLine, curvedDirectedLine, compositePath,
  wave, roundedRectangle, text, loop, blob, roundedRectangleChatBox, blobChatBox,
  oneDimensional, twoDimensional, bezier, shape, path, object, pathOp,
}

enum ImageFormat{
  png, jpg, bmp, gif
}

ImageByteFormat toImageByteFormat(ImageFormat format){
  switch(format){
    case ImageFormat.png:
      return ImageByteFormat.png;
    case ImageFormat.bmp:
    case ImageFormat.gif:
    case ImageFormat.jpg:
    default:
      return ImageByteFormat.rawRgba;
  }
}

String validNumericChars = "0123456789.";
String validIntChars = "0123456789";

bool isNumeric(String string, {bool allowDecimal = true}){
  if(string == ""){
    return false;
  }
  if(allowDecimal){
    int decimal = 0;
    for(int i = 0; i < string.length; i++){
      if(!validNumericChars.contains(string[i])){
        return false;
      }
      if(string[i] == "."){
        decimal++;
        if(decimal > 1){
          return false;
        }
      }
    }
    return true;
  } else {
    for(int i = 0; i < string.length; i++){
      if(!validIntChars.contains(string[i])){
        return false;
      }
    }
    return true;
  }
}

String toProper(String s){
  s = s.trim();
  if(s.isEmpty){
    return s;
  }
  if(s.length == 1){
    return s.toUpperCase();
  }
  return s.substring(0, 1).toUpperCase() + s.substring(1);
}

double incrementZoomFactor(double factor){
  if(factor == 1){
    return 1.1;
  } else if (factor == 1.1){
    return 1.25;
  } else if (factor == 1.25){
    return 1.5;
  } else if (factor == 1.5){
    return 2.0;
  } else if (factor == 2.0){
    return 2.5;
  } else if (factor == 2.5){
    return 3.0;
  } else if (factor == 3.0){
    return 4.0;
  } else {
    return factor;
  }
}

double decrementZoomFactor(double factor){
  if (factor == 1.1){
    return 1.0;
  } else if(factor == 1.25){
    return 1.1;
  } else if (factor == 1.5){
    return 1.25;
  } else if (factor == 2.0){
    return 1.5;
  } else if (factor == 2.5){
    return 2.0;
  } else if (factor == 3.0){
    return 2.5;
  } else if (factor == 4.0){
    return 3.0;
  } else {
    return factor;
  }
}

String removeInvalidChars(String string){
  String output = "";
  if (string == ""){
    return output;
  } else {
    for(int i = 0; i < string.length; i++){
      if(validNumericChars.contains(string[i])){
        output = output + string[i];
      }
    }
  }
  return output;
}

Offset getTextboxSize(String content, double fontSize){
  List<String> lines = content.split("\n");
  double maxLength = getMaxLength(lines, fontSize);
  return Offset(maxLength + textAreaWidthBuffer, max(lines.length, 3) * fontSize * 1.2);
}

double getMaxLength(List<String> content, double charWidth){
  if (content.isEmpty){
    return 0;
  }
  double maxLength = 0;
  double lineLength;
  for(int i = 0; i < content.length; i++){
    lineLength = getLineLength(content[i], charWidth * 0.46);
    if(lineLength > maxLength){
      maxLength = lineLength;
    }
  }
  return max(100, maxLength);
}

double getLineLength(String content, double charWidth){
  return content.length * charWidth;
}

bool isPathMode(EditingMode mode){
  return mode != EditingMode.none && mode != EditingMode.fill && mode != EditingMode.background && mode != EditingMode.text;
}

bool isShapeMode(EditingMode mode){
  return mode == EditingMode.polygon || mode == EditingMode.triangle || mode == EditingMode.rectangle || mode == EditingMode.pentagon || mode == EditingMode.star;
}

bool isLineOrCurve(EditingMode mode){
  return mode == EditingMode.line || mode == EditingMode.arc || mode == EditingMode.splineCurve || mode == EditingMode.quadraticBezier || mode == EditingMode.cubicBezier;
}

bool requireDataPoint(EditingMode mode){
  return mode == EditingMode.arc || mode == EditingMode.conic;
}

bool validNewPoint(EditingMode mode, List<Offset> activePathPoints, PointDrawObject? object){
  //Unrestricted control points
  switch(mode){
    case EditingMode.splineCurve:
      return true;
    // case EditingMode.quadraticBezier:
    //   return object != null && ((object as PointDrawQuadraticBezier).chained || activePathPoints.length < 3);
    // case EditingMode.cubicBezier:
    //   return object != null && ((object as PointDrawCubicBezier).chained || activePathPoints.length < 4);
    // case EditingMode.line:
    //   return object != null && ((object as PointDrawLine).polygonal || activePathPoints.length < 2);
    case EditingMode.arc:
      return activePathPoints.isEmpty;
    case EditingMode.triangle:
      return activePathPoints.length < 3;
    case EditingMode.rectangle:
      return activePathPoints.length < 2;
    case EditingMode.roundedRectangle:
      return activePathPoints.length < 2;
    case EditingMode.pentagon:
      return activePathPoints.length < 5;
    case EditingMode.polygon:
      return true;
    case EditingMode.conic:
      return activePathPoints.isEmpty;
    case EditingMode.star:
      return activePathPoints.length < 2;
    case EditingMode.heart:
      return activePathPoints.length < 3;
    case EditingMode.leaf:
      return activePathPoints.length < 2;
    case EditingMode.arrow:
      return activePathPoints.length < 2;
    case EditingMode.directedLine:
      return activePathPoints.length < 2;
    case EditingMode.curvedDirectedLine:
      return activePathPoints.length < 2;
    case EditingMode.text:
      return activePathPoints.isEmpty;
    default:
      return true;
  }
}

bool getAnimationEnabledMode(EditingMode mode){
  switch(mode) {
    case EditingMode.line:
    case EditingMode.splineCurve:
    case EditingMode.quadraticBezier:
    case EditingMode.cubicBezier:
    case EditingMode.compositePath:
    case EditingMode.loop:
    case EditingMode.triangle:
    case EditingMode.rectangle:
    case EditingMode.roundedRectangle:
    case EditingMode.pentagon:
    case EditingMode.polygon:
    case EditingMode.star:
    case EditingMode.heart:
    case EditingMode.blob:
      return true;
    default:
      return false;
  }
}

dynamic getNewPointDrawObject(EditingMode mode){
  switch(mode){
    // case EditingMode.line:
    //   return PointDrawLine(key: ObjectKey("Line: "+generateAutoID()));
    // case EditingMode.arc:
    //   return PointDrawArc(key: ObjectKey("Arc: "+generateAutoID()));
    // case EditingMode.splineCurve:
    //   return PointDrawSplineCurve(key: ObjectKey("SplineCurve: "+generateAutoID()));
    // case EditingMode.quadraticBezier:
    //   return PointDrawQuadraticBezier(key: ObjectKey("QuadraticBezier: "+generateAutoID()));
    // case EditingMode.cubicBezier:
    //   return PointDrawCubicBezier(key: ObjectKey("CubicBezier: "+generateAutoID()));
    // case EditingMode.compositePath:
    //   return PointDrawComposite(key: ObjectKey("Composite: "+generateAutoID()));
    // case EditingMode.triangle:
    //   return PointDrawPolygon(sides: 3, mode: EditingMode.triangle, key: ObjectKey("Triangle: "+generateAutoID()));
    // case EditingMode.rectangle:
    //   return PointDrawPolygon(sides: 4, mode: EditingMode.rectangle, key: ObjectKey("Rectangle: "+generateAutoID()));
    // case EditingMode.roundedRectangle:
    //   return PointDrawRoundedRectangle(key: ObjectKey("RoundedRectangle: "+generateAutoID()));
    // case EditingMode.pentagon:
    //   return PointDrawPolygon(sides: 5, mode: EditingMode.pentagon, key: ObjectKey("Pentagon: "+generateAutoID()));
    // case EditingMode.polygon:
    //   return PointDrawPolygon(key: ObjectKey("Polygon: "+generateAutoID()));
    // case EditingMode.conic:
    //   return PointDrawConic(key: ObjectKey("Conic: "+generateAutoID()));
    // case EditingMode.star:
    //   return PointDrawStar(key: ObjectKey("Star: "+generateAutoID()));
    // case EditingMode.heart:
    //   return PointDrawHeart(key: ObjectKey("Heart: "+generateAutoID()));
    // case EditingMode.arrow:
    //   return PointDrawArrow(key: ObjectKey("Arrow: "+generateAutoID()));
    // case EditingMode.leaf:
    //   return PointDrawLeaf(key: ObjectKey("Leaf: "+generateAutoID()));
    // case EditingMode.loop:
    //   return PointDrawLoop(key: ObjectKey("Loop: "+generateAutoID()));
    // case EditingMode.blob:
    //   return PointDrawBlob(key: ObjectKey("Blob: "+generateAutoID()));
    case EditingMode.directedLine:
      return PointDrawDirectedLine(key: ObjectKey("DirectedLine: "+generateAutoID()));
    case EditingMode.curvedDirectedLine:
      return PointDrawCurvedDirectedLine(key: ObjectKey("CurvedDirectedLine: "+generateAutoID()));
    case EditingMode.text:
      return PointDrawText(key: ObjectKey("Text: "+generateAutoID()));
    case EditingMode.freeDraw:
      return FreeDraw(SplinePath([]), key: ObjectKey("Free draw: "+ generateAutoID()));
    case EditingMode.group:
      return PointDrawGroup([], key: ObjectKey("Group: "+generateAutoID()));
    default:
      throw UnimplementedError("Creating new object for $mode not implemented");
  }
}


bool isInteger(String string){
  String digits = "0123456789";
  if(string == "" || string.substring(0,1) == "0"){
    return false;
  }
  for(int i = 0; i < string.length; i++){
    if(!digits.contains(string[i])){
      return false;
    }
  }
  return true;
}

Color? colorInput(String? input){
  if (input?.length != 8 || input == null){
    return null;
  }
  try {
    int a = int.parse(input.substring(0,2), radix: 16);
    int r = int.parse(input.substring(2,4), radix: 16);
    int g = int.parse(input.substring(4,6), radix: 16);
    int b = int.parse(input.substring(6,8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  } catch (e){
    debugPrint("Error parsing color input. $e");
    return null;
  }
}

enum DrawAction{
  // General curve editing actions
  duplicateCurve, deleteCurve,
  // Non-free-draw curve editing actions
  transformControlPoints, addControlPoint, deleteControlPoint,
  // Free-draw curve editing actions
  addFreeDraw, transformFreeDraw, addText, addPointDraw,
  // General editing actions,
  changeBackgroundProperty, groupObjects, unGroupObjects, clipObjects, removeClipObjects,
  // Paint editing actions,
  changePaintColor, changePaintStrokeWidth, changePaintShader, changeFillColor,
  // Objects attributes
  changeProperty,
  // Collection action
  reorder, groupDelete, groupAdd,
}

enum TransformCurve{
  translate, rotate, flipHorizontal, flipVertical, scaleHorizontal, scaleVertical, scale, skew, none, moveControlPoint, moveRestrictedControlPoint, moveDataControlPoint, moveShaderCenter, moveShaderFrom, moveShaderTo,
}

const int idLength = 28;

var rand = Random(int.parse((DateTime.now().millisecondsSinceEpoch % 314159265358979328).toString()));

bool noCapitalOrSmallLetterOrNumber(String pw) {
  String capitalLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String smallLetters = "abcdefghijklmnopqrstuvwxyz";
  String numbers = "0123456789";
  int length = pw.length;
  bool containCapital = false;
  bool containSmallLetter = false;
  bool containNumber = false;
  for (int index = 0; index < length; index++) {
    if (capitalLetters.contains(pw[index])){
      containCapital = true;
    }
    if (smallLetters.contains(pw[index])){
      containSmallLetter = true;
    }
    if(numbers.contains(pw[index])) {
      containNumber = true;
    }
  }
  return !containCapital && !containSmallLetter && !containNumber;
}

bool notValidPassword(String pw) {
  if (pw.length < 8 || noCapitalOrSmallLetterOrNumber(pw)) {
    return true;
  }
  return false;
}

String generateAutoID(){
  const baseString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  int baseStringLength = baseString.length;
  String outputString = "";
  for (int i = 0; i < idLength ; i++) {
    outputString += baseString[rand.nextInt(baseStringLength)];
  }
  return outputString;
}

String getDateString(DateTime dateTime){
  return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
}

String ensureDoubleChar(String str){
  assert(str.length <= 2, "Only use ensureDoubleChar method on time parameters");
  return str.length == 1 ? "0" + str : (str.isEmpty ? "00" : str);
}

String getTimeString(DateTime dateTime){
  return "${ensureDoubleChar(dateTime.hour.toString())}:${ensureDoubleChar(dateTime.minute.toString())}";
}

enum LoginStatus{loggedIn, loggedOut, loginSuccess, loginSuccessAndCreatingAccount, loginFailed, logoutSuccess, logoutFailed, reauthenticateSuccess, reauthenticateFailed, emailUnverified}

List<int> shuffle(List<int> range){
  List<int> output = [];
  List<int> input = List.from(range);
  for(int i in range){
    output.add(input.removeAt(rand.nextInt(input.length)));
  }
  return output;
}

MouseCursor getMouseCursor(bool shiftKeyPressed, bool hasPendingOffset){
  if(shiftKeyPressed && hasPendingOffset){
    return SystemMouseCursors.grabbing;
  } else if(shiftKeyPressed){
    return SystemMouseCursors.grab;
  } else {
    return SystemMouseCursors.basic;
  }
}

enum SubscriptionType{free, standard, premium, business, student,}

enum PaymentScheme{free, monthly, annually, perpetual}

enum PaymentStatus{paid, pending, canceled, none}

enum ProductItem{
  studentPlanYearly, standardPlanMonthly, standardPlanYearly, standardPlanPerpetual, premiumPlanMonthly, premiumPlanYearly, premiumPlanPerpetual, none
}

FontWeight getFontWeight(int index){
  return FontWeight.values.firstWhere((element) => element.index == index, orElse: () => FontWeight.normal);
}

TextDirection getTextDirection(String name){
  return TextDirection.values.firstWhere((element) => element.name == name, orElse: () => TextDirection.ltr);
}

TextAlign getTextAlign(String name){
  return TextAlign.values.firstWhere((element) => element.name == name, orElse: () => TextAlign.start);
}

ShaderType getShaderType(String name){
  return ShaderType.values.firstWhere((element) => element.name == name, orElse: () => ShaderType.linear);
}

TileMode getTileMode(String name){
  return TileMode.values.firstWhere((element) => element.name == name, orElse: () => TileMode.clamp);
}

EditingMode getEditingMode(String modeString){
  return EditingMode.values.firstWhere((element) => element.name == modeString);
}

BlurStyle getBlurStyle(String name){
  return BlurStyle.values.firstWhere((element) => element.name == name, orElse: () => BlurStyle.normal);
}

SplineEffects getSplineEffect(String name){
  return SplineEffects.values.firstWhere((element) => element.name == name, orElse: () => SplineEffects.normal);
}

SubscriptionType getSubscriptionType(String name){
  return SubscriptionType.values.firstWhere((element) => element.name == name, orElse: () => SubscriptionType.free);
}

PaymentScheme getPaymentScheme(String name){
  return PaymentScheme.values.firstWhere((element) => element.name == name, orElse: () => PaymentScheme.free);
}

PathOperation getPathOperation(String name){
  return PathOperation.values.firstWhere((element) => element.name == name, orElse: () => PathOperation.union);
}

PaymentStatus getPaymentStatus(String name){
  return PaymentStatus.values.firstWhere((element) => element.name == name, orElse: () => PaymentStatus.none);
}

ProductItem getProductItem(String name){
  return ProductItem.values.firstWhere((element) => element.name == name, orElse: () => ProductItem.none);
}
