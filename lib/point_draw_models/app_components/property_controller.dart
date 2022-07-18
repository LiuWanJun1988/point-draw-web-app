import 'package:flutter/material.dart';
import 'package:pointdraw/point_draw_models/app_components/plus_minus_button.dart';
import 'package:pointdraw/point_draw_models/app_components/user_input_widget.dart';

import 'package:pointdraw/point_draw_models/utilities/utils.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart' show defaultPanelElevation;
import 'package:pointdraw/point_draw_models/app_components/icon_sketch.dart';

class BooleanController extends StatelessWidget {
  final bool boolValue;
  final Widget? displayWidget;
  final Semantics? semantics;
  final void Function()? onChanged;
  final String? toolTipMessage;
  final EdgeInsets margin;
  final bool enabled;
  final double? min;
  final double? max;
  BooleanController(
      this.boolValue,
      {
        required this.onChanged,
        this.displayWidget,
        this.semantics,
        this.toolTipMessage,
        this.margin = EdgeInsets.zero,
        this.enabled = true,
        this.min,
        this.max,
        Key? key,
      }) : super(key: key ?? ValueKey("Boolean controller: ${toolTipMessage ?? generateAutoID()}"));

  @override
  Widget build(BuildContext context) {
    Widget result = MaterialButton(
      onPressed: enabled ? onChanged : null,
      shape: const CircleBorder(),
      color: boolValue ? Colors.cyanAccent : Colors.black,
      clipBehavior: Clip.hardEdge,
      hoverColor: Colors.cyanAccent,
      elevation: 0.0,
      padding: EdgeInsets.zero,
      child: displayWidget,
    );
    if(toolTipMessage != null){
      result = Tooltip(
        message: toolTipMessage,
        child: result,
      );
    }
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      margin: margin,
      child: result,
    );
  }
}

class DoubleController extends StatelessWidget {
  const DoubleController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StringController extends StatelessWidget {
  const StringController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class IntegerController extends StatelessWidget {
  final String label;
  final int intValue;
  final void Function(String?) onChanged;
  final Semantics? semantics;
  final void Function()? onIncrement;
  final void Function()? onDecrement;
  final String? toolTipMessage;
  final EdgeInsets margin;
  final bool enabled;
  final double? min;
  final double? max;
  final double? labelWidth;
  IntegerController(
      this.label,
      this.intValue,
      {
        required this.onIncrement,
        required this.onDecrement,
        required this.onChanged,
        this.labelWidth,
        this.semantics,
        this.toolTipMessage,
        this.margin = EdgeInsets.zero,
        this.enabled = true,
        this.min,
        this.max,
        Key? key,
      }) : super(key: key ?? ValueKey("Integer controller: ${toolTipMessage ?? generateAutoID()}"));

  @override
  Widget build(BuildContext context) {
    var cont = TextEditingController(text: intValue.toString());
    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 20,
            width: labelWidth,
            alignment: Alignment.centerLeft,
            child: Text(label + ": ", style: const TextStyle(fontSize: 14))
        ),
        const SizedBox(width: 5),
        PropertyInputBox(
          cont,
          (val){
            if(isInteger(val ?? "")){
              onChanged.call(val);
            }
          },
          (){},
          const Size(45, 20),
          focusNode: FocusNode(),
        ),
        const SizedBox(width: 5),
        PlusMinusButton(
          widthSize: 24,
          incrementCall: onIncrement,
          decrementCall: onDecrement,
        )
      ],
    );
    Widget result = Material(
      shape: const ContinuousRectangleBorder(),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      elevation: 0.0,
      child: child,
    );
    if(toolTipMessage != null){
      result = Tooltip(
        message: toolTipMessage,
        child: result,
      );
    }
    return Container(
      width: 280,
      height: 32,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      margin: margin,
      child: result,
    );
  }
}

class OffsetController extends StatelessWidget {
  const OffsetController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PropertyInputBox extends StatelessWidget {
  final Size size;
  final TextEditingController controller;
  final void Function(String?) onChanged;
  final void Function() onEditingComplete;
  final FocusNode focusNode;
  const PropertyInputBox(this.controller, this.onChanged, this.onEditingComplete, this.size, {required this.focusNode, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size.width,
        height: size.height,
        child: TextField(
          decoration:  const InputDecoration(
            contentPadding: EdgeInsets.only(left: 3.0, bottom: 4.0),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.black),
            ),
            fillColor: Colors.black,
            focusColor: Colors.white,
          ),
          focusNode: focusNode,
          cursorWidth: 0.5,
          controller: controller,
          onTap: (){
            if(!focusNode.hasFocus){
              focusNode.requestFocus();
            }
          },
          onChanged: onChanged,
          onEditingComplete: (){
            onEditingComplete();
            focusNode.unfocus(disposition: UnfocusDisposition.scope);
          },
          onSubmitted: onChanged,
          textInputAction: TextInputAction.none,
          style: const TextStyle(fontSize:14, color: Colors.black),
        )
    );
  }
}





