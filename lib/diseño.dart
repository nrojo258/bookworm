import 'package:flutter/material.dart';

class AppColores {
  static const Color primario = Color(0xFF7E57C2);
  static const Color secundario = Color(0xFF26A69A);
  static const Color fondo = Color(0xFFF8F9FA);
  static const Color blanco = Colors.white;
  static const Color negro87 = Colors.black87;
  static const Color negro54 = Colors.black54;
  static const Color gris = Colors.grey;
  static const Color rojo = Colors.red;
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
  
  static const TextStyle tituloPequeno = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle cuerpoGrande = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  
  static const TextStyle cuerpoMedio = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
  
  static const TextStyle cuerpoPequeno = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
  
  static ButtonStyle botonPrimario = ElevatedButton.styleFrom(
    backgroundColor: AppColores.primario,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
  );
  
  static ButtonStyle botonSecundario = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColores.primario,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColores.primario),
    ),
    elevation: 0,
  );
  
  static ButtonStyle botonTexto = TextButton.styleFrom(
    foregroundColor: AppColores.primario,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  
  static BoxDecoration decoracionTarjetaPlana = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  );
  
  static BoxDecoration decoracionGradiente = BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColores.primario, AppColores.secundario],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
  static InputDecoration decoracionCampoTexto = InputDecoration(
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: AppColores.primario),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

class DatosApp {
  static const List<String> formatos = ['Todos los formatos', 'Libro físico', 'Audiolibro'];
  static const List<String> generos = [
    'Todos los géneros', 'Ficción', 'Thriller', 'Ciencia Ficción', 'Biografía', 'Romance', 'Fantasía',
    'Misterio', 'Histórica', 'Aventura', 'Terror', 'Desarrollo Personal', 'Poesía',
    'Ensayo', 'Infantil', 'Juvenil'
  ];
  
  static const List<Map<String, dynamic>> accionesRapidas = [
    {'icono': Icons.menu_book, 'etiqueta': 'Libros leídos'},
    {'icono': Icons.flag, 'etiqueta': 'Meta semanal'},
    {'icono': Icons.access_time, 'etiqueta': 'Tiempo leído'},
    {'icono': Icons.local_fire_department, 'etiqueta': 'Días de racha'},
  ];
  
  static const List<Map<String, dynamic>> seccionesPerfil = [
    {'texto': 'Información', 'icono': Icons.person_outline},
    {'texto': 'Mi Progreso', 'icono': Icons.trending_up},
    {'texto': 'Estadísticas', 'icono': Icons.analytics},
    {'texto': 'Configuración', 'icono': Icons.settings},
  ];
}