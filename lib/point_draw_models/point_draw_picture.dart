import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:pointdraw/point_draw_models/keys_and_names.dart';

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/point_draw_collection.dart';
import 'package:pointdraw/point_draw_models/point_draw_background.dart';

class PointDrawPictureMeta extends ChangeNotifier{

  String folderId;

  String folderName;

  String? drawingId;

  String? drawingName;

  PointDrawPictureMeta({this.folderId = "", this.folderName = "portfolio", this.drawingId, this.drawingName = "default_drawing_name"});

  void parse(Map<String, dynamic> data){
    folderId = data[folderIdKey];
    folderName = data[folderNameKey];
    drawingId = data[drawingIdKey];
    drawingName = data[drawingNameKey];
    if(data.containsKey(canvasWidthKey)){
      width = data[canvasWidthKey];
    }
    if(data.containsKey(canvasHeightKey)){
      height = data[canvasHeightKey];
    }
  }

  double? width;

  double? height;

  PointDrawCollection? pointDrawCollection;

  PointDrawBackground? pointDrawBackground;

  void saveSize(double w, double h){
    width = w;
    height = h;
  }

  void saveCollectionRef(PointDrawCollection collection){
    pointDrawCollection = collection;
  }

  void saveBackgroundRef(PointDrawBackground background){
    pointDrawBackground = background;
  }
}