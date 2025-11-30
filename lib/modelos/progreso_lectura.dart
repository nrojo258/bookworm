import 'package:cloud_firestore/cloud_firestore.dart';

class ProgresoLectura {
  final String id;
  final String usuarioId;
  final String libroId;
  final String tituloLibro;
  final List<String> autoresLibro;
  final String? miniaturaLibro;
  final String estado; 
  final int paginaActual;
  final int paginasTotales;
  final DateTime fechaInicio;
  final DateTime? fechaCompletado;
  final double calificacion;
  final String? resena;

  ProgresoLectura({
    required this.id,
    required this.usuarioId,
    required this.libroId,
    required this.tituloLibro,
    required this.autoresLibro,
    this.miniaturaLibro,
    required this.estado,
    required this.paginaActual,
    required this.paginasTotales,
    required this.fechaInicio,
    this.fechaCompletado,
    this.calificacion = 0.0,
    this.resena,
  });
}