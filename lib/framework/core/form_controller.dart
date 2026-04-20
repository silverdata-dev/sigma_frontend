import 'dart:async';

/// Controlador central para formularios dinámicos.
/// Maneja la reactividad a nivel de campo mediante streams.
class FormController {
  final Map<String, dynamic> _data = {};
  final _fieldObservers = StreamController<String>.broadcast();
  
  /// Contador para validaciones o procesos asíncronos activos.
  int activeValidations = 0;

  /// Stream para observar qué campos han cambiado.
  Stream<String> get onFieldChanged => _fieldObservers.stream;

  /// Actualiza un campo y notifica a los observadores.
  void updateField(String key, dynamic value) {
    if (_data[key] == value) return;
    _data[key] = value;
    _fieldObservers.add(key);
  }

  /// Obtiene el valor actual de un campo.
  dynamic getValue(String key) => _data[key];

  /// Retorna una copia de los datos actuales.
  Map<String, dynamic> get data => Map.unmodifiable(_data);

  /// Cierra el controlador de streams.
  void dispose() {
    _fieldObservers.close();
  }

  /// Inicia un proceso de carga/validación.
  void startValidation() => activeValidations++;

  /// Finaliza un proceso de carga/validación.
  void endValidation() => activeValidations = (activeValidations > 0) ? activeValidations - 1 : 0;

  bool get isValidating => activeValidations > 0;
}
