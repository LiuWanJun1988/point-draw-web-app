import 'package:flutter/material.dart';

import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart' show defaultPanelElevation;
import 'package:pointdraw/point_draw_models/app_components/icon_sketch.dart';

enum ActionType{addCurve, toggleOption, others}

class ActionButton extends StatelessWidget {
  final EditingMode mode;
  final bool stateController;
  final Widget displayWidget;
  final Semantics? semantics;
  final void Function()? onPressed;
  final String? toolTipMessage;
  final EdgeInsets margin;
  final bool enabled;
  final Size? size;
  ActionButton(
      this.mode,
      this.stateController,
      {
        required this.displayWidget,
        this.semantics,
        this.onPressed,
        this.toolTipMessage,
        this.margin = EdgeInsets.zero,
        this.enabled = true,
        this.size,
      }) : super(key: ValueKey("Action button (${mode.name}): ${toolTipMessage ?? generateAutoID()}")){
  }

  @override
  Widget build(BuildContext context) {
    Widget result = MaterialButton(
      onPressed: enabled ? onPressed : null,
      shape: const CircleBorder(),
      color: stateController ? Colors.cyanAccent : Colors.black,
      clipBehavior: Clip.hardEdge,
      hoverColor: Colors.cyanAccent,
      elevation: 4.0,
      padding: EdgeInsets.zero,
      child: displayWidget,
    );
    if(toolTipMessage != null){
      result = Tooltip(
        message: toolTipMessage,
        child: result,
      );
    }
    Size widgetSize = size ?? Size(32, 32);
    return Container(
      width: widgetSize.width,
      height: widgetSize.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      margin: margin,
      child: result,
    );
  }
}

class NewFreeDrawActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewFreeDrawActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
        EditingMode.freeDraw,
        stateControl,
        onPressed: onPressed,
        semantics: Semantics(label: "Add a free draw curve"),
      displayWidget: const FreeDrawIcon(widthSize: 28),
      toolTipMessage: "Add free draw",
    );
  }
}

class NewTextActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewTextActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.text,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "Add text"),
      displayWidget: const TextIcon(widthSize: 28),
      toolTipMessage: "Add text",
    );
  }
}

class NewLineActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewLineActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.line,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "Add a straight line control point"),
      displayWidget: const LineIcon(widthSize: 28),
      toolTipMessage: "Add a straight line"
    );
  }
}

class NewArcActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewArcActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
        EditingMode.arc,
        stateControl,
        onPressed: onPressed,
        semantics: Semantics(label: "Add an arc control point"),
        displayWidget: const ArcIcon(widthSize: 28),
        toolTipMessage: "Add an arc"
    );
  }
}

class NewSplineCurveActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewSplineCurveActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
        EditingMode.splineCurve,
        stateControl,
        onPressed: onPressed,
        semantics: Semantics(label: "Add a Catmull Rom spline control point"),
        displayWidget: const CatmullRomCurveIcon(widthSize: 28),
        toolTipMessage: "Add a spline curve"
    );
  }
}

class NewQuadraticBezierActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewQuadraticBezierActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
        EditingMode.quadraticBezier,
        stateControl,
        onPressed: onPressed,
        semantics: Semantics(label: "Edit quadratic bezier curve control point"),
        displayWidget: const QuadraticBezierCurveIcon(widthSize: 28),
        toolTipMessage: "Add a quadratic bezier curve"
    );
  }
}

class NewCubicBezierActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewCubicBezierActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
        EditingMode.cubicBezier,
        stateControl,
        onPressed: onPressed,
      semantics: Semantics(label: "Edit cubic bezier curve control point"),
      displayWidget: const CubicBezierCurveIcon(widthSize: 28),
      toolTipMessage: "Add a cubic bezier curve",
    );
  }
}

class NewCompositeActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewCompositeActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.compositePath,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "Edit composite path control point"),
      displayWidget: const ExtendCompositeIcon(widthSize: 28),
      toolTipMessage: "Add a composite curve object",
    );
  }
}

class NewTriangleActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewTriangleActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.triangle,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "triangle"),
      displayWidget: const TriangleIcon(widthSize: 28),
      toolTipMessage: "Add a triangle",
    );
  }
}

class NewRectangleActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewRectangleActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.rectangle,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "rectangle"),
      displayWidget: const RectangleIcon(widthSize: 28),
      toolTipMessage: "Add a rectangle",
    );
  }
}

class NewRoundedRectangleActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewRoundedRectangleActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.roundedRectangle,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "rounded rectangle"),
      displayWidget: const RoundedRectangleIcon(widthSize: 28),
      toolTipMessage: "Add a rounded rectangle",
    );
  }
}

class NewRoundedRectangleChatBoxActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewRoundedRectangleChatBoxActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.roundedRectangleChatBox,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "rounded rectangle chat box"),
      displayWidget: const RoundedRectangleChatBoxIcon(widthSize: 28),
      toolTipMessage: "Add a rounded-corner chat box",
    );
  }
}

class NewPentagonActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewPentagonActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.pentagon,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "pentagon"),
      displayWidget: const PentagonIcon(widthSize: 28),
      toolTipMessage: "Add a pentagon",
    );
  }
}

class NewPolygonActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewPolygonActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.polygon,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "polygon"),
      displayWidget: const PolygonIcon(widthSize: 28),
      toolTipMessage: "Add a polygon",
    );
  }
}

class NewConicActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewConicActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.conic,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "conic"),
      displayWidget: const ConicIcon(widthSize: 28),
      toolTipMessage: "Add a conic",
    );
  }
}

class NewStarActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewStarActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.star,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "star"),
      displayWidget: const StarIcon(widthSize: 28),
      toolTipMessage: "Add a star",
    );
  }
}

class NewHeartActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewHeartActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.heart,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "heart"),
      displayWidget: const HeartIcon(widthSize: 28),
      toolTipMessage: "Add a heart shape",
    );
  }
}

class NewArrowActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewArrowActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.arrow,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "arrow"),
      displayWidget: const ArrowIcon(widthSize: 28),
      toolTipMessage: "Add an arrow shape",
    );
  }
}

class NewLoopActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewLoopActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.loop,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "loop"),
      displayWidget: const LoopIcon(widthSize: 28),
      toolTipMessage: "Add a loop",
    );
  }
}

class NewLeafActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewLeafActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.leaf,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "leaf"),
      displayWidget: const LeafIcon(widthSize: 28),
      toolTipMessage: "Add a leaf shape",
    );
  }
}

class NewBlobActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewBlobActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.blob,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "blob"),
      displayWidget: const BlobIcon(widthSize: 28),
      toolTipMessage: "Add a blob",
    );
  }
}

class NewDirectedLineActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewDirectedLineActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.directedLine,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "directed_line"),
      displayWidget: const DirectedLineIcon(widthSize: 28),
      toolTipMessage: "Add a directed line",
    );
  }
}

class NewCurvedDirectedLineActionButton extends StatelessWidget {
  final bool stateControl;
  final void Function() onPressed;
  const NewCurvedDirectedLineActionButton(
      {
        required this.stateControl,
        required this.onPressed,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      EditingMode.curvedDirectedLine,
      stateControl,
      onPressed: onPressed,
      semantics: Semantics(label: "curve_directed_line"),
      displayWidget: const CurveDirectedLineIcon(widthSize: 28),
      toolTipMessage: "Add a curved directed line",
    );
  }
}

class OptionBox extends StatelessWidget {

  final EditingMode mode;
  final Map<String, dynamic> odkObject;
  final Map<String, void Function()?> actions;
  OptionBox(this.mode, this.actions, this.odkObject, {Key? key}) : super(key: key ?? ValueKey(mode.name));


  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget optionBox(EditingMode mode){
    // assert(currentEditingODKIndex != null, "Non-none editing mode must correspond to a non-null current editing curve index");
    List<Widget> modeSpecificOptions = [];
    if(mode == EditingMode.text){
      modeSpecificOptions.addAll([
        getActionButton(
            mode,
            false,
            actionType: ActionType.toggleOption,
            widget: const UpFontSizeIcon(widthSize: 28,),
            defaultCall:({EditingMode mode = EditingMode.none}){
              // setState((){
              //   widget.odkObject["font_size"]++;
              // });
            },
            toolTipMessage: "Increase font size"
        ),
        getActionButton(
            mode,
            false,
            actionType: ActionType.toggleOption,
            widget: const DownFontSizeIcon(widthSize: 28,),
            defaultCall:({EditingMode mode = EditingMode.none}){
              // setState((){
              //   widget.odkObject["font_size"]--;
              // });
            },
            toolTipMessage: "Decrease font size"
        ),
      ]
      );
    }
    if(isShapeMode(mode)){
      modeSpecificOptions.add(
          getActionButton(
              mode,
              false,
              actionType: ActionType.toggleOption,
              widget: const RegulariseIcon(widthSize: 28,),
              defaultCall:({EditingMode mode = EditingMode.none}){
                // List<Offset>? regularisedPoints = getRegularisedPoints(widget.odkObject["control_points"], mode);
                // // shapes mode has not introduced restricted control points (yet)
                // if(regularisedPoints != null){
                //   setState((){
                //     pointDrawCollection[currentEditingODKIndex!] = updateAllControlPoints(regularisedPoints, pointDrawCollection[currentEditingODKIndex!]["restricted_control_points"], pointDrawCollection[currentEditingODKIndex!], unZoomed: true);
                //   });
                // }
              },
              toolTipMessage: "Convert to regular shape"
          )
      );
    }
    if(isLineOrCurve(mode)){
      modeSpecificOptions.addAll([
        getActionButton(
            mode,
            false,
            actionType: ActionType.toggleOption,
            widget: const CloseCurveIcon(widthSize: 28,),
            defaultCall:({EditingMode mode = EditingMode.none}){
              // setState(() {
              //   pointDrawCollection[currentEditingODKIndex!]["close"] = !pointDrawCollection[currentEditingODKIndex!]["close"];
              // });
            },
            toolTipMessage: "Join start and end points of curve"
        ),
        getActionButton(
            mode,
            false,
            actionType: ActionType.toggleOption,
            widget: const SquareStrokeCapIcon(widthSize: 28,),
            defaultCall:({EditingMode mode = EditingMode.none}){
              // setState(() {
              //   if(widget.odkObject["stroke"].strokeCap == StrokeCap.square){
              //     widget.odkObject["stroke"].strokeCap = StrokeCap.round;
              //   } else {
              //     widget.odkObject["stroke"].strokeCap = StrokeCap.square;
              //   }
              // });
            },
            toolTipMessage: "Use square stroke cap"
        ),
      ]);
      if(mode == EditingMode.line){
        modeSpecificOptions.add(
            getActionButton(
                mode,
                false,
                actionType: ActionType.toggleOption,
                widget: const PolygonalLineIcon(widthSize: 28,),
                defaultCall:({EditingMode mode = EditingMode.none}){
                  // setState(() {
                  //   widget.odkObject["polygonal"] = !widget.odkObject["polygonal"];
                  // });
                },
                toolTipMessage: "Polygonal line"
            )
        );
      }
      if(mode == EditingMode.quadraticBezier || mode == EditingMode.cubicBezier){
        modeSpecificOptions.add(
            getActionButton(
                mode,
                false,
                actionType: ActionType.toggleOption,
                widget: const ChainBezierIcon(widthSize: 28,),
                defaultCall:({EditingMode mode = EditingMode.none}){
                  // setState(() {
                  //   widget.odkObject["chained"] = !widget.odkObject["chained"];
                  // });
                },
                toolTipMessage: "Chain Bezier curves"
            )
        );
      }
    }
    if(mode == EditingMode.freeDraw){
      modeSpecificOptions.addAll([
        getActionButton(
            EditingMode.freeDraw,
            false,
            actionType: ActionType.toggleOption, defaultCall:({EditingMode mode = EditingMode.none}){
          // setState(() {
          //   readyToTransform = !readyToTransform;
          //   if(readyToTransform){
          //     transformation = TransformCurve.Translate;
          //   } else {
          //     transformation = TransformCurve.None;
          //   }
          // });
        }, widget: const ReadyToShiftIcon(widthSize: 28,), toolTipMessage: "Toggle shift free draw" ),
        getActionButton(EditingMode.freeDraw, false, actionType: ActionType.toggleOption, defaultCall:({EditingMode mode = EditingMode.none}){
          // actionStack.add(
          //     {
          //       DrawAction.transformFreeDraw: {
          //         "editing_curve_index": currentEditingODKIndex,
          //         "free_draw_spline": Path.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].splinePath),
          //         "control_points": List<Offset>.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].points),
          //       }
          //     });
          // setState(() {
          //   pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].smoothen();
          // });
        }, widget: const SmoothenIcon(widthSize: 28), toolTipMessage:  "Smoothen free draw curve"),
        getActionButton(EditingMode.freeDraw, false, actionType: ActionType.toggleOption, defaultCall:({EditingMode mode = EditingMode.none}){
          // actionStack.add(
          //     {
          //       DrawAction.transformFreeDraw: {
          //         "editing_curve_index": currentEditingODKIndex,
          //         "free_draw_spline": Path.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].splinePath),
          //         "control_points": List<Offset>.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].points),
          //       }
          //     });
          // setState(() {
          //   widget.odkObject["free_draw_spline"].irregThicken();
          // });
        }, widget: const IrregEnthickenIcon(widthSize: 28), toolTipMessage:  "Thicken free draw curve irregularly"),
        getActionButton(EditingMode.freeDraw, false, actionType: ActionType.toggleOption,defaultCall:({EditingMode mode = EditingMode.none}){
          // actionStack.add(
          //     {
          //       DrawAction.transformFreeDraw: {
          //         "editing_curve_index": currentEditingODKIndex,
          //         "free_draw_spline": Path.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].splinePath),
          //         "control_points": List<Offset>.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].points),
          //       }
          //     });
          // setState(() {
          //   widget.odkObject["free_draw_spline"].taper();
          // });
        }, widget: const TaperIcon(widthSize: 28), toolTipMessage:  "Taper a thickened free draw curve"),
      ]);
    }
    if(mode == EditingMode.leaf){
      modeSpecificOptions.addAll([
        getActionButton(EditingMode.leaf, false, actionType: ActionType.toggleOption, defaultCall:({EditingMode mode = EditingMode.none}){
          // actionStack.add(
          //     {
          //       DrawAction.changeCurveAttribute: {
          //         "editing_curve_index": currentEditingODKIndex,
          //         "curve": Map<String, dynamic>.from(pointDrawCollection[currentEditingODKIndex!]),
          //         "symmetric": pointDrawCollection[currentEditingODKIndex!]["symmetric"],
          //       }
          //     });
          // setState(() {
          //   pointDrawCollection[currentEditingODKIndex!]["symmetric"] = !pointDrawCollection[currentEditingODKIndex!]["symmetric"];
          // });
        }, widget: const SymmetryIcon(widthSize: 28), toolTipMessage:  "Toggle symmetric"),
        getActionButton(EditingMode.leaf, false, actionType: ActionType.toggleOption, defaultCall:({EditingMode mode = EditingMode.none}){
          // actionStack.add(
          //     {
          //       DrawAction.changeCurveAttribute: {
          //         "editing_curve_index": currentEditingODKIndex,
          //         "curve": Map<String, dynamic>.from(pointDrawCollection[currentEditingODKIndex!]),
          //         "orthogonal_symmetric": pointDrawCollection[currentEditingODKIndex!]["orthogonal_symmetric"],
          //       }
          //     });
          // setState(() {
          //   pointDrawCollection[currentEditingODKIndex!]["orthogonal_symmetric"] = !pointDrawCollection[currentEditingODKIndex!]["orthogonal_symmetric"];
          // });
        }, widget: const SymmetryIcon2(widthSize: 28), toolTipMessage:  "Toggle orthogonal symmetric"),
      ]);
    }
    return Material(
      elevation: defaultPanelElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
          height: 148,
          width: 300,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                GestureDetector(
                  onPanUpdate: (dt){
                    // setState((){
                    //   optionBoxTopPosition += dt.delta.dy;
                    //   optionBoxLeftPosition += dt.delta.dx;
                    // });
                  },
                  child: Material(
                    color: Colors.orange,
                    child: Container(
                      width: 300,
                      height: 20,
                      constraints: const BoxConstraints(
                          minWidth: 200
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text("Mode: ${mode.name}", style: const TextStyle(fontSize: 16, color: Colors.white)
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal:6),
                  height: 20,
                  child: const Text("General tools", style:  TextStyle(fontSize: 16, color: Colors.black)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal:4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: generalTools(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal:6),
                  height: 28,
                  child: Text("${mode.name} tools", style: const TextStyle(fontSize: 16, color: Colors.black)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal:4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    primary: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: modeSpecificOptions,
                    ),
                  ),
                )
              ]
          )
      ),
    );
  }

  Widget getActionButton(
      EditingMode mode, bool stateController,
      {ActionType? actionType, IconData? iconData, Widget? widget, Semantics? semantics, void Function()? specificModeStateUpdate, void Function({EditingMode mode})? defaultCall, String toolTipMessage = ""}
      ){
    Widget iconWidget;
    if(widget != null){
      iconWidget = widget;
    } else if (iconData != null){
      iconWidget = Icon(iconData, size:24, color: Colors.white);
    } else {
      iconWidget = Container();
    }
    return ActionButton(
      mode,
      stateController,
      displayWidget: iconWidget,
      onPressed: defaultCall ,
          // ?? (
          //     actionType == ActionType.addCurve || actionType == null ?
          //     addCurveActionButtonDefaultCall :
          //     (actionType == ActionType.toggleOption ?
          //         ({EditingMode mode = EditingMode.none}){} :
          //     null)
          // ),
      toolTipMessage: toolTipMessage,
    );
  }

  List<Widget> generalTools(){
    return <Widget>[
      getActionButton(EditingMode.none, false, actionType: ActionType.toggleOption, toolTipMessage: "Duplicate", widget: const Icon(Icons.copy, size:18, color:Colors.white),
          defaultCall:({EditingMode mode = EditingMode.none}){
          //   List<Offset> dupControlPoints = List<Offset>.from(pointDrawCollection[currentEditingODKIndex!]["control_points"]);
          //   Map<String, dynamic> duplication = Map<String, dynamic>.from(pointDrawCollection[currentEditingODKIndex!]);
          //   if(currentMode == EditingMode.FreeDraw){
          //     duplication["free_draw_spline"] = SplinePath.generate(List.from(pointDrawCollection[currentEditingODKIndex!]["free_draw_spline"].points));
          //   }
          //   duplication["control_points"] = dupControlPoints;
          //   duplication["restricted_control_points"] = [
          //     for(Offset restrictedPoint in pointDrawCollection[currentEditingODKIndex!]["restricted_control_points"])
          //       Offset(restrictedPoint.dx, restrictedPoint.dy),
          //   ];
          //   duplication["stroke"] = copyPaint(pointDrawCollection[currentEditingODKIndex!]["stroke"]);
          //   duplication["fill"] = copyPaint(pointDrawCollection[currentEditingODKIndex!]["fill"]);
          //   actionStack.add(
          //       {DrawAction.duplicateCurve: {
          //         "duplicated_curve": duplication,
          //         "editing_curve_index": currentEditingODKIndex!,
          //       }
          //       });
          //   setState(() {
          //     pointDrawCollection.insert(currentEditingODKIndex!, duplication);
          //   });
          //   if(currentMode == EditingMode.FreeDraw){
          //     setState((){
          //       pointDrawCollection[currentEditingODKIndex!] = updateFreeDrawPath(pointDrawCollection[currentEditingODKIndex!], translate(const Offset(5,5)));
          //     });
          //   } else if (currentMode == EditingMode.GroupCurve){
          //     setState((){
          //       pointDrawCollection[currentEditingODKIndex!] = updateGroupPath(
          //           pointDrawCollection[currentEditingODKIndex!], {"translate_x": 5, "translate_y":5}, translate(const Offset(5,5))
          //       );
          //     });
          //   } else if (currentMode != EditingMode.None){
          //     readyToTransform = true;
          //     transformation = TransformCurve.Translate;
          //     setState(() {
          //       pointDrawCollection[currentEditingODKIndex!] = updateBasePath(pointDrawCollection[currentEditingODKIndex!], {"translate_x":5, "translate_y":5});
          //     });
          //     readyToTransform = false;
          //     transformation = TransformCurve.None;
          //   }
          }
      ),
      getActionButton(EditingMode.none, false, actionType: ActionType.toggleOption, toolTipMessage: "Flip Horizontal", widget: const FlipHorizontalIcon(widthSize: 28,),
          defaultCall:({EditingMode mode = EditingMode.none}){
            // if(boundingRect != null){
            //   Offset center = boundingRect!.center;
            //   if (currentMode == EditingMode.FreeDraw){
            //     setState((){
            //       pointDrawCollection[currentEditingODKIndex!] = updateFreeDrawPath(pointDrawCollection[currentEditingODKIndex!], horizontalFlip(center));
            //     });
            //   } else if (currentMode == EditingMode.GroupCurve){
            //     List<Offset> rcp = getFlipHorizontal(pointDrawCollection[currentEditingODKIndex!]["restricted_control_points"], descalePoint(center));
            //     setState(() {
            //       updateGroupCurveControlPoints(getFlipHorizontal(pointDrawCollection[currentEditingODKIndex!]["control_points"], center), pointDrawCollection[currentEditingODKIndex!]);
            //       updateGroupCurveRestrictedControlPoints(rcp, pointDrawCollection[currentEditingODKIndex!]);
            //     });
            //   } else if(currentMode != EditingMode.None){
            //     List<Offset> rcp = getFlipHorizontal(pointDrawCollection[currentEditingODKIndex!]["restricted_control_points"], descalePoint(center));
            //     setState((){
            //       pointDrawCollection[currentEditingODKIndex!] = updateAllControlPoints(
            //           getFlipHorizontal(pointDrawCollection[currentEditingODKIndex!]["control_points"], descalePoint(center)),
            //           rcp,
            //           pointDrawCollection[currentEditingODKIndex!], unZoomed : true);
            //     });
            //   }
            // }
          }),
      getActionButton(EditingMode.none, false, actionType: ActionType.toggleOption, toolTipMessage: "Flip Vertical", widget: const FlipVerticalIcon(widthSize: 28,),
          defaultCall:({EditingMode mode = EditingMode.none}){
            // if(boundingRect != null){
            //   Offset center = boundingRect!.center;
            //   if (currentMode == EditingMode.FreeDraw){
            //     setState((){
            //       pointDrawCollection[currentEditingODKIndex!] = updateFreeDrawPath(pointDrawCollection[currentEditingODKIndex!], verticalFlip(center));
            //     });
            //   } else if (currentMode == EditingMode.GroupCurve){
            //     List<Offset> rcp = getFlipVertical(pointDrawCollection[currentEditingODKIndex!]["restricted_control_points"], descalePoint(center));
            //     setState(() {
            //       updateGroupCurveControlPoints(getFlipVertical(pointDrawCollection[currentEditingODKIndex!]["control_points"], center), pointDrawCollection[currentEditingODKIndex!]);
            //       updateGroupCurveRestrictedControlPoints(rcp, pointDrawCollection[currentEditingODKIndex!]);
            //     });
            //   } else if(currentMode != EditingMode.None){
            //     List<Offset> rcp = getFlipVertical(pointDrawCollection[currentEditingODKIndex!]["restricted_control_points"], descalePoint(center));
            //     setState((){
            //       pointDrawCollection[currentEditingODKIndex!] = updateAllControlPoints(
            //           getFlipVertical(pointDrawCollection[currentEditingODKIndex!]["control_points"], descalePoint(center)),
            //           rcp,
            //           pointDrawCollection[currentEditingODKIndex!], unZoomed : true);
            //     });
            //   }
            // }
          }),
      getActionButton(EditingMode.none, false, actionType: ActionType.toggleOption, toolTipMessage: "Toggle Outline", widget: const Icon(Icons.format_paint, size: 18, color: Colors.white),
          // (widthSize: 28,),
          defaultCall:({EditingMode mode = EditingMode.none}){
            // setState((){
            //   pointDrawCollection[currentEditingODKIndex!]["outlined"] = !pointDrawCollection[currentEditingODKIndex!]["outlined"];
            // });
          }),
      getActionButton(EditingMode.none, false, actionType: ActionType.toggleOption, toolTipMessage: "Toggle Filled", widget: const FillIcon(widthSize: 28),
          defaultCall:({EditingMode mode = EditingMode.none}){
            // setState((){
            //   pointDrawCollection[currentEditingODKIndex!]["filled"] = !pointDrawCollection[currentEditingODKIndex!]["filled"];
            // });
          }),
    ];
  }

}



