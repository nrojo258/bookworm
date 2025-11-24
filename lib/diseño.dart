import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7E57C2);
  static const Color secondary = Color(0xFF26A69A);
  static const Color background = Color(0xFFF8F9FA);
  static const Color white = Colors.white;
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color grey = Colors.grey;
}

class AppStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
  
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
  );
  
  static BoxDecoration cardDecoration = BoxDecoration(
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

class AppData {
  static const List<String> formatos = ['Todos los formatos', 'Libro físico', 'Audiolibro'];
  static const List<String> generos = [
    'Ficción', 'Thriller', 'Ciencia Ficción', 'Biografía', 'Romance', 'Fantasía',
    'Misterio', 'Histórica', 'Aventura', 'Terror', 'Desarrollo Personal', 'Poesía',
    'Ensayo', 'Infantil', 'Juvenil'
  ];
}