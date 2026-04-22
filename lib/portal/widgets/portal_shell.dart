import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../sigma_theme.dart';
import 'portal_widgets.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badge;
  const _NavItem(this.label, this.icon, this.route, {this.badge});
}

const _navItems = [
  _NavItem('Inicio',      Icons.grid_view_rounded,        '/portal'),
  _NavItem('Asistencia',  Icons.schedule_rounded,         '/portal/asistencia'),
  _NavItem('Calificaciones', Icons.edit_note_rounded,     '/portal/calificaciones'),
  _NavItem('Comunicados', Icons.mail_outline_rounded,     '/portal/comunicados', badge: 3),
  _NavItem('Perfil',      Icons.account_circle_outlined,  '/portal/perfil'),
];

class PortalShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const PortalShell({super.key, required this.child, required this.currentRoute});

  int get _selectedIndex {
    for (int i = 0; i < _navItems.length; i++) {
      if (currentRoute.startsWith(_navItems[i].route) &&
          (_navItems[i].route != '/portal' || currentRoute == '/portal')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    return isDesktop ? _DesktopLayout(child: child, selected: _selectedIndex) : _MobileLayout(child: child, selected: _selectedIndex);
  }
}

// ── Desktop ──────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final Widget child;
  final int selected;
  const _DesktopLayout({required this.child, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(selected: selected),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selected;
  const _Sidebar({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      color: SigmaColors.navy,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SigmaLogo(size: 28),
                const SizedBox(width: 8),
                const Text('SIGMA', style: TextStyle(color: SigmaColors.snowWhite, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Alumno activo
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: SigmaColors.blue.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                LetterAvatar(letter: 'A', color: SigmaColors.teal, size: 34),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ana Martínez', style: TextStyle(color: SigmaColors.snowWhite, fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
                      Text('3er Grado · Sección A', style: TextStyle(color: Color(0xFF8899BB), fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nav items
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final active = i == selected;
            return _SidebarItem(item: item, active: active, onTap: () => context.go(item.route));
          }),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('U.E. San Ignacio', style: TextStyle(color: Color(0xFF8899BB), fontSize: 10)),
                Text('Año Escolar 2025–2026', style: TextStyle(color: Color(0xFF8899BB), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _SidebarItem({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? SigmaColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 18, color: active ? Colors.white : const Color(0xFF8899BB)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF8899BB),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            if (item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: SigmaColors.amber, borderRadius: BorderRadius.circular(10)),
                child: Text('${item.badge}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Desktop TopBar ────────────────────────────────────────────────────────────
class PortalTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const PortalTopBar({super.key, required this.title, required this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SigmaColors.surfaceCard,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
          const SizedBox(width: 8),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: SigmaColors.textSub)),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, color: SigmaColors.amber, size: 26),
              Positioned(
                top: -2, right: -2,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: SigmaColors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          LetterAvatar(letter: 'C', color: SigmaColors.blue, size: 34),
        ],
      ),
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Widget child;
  final int selected;
  const _MobileLayout({required this.child, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => context.go(_navItems[i].route),
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: item.badge != null
                ? Badge(label: Text('${item.badge}'), child: Icon(item.icon))
                : Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

// ── Mobile AppBar del portal ──────────────────────────────────────────────────
class PortalMobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PortalMobileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SigmaColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SigmaLogo(size: 24),
                const SizedBox(width: 8),
                const Text('SIGMA', style: TextStyle(color: SigmaColors.snowWhite, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
              ],
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: SigmaColors.amber, size: 26),
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: SigmaColors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
