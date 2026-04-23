import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sigma_frontend/portal/widgets/portal_shell.dart';
import 'package:sigma_frontend/services/bloc.dart';
import 'package:sigma_frontend/widgets/admin_shell.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'router.dart';
import 'sigma_theme.dart';

void main() {
  print("main");
  LangBloc().init();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sigma',
      theme: buildSigmaTheme(),
      routerConfig: LangBloc().router,

      builder: (context, child){

        print(("router", LangBloc().router.routeInformationProvider.value.uri.toString()));

        return AdminShell(
          router: LangBloc().router,
          child:child??SizedBox()

        );
      },
    );
  }
}
