import 'package:flutter/material.dart';
import '../../sigma_theme.dart';
import '../widgets/portal_shell.dart';
import '../widgets/portal_widgets.dart';

const _msgs = [
  ('Prof. Rodríguez', 'Evaluación próxima semana', 'Hoy 9:30',  true,  SigmaColors.blue),
  ('Coordinación',   'Reunión de representantes', 'Ayer 14:00', true,  SigmaColors.teal),
  ('Prof. García',   'Felicitaciones por participación', 'Lun 10:15', false, SigmaColors.purple),
];

class PortalComunicadosScreen extends StatelessWidget {
  const PortalComunicadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final content = isDesktop ? _DesktopComunicados() : _MobileComunicados();
    return PortalShell(currentRoute: '/portal/comunicados', child: content);
  }
}

class _MobileComunicados extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PortalMobileAppBar(),
      backgroundColor: SigmaColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comunicados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
            const SizedBox(height: 14),
            ..._msgs.map((m) => MessageItem(
              sender: m.$1, preview: m.$2, time: m.$3, unread: m.$4, avatarColor: m.$5,
            )),
          ],
        ),
      ),
    );
  }
}

class _DesktopComunicados extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigmaColors.surface,
      appBar: const PortalTopBar(title: 'Comunicados', subtitle: 'Abril 2026'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comunicados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                children: _msgs.map((m) => MessageItem(
                  sender: m.$1, preview: m.$2, time: m.$3, unread: m.$4, avatarColor: m.$5,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
