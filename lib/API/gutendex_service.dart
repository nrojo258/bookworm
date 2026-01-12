import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelos.dart';

class GutendexService {
  static const String _urlBase = 'https://gutendex.com/books';

  Future<List<Libro>> buscarLibros({
    required String consulta,
    String? genero,
    String? idioma,
  }) async {
    try {
      String url = '$_urlBase/?search=${Uri.encodeComponent(consulta)}';
      
      if (genero != null && genero != 'Todos los géneros') {
        url += '&topic=${Uri.encodeComponent(genero)}';
      }
      
      if (idioma != null) {
        url += '&languages=$idioma';
      }

      final respuesta = await http.get(Uri.parse(url));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final results = datos['results'] as List?;
        
        if (results == null) return [];
        
        return results.map((book) => _libroDeGutendex(book)).toList();
      } else {
        throw Exception('Error al buscar en Gutendex: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con Gutendex: $e');
    }
  }

  Future<List<Libro>> obtenerLibrosPopulares({int limite = 20}) async {
    try {
      final respuesta = await http.get(Uri.parse(_urlBase));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final results = datos['results'] as List?;
        
        if (results == null) return [];
        
        return results.take(limite).map((book) => _libroDeGutendex(book)).toList();
      } else {
        throw Exception('Error al obtener populares de Gutendex: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con Gutendex: $e');
    }
  }

  Future<Libro?> obtenerLibroPorId(String id) async {
    try {
      final idLimpio = id.replaceFirst('guten_', '');
      final respuesta = await http.get(Uri.parse('$_urlBase/$idLimpio'));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        return _libroDeGutendex(datos);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Libro _libroDeGutendex(Map<String, dynamic> json) {
    final formats = json['formats'] as Map<String, dynamic>? ?? {};
    
    // Priorizamos HTML para lectura online, luego EPUB
    String? urlLectura = formats['text/html'] ?? 
                        formats['text/html; charset=utf-8'] ??
                        formats['application/epub+zip'] ??
                        formats['application/x-mobipocket-ebook'] ??
                        formats['text/plain; charset=utf-8'] ??
                        formats['text/plain'];

    return Libro(
      id: 'guten_${json['id']}',
      titulo: json['title'] ?? 'Título no disponible',
      autores: (json['authors'] as List?)?.map((a) => a['name'] as String).toList() ?? [],
      descripcion: 'Libro del dominio público de Project Gutenberg. Temas: ${(json['subjects'] as List?)?.join(', ') ?? 'Varios'}',
      urlMiniatura: formats['image/jpeg'],
      categorias: List<String>.from(json['bookshelves'] ?? []),
      numeroCalificaciones: json['download_count'],
      urlLectura: urlLectura,
    );
  }
}
