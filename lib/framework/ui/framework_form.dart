import 'package:flutter/material.dart';
import '../core/form_controller.dart';
import 'field_wrappers.dart';
import 'rel_many2one_field.dart';
import 'one2many_field.dart';

/// Generador de UI dinámico basado en esquemas JSON.
class FrameworkForm extends StatelessWidget {
  final List<Map<String, dynamic>> schema;
  final FormController controller;

  /// ID de la entidad actual (necesario para campos one2many_relational).
  final String? entityId;

  /// Permite inyectar widgets personalizados para llaves específicas del esquema.
  final Map<String, Widget Function(FormController)>? overrides;

  const FrameworkForm({
    super.key,
    required this.schema,
    required this.controller,
    this.entityId,
    this.overrides,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: schema.map((field) => _buildField(field)).toList(),
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final String key = field['key'];
    final String type = field['type'];
    final String? label = field['label'];

    // 1. Override personalizado tiene prioridad.
    if (overrides != null && overrides!.containsKey(key)) {
      return overrides![key]!(controller);
    }

    // 2. Renderizado basado en el tipo.
    switch (type) {
      case 'text':
        return FrameworkTextField(
          fieldKey: key,
          controller: controller,
          label: label,
        );

      case 'many2one':
        return FrameworkMany2One(
          fieldKey: key,
          controller: controller,
          label: label,
          dependsOnKey: field['depends_on'],
          optionsProvider: (filter) => [
            {'id': 1, 'display_name': 'Opción A'},
            {'id': 2, 'display_name': 'Opción B'},
          ],
        );

      case 'many2one_relational':
        return FrameworkRelMany2One(
          fieldKey: key,
          controller: controller,
          label: label,
          relatedEndpoint: field['related_endpoint'] as String? ?? '',
          relatedFilter:
              (field['related_filter'] as Map?)?.cast<String, String>(),
          displayFields:
              (field['display_fields'] as List?)?.cast<String>() ?? ['name'],
          relatedSchema:
              (field['related_schema'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
          createExtraData:
              field['create_extra_data'] as Map<String, dynamic>?,
        );

      case 'one2many_relational':
        return FrameworkRelOne2Many(
          entityId: entityId,
          label: label,
          linkEndpoint: field['link_endpoint'] as String? ?? '',
          linkForeignKey: field['link_foreign_key'] as String? ?? '',
          linkRelatedKey: field['link_related_key'] as String? ?? '',
          linkTipo: field['link_tipo'] as String?,
          relatedEndpoint: field['related_endpoint'] as String? ?? '',
          linkDisplayFields:
              (field['link_display_fields'] as List?)?.cast<String>() ??
              ['name'],
          relatedDisplayFields:
              (field['related_display_fields'] as List?)?.cast<String>() ??
              ['name'],
          relatedFilter:
              (field['related_filter'] as Map?)?.cast<String, String>(),
          relatedSchema:
              (field['related_schema'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
          createExtraData:
              field['create_extra_data'] as Map<String, dynamic>?,
        );

      case 'nested':
        return FrameworkNestedForm(
          fieldKey: key,
          controller: controller,
          label: label,
        );

      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Tipo no soportado: $type ($key)',
              style: const TextStyle(color: Colors.red)),
        );
    }
  }
}
