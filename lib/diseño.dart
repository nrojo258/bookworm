import 'package:flutter/material.dart';

class AppColores {
  static const Color primario = Color(0xFF7E57C2);
  static const Color secundario = Color(0xFF26A69A);
  static const Color fondo = Color(0xFFF8F9FA);
  static const Color blanco = Colors.white;
  static const Color negro87 = Colors.black87;
  static const Color negro54 = Colors.black54;
  static const Color gris = Colors.grey;
}

class EstilosApp {
  static const TextStyle tituloGrande = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle tituloMedio = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle cuerpoMedio = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
  
  static ButtonStyle botonPrimario = ElevatedButton.styleFrom(
    backgroundColor: AppColores.primario,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
  );
  
  static BoxDecoration decoracionTarjeta = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class DatosApp {
  static const List<String> formatos = ['Todos los formatos', 'Libro físico', 'Audiolibro'];
  static const List<String> generos = [
    'Todos los géneros', 'Ficción', 'Thriller', 'Ciencia Ficción', 'Biografía', 'Romance', 'Fantasía',
    'Misterio', 'Histórica', 'Aventura', 'Terror', 'Desarrollo Personal', 'Poesía',
    'Ensayo', 'Infantil', 'Juvenil'
  ];
}