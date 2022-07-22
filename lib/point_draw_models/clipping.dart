import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pointdraw/point_draw_models/point_draw_objects.dart';
import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart';

class ClipObject {

  Path? clipPath = Path();

  PointDrawObject? clip;

  PointDrawObject? clipTarget;

  String? pathObjectIdentifier;

  ClipObject({this.clipPath, this.clipTarget, this.clip});

  void clear(){
    clipPath = Path();
    clipTarget = null;
  }
}

class ClipItem extends StatefulWidget {
  final String identifier;
  final ClipObject clipObject;
  final VoidCallback deleteClipObject;
  const ClipItem(this.identifier, this.clipObject, {required this.deleteClipObject, required Key key}) : super(key: key);

  @override
  State<ClipItem> createState() => _ClipItemState();
}

class _ClipItemState extends State<ClipItem> {

  bool showClipObjectDetails = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // int colorsLength = min(colors.length, 4);
    return Column(
      children: [
        MaterialButton(
          onPressed: (){
            setState((){
              showClipObjectDetails = !showClipObjectDetails;
            });
          },
          child: Container(
            height: 32,
            constraints: const BoxConstraints(maxWidth: 300),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.identifier + ":", style: const TextStyle(fontSize: 14)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 20, color: Colors.red),
                  onPressed: (){
                    widget.deleteClipObject.call();
                  },
                  padding: const EdgeInsets.only(bottom: 4.0),
                  splashRadius: 0.1,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ClipObjectDetails extends StatefulWidget {

  final String label;
  final VoidCallback? onPressedHeader;
  final Map<Path, String> clips;
  final void Function() updateActionStack;
  final bool toUpdateActionStack;
  const ClipObjectDetails(this.label, this.clips, {required this.updateActionStack, required this.toUpdateActionStack, this.onPressedHeader, Key? key}) : super(key: key);

  @override
  State<ClipObjectDetails> createState() => _ClipObjectDetailsState();
}

class _ClipObjectDetailsState extends State<ClipObjectDetails> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: interLineEdgeInsets,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Expanded(
                    child: Text(widget.label, style: const TextStyle(fontSize: 14, color: Colors.black)),
                  ),
                  if(widget.onPressedHeader != null)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: MaterialButton(
                        onPressed: widget.onPressedHeader,
                        padding: EdgeInsets.zero,
                        elevation: 6.0,
                        color: Colors.black,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                ]
            ),
          ),

        ]
      )
    );
  }
}