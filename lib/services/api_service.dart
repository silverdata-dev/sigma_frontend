import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subject.dart';

class ApiService {
  // Para Android Emulator, usa 10.0.2.2. Para web/linux local, usa localhost.
  final String baseUrl = "http://localhost:8000/api";

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"status": "error", "message": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection failed: $e"};
    }
  }

  // --- CRUD para Subjects (Personas) ---

  Future<List<Subject>> getSubjects() async {
    final response = await http.get(Uri.parse('$baseUrl/subjects/'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Subject>.from(l.map((model) => Subject.fromJson(model)));
    } else {
      throw Exception('Error al cargar la lista de personas');
    }
  }

  Future<Subject> createSubject(Subject subject) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(subject.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Subject.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el registro: ${response.body}');
    }
  }

  Future<Subject> updateSubject(String id, Subject subject) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(subject.toJson()),
    );
    if (response.statusCode == 200) {
      return Subject.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el registro');
    }
  }

  Future<void> deleteSubject(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/subjects/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el registro');
    }
  }
}
