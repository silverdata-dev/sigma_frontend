import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/framework_example_screen.dart';
import 'screens/generic_list_screen.dart';
import 'screens/generic_form_screen.dart';

// Schema inline para el formulario de representante (dentro de diálogos)
final _representanteInlineSchema = [
  {'key': 'cedula', 'type': 'text', 'label': 'Cédula / Documento Identidad'},
  {'key': 'name', 'type': 'text', 'label': 'Nombre Completo'},
  {'key': 'email', 'type': 'text', 'label': 'Correo Electrónico'},
  {'key': 'phone', 'type': 'text', 'label': 'Teléfono'},
  {'key': 'address', 'type': 'text', 'label': 'Dirección'},
];

// Esquema común para personas (Profesores, Empleados, Representantes, etc.)
final _personaSchema = [
  {'key': 'cedula', 'type': 'text', 'label': 'Cédula / Documento Identidad'},
  {'key': 'name', 'type': 'text', 'label': 'Nombre Completo'},
  {'key': 'email', 'type': 'text', 'label': 'Correo Electrónico'},
  {'key': 'phone', 'type': 'text', 'label': 'Teléfono'},
  {'key': 'address', 'type': 'text', 'label': 'Dirección Física'},
  {'key': 'sex', 'type': 'many2one', 'label': 'Sexo', 'depends_on': null},
];

// Esquema de Estudiante — incluye el one2many de Representantes
final _estudianteSchema = [
  {'key': 'cedula', 'type': 'text', 'label': 'Cédula / Documento Identidad'},
  {'key': 'name', 'type': 'text', 'label': 'Nombre Completo'},
  {'key': 'email', 'type': 'text', 'label': 'Correo Electrónico'},
  {'key': 'phone', 'type': 'text', 'label': 'Teléfono'},
  {'key': 'address', 'type': 'text', 'label': 'Dirección Física'},
  {'key': 'sex', 'type': 'many2one', 'label': 'Sexo', 'depends_on': null},
  {
    'key': 'representantes',
    'type': 'one2many_relational',
    'label': 'Representantes',
    'link_endpoint': 'subject-relaciones',
    'link_foreign_key': 'sujeto_a_id',
    'link_related_key': 'sujeto_b_id',
    'link_tipo': 'representante',
    'related_endpoint': 'subjects',
    'link_display_fields': ['sujeto_b_nombre', 'sujeto_b_cedula'],
    'related_display_fields': ['name', 'cedula'],
    'related_filter': {'metadata_json.rol': 'Representante'},
    'related_schema': _representanteInlineSchema,
    'create_extra_data': {'metadata_json.rol': 'Representante'},
  },
];

// Esquema para Periodos
final _periodoSchema = [
  {'key': 'name', 'type': 'text', 'label': 'Nombre del Periodo (ej. 2025-2026)'},
  {'key': 'status', 'type': 'text', 'label': 'Estado (Planificación, Activo, Cerrado)'},
];

// Esquema para Secciones
final _seccionSchema = [
  {'key': 'name', 'type': 'text', 'label': 'Nombre de Sección (ej. "A")'},
  {'key': 'grado', 'type': 'text', 'label': 'Grado o Año'},
  {'key': 'periodo_id', 'type': 'text', 'label': 'ID Periodo Académico (Temporal text)'},
];

// Esquema para Roles de Sistema
final _rolesSchema = [
  {'key': 'subject_id', 'type': 'text', 'label': 'ID Sujeto'},
  {'key': 'place_id', 'type': 'text', 'label': 'ID Lugar (Sede)'},
  {'key': 'roletype_id', 'type': 'many2one', 'label': 'ID Tipo de Rol'},
];

// Esquema para Eventos
final _eventoSchema = [
  {'key': 'type', 'type': 'text', 'label': 'Tipo de Evento (GRADE_RECORDED, etc)'},
  {'key': 'subject_id', 'type': 'text', 'label': 'A quien le afecta'},
  {'key': 'actor_id', 'type': 'text', 'label': 'Quien lo registró'},
];

// Configuración del enrutador central
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/example',
      builder: (context, state) => const FrameworkExampleScreen(),
    ),
    
    // --- ESTUDIANTES ---
    GoRoute(
      path: '/estudiantes',
      builder: (context, state) => const GenericListScreen(
        title: 'Estudiantes', endpoint: 'subjects', routePrefix: '/estudiantes',
        displayFields: ['name', 'cedula'], filterKey: 'metadata_json.rol', filterValue: 'Estudiante',
      ),
    ),
    GoRoute(
      path: '/estudiantes/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Estudiante', endpoint: 'subjects', entityId: state.pathParameters['id']!,
        schema: _estudianteSchema, extraData: const {'metadata_json.rol': 'Estudiante'},
      ),
    ),

    // --- PROFESORES ---
    GoRoute(
      path: '/profesores',
      builder: (context, state) => const GenericListScreen(
        title: 'Profesores', endpoint: 'subjects', routePrefix: '/profesores',
        displayFields: ['name', 'cedula'], filterKey: 'metadata_json.rol', filterValue: 'Profesor',
      ),
    ),
    GoRoute(
      path: '/profesores/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Profesor', endpoint: 'subjects', entityId: state.pathParameters['id']!,
        schema: _personaSchema, extraData: const {'metadata_json.rol': 'Profesor'},
      ),
    ),

    // --- REPRESENTANTES ---
    GoRoute(
      path: '/representantes',
      builder: (context, state) => const GenericListScreen(
        title: 'Representantes', endpoint: 'subjects', routePrefix: '/representantes',
        displayFields: ['name', 'cedula'], filterKey: 'metadata_json.rol', filterValue: 'Representante',
      ),
    ),
    GoRoute(
      path: '/representantes/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Representante', endpoint: 'subjects', entityId: state.pathParameters['id']!,
        schema: _personaSchema, extraData: const {'metadata_json.rol': 'Representante'},
      ),
    ),

    // --- OTROS EMPLEADOS ---
    GoRoute(
      path: '/empleados',
      builder: (context, state) => const GenericListScreen(
        title: 'Otros Empleados', endpoint: 'subjects', routePrefix: '/empleados',
        displayFields: ['name', 'cedula'], filterKey: 'metadata_json.rol', filterValue: 'Empleado',
      ),
    ),
    GoRoute(
      path: '/empleados/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Empleado', endpoint: 'subjects', entityId: state.pathParameters['id']!,
        schema: _personaSchema, extraData: const {'metadata_json.rol': 'Empleado'},
      ),
    ),

    // ==========================================
    // CRUD GENERAL PARA EL RESTO DE ENTIDADES
    // ==========================================

    // --- PERIODOS ACADEMICOS ---
    GoRoute(
      path: '/periodos',
      builder: (context, state) => const GenericListScreen(
        title: 'Periodos Académicos', endpoint: 'periodos-academicos', routePrefix: '/periodos',
        displayFields: ['name', 'status'],
      ),
    ),
    GoRoute(
      path: '/periodos/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Periodo Académico', endpoint: 'periodos-academicos', entityId: state.pathParameters['id']!,
        schema: _periodoSchema,
      ),
    ),

    // --- SECCIONES ---
    GoRoute(
      path: '/secciones',
      builder: (context, state) => const GenericListScreen(
        title: 'Secciones', endpoint: 'secciones', routePrefix: '/secciones',
        displayFields: ['name', 'grado'],
      ),
    ),
    GoRoute(
      path: '/secciones/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Sección', endpoint: 'secciones', entityId: state.pathParameters['id']!,
        schema: _seccionSchema,
      ),
    ),

    // --- ROLES (Seguridad) ---
    GoRoute(
      path: '/roles',
      builder: (context, state) => const GenericListScreen(
        title: 'Asignación de Roles', endpoint: 'roles', routePrefix: '/roles',
        displayFields: ['roletype_id', 'subject_id'],
      ),
    ),
    GoRoute(
      path: '/roles/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Rol', endpoint: 'roles', entityId: state.pathParameters['id']!,
        schema: _rolesSchema,
      ),
    ),

    // --- EVENTOS (Auditoría / Calificaciones) ---
    GoRoute(
      path: '/eventos',
      builder: (context, state) => const GenericListScreen(
        title: 'Event Store', endpoint: 'events', routePrefix: '/eventos',
        displayFields: ['type', 'recorded_at'],
      ),
    ),
    GoRoute(
      path: '/eventos/:id',
      builder: (context, state) => GenericFormScreen(
        title: 'Evento', endpoint: 'events', entityId: state.pathParameters['id']!,
        schema: _eventoSchema,
      ),
    ),
  ],
);
