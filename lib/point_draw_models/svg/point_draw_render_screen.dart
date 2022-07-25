import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:js' as js;

import 'package:pointdraw/point_draw_models/app_components/action_button.dart';
import 'package:pointdraw/point_draw_models/app_components/property_controller.dart';
import 'package:pointdraw/point_draw_models/grid_parameters.dart';
import 'package:pointdraw/point_draw_models/svg/svg_builder.dart';
import 'package:pointdraw/point_draw_models/utilities/fast_draw.dart';
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/svg/point_draw_editor.dart';
import 'package:provider/provider.dart';

import '../utilities/utils.dart';

class PointDrawRenderScreen extends StatefulWidget {
  final SVGBuilder builder = SVGBuilder();

  PointDrawRenderScreen({Key? key}) : super(key: key);

  @override
  State<PointDrawRenderScreen> createState() => _PointDrawRenderScreenState();
}

double rendererWindowPadding = 10;
double widthIncrementStep = 20;
double heightIncrementStep = 20;

class _PointDrawRenderScreenState extends State<PointDrawRenderScreen> {
  double width = 800;
  double height = 500;

  PointDrawObject? pointDrawObject;

  ui.Picture? picture;

  TextEditingController xController = TextEditingController();
  TextEditingController yController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    EditingMode? currentMode = pointDrawObject?.mode;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              width: 1200,
              height: 50,
              padding: EdgeInsets.symmetric(vertical: rendererWindowPadding),
              decoration: BoxDecoration(
                border: Border.all(width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 30,
                    child: Text(
                        "Point draw renderer. Width: $width Height: $height",
                        style: TextStyle(color: Colors.black)),
                  ),
                  Expanded(child: Container()),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        if (width < 1200) {
                          width += widthIncrementStep;
                        }
                      });
                    },
                    child: const SizedBox(
                        width: 100, height: 30, child: Text("+ width")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        if (width > 800) {
                          width -= widthIncrementStep;
                        }
                      });
                    },
                    child: const SizedBox(
                        width: 100, height: 30, child: Text("- width")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        height += heightIncrementStep;
                      });
                    },
                    child: const SizedBox(
                        width: 100, height: 30, child: Text("+ height")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        if (height > 500) {
                          height -= heightIncrementStep;
                        }
                      });
                    },
                    child: const SizedBox(
                        width: 100, height: 30, child: Text("- height")),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      elevation: 6.0,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              child: const Text(
                                "Lines and Curves",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                            const Divider(
                              height: 10,
                              thickness: 2.0,
                              indent: 2.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewLineActionButton(
                                    stateControl:
                                        currentMode == EditingMode.line,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawLine(
                                            key: ObjectKey(
                                                "Line: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewArcActionButton(
                                    stateControl:
                                        currentMode == EditingMode.arc,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawArc(
                                            key: ObjectKey(
                                                "Arc: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewSplineCurveActionButton(
                                    stateControl:
                                        currentMode == EditingMode.splineCurve,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawSplineCurve(
                                            key: ObjectKey("SplineCurve: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewQuadraticBezierActionButton(
                                    stateControl: currentMode ==
                                        EditingMode.quadraticBezier,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject =
                                            PointDrawQuadraticBezier(
                                                key: ObjectKey(
                                                    "QuadraticBezier: " +
                                                        generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewCubicBezierActionButton(
                                    stateControl:
                                        currentMode == EditingMode.cubicBezier,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawCubicBezier(
                                            key: ObjectKey("CubicBezier: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewCompositeActionButton(
                                    stateControl: currentMode ==
                                        EditingMode.compositePath,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawComposite(
                                            key: ObjectKey("Composite: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewLoopActionButton(
                                    stateControl:
                                        currentMode == EditingMode.loop,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawLoop(
                                            key: ObjectKey(
                                                "Loop: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              child: const Text(
                                "Shapes",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                            const Divider(
                              height: 10,
                              thickness: 2.0,
                              indent: 2.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewTriangleActionButton(
                                    stateControl:
                                        currentMode == EditingMode.triangle,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawPolygon(
                                            sides: 3,
                                            mode: EditingMode.triangle,
                                            key: ObjectKey("Triangle: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewRectangleActionButton(
                                    stateControl:
                                        currentMode == EditingMode.rectangle,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawPolygon(
                                            sides: 4,
                                            mode: EditingMode.rectangle,
                                            key: ObjectKey("Rectangle: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewRoundedRectangleActionButton(
                                    stateControl: currentMode ==
                                        EditingMode.roundedRectangle,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject =
                                            PointDrawRoundedRectangle(
                                                key: ObjectKey(
                                                    "RoundedRectangle: " +
                                                        generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewPentagonActionButton(
                                    stateControl:
                                        currentMode == EditingMode.pentagon,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawPolygon(
                                            sides: 5,
                                            mode: EditingMode.pentagon,
                                            key: ObjectKey("Pentagon: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewPolygonActionButton(
                                    stateControl:
                                        currentMode == EditingMode.polygon,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawPolygon(
                                            key: ObjectKey("Polygon: " +
                                                generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewConicActionButton(
                                    stateControl:
                                        currentMode == EditingMode.conic,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawConic(
                                            key: ObjectKey(
                                                "Conic: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewStarActionButton(
                                    stateControl:
                                        currentMode == EditingMode.star,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawStar(
                                            key: ObjectKey(
                                                "Star: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewHeartActionButton(
                                    stateControl:
                                        currentMode == EditingMode.heart,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawHeart(
                                            key: ObjectKey(
                                                "Heart: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewArrowActionButton(
                                    stateControl:
                                        currentMode == EditingMode.arrow,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawArrow(
                                            key: ObjectKey(
                                                "Arrow: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewLeafActionButton(
                                    stateControl:
                                        currentMode == EditingMode.leaf,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawLeaf(
                                            key: ObjectKey(
                                                "Leaf: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewBlobActionButton(
                                    stateControl:
                                        currentMode == EditingMode.blob,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawBlob(
                                            key: ObjectKey(
                                                "Blob: " + generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              child: const Text(
                                "Miscellaneous",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                            const Divider(
                              height: 10,
                              thickness: 2.0,
                              indent: 2.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewDirectedLineActionButton(
                                    stateControl:
                                        currentMode == EditingMode.directedLine,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject = PointDrawDirectedLine(
                                            key: ObjectKey("DirectedLine: ${generateAutoID()}"));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                                NewCurvedDirectedLineActionButton(
                                    stateControl: currentMode ==
                                        EditingMode.curvedDirectedLine,
                                    onPressed: () {
                                      setState(() {
                                        pointDrawObject =
                                            PointDrawCurvedDirectedLine(
                                                key: ObjectKey(
                                                    "CurvedDirectedLine: " +
                                                        generateAutoID()));
                                        pointDrawObject!.notifyListeners();
                                      });
                                    }),
                              ],
                            ),
                          ])),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                    width: 300,
                    constraints: BoxConstraints(minHeight: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add control points",
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              "New control points: (",
                              style: TextStyle(color: Colors.black),
                            ),
                            PropertyInputBox(
                              xController,
                              (p0) {
                                // context.read<PointDrawObject>().updateObject((object){
                                //   Offset newOffset = Offset(double.parse(xController.text), points[i].dy);
                                //   object.points[i] = newOffset;
                                //   if(isPathMode(currentMode ?? EditingMode.none)){
                                //     (object as PointDrawPath).updateRDSCPWhenCPMoved(zoomTransform);
                                //   }
                                // });
                              },
                              () {
                                // setState(() {
                                //   currentPointEditingIndex = null;
                                // });
                              },
                              const Size(60, 20),
                              focusNode: FocusNode(),
                            ),
                            const Text(", ",
                                style: TextStyle(color: Colors.black)),
                            PropertyInputBox(
                              yController,
                              (p0) {
                                // context.read<PointDrawObject>().updateObject((object){
                                //   Offset newOffset = Offset(object.points[i].dx, double.parse(yController.text));
                                //   object.points[i] = newOffset;
                                //   if(isPathMode(mode)){
                                //     (object as PointDrawPath).updateRDSCPWhenCPMoved(zoomTransform);
                                //   }
                                // });
                              },
                              () {
                                // setState(() {
                                //   currentPointEditingIndex = null;
                                // });
                              },
                              const Size(60, 24),
                              focusNode: FocusNode(),
                            ),
                            const Text(
                              ")",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                if (isNumeric(xController.text) &&
                                    isNumeric(yController.text)) {
                                  Offset newCP = Offset(
                                      double.parse(xController.text),
                                      double.parse(yController.text));
                                  pointDrawObject?.addControlPoint(newCP);
                                  setState(() {});
                                }
                              },
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              color: Colors.grey,
                              elevation: 10.0,
                              child: const Text(
                                "Add",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        )
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                    minHeight: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0),
                  ),
                  child: MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: pointDrawObject,
                      ),
                      ChangeNotifierProvider(
                          create: (context) => GridParameters(width, height,
                              (Offset.zero & Size(width, height)).center))
                    ],
                    builder: (context, _) {
                      return PointDrawDataTab(0, (i, mode) {}, (object) {
                        setState(() {
                          pointDrawObject = null;
                        });
                      }, (mat) {
                        setState(() {
                          pointDrawObject?.flipHorizontal(mat);
                        });
                      }, (mat) {
                        setState(() {
                          pointDrawObject?.flipVertical(mat);
                        });
                      }, () {
                        // not implementing here.
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: 1200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(width: 1.0),
              ),
              child: FastDrawWidget(
                  width: width,
                  height: height,
                  drawer: (Canvas canvas, Size size) {
                    pointDrawObject?.draw(canvas, 0,
                        zoomTransform: Matrix4.identity());
                  }),
            ),
            Container(
              width: 1200,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 30,
                    child: const Text("SVG Output",
                        style: TextStyle(color: Colors.black)),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            Container(
              width: 1200,
              height: 300 + rendererWindowPadding * 2,
              decoration: BoxDecoration(border: Border.all(width: 1.0)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Builder(builder: (context) {
                String? svgString;
                try {
                  svgString = pointDrawObject?.toSVGElement(
                      pointDrawObject?.key.toString() ?? "", {}).toString();
                } catch (e) {
                  svgString = null;
                }
                return Text(
                  svgString ?? "No point draw object created",
                  style: const TextStyle(color: Colors.black),
                );
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: picture != null
                      ? () async {
                          await saveToFile(
                                  picture!, width.round(), height.round(),
                                  format: OutputFormat.svg)
                              .catchError((error) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    title: Text(
                                        "Cannot save to file. Error: $error"),
                                  );
                                });
                          });
                        }
                      : null,
                  color: Colors.grey,
                  child: const Text("Save as",
                      style: TextStyle(color: Colors.black)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveToFile(ui.Picture picture, int width, int height,
      {OutputFormat format = OutputFormat.png}) async {
    ui.Image img = await picture.toImage(width, height);
    ByteData? documentBytes;
    if (format == OutputFormat.png || format == OutputFormat.bmp) {
      documentBytes = await img.toByteData(format: toImageByteFormat(format));
    } else if (format == OutputFormat.svg) {
      var st = pointDrawObject
          ?.toSVGElement(
              pointDrawObject?.key.value.toString() ?? generateAutoID(), {})
          .toString()
          .codeUnits;
      documentBytes = ByteData(st?.length ?? 0);
    } else {
      documentBytes = await encodeAs(img, format, width, height);
    }
    if (documentBytes != null) {
      var outcome = await js.context.callMethod('saveFile', [documentBytes]);
    }
  }

  Future<ByteData?> encodeAs(
      ui.Image image, OutputFormat format, int width, int height) async {
    return Uint8List(0).buffer.asByteData();
  }
}
