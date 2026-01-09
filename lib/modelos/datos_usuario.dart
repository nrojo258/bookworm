import 'package:cloud_firestore/cloud_firestore.dart';

class DatosUsuario {
  final String uid;
  final String nombre;
  final String correo;
  final DateTime fechaCreacion;
  final String? urlImagenPerfil;  
  final String? biografia; 
  final Map<String, dynamic> preferencias;
  final Map<String, dynamic> estadisticas;
  final List<String> generosFavoritos;
  final String biografia;
  final String? urlImagenPerfil;

  DatosUsuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.fechaCreacion,
    this.urlImagenPerfil,         
    this.biografia,
    required this.preferencias,
    required this.estadisticas,
    required this.generosFavoritos,
    this.biografia = '',
    this.urlImagenPerfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'correo': correo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'urlImagenPerfil': urlImagenPerfil,  
      'biografia': biografia,   
      'preferencias': preferencias,
      'estadisticas': estadisticas,
      'generosFavoritos': generosFavoritos,
      'biografia': biografia,
      'urlImagenPerfil': urlImagenPerfil,
    };
  }

  factory DatosUsuario.fromMap(Map<String, dynamic> map) {
    return DatosUsuario(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null 
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
      urlImagenPerfil: map['urlImagenPerfil'],  
      biografia: map['biografia'],            
      preferencias: Map<String, dynamic>.from(map['preferencias'] ?? {}),
      estadisticas: Map<String, dynamic>.from(map['estadisticas'] ?? {}),
      generosFavoritos: List<String>.from(map['generosFavoritos'] ?? []),
      biografia: map['biografia'] ?? '',
      urlImagenPerfil: map['urlImagenPerfil'],
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
      biografia: '',
      urlImagenPerfil: null,
    );
  }
}
