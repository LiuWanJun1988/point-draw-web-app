import 'package:flutter/material.dart';

import 'package:pointdraw/point_draw_models/utilities/ui_parameters.dart';
import 'package:pointdraw/point_draw_models/app_components/function_button.dart';

class SectionTab extends StatefulWidget {
  final String tabName;
  final Widget Function(BuildContext) builder;
  const SectionTab({
    required this.tabName,
    required this.builder,
    Key? key}) : super(key: key);

  @override
  State<SectionTab> createState() => _SectionTabState();
}

class _SectionTabState extends State<SectionTab> {

  bool showTab = true;

  @override
  Widget build(BuildContext context) {
    return Column(
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 24,
                padding: interLineEdgeInsets,
                alignment: Alignment.centerLeft,
                child: Text(widget.tabName + " parameters", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              FunctionButton(
                onPressed: toggleShowTab,
                toolTip: "Show ${widget.tabName.toLowerCase()}",
                primaryState: showTab,
              )
            ],
          ),
          if(showTab)
            widget.builder.call(context),
        ]
    );
  }

  void toggleShowTab(){
    setState((){
      showTab = !showTab;
    });
  }
}