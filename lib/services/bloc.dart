import 'package:flutter/cupertino.dart';


import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../router.dart';

/*import 'dart:js_interop';
@JS('navigator.language')
external JSString get browserLanguage;
@JS('onload')
external void  onload();
@JS('abrir')
external void  abrir(JSString l);
*/

String getBrowserLanguage() {
  return "en";
  //return browserLanguage.toDart;
}

class LangBloc {


  LangBloc._internal();

  static final LangBloc _instance = LangBloc._internal();

  // passes the instantiation to the _instance object
  factory LangBloc() => _instance;




  final ValueNotifier<String> lang = ValueNotifier(getBrowserLanguage());


  late Provider<GoRouter>routerProvider;
  final routeObserverProvider = RouteObserver<ModalRoute<void>>();
  late GoRouter router;

  Future<int> init () async{
    this.router = rerouter();
       // Provider<GoRouter>( create: (BuildContext context) {


        //  final routeObserver = context.read(routeObserverProvider);

        //  return rerouter();
        //},);
    print("init");
    return 0;
  }

}



LangBloc langBloc = LangBloc();



