import 'package:pointdraw/point_draw_models/point_draw_objects.dart';

import 'dart:html';

class SVGBuilder {
  final double version = 1.0;

  final String docType = "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd";

  int? width;

  int? height;

  SVGBuilder({this.width, this.height, this.title});

  String? title;

  String? desc;

  List<SVGPointDrawElement> canvasElement = [];

  void addSVGElement(PointDrawObject object) {
    // TODO:
  }

//   static PointDrawCollection toPointDraw(){
//     // TODO:
//     return PointDrawCollection();
//   }
}

class SVGPointDrawElement {
  const SVGPointDrawElement({required this.svgContent});
  final String svgContent;

  @override
  String toString() {
    return svgContent;
  }
}
