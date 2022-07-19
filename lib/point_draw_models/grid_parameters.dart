import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:math' show min, max;

import 'package:pointdraw/point_draw_models/utilities/matrices.dart' show scaleThenTranslate;
import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart' show incrementZoomFactor, decrementZoomFactor;

class GridParameters extends ChangeNotifier{

  double canvasWidth = 0;

  double canvasHeight = 0;

  Offset canvasCenter = Offset.zero;

  bool gridEnabled = false;

  bool rulerEnabled = true;

  bool snapToGridNode = false;

  double gridHorizontalGap = 40.0;

  double gridVerticalGap = 40.0;

  double zoomFactor = 1.0;

  Offset panOffset = Offset.zero;

  bool isInfiniteCanvas = false;

  late Rect canvasRect;

  late Matrix4 zoomTransform;

  GridParameters(
      this.canvasWidth,
      this.canvasHeight,
      this.canvasCenter,
      {
        this.gridEnabled = false,
        this.rulerEnabled = true,
        this.snapToGridNode = false,
        this.gridHorizontalGap = 40.0,
        this.gridVerticalGap = 40.0,
        this.zoomFactor = 1.0,
        this.panOffset = Offset.zero,
      }) {
    zoomTransform = scaleThenTranslate(zoomFactor, panOffset);
    canvasRect = Rect.fromCenter(center: canvasCenter, width: canvasWidth, height: canvasHeight);
  }

  GridParameters.fromDocument(DocumentSnapshot<Map<String, dynamic>?> snapshot){
    Map<String, dynamic>? data = snapshot.data();
    if(data?.containsKey(rulerEnabledKey) ?? false){
      canvasWidth = data![canvasWidthKey];
      canvasHeight = data[canvasHeightKey];
      canvasCenter = Offset(data[canvasCenterXKey], data[canvasCenterYKey]);
      gridEnabled = data[gridEnabledKey];
      rulerEnabled = data[rulerEnabledKey];
      snapToGridNode = data[snapToGridNodesKey];
      gridHorizontalGap = data[gridHorizontalGapKey];
      gridVerticalGap = data[gridVerticalGapKey];
      zoomFactor = data[zoomFactorKey];
      Map<String, double> panOffsetMap = Map<String, double>.from(data[panOffsetKey]);
      panOffset = Offset(panOffsetMap['x'] ?? 0, panOffsetMap['y'] ?? 0);
      zoomTransform = scaleThenTranslate(zoomFactor, panOffset);
    }
  }

  void update({
    bool? toggleGrid,
    bool? toggleRuler,
    bool? toggleSnapToGridNodes,
    double? newGridHorizontalGap,
    double? newGridVerticalGap,
    double? newZoomFactor,
    Offset? offset,
    bool? toggleInfiniteCanvas = false,
  }){
    if(toggleGrid != null){
      gridEnabled = toggleGrid;
    }
    if(toggleRuler != null){
      rulerEnabled = toggleRuler;
    }
    if(toggleSnapToGridNodes != null){
      snapToGridNode = toggleSnapToGridNodes;
    }
    if(newGridHorizontalGap != null){
      gridHorizontalGap = newGridHorizontalGap;
    }
    if(newGridVerticalGap != null){
      gridVerticalGap = newGridVerticalGap;
    }
    if(newZoomFactor != null){
      zoomFactor = newZoomFactor;
    }
    if(offset != null){
      if(isInfiniteCanvas){
        panOffset = offset;
      } else {
        panOffset = Offset(
            min(max(offset.dx, -(canvasWidth * (zoomFactor - 1))), 0),
            min(max(offset.dy, -(canvasHeight * (zoomFactor - 1))), 0)
        );
      }
    }
    if(newZoomFactor != null || offset != null){
      zoomTransform = scaleThenTranslate(zoomFactor, panOffset);
    }
    if(toggleInfiniteCanvas != null){
      isInfiniteCanvas = toggleInfiniteCanvas;
    }
    notifyListeners();
  }

  void updateFrom(GridParameters parameters){
    canvasWidth = parameters.canvasWidth;
    canvasHeight = parameters.canvasHeight;
    canvasRect = parameters.canvasRect;
    canvasCenter = parameters.canvasCenter;
    gridEnabled = parameters.gridEnabled;
    rulerEnabled = parameters.rulerEnabled;
    snapToGridNode = parameters.snapToGridNode;
    gridHorizontalGap = parameters.gridHorizontalGap;
    gridVerticalGap = parameters.gridVerticalGap;
    zoomFactor = parameters.zoomFactor;
    panOffset = parameters.panOffset;
    zoomTransform = parameters.zoomTransform;
    notifyListeners();
  }

  void updateZoomParameters(bool incrementZoom, Size canvasSize){
    if (incrementZoom){
      zoomFactor = incrementZoomFactor(zoomFactor);
    } else {
      zoomFactor = decrementZoomFactor(zoomFactor);
    }
    panOffset = Offset(
        min(max(panOffset.dx, -(canvasSize.width * (zoomFactor - 1))), 0),
        min(max(panOffset.dy, -(canvasSize.height * (zoomFactor - 1))), 0)
    );
    zoomTransform = scaleThenTranslate(zoomFactor, panOffset);
    notifyListeners();
  }

  Map<String, dynamic> toJson(){
    return {
      canvasWidthKey: canvasWidth,
      canvasHeightKey: canvasHeight,
      canvasCenterXKey: canvasCenter.dx,
      canvasCenterYKey: canvasCenter.dy,
      gridEnabledKey: gridEnabled,
      rulerEnabledKey: rulerEnabled,
      snapToGridNodesKey: snapToGridNode,
      gridHorizontalGapKey: gridHorizontalGap,
      gridVerticalGapKey: gridVerticalGap,
      zoomFactorKey: zoomFactor,
      panOffsetKey: {'x': panOffset.dx, 'y': panOffset.dy}
    };
  }

  Color? colorExtracted;

  void storeColorExtracted(Color color){
    colorExtracted = color;
    notifyListeners();
  }

  void Function({bool? toggle})? enterColorExtractionMode;

  void registerColorExtraction(void Function({bool? toggle}) call){
    if(enterColorExtractionMode == null){
      enterColorExtractionMode = call;
      notifyListeners();
    }
  }

}