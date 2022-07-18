import 'package:flutter/material.dart';

class PlusMinusButton extends StatelessWidget {
  final double? widthSize;
  final void Function()? incrementCall;
  final void Function()? longIncrementCall;
  final void Function()? longIncrementCallEnd;
  final void Function()? decrementCall;
  final void Function()? longDecrementCall;
  final void Function()? longDecrementCallEnd;
  const PlusMinusButton({this.incrementCall, this.longIncrementCall, this.longIncrementCallEnd, this.decrementCall, this.longDecrementCall, this.longDecrementCallEnd, this.widthSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = widthSize ?? 28;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize * 0.45,
            child: Material(
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: GestureDetector(
                onTapDown: (dt) {
                  incrementCall?.call();
                },
                onLongPress: longIncrementCall,
                onLongPressUp: longIncrementCallEnd,
                child: Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: iconSize / 2),
              ),
            ),
          ),
          SizedBox(
            height: iconSize * 0.1,
          ),
          SizedBox(
            width: iconSize,
            height: iconSize * 0.45,
            child: Material(
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: GestureDetector(
                onTapDown: (dt){
                  decrementCall?.call();
                },
                onLongPress: longDecrementCall,
                onLongPressUp: longDecrementCallEnd,
                child: Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: iconSize / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}