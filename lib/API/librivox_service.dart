import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelos.dart';

class LibriVoxService {
  static const String _urlBase = 'https://librivox.org/api/feed/audiobooks';

  Future<List<Libro>> buscarAudiolibros(String consulta, {String? genero}) async {
    try {
      final consultaCodificada = Uri.encodeComponent(consulta);
      String url = 'https://librivox.org/api/feed/audiobooks?format=json';
      
      // Si el usuario escribió algo específicamente (no es el default 'fiction')
      if (consulta.isNotEmpty && consulta.toLowerCase() != 'fiction') {
        // Usamos el prefijo ^ para búsqueda parcial al inicio, que es más flexible en LibriVox
        url += '&title=%5E$consultaCodificada';
      } else if (consulta.toLowerCase() == 'fiction' && (genero == null || genero == 'Todos los géneros')) {
        // Si es la búsqueda por defecto, pedimos libros recientes (limit)
        // ya que genre=Fiction a veces da error 500 en la API JSON
        url += '&limit=20';
      }
      
      if (genero != null && genero != 'Todos los géneros') {
        final generoIngles = _mapearGenero(genero);
        url += '&genre=${Uri.encodeComponent(generoIngles)}';
      }
      
      // Si no hay nada, buscamos algo por defecto para que no salga vacío
      if (consulta.isEmpty && (genero == null || genero == 'Todos los géneros')) {
        url += '&limit=20';
      }

      print('URL LibriVox: $url');
      var respuesta = await http.get(Uri.parse(url));

      // Si da error 500 y teníamos un género, reintentamos sin el género para no dejar al usuario sin nada
      if (respuesta.statusCode == 500 && url.contains('&genre=')) {
        print('Error 500 detectado en LibriVox con género, reintentando sin filtro de género');
        final nuevaUrl = url.split('&genre=')[0];
        respuesta = await http.get(Uri.parse(nuevaUrl));
      }

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        print('LibriVox respondió correctamente');
        
        dynamic books;
        if (datos is Map) {
          books = datos['books'];
        } else if (datos is List) {
          books = datos;
        }

        if (books == null || books is! List || books.isEmpty) {
          print('No hay libros en la respuesta de LibriVox, probando por autor...');
          if (consulta.isNotEmpty && consulta.toLowerCase() != 'fiction') {
            return _buscarPorAutor(consulta);
          }
          return [];
        }
        
        print('Encontrados ${books.length} audiolibros en LibriVox');
        return books.map<Libro>((book) => _mapearLibro(book as Map<String, dynamic>)).toList();
      } else {
        print('Error en LibriVox: ${respuesta.statusCode}');
        if (consulta.isNotEmpty && consulta.toLowerCase() != 'fiction') {
          return _buscarPorAutor(consulta);
        }
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Libro>> _buscarPorAutor(String consulta) async {
    try {
      // Usamos ^ para búsqueda parcial por autor también
      final url = '$_urlBase?author=%5E${Uri.encodeComponent(consulta)}&format=json';
      final respuesta = await http.get(Uri.parse(url));
      
      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final books = (datos is Map) ? datos['books'] : datos;
        if (books != null && books is List) {
          return books.map<Libro>((book) => _mapearLibro(book as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {}
    return [];
  }

  String _mapearGenero(String genero) {
    final Map<String, String> mapa = {
      'Ficción': 'Fiction',
      'Ciencia Ficción': 'Science Fiction',
      'Fantasía': 'Fantasy',
      'Romance': 'Romance',
      'Misterio': 'Mystery',
      'Terror': 'Horror',
      'No Ficción': 'Non-fiction',
      'Biografía': 'Biography',
      'Historia': 'History',
      'Poesía': 'Poetry',
      'Drama': 'Drama',
      'Aventura': 'Adventure',
      'Infantil': 'Children',
      'Juvenil': 'Young Adult',
      'Autoayuda': 'Self-Help',
    };
    return mapa[genero] ?? genero;
  }

  Libro _mapearLibro(Map<String, dynamic> json) {
    // Extraer autores
    List<String> autores = [];
    if (json['authors'] != null && json['authors'] is List) {
      autores = (json['authors'] as List).map<String>((a) {
        return '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim();
      }).toList();
    }

    // LibriVox no suele dar miniaturas directas en este feed, 
    // pero podemos usar una por defecto o intentar obtenerla si estuviera disponible.
    // Usaremos el id de Gutenberg si está disponible para la carátula o una genérica.
    
    // Aseguramos un ID válido
    final id = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    return Libro(
      id: 'librivox_$id',
      titulo: json['title'] ?? 'Título no disponible',
      autores: autores,
      descripcion: json['description'] ?? 'Audiolibro gratuito de LibriVox.',
      urlLectura: json['url_librivox'], // Enlace a la página del audiolibro
      esAudiolibro: true,
      urlVistaPrevia: json['url_zip_file'], // Enlace al archivo completo o stream
    );
  }
}
