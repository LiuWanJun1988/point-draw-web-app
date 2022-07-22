import 'package:flutter/material.dart';
import 'package:pointdraw/point_draw_models/keys_and_names.dart';

import 'dart:ui' as ui;

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/point_draw_background.dart';
import 'package:pointdraw/point_draw_models/action_stack.dart';
import 'package:pointdraw/point_draw_models/clipping.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/matrices.dart' show scalingXY;

class PointDrawCollection extends ChangeNotifier {

  List<PointDrawObject> collection = List<PointDrawObject>.empty(growable: true);

  int? currentEditingIndex;

  List<int> groupSelection = List<int>.empty(growable: true);

  EditingMode mode = EditingMode.none;

  ActionStack actionStack = ActionStack();

  PointDrawCollection({List<PointDrawObject>? pointDrawCollection}){
    if(pointDrawCollection != null){
      collection = pointDrawCollection;
    }
  }

  ui.Image? generatedPatternAsBackground;

  List<PointDrawObject>? generatedPatternAsObjects;

  int? addObject(object, {bool activate = true}){
    collection.add(object);
    if(activate){
      return activateLastObject();
    }
    actionStack.addAction(AddPointDrawObjectAction(curveIndex: collection.length - 1));
    notifyListeners();
    return currentEditingIndex;
  }

  void removeObjectAt(int index){
    collection.removeAt(index);
    notifyListeners();
  }

  void removeObject(PointDrawObject object){
    deactivateCurrentActiveObject(notify: false);
    object.markForRemoval = true;
    object.active = false;
    collection.remove(object);
    notifyListeners();
  }

  bool get isNotEmpty => collection.isNotEmpty;

  void clear({bool notify = true}){
    for (var element in collection) {
      element.dispose();
    }
    collection = List<PointDrawObject>.empty(growable: true);
    currentEditingIndex = null;
    mode = EditingMode.none;
    groupSelection = <int>[];
    generatedPatternAsBackground = null;
    generatedPatternAsObjects = null;
    actionStack.clear();
    if(notify){
      notifyListeners();
    }
  }

  bool get hasPatternImage => generatedPatternAsBackground != null;

  bool get hasPatternObjects => generatedPatternAsObjects != null;

  void cachePattern({ui.Image? patternImage, List<PointDrawObject>? patternObjects}){
    if(patternImage != null){
      generatedPatternAsBackground = patternImage;
      generatedPatternAsObjects = null;
      notifyListeners();
      return;
    }
    if(patternObjects != null){
      generatedPatternAsObjects = patternObjects;
      generatedPatternAsBackground = null;
      notifyListeners();
      return;
    }
  }

  void clearPatterns(){
    generatedPatternAsObjects = null;
    generatedPatternAsBackground = null;
    notifyListeners();
  }

  PointDrawObject? get currentActiveObject => currentEditingIndex != null ? collection[currentEditingIndex!] : null;

  void deactivateCurrentActiveObject({bool notify = true, bool clearGroupSelection = true}) {
    if(currentEditingIndex != null){
      collection[currentEditingIndex!].active = false;
      currentEditingIndex = null;
    }
    if(groupSelection.isNotEmpty){
      for(var i in groupSelection){
        collection[i].active = false;
      }
      if(clearGroupSelection){
        groupSelection = List<int>.empty(growable: true);
      }
    }
    mode = EditingMode.none;
    if(notify){
      notifyListeners();
    }
  }

  void activateObjectAt(int index, {bool deactivateFirst = true}){
    if(deactivateFirst){
      deactivateCurrentActiveObject(notify: false);
    }
    currentEditingIndex = index;
    collection[currentEditingIndex!].active = true;
    mode = collection[currentEditingIndex!].mode;
    notifyListeners();
  }

  int? activateLastObject({bool deactivateFirst = true}){
    if(collection.isNotEmpty){
      if(deactivateFirst){
        deactivateCurrentActiveObject(notify: false);
      }
      currentEditingIndex = collection.length - 1;
      collection.last.active = true;
      mode = collection.last.mode;
      notifyListeners();
      return currentEditingIndex;
    }
    return null;
  }

  void activateGroup(List<Map<int, EditingMode>> selectedPaths, {bool deactivateFirst = true}){
    if(deactivateFirst){
      deactivateCurrentActiveObject(notify: false);
    }
    for(Map<int, EditingMode> path in selectedPaths){
      collection[path.keys.first].active = true;
    }
  }

  void reorder(int oldId, int newId){
    if (oldId < newId){
      addAction(ReorderAction(oldId, newId - 1));
      collection.insert(newId, collection[oldId]);
      collection.removeAt(oldId);
      notifyListeners();
    } else if ( oldId > newId){
      addAction(ReorderAction(oldId, newId));
      collection.insert(newId, collection[oldId]);
      collection.removeAt(oldId + 1);
      notifyListeners();
    }
  }

  set selection(List<int> groupSelect) {
    groupSelection = groupSelect;
    notifyListeners();
  }

  int groupSelectedObjects({bool addToAction = true, List<int>? groupIndices}){
    deactivateCurrentActiveObject(notify: false, clearGroupSelection: false);
    groupIndices ??= groupSelection;
    groupIndices.sort();
    collection.add(PointDrawGroup(groupIndices.map((ind) => collection[ind]).toList(), key: ObjectKey("Group: "+generateAutoID())));
    for(int i in groupIndices.reversed){
      collection.removeAt(i);
    }
    if(addToAction){
      addAction(GroupAction(curveIndex: collection.length - 1));
    }
    groupSelection = List<int>.empty(growable: true);
    return activateLastObject(deactivateFirst: false)!;
  }

  void unGroup({bool addToAction = true, int? indexOfGroupObject}){
    indexOfGroupObject ??= currentEditingIndex;
    if(indexOfGroupObject != null && collection[indexOfGroupObject].mode == EditingMode.group){
      PointDrawGroup pointDrawGroup = collection[indexOfGroupObject] as PointDrawGroup;
      collection[indexOfGroupObject].markForRemoval = true;
      int count = 0;
      for(PointDrawObject pdo in pointDrawGroup.group.reversed){
        pdo.active = false;
        collection.insert(indexOfGroupObject, pdo);
        count++;
      }
      if(addToAction){
        addAction(UngroupAction(List<int>.generate(count, (i) => indexOfGroupObject! + i)));
      }
      currentEditingIndex = null;
      mode = EditingMode.none;
      collection.removeWhere((e) => e.markForRemoval);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> toJson(){
    return [
      for(var obj in collection)
        obj.toJson()
    ];
  }

  void updateCollection(List<PointDrawObject> pointDrawCollection){
    collection = pointDrawCollection;
    notifyListeners();
  }

  void parseObjects(List<Map<String, dynamic>> data, {bool notify = true}){
    clear(notify: false);
    for(Map<String, dynamic> obj in data){
      EditingMode mode = getEditingMode(obj[editingModeKey]);
      var pdo = getNewPointDrawObject(mode)
                  ..toObject(obj);
      pdo.active = false;
      collection.add(pdo);
    }
    if(notify){
      notifyListeners();
    }
  }

  Future<ui.Picture> getCurrentPicture(Rect canvasRect, Rect selectionRect, PointDrawBackground background) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Rect outputRect = Offset.zero & selectionRect.size;
    Canvas canvas = Canvas(recorder, outputRect);
    background.paint(canvas);
    if(hasPatternImage){
      canvas.drawImage(generatedPatternAsBackground!, Offset.zero, Paint());
    }
    if(hasPatternObjects){
      for(PointDrawObject object in generatedPatternAsObjects!){
        object.draw(canvas, 0.0, zoomTransform: Matrix4.identity());
      }
    }
    Matrix4? transform;
    if(outputRect != canvasRect){
      Offset translation = selectionRect.topLeft * -1;
      transform = Matrix4.translationValues(translation.dx, translation.dy, 0);
    }
    for(int i = 0; i < collection.length; i++){
      if(collection[i].isInitialized){
        collection[i].draw(canvas, 0, zoomTransform: transform ?? Matrix4.identity());
        if(collection[i].mode == EditingMode.text){
          (collection[i] as PointDrawText).draw(canvas, 0, zoomTransform: transform ?? Matrix4.identity(), drawText: false);
        }
      } else {
        collection[i].markForRemoval = true;
      }
    }
    collection.removeWhere((element) => element.markForRemoval);
    notifyListeners();
    return recorder.endRecording();
  }

  Future<ui.Picture> generatePreview(Rect canvasRect, Size previewSize) async {
    Offset scalingOffset = Offset(previewSize.width / canvasRect.width, previewSize.height / canvasRect.height);
    Matrix4 scalingMat = scalingXY(scalingOffset, Offset.zero);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder, canvasRect);
    for(int i = 0; i < collection.length; i++){
      if(collection[i].isInitialized){
        collection[i].draw(canvas, 0, zoomTransform: scalingMat);
        if(collection[i].mode == EditingMode.text){
          (collection[i] as PointDrawText).draw(canvas, 0, zoomTransform: scalingMat, drawText: false);
        }
      } else {
        collection[i].markForRemoval = true;
      }
    }
    collection.removeWhere((element) => element.markForRemoval);
    notifyListeners();
    return recorder.endRecording();
  }

  bool get actionStackHasActions => actionStack.isNotEmpty;

  void addAction(PointDrawAction action, {bool checkLast = false}){
    if(checkLast && action.action == actionStack.lastAction.action){
      return;
    }
    actionStack.addAction(action);
  }

  void undoLastAction(StateSetter stateSetter, {Map<String, dynamic>? args, bool notify = true}){
    deactivateCurrentActiveObject();
    args?["ungroup"] = unGroup;
    args?["group"] = groupSelectedObjects;
    actionStack.undoLastAction(collection, stateSetter, args: args);
    if(notify){
      notifyListeners();
    }
  }

  bool get hasRedoAction => actionStack.hasRedoAction;

  void redoUndoneAction(StateSetter stateSetter, {Map<String, dynamic>? args, bool notify = true}){
    actionStack.redoAction(collection, stateSetter, args: args);
    if(notify){
      notifyListeners();
    }
  }
}

mixin PointDrawScene {

  ui.PictureRecorder recorder = ui.PictureRecorder();

  ui.SceneBuilder builder = ui.SceneBuilder();

  Canvas? _canvas;

  void displayScene(){
    WidgetsFlutterBinding.ensureInitialized().window.render(builder.build());
  }

  void startRecording(Rect rect){
    _canvas = Canvas(recorder, rect);
  }

  void recordDraw(PointDrawCollection collection, Rect rect){
    startRecording(rect);
    for(int i = 0; i < collection.collection.length; i++){
      if(collection.collection[i].isInitialized){
        collection.collection[i].draw(_canvas!, 0, zoomTransform: Matrix4.identity());
        if(collection.collection[i].mode == EditingMode.text){
          (collection.collection[i] as PointDrawText).draw(_canvas!, 0, zoomTransform: Matrix4.identity(), drawText: false);
        }
      }
    }
  }

  void addPicture(PointDrawCollection collection, Rect rect){
    recordDraw(collection, rect);
    builder.addPicture(Offset.zero, recorder.endRecording());
    recorder = ui.PictureRecorder();
    _canvas = null;
  }


}