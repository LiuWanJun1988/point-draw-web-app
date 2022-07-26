import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointdraw/point_draw_models/utilities/svg_utils.dart';
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';

import 'dart:html';

class SVGBuilder {
  final double xmlVersion = 1.0;

  final double svgVersion = 1.1;

  final String docType = "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd";

  SVGBuilder();

  String? title;

  String? desc;

  List<SVGPointDrawElement> canvasElements = [];

  void addSVGElement(PointDrawObject object, Map<String, dynamic> attributes) {
    canvasElements.add(object.toSVGElement(object.key.toString(), attributes));
  }

  String output = "";

  void build(int width, int height, Rect canvasRect){
    output = "";
    insertXMLVersion();
    insertSVGVersion();
    insertSVGOpeningTag(width, height, canvasRect);
    insertTitleTag();
    insertDescTag();
    buildDefinitions();
    buildSVGElements();
    insertSVGCloseTag();
  }

  void insertXMLVersion(){
    output += "<?xml version=\"${xmlVersion.toStringAsFixed(1)}\"?>\n";
  }

  void insertSVGVersion(){
    output += "<!DOCTYPE svg PUBLIC \"-//W3C//DTD "
        "SVG ${svgVersion.toStringAsFixed(1)}//EN\" \"$docType\">\n";
  }

  void insertSVGOpeningTag(int width, int height, Rect canvasRect){
    output += "<svg width=\"${width}\" height=\"${height}\" viewBox="
        "\"${offsetToString(canvasRect.topLeft)} ${offsetToString(canvasRect.bottomRight)}\" "
        "xmlns=\"http://www.w3.org/2000/svg\" "
        "version=\"${svgVersion.toStringAsFixed(1)}\">\n";
  }

  void insertTitleTag(){
    output += "<title>${title ?? ''}</title>\n";
  }

  void insertDescTag(){
    output += "<desc>${desc ?? ''}</desc>\n";
  }

  void buildDefinitions(){
    // TODO:
  }

  void buildSVGElements(){
    output += "\n\n";
    for(SVGPointDrawElement svgElement in canvasElements){
      output += svgElement.svgContent;
    }
    output += "\n\n";
  }

  void insertSVGCloseTag(){
    output += "</svg>";
  }

  ByteData? toByteData(int width, int height, Rect canvasRect){
    build(width, height, canvasRect);
    List<int> stringCodes = output.codeUnits;
    Uint8List uCodes = Uint8List.fromList(stringCodes);
    return uCodes.buffer.asByteData();
  }
}

class SVGPointDrawElement {
  const SVGPointDrawElement({required this.svgContent});
  final String svgContent;

  @override
  String toString() {
    return svgContent;
  }
}
