import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:sigma_frontend/widgets/sidebar.dart';
import '../portal/widgets/portal_shell.dart';
import '../sigma_theme.dart';


class AdminShell extends StatefulWidget {
  final Widget child;
  final GoRouter? router;
  //final String currentRoute;

  const AdminShell({
    super.key,
    required this.child,
    this.router,
   // required this.currentRoute,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {

  bool expanded = false;
  double f = 0.2;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;
   // if (!isDesktop) return child;

   // final location = GoRouterState.of(context).uri.toString();
    print("ebuild ${ expanded} location");

    return Scaffold(

      appBar: PortalTopBar(title: 'Sigma',  onMenu:(){
        setState(() {
          print("hola ${ this.expanded}");
          this.expanded = !(this.expanded??false);

        });
      }),
      body:
      (!expanded)? Container(
        key: Key("hacer"),
        //color: Colors.blue,
        //padding: EdgeInsets.all(10),
        child: AnimatedContainer(
            width: double.infinity,
            duration: Duration(milliseconds: 2000),
            child: widget.child),
      ):
      ResizableWidget(
        children: [
          if (expanded)
          AdminSidebar( expanded: expanded,),
          Container(
            key: Key("hacer"),
          //  color: Colors.blue,
          //  padding: EdgeInsets.all(10),
            child: AnimatedContainer(
              width: double.infinity,
                duration: Duration(milliseconds: 2000),
                child: widget.child),
          ),
        ],
        isHorizontalSeparator: false,   // optional
        isDisabledSmartHide: false,     // optional
        separatorColor: Colors.white12, // optional
        separatorSize: 4,               // optional
        percentages: [if (expanded)f, (expanded?1.0-f:1)],   // optional
        onResized: (infoList) {
          this.f = infoList.first.percentage;
          print(infoList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
        },
      ),

    );
  }
}