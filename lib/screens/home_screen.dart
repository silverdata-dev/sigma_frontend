import 'package:flutter/material.dart';
import 'package:anydrawer/anydrawer.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNavigationDrawer(BuildContext context) {
    showDrawer(
      context,
      builder: (context) {
        return AnyDrawerRegion(
          side: DrawerSide.left,
          builder: (BuildContext context) {
            return Container(color: Colors.red);
          },
          child: Material(
            color: Theme.of(context).cardColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Sigma Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gestión Educativa',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Inicio'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Text('PERSONAS', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Estudiantes'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/estudiantes');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.family_restroom),
                  title: const Text('Representantes'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/representantes');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_ind),
                  title: const Text('Profesores'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/profesores');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Otros Empleados'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/empleados');
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Text('GESTIÓN ACADÉMICA', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Periodos Académicos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/periodos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.class_),
                  title: const Text('Secciones'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/secciones');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Asignación de Roles'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/roles');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_note),
                  title: const Text('Eventos (Logs)'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/eventos');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dynamic_form),
                  title: const Text('Ejemplo Framework'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/example');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sigma Admin - Inicio'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _showNavigationDrawer(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accesos Rápidos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuCard(
                  context,
                  title: 'Estudiantes',
                  icon: Icons.school,
                  route: '/estudiantes',
                  color: Colors.blue.shade100,
                ),
                _buildMenuCard(
                  context,
                  title: 'Profesores',
                  icon: Icons.assignment_ind,
                  route: '/profesores',
                  color: Colors.green.shade100,
                ),
                _buildMenuCard(
                  context,
                  title: 'Secciones',
                  icon: Icons.class_,
                  route: '/secciones',
                  color: Colors.orange.shade100,
                ),
                _buildMenuCard(
                  context,
                  title: 'Periodos',
                  icon: Icons.calendar_month,
                  route: '/periodos',
                  color: Colors.purple.shade100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black87),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
