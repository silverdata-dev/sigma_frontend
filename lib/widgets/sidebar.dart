

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../portal/widgets/card/herocard.dart';
import '../portal/widgets/portal_widgets.dart';
import '../services/bloc.dart';
import '../sigma_theme.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

class _NavSection {
  final String title;
  final List<_NavItem> items;
  const _NavSection(this.title, this.items);
}


const _home = _NavItem('Inicio', Icons.grid_view_rounded, '/');

const _sections = [
  _NavSection('PERSONAS', [
    _NavItem('Estudiantes',    Icons.school_rounded,          '/estudiantes'),
    _NavItem('Representantes', Icons.family_restroom_rounded, '/representantes'),
    _NavItem('Profesores',     Icons.assignment_ind_rounded,  '/profesores'),
    _NavItem('Empleados',      Icons.badge_rounded,           '/empleados'),
  ]),
  _NavSection('ACADÉMICO', [
    _NavItem('Periodos',  Icons.calendar_month_rounded, '/periodos'),
    _NavItem('Secciones', Icons.class_rounded,          '/secciones'),
  ]),
  _NavSection('SISTEMA', [
    _NavItem('Roles',   Icons.security_rounded,   '/roles'),
    _NavItem('Eventos', Icons.event_note_rounded, '/eventos'),
  ]),
  _NavSection('PORTAL', [
    //_NavItem('Dashboard',      Icons.grid_view_rounded,          '/portal'),
    _NavItem('Asistencia',     Icons.schedule_rounded,           '/portal/asistencia'),
    _NavItem('Calificaciones', Icons.edit_note_rounded,          '/portal/calificaciones'),
    _NavItem('Comunicados',    Icons.mail_outline_rounded,       '/portal/comunicados'),
    _NavItem('Perfil',         Icons.account_circle_outlined,    '/portal/perfil'),
  ]),
];


class AdminSidebar extends StatefulWidget {

  final bool expanded;

  const AdminSidebar({ this.expanded = false});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
//  PageController page = PageController();

  bool _isActive(_NavItem item) {
    //final location = GoRouterState.of(context).uri.toString();
    final location = LangBloc().router.routeInformationProvider.value.uri.toString();
    //if (item.route == '/' || item.route == '/portal') {
    print(("isactive $item", location, item.route));
    if (location == '/' || location == '/portal') {
      return location==item.route;
     // return widget.currentRoute == item.route;
    }
    return location?.startsWith(item.route)??false;
    //return widget.currentRoute.startsWith(item.route);
  }


  @override
  Widget build(BuildContext context) {

/*
    List<SideMenuItem> items = [
      SideMenuItem(
        // Priority of item to show on SideMenu, lower value is displayed at the top
        priority: 0,
        title: 'Dashboard',
        onTap: () => page.jumpToPage(0),
        icon: Icons.home,
      ),
      SideMenuItem(
        priority: 1,
        title: 'Settings',
        onTap: () => page.jumpToPage(1),
        icon: Icons.settings,
      ),
      SideMenuItem(
        priority: 2,
        title: 'Exit',
        onTap: () {},
        icon: Icons.exit_to_app,
      ),
    ];
   return  SideMenu(
      // page controller to manage a PageView
      controller: page,
      // will shows on top of all items, it can be a logo or a Title text
      title: Image.asset('assets/images/easy_sidemenu.png'),
      // will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
      footer: Text('demo'),
      // List of SideMenuItem to show them on SideMenu
      items: items,
    );*/

    return Container(
      //width: widget.expanded?200:0,
      width: double.infinity,
      color: SigmaColors.navy,
      //duration: Duration(milliseconds: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: SigmaColors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text('Σ',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SIGMA',
                        style: TextStyle(
                            color: SigmaColors.snowWhite,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 2)),
                    Text('ADMIN',
                        style: TextStyle(
                            color: SigmaColors.textSub,
                            fontSize: 9,
                            letterSpacing: 1.5)),
                  ],
                ),

                Align(
                    alignment: Alignment.center,
                    child: SigmaLogo(size: 40)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Home
          _SidebarItem(
            item: _home,
            active: _isActive(_home),
            onTap: () => LangBloc().router.go(_home.route),
          ),

          const SizedBox(height: 4),
          ..._sections.map((section) => _SidebarSection(

            section: section,
            isActive: _isActive,
            onItemTap: (route) => LangBloc().router.go(route)  //context.go(route),
          )),

          const Spacer(),
          StudentHeroCard(),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text('Año Escolar 2025–2026',
                style: TextStyle(color: SigmaColors.textSub, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final _NavSection section;
  final bool Function(_NavItem) isActive;
  final void Function(String) onItemTap;

  const _SidebarSection({
    required this.section,
    required this.isActive,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {

    print("sidebar");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            section.title,
            style: const TextStyle(
              color: SigmaColors.textSub,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...section.items.map((item) => _SidebarItem(
          item: item,
          active: isActive(item),
          onTap: () => onItemTap(item.route),
        )),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {

  bool hover = false;


  @override
  void initState() {
    super.initState();
    print(("activo", widget.active, widget.item));
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final routeObserverProvider = RouteObserver<ModalRoute<void>>(); // <--


    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (e){
        setState(() {

          hover = true;
        });
      },
      onExit: (e){
        setState(() {
          hover = false;
        });

      },
      child: GestureDetector(

        onTap: widget.onTap,
        child: Container(
          color: Color(0xffffff+(hover?0x1f000000:0)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.active ? SigmaColors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon,
                    size: 16,
                    color: widget.active ? Colors.white : SigmaColors.textSub),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: widget.active ? Colors.white : SigmaColors.textSub,
                      fontWeight:
                      widget.active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
