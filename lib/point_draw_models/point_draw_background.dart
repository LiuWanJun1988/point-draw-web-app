import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import 'dart:ui' as ui;
import 'dart:typed_data' show Uint8List;
import 'dart:async' show Completer;

import 'package:pointdraw/point_draw_models/keys_and_names.dart';
import 'package:pointdraw/point_draw_models/point_draw_state_notifier.dart';
import 'package:pointdraw/point_draw_models/shader_parameters.dart';
import 'package:pointdraw/point_draw_models/utilities/utils.dart';


enum ImageSrc{local, network, none}

class PointDrawBackground extends PointDrawStateNotifier{

  EditingMode mode = EditingMode.background;

  Color fill = Colors.transparent;

  ui.Image? backgroundImage;

  List<ShaderParameters> shaders = [];

  PointDrawBackground({this.fill = Colors.white, this.backgroundImage});

  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = {
      editingModeKey: mode.name,
      fillColorKey: [fill.alpha, fill.red, fill.green, fill.blue],
      shadersListKey: [
        for(int i = 0; i < shaders.length; i++)
          shaders[i].toJson(),
      ],
      imageIdentifierKey: imageIdentifier ?? "",
      imageOffsetXKey: imageOffset.dx,
      imageOffsetYKey: imageOffset.dy,
      imageURLKey: imageURL,
      imageSrcKey: imageSrc.name,
    };
    return data;
  }

  bool toObject(Map<String, dynamic> data, {bool notify = true}){
    mode = getEditingMode(data[editingModeKey]);
    List fillData = data[fillColorKey];
    fill = Color.fromARGB(fillData[0], fillData[1], fillData[2], fillData[3]);
    List shadersData = data[shadersListKey];
    shaders = List<ShaderParameters>.generate(shadersData.length, (ind){
      return ShaderParameters.fromData(shadersData[ind]);
    });
    imageIdentifier = data[imageIdentifierKey];
    imageOffset = Offset(data[imageOffsetXKey], data[imageOffsetYKey]);
    imageURL = data[imageURLKey];
    if(notify){
      notifyListeners();
    }
    return imageURL != null && imageURL!.isNotEmpty;
  }

  void addShader(ShaderParameters shaderParameters){
    // var shader = shaderParameters.build();
    shaders.add(shaderParameters);
    notifyListeners();
  }

  void removeShaderAt(int index){
    // var shader = shaderParameters.build();
    shaders.removeAt(index);
    notifyListeners();
  }

  void paint(Canvas canvas,
      {Color? backgroundColor,
      List<ShaderParameters>? shaderParams,
      ui.Image? image}){
    canvas.drawPaint(Paint()..color = backgroundColor ?? fill);
    shaderParams ??= shaders;
    for(int i = 0; i < shaderParams.length; i++){
      canvas.drawPaint(
          Paint()
            ..shader = shaders[i].build()
            ..style = PaintingStyle.fill
      );
    }

    if(image != null){
      canvas.drawImage(image, Offset.zero, Paint());
    } else if (backgroundImage != null){
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }

  }

  bool get hasBackground => fill != Colors.white || backgroundImage != null || shaders.isNotEmpty;

  bool get hasBackgroundImage => backgroundImage != null && (_imageFilePath != null || imageURL != null);

  String? imageIdentifier;

  String? _imageFilePath;

  String _imageFileType = "image";

  String? imageURL;

  ImageSrc get imageSrc => _imageFilePath != null ? ImageSrc.local : (imageURL != null ? ImageSrc.network : ImageSrc.none);

  set imageName(String name) => imageIdentifier = name;

  Offset imageOffset = Offset.zero;

  int preferredImageWidth = 0;

  int preferredImageHeight = 0;

  BlendMode imageBlendMode = BlendMode.srcOver;

  void updateBlendMode(BlendMode mode){
    imageBlendMode = mode;
    notifyListeners();
  }

  void removeBackgroundImage({bool notify = true}){
    backgroundImage?.dispose();
    backgroundImage = null;
    imageOffset = Offset.zero;
    imageIdentifier = null;
    _imageFilePath = null;
    imageURL = null;
    preferredImageHeight = 0;
    preferredImageWidth = 0;
    imageBlendMode = BlendMode.srcOver;
    if(notify){
      notifyListeners();
    }
  }

  void updateImageOffset(Offset offset){
    imageOffset = offset;
    notifyListeners();
  }

  void updatePreferredSize({int? width, int? height}){
    if(width != null){
      preferredImageWidth = width;
      notifyListeners();
      return;
    }
    if(height != null){
      preferredImageHeight = height;
      notifyListeners();
      return;
    }
  }

  void clear({bool notify = true}){
    removeBackgroundImage(notify: false);
    fill = Colors.white;
    shaders.map((e) => e.dispose());
    shaders = List<ShaderParameters>.empty(growable: true);
    if(notify){
      notifyListeners();
    }
  }

  Future<void> buildImage({XFile? imageFile, Uint8List? rawData, String? imageName}) async {
    Uint8List data = Uint8List(0);
    if(rawData != null){
      data = rawData;
    }
    if(imageFile != null){
      _imageFilePath = imageFile.path;
      data = await imageFile.readAsBytes();
    }
    final Completer<ui.Image> completer = Completer();
    if(data.isNotEmpty){
      ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
        preferredImageHeight = img.height;
        preferredImageWidth = img.width;
        debugPrint("width: $preferredImageWidth");
        debugPrint("height: $preferredImageHeight");
        return completer.complete(img);
      });
      imageIdentifier = imageFile!.name.split(".").first;
      _imageFileType = imageFile.name.split(".").last;
      backgroundImage = await completer.future;
      notifyListeners();
    } else {
      throw Exception("Check usage of this method. Must be called with either non-null imageFile or non-empty rawData");
    }
  }

  void updateBackgroundColor(Color color){
    fill = color;
    notifyListeners();
  }

  String get fileType => _imageFileType;

  XFile? getImageFile(){
    if(_imageFilePath != null){
      return XFile(_imageFilePath!, name: imageIdentifier, mimeType: _imageFileType);
    }
    return null;
  }

  void reorder(int oldId, int newId){
    if (oldId < newId){
      shaders.insert(newId, shaders[oldId]);
      shaders.removeAt(oldId);
      notifyListeners();
    } else if ( oldId > newId){
      shaders.insert(newId, shaders[oldId]);
      shaders.removeAt(oldId + 1);
      notifyListeners();
    }
  }

}