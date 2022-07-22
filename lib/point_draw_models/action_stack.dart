import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/point_draw_background.dart';
import 'package:pointdraw/point_draw_models/utilities/spline_path.dart';

abstract class PointDrawAction {

  final DrawAction action;

  final int objectIndex;

  PointDrawAction({required this.action, required this.objectIndex});

  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args});

}

class DeleteAction extends PointDrawAction {

  final PointDrawObject object;

  DeleteAction(this.object, {DrawAction action = DrawAction.deleteCurve, required int curveIndex}) : super(action: action, objectIndex: curveIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    setter((){
      collection.insert(objectIndex, object);
    });
    return AddPointDrawObjectAction(curveIndex: objectIndex);
  }
}

class GroupAddAction extends PointDrawAction {

  final List<int> groupIndices;

  GroupAddAction(this.groupIndices, {DrawAction action = DrawAction.groupAdd}) : super(action: action, objectIndex: -1);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    groupIndices.sort();
    Map<int, PointDrawObject> objects = {};
    setter((){
      for(int i in groupIndices.reversed){
        objects[i] = collection[i];
        collection.removeAt(i);
      }
    });
    return GroupDeleteAction(objects);
  }
}

class GroupDeleteAction extends PointDrawAction {
  final Map<int, PointDrawObject> objects;

  GroupDeleteAction(this.objects, {DrawAction action = DrawAction.groupDelete}) : super(action: action, objectIndex: -1);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    List<int> keys = objects.keys.toList();
    keys.sort();
    setter((){
      for(int i = 0; i < keys.length; i++){
        collection.insert(keys[i], objects[keys[i]]!);
      }
    });
    return GroupAddAction(objects.keys.toList());
  }
}

class TransformObjectAction extends PointDrawAction {

  final List<Offset> points;

  final List<Offset> rPoints;

  final List<Offset> dPoints;

  final List<Offset?> sPoints;

  TransformObjectAction(
      this.points,
      this.rPoints,
      this.dPoints,
      this.sPoints,
      {
        DrawAction action = DrawAction.transformControlPoints,
        required int objectIndex
      }) :
        assert(sPoints.length == 4, "Center, to, from, and focal offsets should be provided"),
        super(action: action, objectIndex: objectIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    TransformObjectAction redoAction = TransformObjectAction(
        List<Offset>.from(collection[objectIndex].points),
        List<Offset>.from(collection[objectIndex].rPoints),
        List<Offset>.from(collection[objectIndex].dPoints),
        List<Offset?>.from(collection[objectIndex].sPoints), objectIndex: objectIndex);
    setter((){
      collection[objectIndex].points = points;
      collection[objectIndex].rPoints = rPoints;
      collection[objectIndex].dPoints = dPoints;
      collection[objectIndex].updateShaderParams(args!["zoom_transform"], centerOffset: sPoints[0], fromOffset: sPoints[1], toOffset: sPoints[2], focalOffset: sPoints[3]);
      if(collection[objectIndex] is PointDrawGroup){
        (collection[objectIndex] as PointDrawGroup).refreshPoints();
      }
    });
    return redoAction;
  }
}

class TransformFreeDrawAction extends PointDrawAction {

  final SplinePath splinePath;

  TransformFreeDrawAction(
      this.splinePath,
      {
        DrawAction action = DrawAction.transformFreeDraw,
        required int curveIndex
      }) :
        super(action: action, objectIndex: curveIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    splinePath.enGenerate();
    TransformFreeDrawAction redoAction = TransformFreeDrawAction(SplinePath((collection[objectIndex] as FreeDraw).splinePath.points), curveIndex: objectIndex);
    setter((){
      (collection[objectIndex] as FreeDraw).splinePath = splinePath;
    });
    return redoAction;
  }
}

class AddControlPointAction extends PointDrawAction {

  final int controlPointIndex;

  AddControlPointAction(this.controlPointIndex, {DrawAction action = DrawAction.addControlPoint, required int curveIndex}) : super(action: action, objectIndex: curveIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    DeleteControlPointAction redoAction = DeleteControlPointAction(collection[objectIndex].points[controlPointIndex], controlPointIndex, curveIndex: objectIndex);
    setter((){
      collection[objectIndex].points.removeAt(controlPointIndex);
    });
    return redoAction;
  }
}

class DeleteControlPointAction extends PointDrawAction {

  final Offset deletedOffset;

  final int controlPointIndex;

  DeleteControlPointAction(this.deletedOffset, this.controlPointIndex, {DrawAction action = DrawAction.deleteControlPoint, required int curveIndex}) : super(action: action, objectIndex: curveIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    AddControlPointAction redoAction = AddControlPointAction(controlPointIndex, curveIndex: objectIndex);
    setter((){
      collection[objectIndex].points.insert(controlPointIndex, deletedOffset);
    });
    return redoAction;
  }
}

class AddPointDrawObjectAction extends PointDrawAction {

  AddPointDrawObjectAction({DrawAction action = DrawAction.addPointDraw, required int curveIndex}) : super(action: action, objectIndex: curveIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    DeleteAction redoAction = DeleteAction(collection[objectIndex], curveIndex: objectIndex);
    collection[objectIndex].markForRemoval = true;
    setter((){
      collection.removeAt(objectIndex);
    });
    return redoAction;
  }
}

class ReorderAction extends PointDrawAction {

  final int movedObjectOriginalIndex;

  final int movedObjectFinalIndex;

  ReorderAction(this.movedObjectOriginalIndex, this.movedObjectFinalIndex, {DrawAction action = DrawAction.reorder,}) : super(action: action, objectIndex: -1);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    ReorderAction redoAction = ReorderAction(movedObjectFinalIndex, movedObjectOriginalIndex);
    setter((){
      if (movedObjectOriginalIndex < movedObjectFinalIndex){
        collection.insert(movedObjectOriginalIndex, collection[movedObjectFinalIndex]);
        collection.removeAt(movedObjectFinalIndex + 1);
      } else if (movedObjectOriginalIndex > movedObjectFinalIndex){
        collection.insert(movedObjectOriginalIndex + 1, collection[movedObjectFinalIndex]);
        collection.removeAt(movedObjectFinalIndex);
      }
    });
    return redoAction;
  }
}

class ClipObjectAction extends PointDrawAction {

  Path clipPath;

  ClipObjectAction(this.clipPath, {DrawAction action = DrawAction.clipObjects, required int objectIndex}) : super(action: action, objectIndex: objectIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    RemoveClipObjectAction redoAction = RemoveClipObjectAction(clipPath, collection[objectIndex].clips[clipPath]!, objectIndex: objectIndex);
    setter((){
      collection[objectIndex].removeClip(clipPath);
    });
    return redoAction;
  }
}

class RemoveClipObjectAction extends PointDrawAction {

  Path clipPath;

  PointDrawObject object;

  RemoveClipObjectAction(this.clipPath, this.object, {DrawAction action = DrawAction.removeClipObjects, required int objectIndex}) : super(action: action, objectIndex: objectIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    ClipObjectAction redoAction = ClipObjectAction(clipPath, objectIndex: objectIndex);
    setter((){
      collection[objectIndex].addClip(clipPath, object);
    });
    return redoAction;
  }

}

class GroupAction extends PointDrawAction {

  GroupAction({DrawAction action = DrawAction.groupObjects, required int curveIndex}) : super(action: action, objectIndex: curveIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    List<int> groupIndices = List<int>.generate((collection[objectIndex] as PointDrawGroup).group.length, (i) => collection.length - 2 + i);
    UngroupAction redoAction = UngroupAction(groupIndices);
    setter((){
      args?["ungroup"](addToAction: false, indexOfGroupObject: objectIndex);
    });
    return redoAction;
  }
}

class UngroupAction extends PointDrawAction {

  final List<int> groupSelection;

  UngroupAction(this.groupSelection, {DrawAction action = DrawAction.unGroupObjects,}) : super(action: action, objectIndex: -1);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    GroupAction redoAction = GroupAction(curveIndex: collection.length - groupSelection.length);
    setter((){
      args?["group"](addToAction: false, groupIndices: groupSelection);
    });
    return redoAction;
  }
}

enum Property{outlined, filled, strokeColor, strokeWidth, fillColor, fillShader, squareStrokeCap, regular, closed, shaders, shaderItem, image}

class UpdateObjectPropertyAction extends PointDrawAction {

  Property property;

  dynamic value;

  UpdateObjectPropertyAction(this.property, this.value, {DrawAction action = DrawAction.changeProperty, required int objectIndex}) : super(action: action, objectIndex: objectIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args}){
    switch(property){
      case Property.outlined:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].outlined, objectIndex: objectIndex);
        setter((){
          collection[objectIndex].outlined = value as bool;
        });
        return redoAction;
      case Property.filled:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].filled, objectIndex: objectIndex);
        setter((){
          collection[objectIndex].filled = value as bool;
        });
        return redoAction;
      case Property.strokeColor:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].sPaint.color, objectIndex: objectIndex);
        setter((){
          collection[objectIndex].sPaint.color = value as Color;
        });
        return redoAction;
      case Property.strokeWidth:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].sPaint.strokeWidth, objectIndex: objectIndex);
        setter((){
          collection[objectIndex].sPaint.strokeWidth = value as double;
        });
        return redoAction;
      case Property.squareStrokeCap:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].sPaint.strokeCap == StrokeCap.square, objectIndex: objectIndex);
        if(value){
          setter((){
            collection[objectIndex].sPaint.strokeCap = StrokeCap.square;
          });
        } else {
          setter((){
            collection[objectIndex].sPaint.strokeCap = StrokeCap.round;
          });
        }
        return redoAction;
      case Property.fillColor:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].fPaint.color, objectIndex: objectIndex);
        setter((){
          collection[objectIndex].fPaint.color = value;
        });
        return redoAction;
      case Property.fillShader:
        UpdateObjectPropertyAction redoAction = UpdateObjectPropertyAction(property, collection[objectIndex].fPaint.shader, objectIndex: objectIndex);
        setter((){
          collection[objectIndex].fPaint.shader = value;
        });
        return redoAction;
      default:
        debugPrint("Undoing change of $property not implemented.");
        return this;
    }
  }
}

class UpdateBackgroundPropertyAction extends PointDrawAction {

  Property property;

  dynamic value;

  UpdateBackgroundPropertyAction(this.property, this.value, {DrawAction action = DrawAction.changeBackgroundProperty, int objectIndex = -1}) : super(action: action, objectIndex: objectIndex);

  @override
  PointDrawAction undo(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args, PointDrawBackground? background}){
    switch(property){
      case Property.fillColor:
        UpdateBackgroundPropertyAction redoAction = UpdateBackgroundPropertyAction(property, background!.fill);
        setter((){
          background.fill = value as Color;
        });
        return redoAction;
      case Property.shaders:
        UpdateBackgroundPropertyAction redoAction = UpdateBackgroundPropertyAction(property, background!.shaders);
        setter((){
          background.shaders = value as List<ShaderParameters>;
        });
        return redoAction;
      case Property.shaderItem:
        UpdateBackgroundPropertyAction redoAction = UpdateBackgroundPropertyAction(property, background!.shaders[objectIndex]);
        setter((){
          background.shaders[objectIndex] = value as ShaderParameters;
        });
        return redoAction;
      case Property.image:
        UpdateBackgroundPropertyAction redoAction = UpdateBackgroundPropertyAction(property, background!.backgroundImage);
        setter((){
          background.backgroundImage = value as ui.Image?;
        });
        return redoAction;
      default:
        debugPrint("Undoing change of $property not implemented.");
        return this;
    }
  }
}




class ActionStack {

  final List<PointDrawAction> _stack = List<PointDrawAction>.empty(growable: true);

  final List<PointDrawAction> _redoStack = List<PointDrawAction>.empty(growable: true);

  int step = -1;

  bool get hasRedoAction => _redoStack.isNotEmpty;

  ActionStack();

  void clear(){
    _stack.clear();
    _redoStack.clear();
    step = -1;
  }

  void addAction(PointDrawAction action){
    if(step < _stack.length - 1){
      _stack.removeRange(step + 1, _stack.length);
    }
    _stack.add(action);
    step = _stack.length - 1;
    if(_redoStack.isNotEmpty){
      _redoStack.clear();
    }
  }

  bool get isNotEmpty => _stack.isNotEmpty;

  PointDrawAction get lastAction => _stack.last;

  void undoLastAction(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args, PointDrawAction Function(PointDrawAction?)? undoCall}){
    if(step >= 0 && _stack.isNotEmpty){
      PointDrawAction redoAction;
      if(undoCall != null){
        redoAction = undoCall.call(_stack[step]);
      } else {
        try {
          redoAction = _stack[step].undo(collection, setter, args: args);
        } catch (e){
          throw FlutterError("Undoing ${_stack.last.action.name} failed. Error: $e");
        }
      }
      _redoStack.add(redoAction);
      step--;
    }
  }

  void redoAction(List<PointDrawObject> collection, StateSetter setter, {Map<String, dynamic>? args, void Function(PointDrawAction?)? redoCall}){
    if(_redoStack.isNotEmpty){
      if(redoCall != null){
        redoCall.call(_redoStack.last);
      } else {
        try {
          _redoStack.last.undo(collection, setter, args: args);
        } catch (e){
          throw FlutterError("Redoing ${_redoStack.last.action.name} failed. Error $e");
        }
      }
      _redoStack.removeLast();
    }
  }
}

// void undoLastAction(){
//   closeMenus();
//   switch(actionStack.last.keys.first){
//     case DrawAction.moveControlPoint:
//       List<Offset> controlPoints = List<Offset>.from(actionStack.last[DrawAction.moveControlPoint]["control_points"]);
//       List<Offset> restrictedControlPoints = List<Offset>.from(actionStack.last[DrawAction.moveControlPoint]["restricted_control_points"]);
//       var editingCurveIndex = actionStack.last[DrawAction.moveControlPoint]["editing_curve_index"];
//       // var selectedPointIndex = actionStack.last[DrawAction.moveControlPoint]["selected_point_index"];
//       // bool restricted = actionStack.last[DrawAction.moveControlPoint]["restricted"];
//       setState(() {
//         pointDrawCollection[editingCurveIndex].points = controlPoints;
//         if(pointDrawCollection[editingCurveIndex].mode == EditingMode.group){
//           int curveIndex = actionStack.last[DrawAction.moveControlPoint]["index_of_grouped_path"];
//           int from = actionStack.last[DrawAction.moveControlPoint]["grouped_path_control_point_from"];
//           int to = actionStack.last[DrawAction.moveControlPoint]["grouped_path_control_point_to"];
//           int restrictedFrom = actionStack.last[DrawAction.moveControlPoint]["grouped_restricted_path_control_point_from"];
//           int restrictedTo = actionStack.last[DrawAction.moveControlPoint]["grouped_restricted_path_control_point_to"];
//           if(from < to){
//             (pointDrawCollection[editingCurveIndex] as PointDrawGroup).group[curveIndex].points = controlPoints.sublist(from, to);
//           }
//           if(restrictedFrom < restrictedTo){
//             (pointDrawCollection[editingCurveIndex] as PointDrawGroup).group[curveIndex].rPoints = restrictedControlPoints.sublist(restrictedFrom, restrictedTo);
//           }
//         }
//         currentEditingPDIndex = editingCurveIndex;
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.addControlPoint:
//       List<Offset> controlPoints = List<Offset>.from(actionStack.last[DrawAction.addControlPoint]["control_points"]);
//       List<Offset> restrictedControlPoints = List<Offset>.from(actionStack.last[DrawAction.addControlPoint]["restricted_control_points"]);
//       var editingCurveIndex = actionStack.last[DrawAction.addControlPoint]["editing_curve_index"];
//       setState(() {
//         pointDrawCollection[editingCurveIndex].points = controlPoints;
//         pointDrawCollection[editingCurveIndex].rPoints = restrictedControlPoints;
//         currentEditingPDIndex = editingCurveIndex;
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.transformControlPoints:
//       // This action is applicable only to non-free-draw mode actions.
//       // Free-Draw mode actions does not work solely on control points but
//       // directly on the spline path created by the added control points
//       List<Offset> controlPoints = List<Offset>.from(actionStack.last[DrawAction.transformControlPoints]["control_points"]);
//       List<Offset> restrictedControlPoints = List<Offset>.from(actionStack.last[DrawAction.transformControlPoints]["restricted_control_points"]);
//       var editingCurveIndex = actionStack.last[DrawAction.transformControlPoints]["editing_curve_index"];
//       setState(() {
//         pointDrawCollection[editingCurveIndex].points = controlPoints;
//         pointDrawCollection[editingCurveIndex].rPoints = restrictedControlPoints;
//         currentEditingPDIndex = editingCurveIndex;
//       });
//       actionStack.removeLast();
//       break;
//     // case DrawAction.changeCurveAttribute:
//     //   var editingCurveIndex = actionStack.last[DrawAction.changeCurveAttribute]["editing_curve_index"];
//     //   setState(() {
//     //     for(MapEntry<String, dynamic> attribute in actionStack.last[DrawAction.changeCurveAttribute].entries){
//     //       if(attribute.key != "editing_curve_index"){
//     //         pointDrawCollection[editingCurveIndex][attribute.key] = attribute.value;
//     //       }
//     //     }
//     //     actionStack.removeLast();
//     //   });
//     //   break;
//     case DrawAction.changePaintShader:
//       // Unimplemented case;
//       break;
//     case DrawAction.changeFillColor:
//       // Color color = actionStack.last[DrawAction.changeFillColor]["original_fill_color"];
//       var editingCurveIndex = actionStack.last[DrawAction.changeFillColor]["editing_curve_index"];
//       setState(() {
//         if(editingCurveIndex != null){
//           pointDrawCollection[editingCurveIndex].fPaint.color = actionStack.last[DrawAction.changeFillColor]["original_curve_fill_color"];
//           pointDrawCollection[editingCurveIndex].filled = actionStack.last[DrawAction.changeFillColor]["original_filled_attribute"];
//         }
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.changePaintColor:
//       var editingCurveIndex = actionStack.last[DrawAction.changePaintColor]["editing_curve_index"];
//       setState(() {
//         if(editingCurveIndex != null){
//           pointDrawCollection[editingCurveIndex].sPaint.color = actionStack.last[DrawAction.changePaintColor]["original_curve_paint_color"];
//         }
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.changePaintStrokeWidth:
//       var editingCurveIndex = actionStack.last[DrawAction.changePaintStrokeWidth]["editing_curve_index"];
//       setState(() {
//         if(editingCurveIndex != null){
//           pointDrawCollection[editingCurveIndex].sPaint.strokeWidth = actionStack.last[DrawAction.changePaintStrokeWidth]["original_curve_paint_stroke_width"];
//         }
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.duplicateCurve:
//       var editingCurveIndex = actionStack.last[DrawAction.duplicateCurve]["editing_curve_index"];
//       setState(() {
//         pointDrawCollection.removeAt(editingCurveIndex);
//         if(currentEditingPDIndex != null && editingCurveIndex < currentEditingPDIndex){
//           currentEditingPDIndex = currentEditingPDIndex! - 1;
//         }
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.deleteCurve:
//       var editingCurveIndex = actionStack.last[DrawAction.deleteCurve]["editing_curve_index"];
//       var path = actionStack.last[DrawAction.deleteCurve]["deleted_curve"];
//       setState(() {
//         pointDrawCollection.insert(editingCurveIndex, path);
//         if(currentEditingPDIndex != null && editingCurveIndex <= currentEditingPDIndex){
//           currentEditingPDIndex = currentEditingPDIndex! + 1;
//         }
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.groupObjects:
//       int index = actionStack.last[DrawAction.groupObjects]["editing_curve_index"];
//       unGroup(pdg: pointDrawCollection[index] as PointDrawGroup, index: index, addToAction: false);
//       break;
//     case DrawAction.unGroupObjects:
//       groupSelection = actionStack.last[DrawAction.unGroupObjects]["group_selection"];
//       groupSelectedObjects(groupSelection, addToAction: false);
//       break;
//     case DrawAction.addFreeDraw:
//       var editingCurveIndex = actionStack.last[DrawAction.addFreeDraw]["editing_curve_index"];
//       setState(() {
//         pointDrawCollection.removeAt(editingCurveIndex);
//         actionStack.removeLast();
//       });
//       if(currentEditingPDIndex == editingCurveIndex){
//         deactivateCurrentActivePath();
//       }
//       break;
//     case DrawAction.transformFreeDraw:
//       var editingCurveIndex = actionStack.last[DrawAction.transformFreeDraw]["editing_curve_index"];
//       List<Offset> controlPoints = List<Offset>.from(actionStack.last[DrawAction.transformFreeDraw]["control_points"]);
//       Path originalPath = Path();
//       originalPath.addPath(actionStack.last[DrawAction.transformFreeDraw]["free_draw_spline"], Offset.zero);
//       setState(() {
//         (pointDrawCollection[editingCurveIndex] as FreeDraw).splinePath.splinePath = originalPath;
//         (pointDrawCollection[editingCurveIndex] as FreeDraw).splinePath.points = controlPoints;
//         currentEditingPDIndex = editingCurveIndex;
//         actionStack.removeLast();
//       });
//       break;
//     case DrawAction.alterBackgroundImage:
//       throw Exception("Unimplemented change background image draw action to undo.");
//     default:
//       throw Exception("Unimplemented draw action ${actionStack.last.keys.first} to undo.");
//   }
// }