import 'package:flutter/material.dart';
import '../framework/core/form_controller.dart';
import '../framework/ui/framework_form.dart';

class FrameworkExampleScreen extends StatefulWidget {
  const FrameworkExampleScreen({super.key});

  @override
  State<FrameworkExampleScreen> createState() => _FrameworkExampleScreenState();
}

class _FrameworkExampleScreenState extends State<FrameworkExampleScreen> {
  late FormController _formController;
  
  // Definimos un esquema de ejemplo basado en nuestra arquitectura
  final List<Map<String, dynamic>> _schema = [
    {
      'key': 'title',
      'type': 'text',
      'label': 'Título de la Tarea',
    },
    {
      'key': 'priority',
      'type': 'many2one',
      'label': 'Prioridad',
      'depends_on': null,
    },
    {
      'key': 'subtasks',
      'type': 'nested',
      'label': 'Subtareas',
    }
  ];

  @override
  void initState() {
    super.initState();
    _formController = FormController();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo del Framework'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lado Izquierdo: El formulario dinámico generado por el JSON
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              child: FrameworkForm(
                schema: _schema,
                controller: _formController,
                // Ejemplo de inyección de un widget personalizado saltándose el esquema
                overrides: {
                  'priority': (controller) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Prioridad (Override Personalizado)'),
                      value: controller.getValue('priority'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Baja')),
                        DropdownMenuItem(value: 'high', child: Text('Alta (Crítica)')),
                      ],
                      onChanged: (val) => controller.updateField('priority', val),
                    );
                  }
                },
              ),
            ),
          ),
          
          // Lado Derecho: Inspector Reactivo (muestra en tiempo real los datos del JSON local)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado del JSON (En Vivo):', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white54),
                    Expanded(
                      child: StreamBuilder<String>(
                        stream: _formController.onFieldChanged,
                        builder: (context, snapshot) {
                          // Obtenemos los datos inmutables del controlador
                          final currentData = _formController.data;
                          return SingleChildScrollView(
                            child: Text(
                              _prettyPrintJson(currentData),
                              style: const TextStyle(
                                color: Colors.greenAccent, 
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Operación guardada en el SyncEngine (Simulado)')),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Guardar Entidad'),
      ),
    );
  }

  String _prettyPrintJson(Map<String, dynamic> data) {
    if (data.isEmpty) return '{\n  // Vacío\n}';
    final buffer = StringBuffer();
    buffer.writeln('{');
    data.forEach((key, value) {
      buffer.writeln('  "$key": $value,');
    });
    buffer.writeln('}');
    return buffer.toString();
  }
}
