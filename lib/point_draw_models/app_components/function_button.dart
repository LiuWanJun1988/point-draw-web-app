import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  final bool showButton;
  final void Function() onPressed;
  final String toolTip;
  final EdgeInsets? margin;
  final Widget? primaryStateWidget;
  final Widget? altStateWidget;
  final bool primaryState;
  const FunctionButton(
      {
        required this.onPressed,
        required this.toolTip,
        this.margin,
        this.primaryStateWidget = const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white),
        this.altStateWidget = const Icon(Icons.arrow_right, size: 16, color: Colors.white),
        this.primaryState = true,
        this.showButton = true,
        Key? key
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(showButton){
      return Container(
        width: 24,
        height: 24,
        margin: margin ?? EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical:4),
        child: Tooltip(
          message: toolTip,
          child: MaterialButton(
            onPressed: onPressed,
            padding:EdgeInsets.zero,
            shape: const CircleBorder(),
            color: Colors.black,
            child: primaryState ? primaryStateWidget : altStateWidget,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}