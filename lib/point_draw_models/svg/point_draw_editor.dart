import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:math';

import 'package:pointdraw/point_draw_models/app_components/radian_sweeper.dart';
import 'package:pointdraw/point_draw_models/app_components/color_stops_bar.dart';
import 'package:pointdraw/point_draw_models/app_components/section_tab.dart';
import 'package:pointdraw/point_draw_models/app_components/action_button.dart';
import 'package:pointdraw/point_draw_models/app_components/function_button.dart';
import 'package:pointdraw/point_draw_models/app_components/color_tab.dart';
import 'package:pointdraw/point_draw_models/app_components/icon_sketch.dart';
import 'package:pointdraw/point_draw_models/app_components/property_controller.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/grid_parameters.dart';
// import 'package:pointdraw/point_draw_models/effects_parameters.dart';

class PointDrawDataTab extends StatefulWidget {

  final int indexOfObject;
  final void Function(int, EditingMode) activatePath;
  final void Function(PointDrawObject) deleteObject;
  final void Function(Matrix4) flipHorizontal;
  final void Function(Matrix4) flipVertical;
  final void Function() duplicate;
  final String? mode;

  const PointDrawDataTab(this.indexOfObject, this.activatePath, this.deleteObject, this.flipHorizontal, this.flipVertical, this.duplicate, {this.mode, Key? key}) : super(key: key);

  @override
  State<PointDrawDataTab> createState(){
    return _PointDrawDataTabState();
  }
}

class _PointDrawDataTabState extends State<PointDrawDataTab> {

  late bool useShader;
  late ShaderType shaderType;

  double radialMultiplier = 1.0;

  List<TextEditingController> shaderColorController = [
    TextEditingController(text: Colors.white.value.toRadixString(16)),
    TextEditingController(text: Colors.blue.value.toRadixString(16)),
  ];

  TextEditingController sColorController = TextEditingController(text: Colors.blue.value.toRadixString(16));
  TextEditingController fColorController = TextEditingController(text: Colors.blue.value.toRadixString(16));

  int? currentPointEditingIndex;
  int? currentRestrictedPointEditingIndex;
  int? currentDataPointEditingIndex;

  FocusNode xEditingFocusNode = FocusNode();
  FocusNode yEditingFocusNode = FocusNode();
  bool sColorInputError = false;
  bool fColorInputError = false;
  TextEditingController xController = TextEditingController();
  TextEditingController yController = TextEditingController();

  bool showStrokeColorSelector = false;
  bool showFillColorSelector = false;
  bool showShaderColorSelector = false;
  bool showDetails = false;
  bool showControlPoints = false;
  bool showPaintParameters = false;
  bool showGlowParameters = false;

  int? shadeColorIndex;

  // ClipObject newClippingObject = ClipObject();

  void cancelEditing(){
    setState((){
      currentPointEditingIndex = null;
      currentRestrictedPointEditingIndex = null;
      currentDataPointEditingIndex = null;
    });
  }

  @override
  void dispose(){
    // widget.object.markForRemoval = true;
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    useShader = Provider.of<PointDrawObject?>(context, listen: false)?.useShader ?? false;
    if(useShader){
      shaderType = Provider.of<PointDrawObject?>(context, listen: false)?.shaderParam?.type ?? ShaderType.linear;
    } else {
      shaderType = ShaderType.linear;
    }
    xEditingFocusNode.addListener((){
      if(!xEditingFocusNode.hasFocus){
        cancelEditing();
      }
    });
    yEditingFocusNode.addListener((){
      if(!yEditingFocusNode.hasFocus){
        cancelEditing();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      debugPrint("Inside tab. Object: ${context.watch<PointDrawObject?>()}");
      Matrix4 zoomTransform = context.watch<GridParameters>().zoomTransform;
      sColorController.text = context.watch<PointDrawObject?>()?.sPaint.color.value.toRadixString(16) ?? "";
      fColorController.text = context.watch<PointDrawObject?>()?.fPaint.color.value.toRadixString(16) ?? "";
      Color sColor = context.watch<PointDrawObject?>()?.sPaint.color ?? Colors.blue;
      Color fColor = context.watch<PointDrawObject?>()?.fPaint.color ?? Colors.blue;
      bool isOutlined = context.watch<PointDrawObject?>()?.outlined ?? false;
      double strokeThickness = context.watch<PointDrawObject?>()?.sPaint.strokeWidth ?? 1.0;
      bool isFilled = context.watch<PointDrawObject?>()?.filled ?? false;
      useShader = context.watch<PointDrawObject?>()?.useShader ?? false;
      ShaderType shaderType = useShader ? (context.watch<PointDrawObject?>()?.shaderType ?? ShaderType.linear) : ShaderType.linear;
      bool active = context.watch<PointDrawObject?>()?.active ?? false;
      EditingMode mode = context.watch<PointDrawObject?>()?.mode ?? EditingMode.none;
      List<Offset> points = context.watch<PointDrawObject?>()?.points ?? [];
      List<Offset> rPoints = context.watch<PointDrawObject?>()?.rPoints ?? [];
      List<Offset> dPoints = context.watch<PointDrawObject?>()?.dPoints ?? [];
      String label = context.watch<PointDrawObject?>()?.toString() ?? "None";
      List<Widget> supplementaryPropertiesModifiers = [
        for(Widget Function() widgetBuilder in context.watch<PointDrawObject?>()?.supplementaryPropertiesModifiers ?? [])
          widgetBuilder.call(),
      ];
      bool enableDeleteControlPoint = context.watch<PointDrawObject?>()?.enableDeleteControlPoint ?? false;
      // bool hasGlow = false;
      // double glowRatio = 0.0;
      // BlurStyle blurStyle = BlurStyle.normal;
      // if((context.read<PointDrawObject>() is PointDrawTwoDimensional) && (context.read<PointDrawObject>() as PointDrawTwoDimensional).glowRadius != 0.0){
      //   hasGlow = true;
      //   glowRatio = (context.watch<PointDrawObject>() as PointDrawTwoDimensional).glowRatio;
      //   blurStyle = (context.watch<PointDrawObject>() as PointDrawTwoDimensional).blurStyle;
      // }
      // bool hasRoundedCorners = false;
      // double roundingFactor = 0.0;
      // if(context.read<PointDrawObject>() is PointDrawStraightEdgedShape){
      //   hasRoundedCorners = (context.watch<PointDrawObject>() as PointDrawStraightEdgedShape).roundCorners;
      //   roundingFactor = (context.watch<PointDrawObject>() as PointDrawStraightEdgedShape).roundingFactor;
      // }
      TextStyle radioLabelStyle = TextStyle(fontSize: 10, color: useShader ? Colors.black : Colors.grey[200]);
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: MaterialButton(
          onPressed:(){
            // widget.activatePath(widget.indexOfObject, mode);
          },
          shape: const ContinuousRectangleBorder(
            side: BorderSide(width: 0.5, color: Colors.indigo),
          ),
          color: active ? Colors.grey : Colors.grey[300],
          elevation: defaultPanelElevation,
          padding: const EdgeInsets.all(10.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Padding(
                  padding: interLineEdgeInsets,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          alignment: Alignment.centerLeft,
                          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                      ),
                      Expanded(
                        child:Container(),
                      ),
                      FunctionButton(
                        showButton: mode != EditingMode.text,
                        onPressed: (){
                          widget.flipVertical.call(zoomTransform);
                        },
                        toolTip: "Flip vertical",
                        primaryStateWidget: const FlipVerticalIcon(widthSize: 20),),
                      FunctionButton(
                        showButton: mode != EditingMode.text,
                        onPressed: (){
                          widget.flipHorizontal.call(zoomTransform);
                        },
                        toolTip: "Flip horizontal",
                        primaryStateWidget: const FlipHorizontalIcon(widthSize: 20),),
                      FunctionButton(
                        onPressed: widget.duplicate,
                        toolTip: "Duplicate",
                        primaryStateWidget: const Icon(Icons.copy, size: 12, color: Colors.white),
                      ),
                      FunctionButton(
                        onPressed: toggleShowDetails,
                        toolTip: "Show details",
                        primaryState: showDetails,
                      ),
                      FunctionButton(
                        onPressed: (){
                          deleteObject.call(0);
                        },
                        toolTip: "Delete",
                        primaryStateWidget: const Icon(Icons.delete, size:14, color: Colors.white),
                      )
                    ],
                  ),
                ),
                if(showDetails)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 5.0,
                        children: [
                          for(Widget widget in supplementaryPropertiesModifiers)
                            widget,
                        ],
                      ),
                      if(mode != EditingMode.freeDraw)
                        SectionTab(
                            tabName: "Control point",
                            builder: (context){
                              // List<int> animatedPointsList = context.watch<AnimationParams>().animatedControlPoints.keys.toList();
                              Size animationButtonSize = const Size(24, 24);
                              debugPrint("Building control points section tab. ${context.watch<PointDrawObject?>()?.points}");
                              return ConstrainedBox(
                                constraints: BoxConstraints.loose(const Size(300, 100)),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  controller: ScrollController(),
                                  child: Column(
                                      children: [
                                        for(int i = 0;i < points.length; i++)
                                          Padding(
                                            padding: interLineEdgeInsets,
                                            child: MaterialButton(
                                              onPressed: (){
                                                if(currentPointEditingIndex != i){
                                                  setState(() {
                                                    currentPointEditingIndex = i;
                                                    currentRestrictedPointEditingIndex = null;
                                                    currentDataPointEditingIndex = null;
                                                    xController.text = points[i].dx.toString();
                                                    yController.text = points[i].dy.toString();
                                                  });
                                                } else {
                                                  setState(() {
                                                    currentPointEditingIndex = null;
                                                    currentRestrictedPointEditingIndex = null;
                                                    currentDataPointEditingIndex = null;
                                                    xController.clear();
                                                    yController.clear();
                                                  });
                                                }
                                              },
                                              height: 20.0,
                                              color: Colors.transparent,
                                              padding: EdgeInsets.zero,
                                              elevation: defaultPanelElevation,
                                              hoverElevation: defaultPanelElevation,
                                              hoverColor: Colors.grey[100],
                                              highlightColor: Colors.transparent,
                                              highlightElevation: defaultPanelElevation,
                                              focusElevation: defaultPanelElevation,
                                              child: currentPointEditingIndex != i ? Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text("Point ${i + 1}: (${points[i].dx.toStringAsFixed(1)}, ${points[i].dy.toStringAsFixed(1)})", textAlign: TextAlign.left),
                                                    Expanded(
                                                        child: Container()
                                                    ),
                                                    if(enableDeleteControlPoint)
                                                      ActionButton(
                                                        EditingMode.none,
                                                        false,
                                                        displayWidget: const Icon(Icons.remove_circle, size: 16, color: Colors.red),
                                                        onPressed: (){
                                                          // context.read<PointDrawCollection>().addAction(
                                                          //     DeleteControlPointAction(points[i], i, curveIndex: widget.indexOfObject)
                                                          // );
                                                          context.read<PointDrawObject>().deleteControlPoint(i);
                                                        },
                                                        enabled: true,
                                                        size: animationButtonSize,
                                                      ),
                                                  ],
                                                ),
                                              ) : Row(
                                                children: [
                                                  Text("Point ${i + 1}: (",),
                                                  PropertyInputBox(xController, (p0) {
                                                    context.read<PointDrawObject>().updateObject((object){
                                                      Offset newOffset = Offset(double.parse(xController.text), points[i].dy);
                                                      object.points[i] = newOffset;
                                                      if(isPathMode(mode)){
                                                        (object as PointDrawPath).updateRDSCPWhenCPMoved(zoomTransform);
                                                      }
                                                    });}, (){
                                                    setState(() {
                                                      currentPointEditingIndex = null;
                                                    });
                                                  }, const Size(60, 20), focusNode: xEditingFocusNode,
                                                  ),
                                                  const Text(", ",),
                                                  PropertyInputBox(yController, (p0) {
                                                    context.read<PointDrawObject>().updateObject((object){
                                                      Offset newOffset = Offset(object.points[i].dx, double.parse(yController.text));
                                                      object.points[i] = newOffset;
                                                      if(isPathMode(mode)){
                                                        (object as PointDrawPath).updateRDSCPWhenCPMoved(zoomTransform);
                                                      }
                                                    });},
                                                        (){
                                                      setState(() {
                                                        currentPointEditingIndex = null;
                                                      });
                                                    }, const Size(60, 24), focusNode: yEditingFocusNode,
                                                  ),
                                                  const Text(")"),
                                                ],
                                              ),
                                            ),
                                          ),
                                        for(int i = 0; i < rPoints.length; i++)
                                          Container(
                                            padding: const EdgeInsets.only(left: 6.0, bottom: 3.0),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text("Restricted point ${i + 1}: (${rPoints[i].dx.toStringAsFixed(1)}, ${rPoints[i].dy.toStringAsFixed(1)})", textAlign: TextAlign.left),
                                                Expanded(
                                                    child: Container()
                                                ),
                                              ],
                                            ),
                                          ),
                                        for(int i = 0; i < dPoints.length; i++)
                                          Container(
                                            padding: const EdgeInsets.only(left: 6.0, bottom: 3.0),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text("Data point ${i + 1}: (${dPoints[i].dx.toStringAsFixed(1)}, ${dPoints[i].dy.toStringAsFixed(1)})", textAlign: TextAlign.left),
                                                Expanded(
                                                    child: Container()
                                                ),
                                              ],
                                            ),
                                          ),
                                      ]
                                  ),
                                ),
                              );
                            }
                        ),// Control points section tab
                      SectionTab(
                        tabName: "Paint",
                        builder: (context){
                          Color strokeColor = context.watch<PointDrawObject?>()?.sPaint.color ?? Colors.blue;
                          Color fillColor = context.watch<PointDrawObject?>()?.fPaint.color ?? Colors.blue;
                          // Shader? fillShader = context.watch<PointDrawObject?>()?.fPaint.shader;
                          return Column(
                            children: [
                              Padding(
                                padding: interLineEdgeInsets,
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children:[
                                      SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                              value: mode == EditingMode.text ? true : isOutlined,
                                              splashRadius: 0.1,
                                              onChanged: mode == EditingMode.text ? null : (val){
                                                // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.outlined, val, objectIndex: widget.indexOfObject));
                                                context.read<PointDrawObject>().updateStrokePaint(isOutlined: val);
                                              },
                                              shape: const CircleBorder())
                                      ),
                                      Container(
                                          width: 60,
                                          height: 24,
                                          alignment: Alignment.centerLeft,
                                          child: Text(mode == EditingMode.text || mode == EditingMode.freeDraw ? "Color" : "Outline", style: const TextStyle(fontSize:14, color: Colors.black))
                                      ),
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: MaterialButton(
                                          onPressed: (){
                                            setState(() {
                                              showStrokeColorSelector = !showStrokeColorSelector;
                                            });
                                          },
                                          shape: const CircleBorder(),
                                          color: sColor,
                                          elevation: colorSelectorElevation,
                                        ),),
                                      Container(
                                        width: 18,
                                        height: 24,
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.only(left: 10.0),
                                        child: const Text("#:"),
                                      ),
                                      PropertyInputBox(sColorController, (p0) {},
                                            (){
                                          Color? newColor = colorInput(sColorController.text);
                                          if(newColor != null){
                                            if(mode == EditingMode.freeDraw){
                                              // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillColor, sColor, objectIndex: widget.indexOfObject));
                                              context.read<PointDrawObject>().updateFillPaint(zoomTransform,
                                                  color: newColor
                                              );
                                            } else {
                                              // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.strokeColor, sColor, objectIndex: widget.indexOfObject));
                                              context.read<PointDrawObject>().updateStrokePaint(
                                                  color: newColor
                                              );
                                            }
                                          }
                                        }, textFieldSize, focusNode: FocusNode(),
                                      ),
                                      // ColorExtractor(
                                      //     onClick: (){
                                      //       Function? fn = context.read<GridParameters>().enterColorExtractionMode;
                                      //       if(fn != null){
                                      //         fn(toggle: true);
                                      //       }
                                      //     },
                                      //   size: const Size(24, 24),
                                      //   color: const Color.fromARGB(255, 0, 255, 0),
                                      // )
                                    ]
                                ),
                              ),
                              if(showStrokeColorSelector)
                                ColorSelector(
                                  Colors.white,
                                  initialColor: strokeColor,
                                  updateColor: (color){
                                    context.read<PointDrawObject>().updateStrokePaint(color: color);
                                  },
                                  updateActionStack: (){
                                    // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.strokeColor, sColor, objectIndex: widget.indexOfObject));
                                  },
                                ),
                              // PointDrawObjectColorSelector(
                              //   context.read<PointDrawObject>(),
                              //   PaintType.stroke,
                              // ),
                              if(mode != EditingMode.freeDraw)
                                Padding(
                                  padding: interLineEdgeInsets,
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children:[
                                        SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                                value: isFilled,
                                                onChanged: (val){
                                                  // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.filled, val, objectIndex: widget.indexOfObject));
                                                  context.read<PointDrawObject>().updateFillPaint(zoomTransform, isFilled: val);
                                                },
                                                shape: const CircleBorder())
                                        ),
                                        Container(
                                            width: 60,
                                            height: 24,
                                            alignment: Alignment.centerLeft,
                                            child: const Text("Fill", style: TextStyle(fontSize:14, color: Colors.black))
                                        ),
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: MaterialButton(
                                            onPressed: (){
                                              setState(() {
                                                showFillColorSelector = !showFillColorSelector;
                                              });
                                            },
                                            shape: const CircleBorder(),
                                            color: fColor,
                                            elevation: colorSelectorElevation,
                                          ),),
                                        Container(
                                          width: 18,
                                          height: 24,
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.only(left: 10.0),
                                          child: const Text("#:"),
                                        ),
                                        PropertyInputBox(fColorController, (p0) {},
                                              (){
                                            Color? fillColor = colorInput(fColorController.text);
                                            if(fillColor != null){
                                              // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillColor, fColor, objectIndex: widget.indexOfObject));
                                              context.read<PointDrawObject>().updateFillPaint(zoomTransform, color: fillColor);
                                            }
                                          }, textFieldSize, focusNode: FocusNode(),
                                        ),

                                      ]
                                  ),
                                ),
                              if(showFillColorSelector)
                                ColorSelector(
                                    Colors.white,
                                    initialColor: fillColor,
                                    updateColor: (color){
                                      context.read<PointDrawObject>().updateFillPaint(zoomTransform, color: color);
                                    },
                                    updateActionStack: (){
                                      // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillColor, fColor, objectIndex: widget.indexOfObject));
                                    }
                                ),
                              // PointDrawObjectColorSelector(
                              //   context.read<PointDrawObject>(),
                              //   PaintType.fill,
                              // ),
                              if(mode != EditingMode.text)
                                Container(
                                  padding: interLineEdgeInsets,
                                  alignment: Alignment.centerLeft,
                                  child: const Text("Stroke thickness", textAlign: TextAlign.left,),
                                ),
                              if(mode != EditingMode.text)
                                Padding(
                                  padding: interLineEdgeInsets,
                                  child: SizedBox(
                                    height: 35,
                                    child: Slider(
                                      value: strokeThickness,
                                      onChanged: (double val) {
                                        context.read<PointDrawObject>().updateStrokePaint(strokeWidth: val);
                                      },
                                      onChangeStart: (double val){
                                        // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.strokeWidth, val, objectIndex: widget.indexOfObject));
                                      },
                                      min: 1.0,
                                      max: 20.0,
                                      divisions: 190,
                                      label: strokeThickness.toStringAsFixed(3), thumbColor: Colors.indigo,
                                    ),
                                  ),
                                ),
                              if(mode != EditingMode.freeDraw && mode != EditingMode.text)
                                Padding(
                                  padding: interLineEdgeInsets,
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children:[
                                        SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                                value: useShader,
                                                onChanged: isFilled ? (val){
                                                  // Enable use of shader only when fill option is checked
                                                  setState((){
                                                    useShader = !useShader;
                                                  });
                                                  // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                                  context.read<PointDrawObject>().updateFillPaint(zoomTransform, useShader: useShader);
                                                } : null,
                                                shape: const CircleBorder())
                                        ),
                                        Container(
                                            width: 60,
                                            height: 24,
                                            alignment: Alignment.centerLeft,
                                            child: const Text("Shader", style: TextStyle(fontSize:14, color: Colors.black))
                                        ),
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Radio(
                                            groupValue: shaderType,
                                            value: ShaderType.linear,
                                            onChanged: useShader ? (ShaderType? val){
                                              setState(() {
                                                shaderType = ShaderType.linear;
                                              });
                                              Rect bound = context.read<PointDrawObject>().boundingRect;
                                              // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                              context.read<PointDrawObject>().updateFillPaint(zoomTransform, shaderParameters: ShaderParameters(type: ShaderType.linear, boundingRect: bound));
                                            } : null,splashRadius: 0.1,
                                          ),),
                                        SizedBox(
                                            height: 12,
                                            width: 36,
                                            child: Text("Linear", style: radioLabelStyle)
                                        ),
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Radio(
                                            groupValue: shaderType,
                                            value: ShaderType.radial,
                                            onChanged: useShader ? (ShaderType? val){
                                              setState(() {
                                                shaderType = ShaderType.radial;
                                              });
                                              Rect bound = context.read<PointDrawObject>().boundingRect;
                                              // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                              context.read<PointDrawObject>().updateFillPaint(zoomTransform, shaderParameters: ShaderParameters(type: ShaderType.radial, boundingRect: bound));
                                            } : null, splashRadius: 0.1,
                                          ),),
                                        SizedBox(
                                            height: 12,
                                            width: 36,
                                            child: Text("Radial", style: radioLabelStyle)
                                        ),
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Radio(
                                            groupValue: shaderType,
                                            value: ShaderType.sweep,
                                            onChanged: useShader ? (ShaderType? val){
                                              setState(() {
                                                shaderType = ShaderType.sweep;
                                              });
                                              // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                              context.read<PointDrawObject>().updateFillPaint(zoomTransform, shaderParameters: ShaderParameters(type: ShaderType.sweep));
                                            } : null, splashRadius: 0.1,
                                          ),),
                                        SizedBox(
                                            height: 12,
                                            width: 36,
                                            child: Text("Sweep", style: radioLabelStyle)
                                        ),
                                      ]
                                  ),
                                ),
                              if(useShader && isFilled)
                                ChangeNotifierProvider<ShaderParameters?>.value(
                                  value: context.read<PointDrawObject>().shaderParam,
                                  builder:(context, _){
                                    List<Color> colors = context.watch<ShaderParameters?>()?.colors ?? [Colors.white, Colors.blue];
                                    List<double> stops = context.watch<ShaderParameters?>()?.stops ?? [0.0, 1.0];

                                    assert(colors.length == stops.length, "'Colors' length ${colors.length} and 'stops' length ${stops.length} must be the same");
                                    if(shaderColorController.length < stops.length){
                                      shaderColorController.add(TextEditingController());
                                    }
                                    for(int i = 0; i < shaderColorController.length; i++){
                                      shaderColorController[i].text = colors[i].value.toRadixString(16);
                                    }
                                    return SectionTab(
                                      tabName: "Shader",
                                      builder: (context){
                                        return Column(
                                          children: [
                                            if(shaderType == ShaderType.linear)
                                              Padding(
                                                padding: interLineEdgeInsets,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      alignment: Alignment.centerLeft,
                                                      width: 135,
                                                      child: Text("From: (${context.watch<ShaderParameters>().from?.dx.toStringAsFixed(1)}, ${context.watch<ShaderParameters>().from?.dy.toStringAsFixed(1)})", textAlign: TextAlign.left, style: const TextStyle(fontSize:12),),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      alignment: Alignment.centerLeft,
                                                      width: 135,
                                                      child: Text("To: (${context.watch<ShaderParameters>().to?.dx.toStringAsFixed(1)}, ${context.watch<ShaderParameters>().to?.dy.toStringAsFixed(1)})", textAlign: TextAlign.left, style: const TextStyle(fontSize:12),),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if(shaderType == ShaderType.radial || shaderType == ShaderType.sweep)
                                              Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 3.0),
                                                          alignment: Alignment.centerLeft,
                                                          width: 160,
                                                          child: Text("Center: (${context.watch<ShaderParameters>().center?.dx.toStringAsFixed(1)}, ${context.watch<ShaderParameters>().center?.dy.toStringAsFixed(1)})", textAlign: TextAlign.left, style: const TextStyle(fontSize:12),),
                                                        ),
                                                        if(shaderType == ShaderType.radial)
                                                          Container(
                                                            padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 3.0),
                                                            alignment: Alignment.centerLeft,
                                                            width: 90,
                                                            child: Text("Radius: ${context.watch<ShaderParameters>().radius?.toStringAsFixed(1)}", textAlign: TextAlign.left, style: const TextStyle(fontSize:12),),
                                                          ),
                                                      ],
                                                    ),
                                                    if(shaderType == ShaderType.radial)
                                                      Container(
                                                        padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 3.0),
                                                        alignment: Alignment.center,
                                                        height: 35,
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                                height: 35,
                                                                width: 50,
                                                                child: Text("Rad. multiplier", style: TextStyle(fontSize: 12),)
                                                            ),
                                                            Slider(
                                                              value: radialMultiplier,
                                                              onChanged: (val){
                                                                setState(() {
                                                                  radialMultiplier = val;
                                                                });
                                                                // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                                                context.read<PointDrawObject>().updateShaderParams(zoomTransform, radialMultiplier: radialMultiplier);
                                                              },
                                                              min: 0.0,
                                                              max: 10.0,
                                                              divisions: 100,
                                                              label: radialMultiplier.toStringAsFixed(1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ]
                                              ),
                                            for(int i = 0; i < colors.length; i++)
                                              Padding(
                                                padding: interLineEdgeInsets,
                                                child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children:[
                                                      SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child: MaterialButton(
                                                            onPressed: (){
                                                              if(colors.length > 2){
                                                                // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                                                context.read<PointDrawObject>().updateShaderParams(zoomTransform, removeIndex: i);
                                                                shaderColorController.removeAt(i);
                                                              }
                                                            },
                                                            child: const Icon(Icons.remove_circle, size: 20, color: Colors.red,),
                                                            shape: const CircleBorder(),
                                                            padding: EdgeInsets.zero,
                                                            elevation: 0.0,
                                                          )
                                                      ),
                                                      Container(
                                                          width: 60,
                                                          height: 24,
                                                          alignment: Alignment.centerLeft,
                                                          child: Text("Color(${stops[i].toStringAsFixed(2)})", style: radioLabelStyle)
                                                      ),
                                                      SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: MaterialButton(
                                                          onPressed: (){
                                                            setState(() {
                                                              showShaderColorSelector = !showShaderColorSelector;
                                                              shadeColorIndex = i;
                                                            });
                                                          },
                                                          shape: const CircleBorder(),
                                                          color: colors[i],
                                                          elevation: colorSelectorElevation,
                                                        ),),
                                                      Container(
                                                        width: 18,
                                                        height: 24,
                                                        alignment: Alignment.centerLeft,
                                                        margin: const EdgeInsets.only(left: 10.0),
                                                        child: const Text("#:"),
                                                      ),
                                                      PropertyInputBox(shaderColorController[i], (p0) {},
                                                            (){
                                                          Color? shColor = colorInput(shaderColorController[i].text);
                                                          if(shColor != null){
                                                            List<Color> newColors = List<Color>.generate(colors.length, (j){
                                                              if(j == i){
                                                                return shColor;
                                                              } else {
                                                                return colors[j];
                                                              }
                                                            });
                                                            // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                                            context.read<PointDrawObject>().updateShaderParams(zoomTransform, colorsList: newColors);
                                                          }
                                                        }, textFieldSize, focusNode: FocusNode(),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            if(useShader && showShaderColorSelector)
                                              ColorSelector(
                                                  Colors.white,
                                                  initialColor: colors[shadeColorIndex!],
                                                  updateColor: (color){
                                                    List<Color> newColors = List.from(colors);
                                                    newColors[shadeColorIndex!] = color;
                                                    context.read<PointDrawObject>().updateShaderParams(zoomTransform, colorsList: newColors);
                                                  },
                                                  updateActionStack: (){
                                                    // context.read<PointDrawCollection>().addAction(UpdateObjectPropertyAction(Property.fillShader, fillShader, objectIndex: widget.indexOfObject));
                                                  }
                                              ),
                                            // PointDrawObjectColorSelector(
                                            //   context.read<PointDrawObject>(),
                                            //   PaintType.shader,
                                            //   initialColor: colors[shadeColorIndex!],
                                            //   colorIndex: shadeColorIndex,
                                            // ),
                                            Padding(
                                              padding: interLineEdgeInsets,
                                              child: ColorStopsBar(
                                                Colors.transparent,
                                                size: const Size(270, 40),
                                                stops: context.watch<ShaderParameters>().stops,
                                                colors: context.watch<ShaderParameters>().colors,
                                                onCreateStop: (double newStop, List<double> stops, List<Color> colors){
                                                  bool foundNewStopIndex = false;
                                                  List<Color> newColors = List<Color>.filled(stops.length + 1, Colors.white);
                                                  List<double> newStops = List<double>.generate(stops.length + 1, (ind){
                                                    if(ind < stops.length && stops[ind] < newStop && !foundNewStopIndex){
                                                      newColors[ind] = colors[ind];
                                                      return stops[ind];
                                                    } else if (!foundNewStopIndex){
                                                      newColors[ind] = Colors.blue;
                                                      foundNewStopIndex = true;
                                                      return newStop;
                                                    } else {
                                                      newColors[ind] = colors[ind - 1];
                                                      return stops[ind - 1];
                                                    }
                                                  });
                                                  assert(foundNewStopIndex, "New stop is not inserted properly");
                                                  context.read<PointDrawObject>().updateShaderParams(zoomTransform, stopsList: newStops, colorsList: newColors);
                                                },
                                                updater: (List<double> stops){
                                                  context.read<PointDrawObject>().updateShaderParams(zoomTransform, stopsList: stops);
                                                },
                                              ),
                                            ),
                                            if(shaderType == ShaderType.sweep)
                                              Column(
                                                  children: [
                                                    Padding(
                                                      padding: interLineEdgeInsets,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                            alignment: Alignment.centerLeft,
                                                            width: 135,
                                                            child: Text("Start angle: ${context.watch<ShaderParameters>().startAngle?.toStringAsFixed(2)} rad", textAlign: TextAlign.left, style: const TextStyle(fontSize:12),),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                            alignment: Alignment.centerLeft,
                                                            width: 135,
                                                            child: Text("End angle: ${context.watch<ShaderParameters>().endAngle?.toStringAsFixed(2)} rad", textAlign: TextAlign.left, style: const TextStyle(fontSize:12),),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: interLineEdgeInsets,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                            alignment: Alignment.center,
                                                            width: 110,
                                                            height: 110,
                                                            child: RadianSweeper(
                                                                size: const Size(110, 110),
                                                                radian: context.watch<ShaderParameters>().startAngle ?? 0,
                                                                updater: (val){
                                                                  context.read<PointDrawObject>().updateShaderParams(zoomTransform, start: val);
                                                                }),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                            alignment: Alignment.center,
                                                            width: 110,
                                                            height: 110,
                                                            child: RadianSweeper(
                                                                size: const Size(110, 110),
                                                                radian: context.watch<ShaderParameters>().endAngle ?? (2.0 * pi),
                                                                updater: (val){
                                                                  context.read<PointDrawObject>().updateShaderParams(zoomTransform, end: val);
                                                                }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            // Padding(
                                            //   padding: interLineEdgeInsets,
                                            //   child: Row(
                                            //       crossAxisAlignment: CrossAxisAlignment.center,
                                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //       children:[
                                            //         Container(
                                            //             width: 30,
                                            //             height: 24,
                                            //             alignment: Alignment.centerLeft,
                                            //             child: const Text("Tile", style: TextStyle(fontSize:14, color: Colors.black))
                                            //         ),
                                            //
                                            //         SizedBox(
                                            //           width: 24,
                                            //           height: 24,
                                            //           child: Radio(
                                            //             groupValue: context.watch<ShaderParameters>().tileMode,
                                            //             value: TileMode.clamp,
                                            //             onChanged: (TileMode? val){
                                            //               context.read<PointDrawObject>().updateShaderParams(zoomTransform, mode: TileMode.clamp);
                                            //             },splashRadius: 0.1,
                                            //           ),),
                                            //         SizedBox(
                                            //             height: 12,
                                            //             width: 36,
                                            //             child: Text("Clamp", style: radioLabelStyle)
                                            //         ),
                                            //         SizedBox(
                                            //           width: 24,
                                            //           height: 24,
                                            //           child: Radio(
                                            //             groupValue: context.watch<ShaderParameters>().tileMode,
                                            //             value: TileMode.decal,
                                            //             onChanged: (TileMode? val){
                                            //               context.read<PointDrawObject>().updateShaderParams(zoomTransform, mode: TileMode.decal);
                                            //             },splashRadius: 0.1,
                                            //           ),),
                                            //         SizedBox(
                                            //             height: 12,
                                            //             width: 36,
                                            //             child: Text("Decal", style: radioLabelStyle)
                                            //         ),
                                            //         SizedBox(
                                            //           width: 24,
                                            //           height: 24,
                                            //           child: Radio(
                                            //             groupValue: context.watch<ShaderParameters>().tileMode,
                                            //             value: TileMode.mirror,
                                            //             onChanged: (TileMode? val){
                                            //               context.read<PointDrawObject>().updateShaderParams(zoomTransform, mode: TileMode.mirror);
                                            //             },splashRadius: 0.1,
                                            //           ),),
                                            //         SizedBox(
                                            //             height: 12,
                                            //             width: 36,
                                            //             child: Text("Mirror", style: radioLabelStyle)
                                            //         ),
                                            //         SizedBox(
                                            //           width: 24,
                                            //           height: 24,
                                            //           child: Radio(
                                            //             groupValue: context.watch<ShaderParameters>().tileMode,
                                            //             value: TileMode.repeated,
                                            //             onChanged: (TileMode? val){
                                            //               context.read<PointDrawObject>().updateShaderParams(zoomTransform, mode: TileMode.repeated);
                                            //             },splashRadius: 0.1,
                                            //           ),),
                                            //         SizedBox(
                                            //             height: 12,
                                            //             width: 39,
                                            //             child: Text("Repeat", style: radioLabelStyle)
                                            //         ),
                                            //       ]),
                                            // ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                      // if(mode != EditingMode.text && mode != EditingMode.freeDraw && hasGlow)
                        // SectionTab(
                        //   tabName: "Glow effect",
                        //   builder: (context){
                        //     return Column(
                        //         children: [
                        //           Padding(
                        //             padding: interLineEdgeInsets,
                        //             child: SizedBox(
                        //               height: 35,
                        //               child: Row(
                        //                 children: [
                        //                   const SizedBox(
                        //                       height: 35,
                        //                       width: 50,
                        //                       child: Text("Glow ratio", style: TextStyle(fontSize: 12),)
                        //                   ),
                        //                   Slider(
                        //                     value: glowRatio,
                        //                     onChanged: (double val) {
                        //                       (context.read<PointDrawObject>() as PointDrawTwoDimensional).updateGlowRadius(val);
                        //                     },
                        //                     min: 0.0,
                        //                     max: 1.0,
                        //                     divisions: 100,
                        //                     label: glowRatio.toStringAsFixed(2), thumbColor: Colors.indigo,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: interLineEdgeInsets,
                        //             child: Row(
                        //                 crossAxisAlignment: CrossAxisAlignment.center,
                        //                 children:[
                        //                   Container(
                        //                       width: 35,
                        //                       height: 24,
                        //                       alignment: Alignment.centerLeft,
                        //                       child: const Text("Type", style: TextStyle(fontSize:14, color: Colors.black))
                        //                   ),
                        //                   SizedBox(
                        //                     width: 24,
                        //                     height: 24,
                        //                     child: Radio(
                        //                       groupValue: blurStyle,
                        //                       value: BlurStyle.normal,
                        //                       onChanged: (BlurStyle? val){
                        //                         setState(() {
                        //                           blurStyle = BlurStyle.normal;
                        //                         });
                        //                         (context.read<PointDrawObject>() as PointDrawTwoDimensional).updateBlurStyle(blurStyle);
                        //                       },
                        //                       splashRadius: 0.1,
                        //                     ),),
                        //                   SizedBox(
                        //                       height: 12,
                        //                       width: 36,
                        //                       child: Text("Normal", style: radioLabelStyle)
                        //                   ),
                        //                   SizedBox(
                        //                     width: 24,
                        //                     height: 24,
                        //                     child: Radio(
                        //                       groupValue: blurStyle,
                        //                       value: BlurStyle.inner,
                        //                       onChanged: (BlurStyle? val){
                        //                         setState(() {
                        //                           blurStyle = BlurStyle.inner;
                        //                         });
                        //                         (context.read<PointDrawObject>() as PointDrawTwoDimensional).updateBlurStyle(blurStyle);
                        //                       }, splashRadius: 0.1,
                        //                     ),),
                        //                   SizedBox(
                        //                       height: 12,
                        //                       width: 36,
                        //                       child: Text("Inner", style: radioLabelStyle)
                        //                   ),
                        //                   SizedBox(
                        //                     width: 24,
                        //                     height: 24,
                        //                     child: Radio(
                        //                       groupValue: blurStyle,
                        //                       value: BlurStyle.outer,
                        //                       onChanged: (BlurStyle? val){
                        //                         setState(() {
                        //                           blurStyle = BlurStyle.outer;
                        //                         });
                        //                         (context.read<PointDrawObject>() as PointDrawTwoDimensional).updateBlurStyle(blurStyle);
                        //                       }, splashRadius: 0.1,
                        //                     ),),
                        //                   SizedBox(
                        //                       height: 12,
                        //                       width: 36,
                        //                       child: Text("Outer", style: radioLabelStyle)
                        //                   ),
                        //                   SizedBox(
                        //                     width: 24,
                        //                     height: 24,
                        //                     child: Radio(
                        //                       groupValue: blurStyle,
                        //                       value: BlurStyle.solid,
                        //                       onChanged: (BlurStyle? val){
                        //                         setState(() {
                        //                           blurStyle = BlurStyle.solid;
                        //                         });
                        //                         (context.read<PointDrawObject>() as PointDrawTwoDimensional).updateBlurStyle(blurStyle);
                        //                       }, splashRadius: 0.1,
                        //                     ),),
                        //                   SizedBox(
                        //                       height: 12,
                        //                       width: 36,
                        //                       child: Text("Solid", style: radioLabelStyle)
                        //                   ),
                        //                 ]
                        //             ),
                        //           ),
                        //         ]
                        //     );
                        //   },
                        // ),
                      // if(hasRoundedCorners)
                        // SectionTab(
                        //   tabName: "Round corners",
                        //   builder: (context){
                        //     return Column(
                        //         children: [
                        //           Padding(
                        //             padding: interLineEdgeInsets,
                        //             child: SizedBox(
                        //               height: 35,
                        //               child: Row(
                        //                 children: [
                        //                   const SizedBox(
                        //                       height: 35,
                        //                       width: 80,
                        //                       child: Text("Rounding factor", style: TextStyle(fontSize: 12),)
                        //                   ),
                        //                   Slider(
                        //                     value: roundingFactor,
                        //                     onChanged: (double val) {
                        //                       (context.read<PointDrawObject>() as PointDrawStraightEdgedShape).updateRoundingRadius(val);
                        //                     },
                        //                     min: 0.0,
                        //                     max: 1.0,
                        //                     divisions: 100,
                        //                     label: roundingFactor.toStringAsFixed(2), thumbColor: Colors.indigo,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ]
                        //     );
                        //   },
                        // ),
                      // if(mode == EditingMode.freeDraw)
                      //   ChangeNotifierProvider<EffectsParameters?>.value(
                      //     value: (context.watch<PointDrawObject?>() as FreeDraw).effectsParams,
                      //     child: SectionTab(
                      //       tabName: "Effects",
                      //       builder: (context){
                      //         // SplineEffects type = context.watch<EffectsParameters>().type;
                      //         double pointsGapCoefficient = context.watch<EffectsParameters>().pointsGapCoefficient;
                      //         double maxWidth = context.watch<EffectsParameters>().maxWidth;
                      //         double variance = context.watch<EffectsParameters>().variance;
                      //         double varPercent = variance / maxWidth * 100;
                      //         double endWidth = context.watch<EffectsParameters>().endWidth;
                      //         double endWidthPercent = endWidth / maxWidth * 100;
                      //         return Column(
                      //           children: [
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: SizedBox(
                      //                 height: 30,
                      //                 child: Row(
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: [
                      //                     Container(
                      //                         height: 30,
                      //                         width: 70,
                      //                         alignment: Alignment.centerLeft,
                      //                         child: const Text("Points gap coefficient", style: TextStyle(fontSize: 12),)
                      //                     ),
                      //                     Slider(
                      //                       value: pointsGapCoefficient,
                      //                       onChanged: (double val) {
                      //                         (context.read<PointDrawObject>() as FreeDraw).updateEffectsParams(pointsGapCoefficient: val);
                      //                       },
                      //                       onChangeEnd: (double val){
                      //                         (context.read<PointDrawObject>() as FreeDraw).regenerateSpline(filter: true, computeMetric: true);
                      //                       },
                      //                       min: 0.0,
                      //                       max: 100.0,
                      //                       divisions: 100,
                      //                       label: pointsGapCoefficient.toStringAsFixed(2), thumbColor: Colors.indigo,
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: SizedBox(
                      //                 height: 30,
                      //                 child: Row(
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: [
                      //                     Container(
                      //                         height: 30,
                      //                         width: 70,
                      //                         alignment: Alignment.centerLeft,
                      //                         child: const Text("Max. width", style: TextStyle(fontSize: 12),)
                      //                     ),
                      //                     Slider(
                      //                       value: maxWidth,
                      //                       onChanged: (double val) {
                      //                         (context.read<PointDrawObject>() as FreeDraw).updateEffectsParams(maxWidth: val);
                      //                       },
                      //                       onChangeEnd: (double val){
                      //                         (context.read<PointDrawObject>() as FreeDraw).regenerateSpline();
                      //                       },
                      //                       min: 1.0,
                      //                       max: 25.0,
                      //                       divisions: 384,
                      //                       label: maxWidth.toStringAsFixed(2), thumbColor: Colors.indigo,
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: SizedBox(
                      //                 height: 30,
                      //                 child: Row(
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: [
                      //                     Container(
                      //                         height: 30,
                      //                         width: 70,
                      //                         alignment: Alignment.centerLeft,
                      //                         child: const Text("Variance", style: TextStyle(fontSize: 12),)
                      //                     ),
                      //                     Slider(
                      //                       value: varPercent,
                      //                       onChanged: (double val) {
                      //                         (context.read<PointDrawObject>() as FreeDraw).updateEffectsParams(variance: val / 100 * maxWidth);
                      //                       },
                      //                       onChangeEnd: (double val){
                      //                         (context.read<PointDrawObject>() as FreeDraw).regenerateSpline();
                      //                       },
                      //                       min: 0.0,
                      //                       max: 100.0,
                      //                       divisions: 100,
                      //                       label: varPercent.toStringAsFixed(0) + "%", thumbColor: Colors.indigo,
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: SizedBox(
                      //                 height: 30,
                      //                 child: Row(
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: [
                      //                     Container(
                      //                         height: 30,
                      //                         width: 70,
                      //                         alignment: Alignment.centerLeft,
                      //                         child: const Text("End width", style: TextStyle(fontSize: 12),)
                      //                     ),
                      //                     Slider(
                      //                       value: endWidthPercent,
                      //                       onChanged: (double val) {
                      //                         (context.read<PointDrawObject>() as FreeDraw).updateEffectsParams(endWidth: val / 100 * maxWidth);
                      //                       },
                      //                       onChangeEnd: (double val){
                      //                         (context.read<PointDrawObject>() as FreeDraw).regenerateSpline();
                      //                       },
                      //                       min: 0.0,
                      //                       max: 100.0,
                      //                       divisions: 100,
                      //                       label: endWidthPercent.toStringAsFixed(0) + "%", thumbColor: Colors.indigo,
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // Container(
                      //     width: 300,
                      //     padding: const EdgeInsets.all(4.0),
                      //     child: SectionTab(
                      //       tabName: "Clipping",
                      //       builder: (context){
                      //         List<PointDrawObject> collection = context.watch<PointDrawCollection>().collection;
                      //         Map<Path, PointDrawObject> clips = context.watch<PointDrawObject>().clips;
                      //         return Column(
                      //           children: [
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: Row(
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children:[
                      //                     Container(
                      //                         height: 24,
                      //                         alignment: Alignment.centerLeft,
                      //                         child: const Text("Current clips:", style: TextStyle(fontSize:14, color: Colors.black, fontWeight: FontWeight.normal))
                      //                     ),
                      //                   ]
                      //               ),
                      //             ),
                      //             const SizedBox(
                      //               height: 6,
                      //             ),
                      //             ConstrainedBox(
                      //               constraints: BoxConstraints.loose(
                      //                   const Size(300, 400)
                      //               ),
                      //               child: SingleChildScrollView(
                      //                 scrollDirection: Axis.vertical,
                      //                 padding: EdgeInsets.zero,
                      //                 controller: ScrollController(),
                      //                 child: Column(
                      //                   children: [
                      //                     for(MapEntry<Path, PointDrawObject> clipEntry in clips.entries)
                      //                       ClipItem(
                      //                         clipEntry.value.toString(),
                      //                         ClipObject(clipPath: clipEntry.key),
                      //                         deleteClipObject: (){
                      //                           context.read<PointDrawObject>().removeClip(clipEntry.key);
                      //                           context.read<PointDrawCollection>().addAction(RemoveClipObjectAction(clipEntry.key, clipEntry.value, objectIndex: widget.indexOfObject));
                      //                         },
                      //                         key: ObjectKey(clipEntry.key.toString() + clipEntry.value.toString()),
                      //                       ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //             if(clips.isEmpty)
                      //               ConstrainedBox(
                      //                 constraints: BoxConstraints.loose(
                      //                     const Size(300, 24)
                      //                 ),
                      //                 child: const Text("No clips", style: TextStyle(fontSize: 14),),
                      //               ),
                      //             const SizedBox(
                      //               height: 6,
                      //             ),
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: Row(
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children:[
                      //                     Container(
                      //                         height: 24,
                      //                         alignment: Alignment.centerLeft,
                      //                         child: const Text("Add clip", style: TextStyle(fontSize:14, color: Colors.black, fontWeight: FontWeight.normal))
                      //                     ),
                      //                   ]
                      //               ),
                      //             ),
                      //             Padding(
                      //               padding: interLineEdgeInsets,
                      //               child: Row(
                      //                 crossAxisAlignment: CrossAxisAlignment.center,
                      //                 children: [
                      //                   const Text("Clip path: ", style: TextStyle(fontSize: 14)),
                      //                   const SizedBox(
                      //                       width: 6.0
                      //                   ),
                      //                   PopupMenuButton<PointDrawPath?>(
                      //                     initialValue: null,
                      //                     onSelected: (PointDrawPath? object){
                      //                       if(object != null){
                      //                         setState((){
                      //                           newClippingObject.clipTarget = context.read<PointDrawObject>();
                      //                           newClippingObject.clipPath = object.getPath();
                      //                           newClippingObject.clip = object;
                      //                           newClippingObject.pathObjectIdentifier = object.toString();
                      //                         });
                      //                       } else {
                      //                         showInformationMessage(context, "No object selected");
                      //                       }
                      //                     },
                      //                     itemBuilder: (context){
                      //                       return [
                      //                         for(PointDrawObject object in collection)
                      //                           if(object is PointDrawPath)
                      //                             PopupMenuItem<PointDrawPath>(
                      //                               value: object,
                      //                               child: Text(toProper(object.mode.name)),
                      //                               height: 20,
                      //                               padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      //                             ),
                      //                       ];
                      //                     },
                      //                     padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      //                     tooltip: "Select base object",
                      //                     child: Material(
                      //                       shape: RoundedRectangleBorder(
                      //                         borderRadius: BorderRadius.circular(4.0),
                      //                       ),
                      //                       color: Colors.grey[200]!,
                      //                       elevation: 6.0,
                      //                       child: Container(
                      //                           width: 120,
                      //                           height: 24,
                      //                           alignment: Alignment.center,
                      //                           child: Text(newClippingObject.clipPath != null ? (newClippingObject.pathObjectIdentifier ?? "No object") : "No object", style: const TextStyle(fontSize: 14))
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   Expanded(
                      //                       child: Container()
                      //                   ),
                      //                   SizedBox(
                      //                     width: 20,
                      //                     height: 20,
                      //                     child: MaterialButton(
                      //                       onPressed:(){
                      //                         if(newClippingObject.clipTarget != null && newClippingObject.clipPath != null){
                      //                           context.read<PointDrawObject>().addClip(newClippingObject.clipPath!, newClippingObject.clip!);
                      //                           context.read<PointDrawCollection>().addAction(ClipObjectAction(newClippingObject.clipPath!, objectIndex: widget.indexOfObject));
                      //                         }
                      //                         setState((){
                      //                           newClippingObject = ClipObject();
                      //                         });
                      //                       },
                      //                       padding: EdgeInsets.zero,
                      //                       elevation: 6.0,
                      //                       color: Colors.black,
                      //                       shape: const CircleBorder(),
                      //                       child: const Icon(Icons.add, size: 16, color: Colors.white),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     )
                      // ),
                    ],
                  ),
              ]
          ),
        ),
      );
    } catch(e){
      debugPrint("Cannot render tab properly. Error: $e");
      return Container(
        padding: const EdgeInsets.only(left: 8.0, bottom: 3.0),
        constraints: BoxConstraints.tight(const Size(300, 32)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ReorderableDelayedDragStartListener(
                index: 0,
                child: Card(
                    color: Colors.grey[300],
                    margin: EdgeInsets.zero,
                    child: const Icon(Icons.drag_handle, size:16, color: Colors.black))
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                alignment: Alignment.centerLeft,
                child: Text(widget.mode ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ),
            Expanded(
              child:Container(),
            ),
            FunctionButton(
              showButton: widget.mode != "text",
              onPressed: (){},
              toolTip: "Flip vertical",
              primaryStateWidget: const FlipVerticalIcon(widthSize: 20),),
            FunctionButton(
              showButton: widget.mode != "text",
              onPressed: (){},
              toolTip: "Flip horizontal",
              primaryStateWidget: const FlipHorizontalIcon(widthSize: 20),),
            FunctionButton(
              onPressed: widget.duplicate,
              toolTip: "Duplicate",
              primaryStateWidget: const Icon(Icons.copy, size: 12, color: Colors.white),
            ),
            FunctionButton(
              onPressed: toggleShowDetails,
              toolTip: "Show details",
              primaryState: showDetails,
            ),
            FunctionButton(
              onPressed: (){
                deleteObject.call(0);
              },
              toolTip: "Delete",
              primaryStateWidget: const Icon(Icons.delete, size:14, color: Colors.white),
            )
          ],
        ),
      );
    }
  }

  void toggleShowDetails(){
    setState((){
      showDetails = !showDetails;
      debugPrint("Switching show details, $showDetails");
      if(showDetails){
        showControlPoints = true;
        showPaintParameters = true;
        // showGlowParameters = true;
      }
    });
  }

  void toggleShowControlPoints(){
    setState((){
      showControlPoints = !showControlPoints;
    });
  }

  void deleteObject(int objectIndex){
    PointDrawObject object = context.read<PointDrawObject>();
    // context.read<PointDrawCollection>().addAction(DeleteAction(object, curveIndex: objectIndex));
    widget.deleteObject.call(object);
  }
}
