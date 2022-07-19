import 'package:flutter/material.dart';

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

  TextEditingController xController = TextEditingController();
  TextEditingController yController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    EditingMode? currentMode = pointDrawObject?.mode;
    debugPrint("object: $pointDrawObject");
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
                    child: Text("Point draw renderer. Width: $width Height: $height", style: TextStyle(color: Colors.black)),
                  ),
                  Expanded(
                    child: Container()
                  ),
                  MaterialButton(
                    onPressed: (){
                      setState((){
                        if(width < 1200){
                          width += widthIncrementStep;
                        }
                      });
                    },
                    child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text("+ width")
                    ),
                  ),
                  MaterialButton(
                    onPressed: (){
                      setState((){
                        if(width > 800){
                          width -= widthIncrementStep;
                        }
                      });
                    },
                    child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text("- width")
                    ),
                  ),
                  MaterialButton(
                    onPressed: (){
                      setState((){
                        height += heightIncrementStep;
                      });
                    },
                    child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text("+ height")
                    ),
                  ),
                  MaterialButton(
                    onPressed: (){
                      setState((){
                        if(height > 500){
                          height -= heightIncrementStep;
                        }
                      });
                    },
                    child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text("- height")
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10
            ),
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
                          children:[
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              child: const Text("Lines and Curves", style: TextStyle(fontSize: 14, color: Colors.black),),
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
                                NewLineActionButton(stateControl: currentMode == EditingMode.line, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawLine(key: ObjectKey("Arc: "+ generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.line, index);
                                }),
                                NewArcActionButton(stateControl: currentMode == EditingMode.arc, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawArc(key: ObjectKey("Arc: "+ generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.arc, index);
                                }),
                                NewSplineCurveActionButton(stateControl: currentMode == EditingMode.splineCurve, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawSplineCurve(key: ObjectKey("SplineCurve: " + generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.splineCurve, index);
                                }),
                                NewQuadraticBezierActionButton(stateControl: currentMode == EditingMode.quadraticBezier, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawQuadraticBezier(key: ObjectKey("QuadraticBezier: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.quadraticBezier, index);
                                }),
                                NewCubicBezierActionButton(stateControl: currentMode == EditingMode.cubicBezier, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawCubicBezier(key: ObjectKey("CubicBezier: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.cubicBezier, index);
                                }),
                                NewCompositeActionButton(stateControl: currentMode == EditingMode.compositePath, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawComposite(key: ObjectKey("Composite: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.compositePath, index);
                                }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewLoopActionButton(stateControl: currentMode == EditingMode.loop, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawLoop(key: ObjectKey("Loop: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.loop, index);
                                }),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              child: const Text("Shapes", style: TextStyle(fontSize: 14, color: Colors.black),),
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
                                NewTriangleActionButton(stateControl: currentMode == EditingMode.triangle, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawPolygon(sides: 3, mode: EditingMode.triangle, key: ObjectKey("Triangle: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.triangle, index);
                                }),
                                NewRectangleActionButton(stateControl: currentMode == EditingMode.rectangle, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawPolygon(sides: 4, mode: EditingMode.rectangle, key: ObjectKey("Rectangle: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.rectangle, index);
                                }),
                                NewRoundedRectangleActionButton(stateControl: currentMode == EditingMode.roundedRectangle, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawRoundedRectangle(key: ObjectKey("RoundedRectangle: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.roundedRectangle, index);
                                }),
                                NewPentagonActionButton(stateControl: currentMode == EditingMode.pentagon, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawPolygon(sides: 5, mode: EditingMode.pentagon, key: ObjectKey("Pentagon: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.pentagon, index);
                                }),
                                NewPolygonActionButton(stateControl: currentMode == EditingMode.polygon, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawPolygon(key: ObjectKey("Polygon: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.polygon, index);
                                }),
                                NewConicActionButton(stateControl: currentMode == EditingMode.conic, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawConic(key: ObjectKey("Conic: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.conic, index);
                                }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NewStarActionButton(stateControl: currentMode == EditingMode.star, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawStar(key: ObjectKey("Star: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.star, index);
                                }),
                                NewHeartActionButton(stateControl: currentMode == EditingMode.heart, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawHeart(key: ObjectKey("Heart: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.heart, index);
                                }),
                                NewArrowActionButton(stateControl: currentMode == EditingMode.arrow, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawArrow(key: ObjectKey("Arrow: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.arrow, index);
                                }),
                                NewLeafActionButton(stateControl: currentMode == EditingMode.leaf, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawLeaf(key: ObjectKey("Leaf: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.leaf, index);
                                }),
                                NewBlobActionButton(stateControl: currentMode == EditingMode.blob, onPressed: (){
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawBlob(key: ObjectKey("Blob: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.blob, index);
                                }),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                              child: const Text("Miscellaneous", style: TextStyle(fontSize: 14, color: Colors.black),),
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
                                NewDirectedLineActionButton(stateControl: currentMode == EditingMode.directedLine, onPressed: (){
                                  setState((){
                                    pointDrawObject = PointDrawDirectedLine(key: ObjectKey("DirectedLine: "+generateAutoID()));
                                    pointDrawObject!.notifyListeners();
                                  });
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawDirectedLine(key: ObjectKey("DirectedLine: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.directedLine, index);
                                }),
                                NewCurvedDirectedLineActionButton(stateControl: currentMode == EditingMode.curvedDirectedLine, onPressed: (){
                                  setState((){
                                    pointDrawObject = PointDrawCurvedDirectedLine(key: ObjectKey("CurvedDirectedLine: "+generateAutoID()));
                                    pointDrawObject!.notifyListeners();
                                  });
                                  // int index = context.read<PointDrawCollection>().addObject(PointDrawCurvedDirectedLine(key: ObjectKey("CurvedDirectedLine: "+generateAutoID())))!;
                                  // addPointDrawObjectActionSequence(EditingMode.curvedDirectedLine, index);
                                }),
                              ],
                            ),
                            // Container(
                            //   padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                            //   child: const Text("Large Objects", style: TextStyle(fontSize: 14, color: Colors.black),),
                            // ),
                            // const Divider(
                            //   height: 10,
                            //   thickness: 2.0,
                            //   indent: 2.0,
                            // ),
                          ]
                      )
                  ),
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
                      Text("Add control points", style: TextStyle(color: Colors.black),),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text("New control points: (", style: TextStyle(color: Colors.black),),
                          PropertyInputBox(xController, (p0) {
                            // context.read<PointDrawObject>().updateObject((object){
                            //   Offset newOffset = Offset(double.parse(xController.text), points[i].dy);
                            //   object.points[i] = newOffset;
                            //   if(isPathMode(currentMode ?? EditingMode.none)){
                            //     (object as PointDrawPath).updateRDSCPWhenCPMoved(zoomTransform);
                            //   }
                            // });
                            }, (){
                            // setState(() {
                            //   currentPointEditingIndex = null;
                            // });
                          }, const Size(60, 20), focusNode: FocusNode(),
                          ),
                          const Text(", ", style: TextStyle(color: Colors.black)),
                          PropertyInputBox(yController, (p0) {
                            // context.read<PointDrawObject>().updateObject((object){
                            //   Offset newOffset = Offset(object.points[i].dx, double.parse(yController.text));
                            //   object.points[i] = newOffset;
                            //   if(isPathMode(mode)){
                            //     (object as PointDrawPath).updateRDSCPWhenCPMoved(zoomTransform);
                            //   }
                            // });
                            },
                                (){
                              // setState(() {
                              //   currentPointEditingIndex = null;
                              // });
                            }, const Size(60, 24), focusNode: FocusNode(),
                          ),
                          const Text(")", style: TextStyle(color: Colors.black),),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(onPressed: (){
                            if(isNumeric(xController.text) && isNumeric(yController.text)){
                              Offset newCP = Offset(double.parse(xController.text), double.parse(yController.text));
                              pointDrawObject?.addControlPoint(newCP);
                            }
                          },
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: const Text("Add", style: TextStyle(color: Colors.black),),
                            color: Colors.grey,
                            elevation: 10.0,
                          )
                        ],
                      )
                    ],
                  )
                ),
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
                      ChangeNotifierProvider(create: (context) => GridParameters(width, height, (Offset.zero & Size(width, height)).center))
                    ],
                    builder: (context, _){
                      return PointDrawDataTab(
                          0,
                              (i, mode){},
                              (object){
                            setState((){
                              pointDrawObject = null;
                            });
                          },
                              (mat){
                            setState((){
                              pointDrawObject?.flipHorizontal(mat);
                            });
                          },
                              (mat){
                            setState((){
                              pointDrawObject?.flipVertical(mat);
                            });
                          },
                              (){
                            // not implementing here.
                          }
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 10
            ),
            Container(
              width: 1200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(width: 1.0),
              ),
              child: FastDrawWidget(
                  width: width,
                  height: height,
                  drawer: (Canvas canvas, Size size){
                    pointDrawObject?.draw(canvas, 0, zoomTransform: Matrix4.identity());
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
                    child: const Text("SVG Output", style: TextStyle(color: Colors.black)),
                  ),
                  Expanded(
                      child: Container()
                  ),
                ],
              ),
            ),
            Container(
              width: 1200,
              height: height + rendererWindowPadding * 2,
              decoration: BoxDecoration(
                border: Border.all(width: 1.0)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(pointDrawObject?.toSVGElement(pointDrawObject?.key.toString() ?? "",
                  {}).toString() ?? "No point draw object created", ),
            )
          ],
        ),
      ),
    );
  }
}
