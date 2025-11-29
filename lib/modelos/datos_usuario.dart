import 'package:cloud_firestore/cloud_firestore.dart';

class DatosUsuario {
  final String uid;
  final String nombre;
  final String correo;
  final DateTime fechaCreacion;
  final Map<String, dynamic> preferencias;
  final Map<String, dynamic> estadisticas;
  final List<String> generosFavoritos;

  DatosUsuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.fechaCreacion,
    required this.preferencias,
    required this.estadisticas,
    required this.generosFavoritos,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'correo': correo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'preferencias': preferencias,
      'estadisticas': estadisticas,
      'generosFavoritos': generosFavoritos,
    };
  }

  factory DatosUsuario.fromMap(Map<String, dynamic> map) {
    return DatosUsuario(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      preferencias: Map<String, dynamic>.from(map['preferencias'] ?? {}),
      estadisticas: Map<String, dynamic>.from(map['estadisticas'] ?? {}),
      generosFavoritos: List<String>.from(map['generosFavoritos'] ?? []),
    );
  }

  factory DatosUsuario.vacio() {
    return DatosUsuario(
      uid: '',
      nombre: '',
      correo: '',
      fechaCreacion: DateTime.now(),
      preferencias: {
        'generos': [],
        'formatos': ['fisico', 'audio'],
        'notificaciones': true,
      },
      estadisticas: {
        'librosLeidos': 0,
        'tiempoLectura': 0,
        'rachaActual': 0,
        'paginasTotales': 0,
      },
      generosFavoritos: [],
    );
  }
}