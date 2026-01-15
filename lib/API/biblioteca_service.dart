import 'traductor_service.dart';
import 'google_books_service.dart';
import 'gutendex_service.dart';
import 'internet_archive_service.dart';
import 'open_library.dart';
import 'librivox_service.dart';
import 'modelos.dart';

class BibliotecaServiceUnificado {
  final GoogleBooksService _googleService;
  final GutendexService _gutendexService;
  final InternetArchiveService _archiveService;
  final OpenLibraryService _openLibraryService;
  final LibriVoxService _librivoxService;
  final TraductorService _traductorService;
  
  BibliotecaServiceUnificado({required String apiKey}) 
    : _googleService = GoogleBooksService(apiKey: apiKey),
      _gutendexService = GutendexService(),
      _archiveService = InternetArchiveService(),
      _openLibraryService = OpenLibraryService(),
      _librivoxService = LibriVoxService(),
      _traductorService = TraductorService();

  Future<List<Libro>> buscarLibros(String consulta, {String? genero, int limite = 20}) async {
    final List<Libro> todosLibros = [];
    
    // Buscar en todas las APIs (excepto Google que ya tiene español)
    final futures = [
      _googleService.buscarLibros(consulta, genero: genero, limite: limite, pais: 'ES'),
      _gutendexService.buscarLibros(consulta, genero: genero, limite: limite),
      _archiveService.buscarLibros(consulta, genero: genero, limite: limite),
      _openLibraryService.buscarLibros(consulta, genero: genero, limite: limite),
      _librivoxService.buscarLibros(consulta, genero: genero, limite: limite),
    ];
    
    try {
      final resultados = await Future.wait(futures);
      
      for (var libros in resultados) {
        // Mejorar descripciones en español
        final librosMejorados = await Future.wait(
          libros.map((libro) => _mejorarDescripcionEspanol(libro))
        );
        todosLibros.addAll(librosMejorados);
      }
    } catch (e) {
      print('Error en búsqueda unificada: $e');
    }
    
    return todosLibros;
  }

  Future<Libro> _mejorarDescripcionEspanol(Libro libro) async {
    if (libro.descripcion == null || libro.descripcion!.isEmpty) {
      return libro;
    }
    
    final descripcion = libro.descripcion!;

    // Usar métodos públicos (sin guión bajo)
    if (_traductorService.esTextoEspanol(descripcion) || descripcion.length < 50) {
      return libro;
    }
    
    if (_traductorService.esTextoIngles(descripcion)) {
      final traducido = await _traductorService.traducirTexto(descripcion);
      if (traducido != null && traducido.isNotEmpty) {
        return libro.copyWith(descripcion: traducido);
      }
    }
    
    return libro;
  }

  Future<Libro?> obtenerDetalles(String id) async {
    Libro? libro;
    
    try {
      if (id.startsWith('google_')) {
        libro = await _googleService.obtenerDetalles(id);
      } else if (id.startsWith('guten_')) {
        libro = await _gutendexService.obtenerDetalles(id);
      } else if (id.startsWith('ia_')) {
        libro = await _archiveService.obtenerDetalles(id);
      } else if (id.startsWith('ol_')) {
        libro = await _openLibraryService.obtenerDetalles(id);
      } else if (id.startsWith('librivox_')) {
        libro = await _librivoxService.obtenerDetalles(id);
      }
      
      if (libro != null) {
        return await _mejorarDescripcionEspanol(libro);
      }
    } catch (e) {
      print('Error obteniendo detalles unificados: $e');
    }
    
    return null;
  }
  
  // CORRECCIÓN en biblioteca_service_unificado.dart
Future<List<Libro>> obtenerLibrosPopulares({int limite = 20}) async {
  final List<Libro> todosLibros = []; // ← Especificar el tipo List<Libro>
  
  try {
    // Solo algunas APIs tienen libros populares
    final futures = [
      _gutendexService.obtenerLibrosPopulares(limite: limite),
      // Agrega otros servicios si tienen método similar
    ];
    
    final resultados = await Future.wait(futures);
    
    for (var libros in resultados) {
      final librosMejorados = await Future.wait(
        libros.map((libro) => _mejorarDescripcionEspanol(libro))
      );
      todosLibros.addAll(librosMejorados);
    }
  } catch (e) {
    print('Error obteniendo populares: $e');
  }
  
  return todosLibros.take(limite).toList();
}
}