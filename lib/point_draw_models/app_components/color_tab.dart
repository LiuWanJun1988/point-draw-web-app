import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:async' show Timer;
import 'dart:math' show max, min, pi;

import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart' show defaultPanelElevation, controlPointSize;
import 'package:pointdraw/point_draw_models/app_components/color_palette.dart';
import 'package:pointdraw/point_draw_models/app_components/plus_minus_button.dart';
import 'package:pointdraw/point_draw_models/utilities/fast_draw.dart';
import 'package:pointdraw/point_draw_models/point_draw_objects.dart' show PointDrawObject;
import 'package:pointdraw/point_draw_models/grid_parameters.dart';

class ColorSelector extends StatefulWidget {
  final Color? initialColor;
  final Color alphaBarColor;
  final void Function(Color) updateColor;
  final void Function() updateActionStack;
  const ColorSelector(this.alphaBarColor, {Key? key, required this.updateColor, required this.updateActionStack, this.initialColor}) : super(key: key);

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {

  late Color color;
  late Color shadeColor;
  Offset colorPointer = const Offset(50, 100);
  Offset shadePointer = const Offset(33, 100);
  Offset alphaPointer = const Offset(16, 186);
  final Offset circularPaletteCenter = const Offset(100, 100);
  final Offset colorPointerAdjuster = const Offset(5, 0);
  final Offset rectangularPaletteCenter = const Offset(10, 100);

  void updateColor({DragDownDetails? dt, DragUpdateDetails? panDt}){
    Offset displacement = (dt?.localPosition ?? panDt!.localPosition) - circularPaletteCenter;
    setState(() {
      colorPointer = circularPaletteCenter + Offset.fromDirection(displacement.direction, min(displacement.distance, 100)) + colorPointerAdjuster;
      color = getColorFromPalette(displacement.direction / pi, 1 - displacement.distance / 100) ?? color;
      shadePointer = Offset(shadePointer.dx, 100);
      alphaPointer = Offset(alphaPointer.dx, 186);
      Colors.green;
    });
    widget.updateColor(color);
  }

  void updateShade({DragDownDetails? dt, DragUpdateDetails? panDt, bool pointer = false}){
    Offset offset;
    if(pointer){
      offset = shadePointer + panDt!.delta;
    } else {
      offset = dt?.localPosition ?? panDt!.localPosition;
    }
    setState(() {
      shadePointer = Offset(shadePointer.dx, max(min(offset.dy, 190), 10));
      shadeColor = getGradientColor(color, (shadePointer.dy - 10) / 180) ?? shadeColor;
    });
    widget.updateColor(shadeColor);
  }

  void updateAlpha({DragDownDetails? dt, DragUpdateDetails? panDt, bool pointer = false}){
    Offset offset;
    if(pointer){
      offset = alphaPointer + panDt!.delta;
    } else {
      offset = dt?.localPosition ?? panDt!.localPosition;
    }
    int a = min(max(((offset.dy - 10)/ 180 * 255), 0).round(), 255);
    setState(() {
      alphaPointer = Offset(alphaPointer.dx, max(min(offset.dy, 190), 10));
      shadeColor = Color.fromARGB(a, shadeColor.red, shadeColor.green, shadeColor.blue);
    });
    widget.updateColor(shadeColor);
  }

  @override
  void initState(){
    super.initState();
    color = widget.initialColor!;
    shadeColor = color;
  }

  @override
  Widget build(BuildContext context) {
    const Widget spacing = SizedBox(width: 10);
    return Stack(
      children: [
        SizedBox(
          width: 300,
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 200,
                child: GestureDetector(
                  onPanDown:(dt){
                    widget.updateActionStack.call();
                    updateColor(dt: dt);
                  },
                  onPanUpdate: (dt){
                    updateColor(panDt: dt);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: CircularColorPalette(
                    200,
                    200,
                    color,)
                ),
              ),
              spacing,
              Container(
                padding: const EdgeInsets.only(right: 4.0),
                width: 50,
                height: 200,
                child: GestureDetector(
                  onPanDown: (dt){
                    widget.updateActionStack.call();
                    updateShade(dt: dt);
                  },
                  onPanUpdate: (dt){
                    updateShade(panDt: dt);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: RectangularShadesPalette(
                    50,
                    200,
                    color),
                ),
              ),
              spacing,
              Container(
                padding: const EdgeInsets.only(right:4.0),
                width: 8,
                height: 200,
                alignment: Alignment.center,
                child: GestureDetector(
                  onPanDown: (dt){
                    widget.updateActionStack.call();
                    updateAlpha(dt: dt);
                  },
                  onPanUpdate: (dt){
                    updateAlpha(panDt: dt);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AlphaBar(8, 200, widget.alphaBarColor),
                ),
              )
            ],
          )
        ),
        Positioned(
          top: colorPointer.dy - 2.5,
          left: colorPointer.dx - 2.5,
          child: const Material(
            color: Colors.transparent,
            shape: CircleBorder(
              side: BorderSide(width:1.0, color: Colors.black)
            ),
            child: SizedBox(
              width: 5,
              height: 5,
            )
          )
        ),
        Positioned(
          top: shadePointer.dy - 2.5,
          right: shadePointer.dx,
          child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.5),
                  side: const BorderSide(width:1.0, color: Colors.black)
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (dt){
                  updateShade(panDt: dt, pointer: true);
                },
                child: const SizedBox(
                  width: 50,
                  height: 5,
                ),
              )
          )
        ),
        Positioned(
            top: alphaPointer.dy - 4,
            right: alphaPointer.dx,
            child: Material(
                color: Colors.white,
                shape: const CircleBorder(
                    side: BorderSide(width:1.0, color: Colors.black)
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (dt){
                    updateAlpha(panDt: dt, pointer: true);
                  },
                  child: const SizedBox(
                      width: 8,
                      height: 8,
                  ),
                ),
            )
        )
      ],
    );
  }
}

class ColorTab extends StatefulWidget {

  final PaintingStyle tabPaintingStyle;
  const ColorTab(this.tabPaintingStyle, {Key? key}) : super(key: key);

  @override
  State<ColorTab> createState() => _ColorTabState();
}

class _ColorTabState extends State<ColorTab> {
  AnchorColor strokeAnchorColor = AnchorColor.red;
  AnchorColor fillAnchorColor = AnchorColor.red;
  int strokeAnchorColorValue = 64;
  int fillAnchorColorValue = 0;
  late Timer colorChangeTimer;
  int strokeRedInt = 64;
  int strokeGreenInt = 96;
  int strokeBlueInt = 255;
  int strokeAlphaInt = 255;
  int fillRedInt = 64;
  int fillGreenInt = 96;
  int fillBlueInt = 255;
  int fillAlphaInt = 255;
  Offset strokeColorPickerCursor = const Offset(255, 96);
  Offset fillColorPickerCursor = const Offset(255, 96);
  Offset? gradientPointer;
  Color gradientColor = const Color.fromARGB(255, 64, 96, 255);
  Color strokePendingColor = const Color.fromARGB(255, 64, 96, 255);
  Color fillPendingColor = const Color.fromARGB(255, 64, 96, 255);


  void changeRed(bool increment, String colorReceiver){
    if(increment){
      if(colorReceiver == "Stroke" && strokeRedInt <= 252){
        setState((){
          strokeRedInt += 3;
          if(strokeAnchorColor == AnchorColor.red){
            strokeAnchorColorValue = strokeRedInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeRedInt < 255){
        setState((){
          strokeRedInt = 255;
          if(strokeAnchorColor == AnchorColor.red){
            strokeAnchorColorValue = strokeRedInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillRedInt <= 252){
        setState((){
          fillRedInt += 3;
          if(fillAnchorColor == AnchorColor.red){
            fillAnchorColorValue = fillRedInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillRedInt < 255){
        setState((){
          fillRedInt = 255;
          if(fillAnchorColor == AnchorColor.red){
            fillAnchorColorValue = fillRedInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    } else {
      if(colorReceiver == "Stroke" && strokeRedInt >= 3){
        setState((){
          strokeRedInt -= 3;
          if(strokeAnchorColor == AnchorColor.red){
            strokeAnchorColorValue = strokeRedInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeRedInt > 0){
        setState((){
          strokeRedInt = 0;
          if(strokeAnchorColor == AnchorColor.red){
            strokeAnchorColorValue = strokeRedInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillRedInt >= 3){
        setState((){
          fillRedInt -= 3;
          if(fillAnchorColor == AnchorColor.red){
            fillAnchorColorValue = fillRedInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillRedInt > 0){
        setState((){
          fillRedInt = 0;
          if(fillAnchorColor == AnchorColor.red){
            fillAnchorColorValue = fillRedInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    }
    moveColorPickerCursor(colorReceiver);
  }

  void changeGreen(bool increment, String colorReceiver){
    if(increment){
      if(colorReceiver == "Stroke" && strokeGreenInt <= 252){
        setState((){
          strokeGreenInt += 3;
          if(strokeAnchorColor == AnchorColor.green){
            strokeAnchorColorValue = strokeGreenInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeGreenInt < 255){
        setState((){
          strokeGreenInt = 255;
          if(strokeAnchorColor == AnchorColor.green){
            strokeAnchorColorValue = strokeGreenInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillGreenInt <= 252){
        setState((){
          fillGreenInt += 3;
          if(fillAnchorColor == AnchorColor.green){
            fillAnchorColorValue = fillGreenInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillGreenInt < 255){
        setState((){
          fillGreenInt = 255;
          if(fillAnchorColor == AnchorColor.green){
            fillAnchorColorValue = fillGreenInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    } else {
      if(colorReceiver == "Stroke" && strokeGreenInt >= 3){
        setState((){
          strokeGreenInt -= 3;
          if(strokeAnchorColor == AnchorColor.green){
            strokeAnchorColorValue = strokeGreenInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeGreenInt > 0){
        setState((){
          strokeGreenInt = 0;
          if(strokeAnchorColor == AnchorColor.green){
            strokeAnchorColorValue = strokeGreenInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillGreenInt >= 3){
        setState((){
          fillGreenInt -= 3;
          if(fillAnchorColor == AnchorColor.green){
            fillAnchorColorValue = fillGreenInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillGreenInt > 0){
        setState((){
          fillGreenInt = 0;
          if(fillAnchorColor == AnchorColor.green){
            fillAnchorColorValue = fillGreenInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    }
    moveColorPickerCursor(colorReceiver);
  }

  void changeBlue(bool increment, String colorReceiver){
    if(increment){
      if(colorReceiver == "Stroke" && strokeBlueInt <= 252){
        setState((){
          strokeBlueInt += 3;
          if(strokeAnchorColor == AnchorColor.blue){
            strokeAnchorColorValue = strokeBlueInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeBlueInt < 255){
        setState((){
          strokeBlueInt = 255;
          if(strokeAnchorColor == AnchorColor.blue){
            strokeAnchorColorValue = strokeBlueInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillBlueInt <= 252){
        setState((){
          fillBlueInt += 3;
          if(fillAnchorColor == AnchorColor.blue){
            fillAnchorColorValue = fillBlueInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillBlueInt < 255){
        setState((){
          fillBlueInt = 255;
          if(fillAnchorColor == AnchorColor.blue){
            fillAnchorColorValue = fillBlueInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    } else {
      if(colorReceiver == "Stroke" && strokeBlueInt >= 3){
        setState((){
          strokeBlueInt -= 3;
          if(strokeAnchorColor == AnchorColor.blue){
            strokeAnchorColorValue = strokeBlueInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeBlueInt > 0){
        setState((){
          strokeBlueInt = 0;
          if(strokeAnchorColor == AnchorColor.blue){
            strokeAnchorColorValue = strokeBlueInt;
          }
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillBlueInt >= 3){
        setState((){
          fillBlueInt -= 3;
          if(fillAnchorColor == AnchorColor.blue){
            fillAnchorColorValue = fillBlueInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillBlueInt > 0){
        setState((){
          fillBlueInt = 0;
          if(fillAnchorColor == AnchorColor.blue){
            fillAnchorColorValue = fillBlueInt;
          }
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    }
    moveColorPickerCursor(colorReceiver);
  }

  void changeAlpha(bool increment, String colorReceiver){
    if(increment){
      if(colorReceiver == "Stroke" && strokeAlphaInt <= 252){
        setState((){
          strokeAlphaInt += 3;
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeAlphaInt < 255){
        setState((){
          strokeAlphaInt = 255;
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillAlphaInt <= 252){
        setState((){
          fillAlphaInt += 3;
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillAlphaInt < 255){
        setState((){
          fillAlphaInt = 255;
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    } else {
      if(colorReceiver == "Stroke" && strokeAlphaInt >= 3){
        setState((){
          strokeAlphaInt -= 3;
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if (colorReceiver == "Stroke" && strokeAlphaInt > 0){
        setState((){
          strokeAlphaInt = 0;
          strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
        });
      } else if(colorReceiver == "Fill" && fillAlphaInt >= 3){
        setState((){
          fillAlphaInt -= 3;
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      } else if (colorReceiver == "Fill" && fillAlphaInt > 0){
        setState((){
          fillAlphaInt = 0;
          fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
        });
      }
    }
  }

  Future<void> startChangeColorValues(AnchorColor anchorColor, bool increment, String colorReceiver) async {
    switch(anchorColor){
      case AnchorColor.red:
        colorChangeTimer = Timer.periodic(
            const Duration(milliseconds: 30),
                (_timer){
              changeRed(increment, colorReceiver);
            });
        break;
      case AnchorColor.green:
        colorChangeTimer = Timer.periodic(
            const Duration(milliseconds: 30),
                (_timer){
              changeGreen(increment, colorReceiver);
            });
        break;
      case AnchorColor.blue:
        colorChangeTimer = Timer.periodic(
            const Duration(milliseconds: 30),
                (_timer){
              changeBlue(increment, colorReceiver);
            });
        break;
      case AnchorColor.alpha:
        colorChangeTimer = Timer.periodic(
            const Duration(milliseconds: 30),
                (_timer){
              changeAlpha(increment, colorReceiver);
            });
        break;
      default:
        break;
    }
  }

  void moveColorPickerCursor(String colorReceiver, {TapDownDetails? tapDownDetails, DragUpdateDetails? dragDetails}){
    if(colorReceiver == "Stroke" && tapDownDetails != null){
      setState((){
        strokeColorPickerCursor = tapDownDetails.localPosition;
      });
    } else if (colorReceiver == "Stroke" && dragDetails != null ){
      setState((){
        strokeColorPickerCursor = dragDetails.localPosition;
      });
    } else if(colorReceiver == "Fill" && tapDownDetails != null){
      setState((){
        fillColorPickerCursor = tapDownDetails.localPosition;
      });
    } else if (colorReceiver == "Fill" && dragDetails != null ){
      setState((){
        fillColorPickerCursor = dragDetails.localPosition;
      });
    } else {
      switch(colorReceiver == "Stroke" ? strokeAnchorColor : fillAnchorColor){
        case AnchorColor.red:
          if(colorReceiver == "Stroke"){
            setState((){
              strokeColorPickerCursor = Offset(strokeBlueInt / 1, strokeGreenInt / 1);
            });
          } else if (colorReceiver == "Fill"){
            setState((){
              fillColorPickerCursor = Offset(fillBlueInt / 1, fillGreenInt / 1);
            });
          }
          break;
        case AnchorColor.green:
          if(colorReceiver == "Stroke"){
            setState((){
              strokeColorPickerCursor = Offset(strokeBlueInt / 1, strokeRedInt / 1);
            });
          } else if (colorReceiver == "Fill"){
            setState((){
              fillColorPickerCursor = Offset(fillBlueInt / 1, fillRedInt / 1);
            });
          }
          break;
        case AnchorColor.blue:
          if(colorReceiver == "Stroke"){
            setState((){
              strokeColorPickerCursor = Offset(strokeGreenInt / 1, strokeRedInt / 1);
            });
          } else if (colorReceiver == "Fill"){
            setState((){
              fillColorPickerCursor = Offset(fillGreenInt / 1, fillRedInt / 1);
            });
          }
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget colorTab(Rect paletteRect, String colorReceiver){
    return Material(
      elevation: defaultPanelElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide.none
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
          width: 268,
          padding: EdgeInsets.zero,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                GestureDetector(
                  onPanUpdate: (dt){
                    if(colorReceiver == "Stroke"){
                      setState((){

                      });
                    } else if (colorReceiver == "Fill"){
                      setState((){

                      });
                    }
                  },
                  child: Material(
                    color: Colors.orange,
                    child: Container(
                      width: 268,
                      height: 20,
                      constraints: const BoxConstraints(
                          minWidth: 200
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text("$colorReceiver color", style: const TextStyle(fontSize: 16, color: Colors.white)
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                      width: 262,
                      height: 260,
                      child: GestureDetector(
                        onTapDown:(dt){
                          if(paletteRect.contains(dt.localPosition)){
                            int red, green, blue;
                            switch (colorReceiver == "Stroke" ? strokeAnchorColor : fillAnchorColor) {
                              case AnchorColor.red:
                                red = colorReceiver == "Stroke" ? strokeRedInt : fillRedInt;
                                green = (dt.localPosition.dy - 1) ~/ 1;
                                blue = (dt.localPosition.dx - 1) ~/ 1;
                                break;
                              case AnchorColor.green:
                                green = colorReceiver == "Stroke" ? strokeGreenInt : fillGreenInt;
                                red = (dt.localPosition.dy - 1) ~/ 1;
                                blue = (dt.localPosition.dx - 1) ~/ 1;
                                break;
                              case AnchorColor.blue:
                                blue = colorReceiver == "Stroke" ? strokeBlueInt : fillBlueInt;
                                red = (dt.localPosition.dy - 1) ~/ 1;
                                green = (dt.localPosition.dx - 1) ~/ 1;
                                break;
                              default:
                                if(colorReceiver == "Stroke"){
                                  red = strokeRedInt;
                                  green = strokeGreenInt;
                                  blue = strokeBlueInt;
                                } else {
                                  red = fillRedInt;
                                  green = fillGreenInt;
                                  blue = fillBlueInt;
                                }
                                break;
                            }
                            moveColorPickerCursor(colorReceiver, tapDownDetails: dt);
                            if(colorReceiver == "Stroke"){
                              setState((){
                                strokeRedInt = red;
                                strokeGreenInt = green;
                                strokeBlueInt = blue;
                                strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
                              });
                            } else if (colorReceiver == "Fill") {
                              setState(() {
                                fillRedInt = red;
                                fillGreenInt = green;
                                fillBlueInt = blue;
                                fillPendingColor = Color.fromARGB(
                                    fillAlphaInt, fillRedInt, fillGreenInt,
                                    fillBlueInt);
                              });
                            }
                          }
                        },
                        onPanUpdate: (dt){
                          if(paletteRect.contains(dt.localPosition)){
                            int red, green, blue;
                            switch (colorReceiver == "Stroke" ? strokeAnchorColor : fillAnchorColor) {
                              case AnchorColor.red:
                                red = colorReceiver == "Stroke" ? strokeRedInt : fillRedInt;
                                green = (dt.localPosition.dy - 1) ~/ 1;
                                blue = (dt.localPosition.dx - 1) ~/ 1;
                                break;
                              case AnchorColor.green:
                                green = colorReceiver == "Stroke" ? strokeGreenInt : fillGreenInt;
                                red = (dt.localPosition.dy - 1) ~/ 1;
                                blue = (dt.localPosition.dx - 1) ~/ 1;
                                break;
                              case AnchorColor.blue:
                                blue = colorReceiver == "Stroke" ? strokeBlueInt : fillBlueInt;
                                red = (dt.localPosition.dy - 1) ~/ 1;
                                green = (dt.localPosition.dx - 1) ~/ 1;
                                break;
                              default:
                                red = colorReceiver == "Stroke" ? strokeRedInt : fillRedInt;
                                green = colorReceiver == "Stroke" ? strokeGreenInt : fillGreenInt;
                                blue = colorReceiver == "Stroke" ? strokeBlueInt : fillBlueInt;
                                break;
                            }
                            moveColorPickerCursor(colorReceiver, dragDetails: dt);
                            if(colorReceiver == "Stroke"){
                              setState((){
                                strokeRedInt = red;
                                strokeGreenInt = green;
                                strokeBlueInt = blue;
                                strokePendingColor = Color.fromARGB(strokeAlphaInt, strokeRedInt, strokeGreenInt, strokeBlueInt);
                              });
                            } else if (colorReceiver == "Fill"){
                              setState((){
                                fillRedInt = red;
                                fillGreenInt = green;
                                fillBlueInt = blue;
                                fillPendingColor = Color.fromARGB(fillAlphaInt, fillRedInt, fillGreenInt, fillBlueInt);
                              });
                            }
                          }
                        },
                        child: CustomPaint(
                          child: colorReceiver == "Stroke" ? ThreeDimColorPalette(256, 256, strokeAnchorColor, strokeAnchorColorValue, 255) : ThreeDimColorPalette(256, 256, fillAnchorColor, fillAnchorColorValue, 255),
                          foregroundPainter: FastDraw(
                            drawer: (Canvas canvas, Size size){
                              canvas.clipRect(Offset.zero & size);
                              Path cursor = Path();
                              if(colorReceiver == "Stroke"){
                                cursor.addRect(Rect.fromCenter(center: strokeColorPickerCursor - const Offset(0, controlPointSize), width: controlPointSize / 2, height: controlPointSize));
                                cursor.addRect(Rect.fromCenter(center: strokeColorPickerCursor + const Offset(0, controlPointSize), width: controlPointSize / 2, height: controlPointSize));
                                cursor.addRect(Rect.fromCenter(center: strokeColorPickerCursor - const Offset(controlPointSize, 0), width: controlPointSize, height: controlPointSize / 2));
                                cursor.addRect(Rect.fromCenter(center: strokeColorPickerCursor + const Offset(controlPointSize, 0), width: controlPointSize, height: controlPointSize / 2));
                              } else if (colorReceiver == "Fill"){
                                cursor.addRect(Rect.fromCenter(center: fillColorPickerCursor - const Offset(0, controlPointSize), width: controlPointSize / 2, height: controlPointSize));
                                cursor.addRect(Rect.fromCenter(center: fillColorPickerCursor + const Offset(0, controlPointSize), width: controlPointSize / 2, height: controlPointSize));
                                cursor.addRect(Rect.fromCenter(center: fillColorPickerCursor - const Offset(controlPointSize, 0), width: controlPointSize, height: controlPointSize / 2));
                                cursor.addRect(Rect.fromCenter(center: fillColorPickerCursor + const Offset(controlPointSize, 0), width: controlPointSize, height: controlPointSize / 2));
                              }
                              canvas.drawPath(cursor, fillPaint);
                            },
                            shouldRedraw: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical:3.0),
                    width: 262,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(value: AnchorColor.red, groupValue: colorReceiver == "Stroke" ? strokeAnchorColor : fillAnchorColor, onChanged: (AnchorColor? val){
                                    if(colorReceiver == "Stroke"){
                                      setState((){
                                        strokeAnchorColor = val ?? strokeAnchorColor;
                                        strokeAnchorColorValue = strokeAnchorColor == AnchorColor.red ? strokeRedInt : (strokeAnchorColor == AnchorColor.green ? strokeGreenInt : strokeBlueInt);
                                      });
                                    } else if (colorReceiver == "Fill"){
                                      setState((){
                                        fillAnchorColor = val ?? fillAnchorColor;
                                        fillAnchorColorValue = fillAnchorColor == AnchorColor.red ? fillRedInt : (fillAnchorColor == AnchorColor.green ? fillGreenInt : fillBlueInt);
                                      });
                                    }
                                  }),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal:8),
                                      width: 60,
                                      child: const Text("Red: ")
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      width: 42,
                                      child: colorReceiver == "Stroke" ? Text("$strokeRedInt",) : Text("$fillRedInt",)
                                  ),
                                  PlusMinusButton(
                                    incrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeRedInt < 255){setState((){strokeRedInt++;});}
                                      if(colorReceiver == "Fill" && fillRedInt < 255){setState((){fillRedInt++;});}
                                    },
                                    longIncrementCall:(){
                                      startChangeColorValues(AnchorColor.red, true, colorReceiver);
                                    },
                                    longIncrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                    decrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeRedInt > 0){setState((){strokeRedInt--;});}
                                      if(colorReceiver == "Fill" && fillRedInt > 0){setState((){fillRedInt--;});}
                                    },
                                    longDecrementCall:(){
                                      startChangeColorValues(AnchorColor.red, false, colorReceiver);
                                    },
                                    longDecrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                  ),
                                ]
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(value: AnchorColor.green, groupValue: colorReceiver == "Stroke" ? strokeAnchorColor : fillAnchorColor, onChanged: (AnchorColor? val){
                                    if(colorReceiver == "Stroke"){
                                      setState((){
                                        strokeAnchorColor = val ?? strokeAnchorColor;
                                        strokeAnchorColorValue = strokeAnchorColor == AnchorColor.red ? strokeRedInt : (strokeAnchorColor == AnchorColor.green ? strokeGreenInt : strokeBlueInt);
                                      });
                                    } else if (colorReceiver == "Fill"){
                                      setState((){
                                        fillAnchorColor = val ?? fillAnchorColor;
                                        fillAnchorColorValue = fillAnchorColor == AnchorColor.red ? fillRedInt : (fillAnchorColor == AnchorColor.green ? fillGreenInt : fillBlueInt);
                                      });
                                    }
                                  }),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal:8),
                                      width: 60,
                                      child: const Text("Green: ")
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      width: 42,
                                      child: colorReceiver == "Stroke" ? Text("$strokeGreenInt",) : Text("$fillGreenInt",)
                                  ),
                                  PlusMinusButton(
                                    incrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeGreenInt < 255){setState((){strokeGreenInt++;});}
                                      if(colorReceiver == "Fill" && fillGreenInt < 255){setState((){fillGreenInt++;});}
                                    },
                                    longIncrementCall:(){
                                      startChangeColorValues(AnchorColor.green, true, colorReceiver);
                                    },
                                    longIncrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                    decrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeGreenInt > 0){setState((){strokeGreenInt--;});}
                                      if(colorReceiver == "Fill" && fillGreenInt > 0){setState((){fillGreenInt--;});}
                                    },
                                    longDecrementCall:(){
                                      startChangeColorValues(AnchorColor.green, false, colorReceiver);
                                    },
                                    longDecrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                  ),
                                ]
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(value: AnchorColor.blue, groupValue: colorReceiver == "Stroke" ? strokeAnchorColor : fillAnchorColor, onChanged: (AnchorColor? val){
                                    if(colorReceiver == "Stroke"){
                                      setState((){
                                        strokeAnchorColor = val ?? strokeAnchorColor;
                                        strokeAnchorColorValue = strokeAnchorColor == AnchorColor.red ? strokeRedInt : (strokeAnchorColor == AnchorColor.green ? strokeGreenInt : strokeBlueInt);
                                      });
                                    } else if (colorReceiver == "Fill"){
                                      setState((){
                                        fillAnchorColor = val ?? fillAnchorColor;
                                        fillAnchorColorValue = fillAnchorColor == AnchorColor.red ? fillRedInt : (fillAnchorColor == AnchorColor.green ? fillGreenInt : fillBlueInt);
                                      });
                                    }
                                  }),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal:8),
                                      width: 60,
                                      child: const Text("Blue: ")
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      width: 42,
                                      child: colorReceiver == "Stroke" ? Text("$strokeBlueInt",) : Text("$fillBlueInt",)
                                  ),
                                  PlusMinusButton(
                                    incrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeBlueInt < 255){setState((){strokeBlueInt++;});}
                                      if(colorReceiver == "Fill" && fillBlueInt < 255){setState((){fillBlueInt++;});}
                                    },
                                    longIncrementCall:(){
                                      startChangeColorValues(AnchorColor.blue, true, colorReceiver);
                                    },
                                    longIncrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                    decrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeBlueInt > 0){setState((){strokeBlueInt--;});}
                                      if(colorReceiver == "Fill" && fillBlueInt > 0){setState((){fillBlueInt--;});}
                                    },
                                    longDecrementCall:(){
                                      startChangeColorValues(AnchorColor.blue, false, colorReceiver);
                                    },
                                    longDecrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                  ),
                                ]
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                      width:32,
                                      height:30
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal:8),
                                      width: 60,
                                      child: const Text("Alpha: ")
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      width: 42,
                                      child: colorReceiver == "Stroke" ? Text("$strokeAlphaInt",) : Text("$fillAlphaInt",)
                                  ),
                                  PlusMinusButton(
                                    incrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeAlphaInt < 255){setState((){strokeAlphaInt++;});}
                                      if(colorReceiver == "Fill" && fillAlphaInt < 255){setState((){fillAlphaInt++;});}
                                    },
                                    longIncrementCall:(){
                                      startChangeColorValues(AnchorColor.alpha, true, colorReceiver);
                                    },
                                    longIncrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                    decrementCall: (){
                                      if(colorReceiver == "Stroke" && strokeAlphaInt > 0){setState((){strokeAlphaInt--;});}
                                      if(colorReceiver == "Fill" && fillAlphaInt > 0){setState((){fillAlphaInt--;});}
                                    },
                                    longDecrementCall:(){
                                      startChangeColorValues(AnchorColor.alpha, false, colorReceiver);
                                    },
                                    longDecrementCallEnd:(){setState((){colorChangeTimer.cancel();});},
                                  ),
                                ]
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                                width: 50,
                                height: 50,
                                child: Material(
                                  shape: const CircleBorder(),
                                  color: colorReceiver == "Stroke" ? strokePendingColor : fillPendingColor,
                                )
                            ),
                            Container(
                                height: 32,
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: MaterialButton(
                                    onPressed:(){
                                      // if(colorReceiver == "Stroke"){
                                      //   if(actionStack.isEmpty || !(actionStack.last).containsKey(DrawAction.changePaintColor)){
                                      //     actionStack.add({
                                      //       DrawAction.changePaintColor: {
                                      //         "original_paint_color": _defaultStrokePaint.color,
                                      //         "editing_curve_index": currentEditingODKIndex,
                                      //       }
                                      //     });
                                      //     if(currentEditingODKIndex != null){
                                      //       actionStack.last[DrawAction.changePaintColor]["original_curve_paint_color"] = pointDrawCollection[currentEditingODKIndex!]["stroke"].color;
                                      //     }
                                      //   }
                                      //   setState((){
                                      //     _defaultStrokePaint.color = strokePendingColor;
                                      //     if(currentEditingODKIndex != null){
                                      //       pointDrawCollection[currentEditingODKIndex!]["stroke"].color = strokePendingColor;
                                      //     }
                                      //     showColorSelector = false;
                                      //     colorReceiver = "";
                                      //   });
                                      // } else if (colorReceiver == "Fill"){
                                      //   actionStack.add({
                                      //     DrawAction.changeFillColor: {
                                      //       "original_fill_color": _defaultFillPaint.color,
                                      //       "editing_curve_index": currentEditingODKIndex,
                                      //     }
                                      //   });
                                      //   if(currentEditingODKIndex != null){
                                      //     actionStack.last[DrawAction.changeFillColor]["original_curve_fill_color"] = pointDrawCollection[currentEditingODKIndex!]["fill"].color;
                                      //     actionStack.last[DrawAction.changeFillColor]["original_filled_attribute"] = pointDrawCollection[currentEditingODKIndex!]["filled"];
                                      //   }
                                      //   setState((){
                                      //     _defaultFillPaint.color = fillPendingColor;
                                      //     if(currentEditingODKIndex != null){
                                      //       pointDrawCollection[currentEditingODKIndex!]["fill"].color = fillPendingColor;
                                      //       pointDrawCollection[currentEditingODKIndex!]["filled"] = true;
                                      //     }
                                      //     showColorSelector = false;
                                      //   });
                                      // }
                                    },
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6.0)
                                    ),
                                    elevation: defaultPanelElevation,
                                    padding: EdgeInsets.zero,
                                    child: const Text("Pick color", style: TextStyle(fontSize:16, color: Colors.white))
                                )
                            ),
                          ],
                        )
                      ],
                    )
                ),
              ]
          )
      ),
    );
  }
}

enum PaintType{stroke, fill, shader}

class PointDrawObjectColorSelector extends StatefulWidget {

  final PointDrawObject pointDrawObject;
  final PaintType paintType;
  final Color? initialColor;
  final int? colorIndex;
  PointDrawObjectColorSelector(this.pointDrawObject, this.paintType, {Key? key, this.initialColor, this.colorIndex}) : super(key: key){
    assert(paintType != PaintType.shader || initialColor != null, "Initial color cannot be null when paint type is shader");
  }

  @override
  State<PointDrawObjectColorSelector> createState() => _PointDrawObjectColorSelectorState();
}

class _PointDrawObjectColorSelectorState extends State<PointDrawObjectColorSelector> {

  late Color color;
  late Color shadeColor;
  Offset colorPointer = const Offset(50, 100);
  Offset shadePointer = const Offset(33, 100);
  Offset alphaPointer = const Offset(16, 186);
  final Offset circularPaletteCenter = const Offset(100, 100);
  final Offset colorPointerAdjuster = const Offset(5, 0);
  final Offset rectangularPaletteCenter = const Offset(10, 100);

  void updateColor({DragDownDetails? dt, DragUpdateDetails? panDt}){
    Offset displacement = (dt?.localPosition ?? panDt!.localPosition) - circularPaletteCenter;
    setState(() {
      colorPointer = circularPaletteCenter + Offset.fromDirection(displacement.direction, min(displacement.distance, 100)) + colorPointerAdjuster;
      color = getColorFromPalette(displacement.direction / pi, 0) ?? color;
      shadePointer = Offset(shadePointer.dx, 100);
      alphaPointer = Offset(alphaPointer.dx, 186);
      Colors.green;
    });
    Matrix4 zoomTransform = context.read<GridParameters>().zoomTransform;
    if(widget.paintType == PaintType.stroke){
      widget.pointDrawObject.updateStrokePaint(color: color);
    } else if(widget.paintType == PaintType.fill) {
      widget.pointDrawObject.updateFillPaint(zoomTransform, color: color);
    } else {
      List<Color> colors = List.from(widget.pointDrawObject.shaderParam!.colors);
      colors[widget.colorIndex!] = color;
      widget.pointDrawObject.updateShaderParams(zoomTransform, colorsList: colors);
    }
  }

  void updateShade({DragDownDetails? dt, DragUpdateDetails? panDt}){
    Offset offset = dt?.localPosition ?? panDt!.localPosition;
    setState(() {
      shadePointer = Offset(shadePointer.dx, max(min(offset.dy, 190), 10));
      shadeColor = getGradientColor(color, (shadePointer.dy - 10) / 180) ?? shadeColor;
    });
    Matrix4 zoomTransform = context.read<GridParameters>().zoomTransform;
    if(widget.paintType == PaintType.stroke){
      widget.pointDrawObject.updateStrokePaint(color: shadeColor);
    } else if (widget.paintType == PaintType.fill) {
      context.read<PointDrawObject>().updateFillPaint(zoomTransform, color: shadeColor);
    } else {
      // Fill is true and using shader
      List<Color> colors = List.from(widget.pointDrawObject.shaderParam!.colors);
      colors[widget.colorIndex!] = shadeColor;
      context.read<PointDrawObject>().updateShaderParams(zoomTransform, colorsList: colors);
    }
  }

  void updateAlpha({DragDownDetails? dt, DragUpdateDetails? panDt, bool pointer = false}){
    Offset offset = dt?.localPosition ?? panDt!.localPosition;
    int a = min(max(((offset.dy - 10)/ 180 * 255), 0).round(), 255);
    setState(() {
      alphaPointer = Offset(alphaPointer.dx, max(min(offset.dy, 190), 10));
      shadeColor = Color.fromARGB(a, shadeColor.red, shadeColor.green, shadeColor.blue);
    });
    Matrix4 zoomTransform = context.read<GridParameters>().zoomTransform;
    if(widget.paintType == PaintType.stroke){
      widget.pointDrawObject.updateStrokePaint(color: shadeColor);
    } else if (widget.paintType == PaintType.fill) {
      context.read<PointDrawObject>().updateFillPaint(zoomTransform, color: shadeColor);
    } else {
      // Fill is true and using shader
      List<Color> colors = List.from(widget.pointDrawObject.shaderParam!.colors);
      colors[widget.colorIndex!] = shadeColor;
      context.read<PointDrawObject>().updateShaderParams(zoomTransform, colorsList: colors);
    }
  }

  @override
  void initState(){
    super.initState();
    if(widget.paintType == PaintType.stroke){
      color = widget.pointDrawObject.sPaint.color;
    } else if (widget.paintType == PaintType.fill){
      color = widget.pointDrawObject.fPaint.color;
    } else {
      color = widget.initialColor!;
    }
    shadeColor = color;
  }

  @override
  Widget build(BuildContext context) {
    const Widget spacing = SizedBox(width: 10);
    return Stack(
      children: [
        SizedBox(
            width: 300,
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: 200,
                  child: GestureDetector(
                      onPanDown:(dt){
                        updateColor(dt: dt);
                      },
                      onPanUpdate: (dt){
                        updateColor(panDt: dt);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: CircularColorPalette(
                        200,
                        200,
                        color,)
                  ),
                ),
                spacing,
                Container(
                  padding: const EdgeInsets.only(right: 4.0),
                  width: 50,
                  height: 200,
                  child: GestureDetector(
                    onPanDown: (dt){
                      updateShade(dt: dt);
                    },
                    onPanUpdate: (dt){
                      updateShade(panDt: dt);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: RectangularShadesPalette(
                        50,
                        200,
                        color),
                  ),
                ),
                spacing,
                Container(
                  padding: const EdgeInsets.only(right:4.0),
                  width: 8,
                  height: 200,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onPanDown: (dt){
                      updateAlpha(dt: dt);
                    },
                    onPanUpdate: (dt){
                      updateAlpha(panDt: dt);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const AlphaBar(8, 200, Colors.white),
                  ),
                )
              ],
            )
        ),
        Positioned(
            top: colorPointer.dy - 2.5,
            left: colorPointer.dx - 2.5,
            child: const Material(
                color: Colors.transparent,
                shape: CircleBorder(
                    side: BorderSide(width:1.0, color: Colors.black)
                ),
                child: SizedBox(
                  width: 5,
                  height: 5,
                )
            )
        ),
        Positioned(
            top: shadePointer.dy - 2.5,
            right: shadePointer.dx,
            child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5),
                    side: const BorderSide(width:1.0, color: Colors.white)
                ),
                child: const SizedBox(
                  width: 50,
                  height: 5,
                )
            )
        ),
        Positioned(
            top: alphaPointer.dy - 4,
            right: alphaPointer.dx,
            child: Material(
              color: Colors.white,
              shape: CircleBorder(
                  side: BorderSide(width:1.0, color: Colors.grey[50]!)
              ),
              child: GestureDetector(
                onVerticalDragUpdate: (dt){
                  updateAlpha(panDt: dt, pointer: true);
                },
                child: const SizedBox(
                  width: 8,
                  height: 8,
                ),
              ),
            )
        )
      ],
    );
  }
}