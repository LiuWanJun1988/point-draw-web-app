import 'package:flutter/material.dart';

import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart';

class UserInputWidget extends StatefulWidget {
  TextEditingController editingController;
  void Function(String) onChanged;
  void Function(String)? onSubmitted;
  void Function()? onEditingComplete;
  EdgeInsets? contentPadding;
  String? hintText;
  BoxConstraints? constraints;
  Color? textColor;
  Size? overallSize;
  bool showHideTextToggle;
  bool autoFocus;
  Widget? suffixIcon;
  TextAlign align;
  FocusNode? focusNode;
  String? fontFamily;
  double fontSize;
  int? maxLines;
  int minLines;
  FontWeight weight;
  Color? backgroundColor;
  ShapeBorder? shape;
  UserInputWidget(
      {
        required this.editingController,
        required this.onChanged,
        this.onSubmitted,
        this.onEditingComplete,
        this.overallSize,
        this.contentPadding,
        this.hintText,
        this.constraints,
        this.textColor,
        this.align = TextAlign.left,
        this.weight = FontWeight.normal,
        this.fontFamily,
        this.showHideTextToggle = false,
        this.autoFocus = false,
        this.suffixIcon,
        this.focusNode,
        this.fontSize = 16,
        this.maxLines,
        this.minLines = 3,
        this.backgroundColor,
        this.shape,
        Key? key
      }) : super(key: key);

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {

  bool? hideText;
  FocusNode? node;

  @override
  void initState(){
    hideText = widget.showHideTextToggle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Material(
      color: widget.backgroundColor ?? Colors.transparent,
      shape: widget.shape ?? const ContinuousRectangleBorder(),
      clipBehavior: Clip.hardEdge,
      child: Container(
        constraints: widget.constraints ?? const BoxConstraints.expand(),
        child: Builder(
          builder: (context) {
            if(widget.autoFocus){
              node = FocusNode()..requestFocus();
            }
            return TextField(
              decoration: InputDecoration(
                contentPadding: widget.contentPadding ?? EdgeInsets.fromLTRB(4.0, -5.0, 0, 12.0),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: widget.fontSize,
                  fontStyle: FontStyle.normal,
                  color: Colors.grey.shade300,
                ),
                border: InputBorder.none,
                suffixIcon: null,
              ),
              cursorWidth: 0.8,
              obscureText: hideText ?? false,
              controller: widget.editingController,
              focusNode: node,
              autofocus: widget.autoFocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              maxLines: widget.maxLines ?? null,
              minLines: widget.minLines,
              style: TextStyle(
                fontSize: widget.fontSize ,
                color: widget.textColor,
                fontWeight: widget.weight,
                fontFamily: widget.fontFamily
              ),
              textAlign: widget.align,
              keyboardType: TextInputType.multiline,
              inputFormatters: [],
              textInputAction: TextInputAction.newline,
            );
          }
        ),
      ),
    );
    if(widget.overallSize != null){
      return SizedBox(
        width: widget.overallSize!.width,
        height: widget.overallSize!.height,
        child: result
      );
    } else {
      return SizedBox(
        height: widget.fontSize * widget.minLines,
        child: result);
    }
  }
}
