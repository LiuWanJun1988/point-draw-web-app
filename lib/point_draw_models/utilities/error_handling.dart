import 'package:flutter/material.dart';

class ErrorPopupMessage extends StatefulWidget {
  final String errorMessage;
  final List<void Function()> actionCalls;
  final List<String> callNames;
  const ErrorPopupMessage(this.errorMessage, {Key? key, this.actionCalls : const [], this.callNames: const []})
      : assert(actionCalls.length == callNames.length, "Must have same number of action calls and call names"),
        super(key: key);

  @override
  _ErrorPopupMessageState createState() => _ErrorPopupMessageState();
}

class _ErrorPopupMessageState extends State<ErrorPopupMessage> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.errorMessage),
      titleTextStyle: const TextStyle(fontSize: 16,),
      alignment: Alignment.center,
      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      actions: [
        Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.zero,
          child: MaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Ok", style: TextStyle(color: Colors.white)),
            color: Colors.black,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
        ),
        if(widget.actionCalls.isNotEmpty)
          for(int i = 0; i < widget.actionCalls.length; i++)
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: MaterialButton(
                onPressed: (){
                  widget.actionCalls[i]();
                },
                child: Text(widget.callNames[i], style: const TextStyle(color: Colors.white)),
                color: Colors.black,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
            ),
      ],
    );
  }
}

Future<void> showErrorMessage(BuildContext context, String message, List<void Function()> actionCalls) async {
  return await showDialog(
    context: context,
    builder:(context){
      return ErrorPopupMessage(message, actionCalls: actionCalls);
    }
  );
}
