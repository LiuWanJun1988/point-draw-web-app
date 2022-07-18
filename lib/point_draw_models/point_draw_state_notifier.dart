import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';



abstract class PointDrawStateNotifier extends ChangeNotifier{

  bool active = true;

  final Map<Function, Function?> _registeredStateSettersCallBacks = {};

  List<VoidCallback?> _registeredListeners = const [];

  PointDrawStateNotifier({this.active = true});

  void registerSetStateCallBack(StateSetter stateSetter,
      {Function? stateSetterFunctionBody}){
    // This is an "addListener" function specific to adding callbacks of
    // type "StateSetter".
    // The intent of this listener adder is to make sure that the widget containing
    // this Point Draw Object calls the registered set state callbacks.
    // An object make register a few state setters as it may exists across a
    // few widgets within a tree.
    if(!_registeredStateSettersCallBacks.containsKey(stateSetter)){
      _registeredStateSettersCallBacks.addAll({stateSetter : stateSetterFunctionBody});
      debugPrint("Callbacks registered: ${_registeredStateSettersCallBacks}");
    } else if (_registeredStateSettersCallBacks[stateSetter] != stateSetterFunctionBody) {
      _registeredStateSettersCallBacks[stateSetter] = stateSetterFunctionBody;
    }
  }

  void deregisterSetStateCallBack(StateSetter stateSetter,
      {Function? stateSetterFunctionBody}){
    _registeredStateSettersCallBacks.remove(stateSetter);
  }

  void executeRegisteredSetStateCallBacks(){
    for(var registeredCall in _registeredStateSettersCallBacks.entries){
      registeredCall.key.call((){
        registeredCall.value?.call();
      });
    }
  }

  void updateObject(Function(PointDrawStateNotifier) updatingCall, {bool executeAll = true, List<StateSetter> exclusion = const []}){
   updatingCall.call(this);
   if(executeAll){
     // executeRegisteredSetStateCallBacks();
     notifyListeners();
   } else {
     Map<StateSetter, Function?> forExclusion = {};
     for(StateSetter f in exclusion){
       forExclusion[f] = _registeredStateSettersCallBacks[f];
       deregisterSetStateCallBack(f);
     }
     executeRegisteredSetStateCallBacks();
     for(var f in forExclusion.entries){
       registerSetStateCallBack(f.key, stateSetterFunctionBody: f.value);
     }
   }
  }

  void updateSetStateFunctionBody(StateSetter stateSetter, Function functionBody){
    try {
      _registeredStateSettersCallBacks[stateSetter] = functionBody;
    } catch (exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'point draw structure: point draw state notifier',
        context: ErrorDescription('while updating function body of registered state setter for $runtimeType'),
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsProperty<PointDrawStateNotifier>(
            'The $runtimeType sending notification was',
            this,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ],
      ));
    }
  }
}