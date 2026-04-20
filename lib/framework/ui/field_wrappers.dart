import 'dart:async';
import 'package:flutter/material.dart';
import '../core/form_controller.dart';

/// Clase base para todos los inputs del framework.
abstract class FormFieldWrapper extends StatefulWidget {
  final String fieldKey;
  final FormController controller;
  final String? label;

  const FormFieldWrapper({
    super.key,
    required this.fieldKey,
    required this.controller,
    this.label,
  });
}

abstract class FormFieldWrapperState<T extends FormFieldWrapper> extends State<T> {
  StreamSubscription? _subscription;
  dynamic currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.controller.getValue(widget.fieldKey);
    // Suscripción reactiva a cambios en el controlador.
    _subscription = widget.controller.onFieldChanged.listen((key) {
      if (key == widget.fieldKey) {
        setState(() {
          currentValue = widget.controller.getValue(widget.fieldKey);
        });
      }
      onDependencyChanged(key);
    });
  }

  /// Hook para reaccionar cuando otros campos cambian (útil para filtrado).
  void onDependencyChanged(String key) {}

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Implementación simple para texto.
class FrameworkTextField extends FormFieldWrapper {
  const FrameworkTextField({
    super.key,
    required super.fieldKey,
    required super.controller,
    super.label,
  });

  @override
  State<FrameworkTextField> createState() => _FrameworkTextFieldState();
}

class _FrameworkTextFieldState extends FormFieldWrapperState<FrameworkTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: currentValue?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _textController,
        decoration: InputDecoration(labelText: widget.label ?? widget.fieldKey),
        onChanged: (val) => widget.controller.updateField(widget.fieldKey, val),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

/// Selector Many2One con soporte para dependencias reactivas.
class FrameworkMany2One extends FormFieldWrapper {
  final String? dependsOnKey;
  final List<Map<String, dynamic>> Function(dynamic filterValue)? optionsProvider;

  const FrameworkMany2One({
    super.key,
    required super.fieldKey,
    required super.controller,
    this.dependsOnKey,
    this.optionsProvider,
    super.label,
  });

  @override
  State<FrameworkMany2One> createState() => _FrameworkMany2OneState();
}

class _FrameworkMany2OneState extends FormFieldWrapperState<FrameworkMany2One> {
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  void _loadOptions() {
    if (widget.optionsProvider != null) {
      final filterVal = widget.dependsOnKey != null 
          ? widget.controller.getValue(widget.dependsOnKey!) 
          : null;
      setState(() {
        _options = widget.optionsProvider!(filterVal);
      });
    }
  }

  @override
  void onDependencyChanged(String key) {
    if (key == widget.dependsOnKey) {
      _loadOptions();
      // Resetear valor si la dependencia cambia.
      widget.controller.updateField(widget.fieldKey, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<dynamic>(
        value: currentValue,
        decoration: InputDecoration(labelText: widget.label ?? widget.fieldKey),
        items: _options.map((opt) {
          return DropdownMenuItem(
            value: opt['id'],
            child: Text(opt['display_name'] ?? opt['id'].toString()),
          );
        }).toList(),
        onChanged: (val) => widget.controller.updateField(widget.fieldKey, val),
      ),
    );
  }
}

/// Wrapper para listas anidadas (One2Many / Many2Many).
class FrameworkNestedForm extends FormFieldWrapper {
  const FrameworkNestedForm({
    super.key,
    required super.fieldKey,
    required super.controller,
    super.label,
  });

  @override
  State<FrameworkNestedForm> createState() => _FrameworkNestedFormState();
}

class _FrameworkNestedFormState extends FormFieldWrapperState<FrameworkNestedForm> {
  List<Map<String, dynamic>> get _items => 
      List<Map<String, dynamic>>.from(currentValue ?? []);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) Text(widget.label!, style: Theme.of(context).textTheme.titleMedium),
        ..._items.map((item) => ListTile(
          title: Text(item.toString()),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final newList = _items..remove(item);
              widget.controller.updateField(widget.fieldKey, newList);
            },
          ),
        )),
        TextButton.icon(
          onPressed: () {
            // Ejemplo de agregar item vacío.
            final newList = _items..add({'id': 'TEMP_${DateTime.now().millisecondsSinceEpoch}'});
            widget.controller.updateField(widget.fieldKey, newList);
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar Item'),
        ),
      ],
    );
  }
}
