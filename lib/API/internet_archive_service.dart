import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelos.dart';

class InternetArchiveService {
  static const String _urlBase = 'https://archive.org/advancedsearch.php';

  Future<List<Libro>> buscarLibros(String consulta, {String? genero, int limite = 20}) async {
    if (consulta.isEmpty) return [];
    
    try {
      String query = 'title:($consulta) AND mediatype:(texts)';
      if (genero != null && genero != 'Todos los géneros') {
        query += ' AND subject:(${Uri.encodeComponent(genero)})';
      }
      
      final url = '$_urlBase?q=${Uri.encodeComponent(query)}&rows=$limite&output=json';
      final respuesta = await http.get(Uri.parse(url));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final List<dynamic> docs = datos['response']?['docs'] ?? [];
        return docs.map((doc) => _mapearLibro(doc)).toList();
      }
      return [];
    } catch (e) {
      print('Error en Internet Archive: $e');
      return [];
    }
  }

  Future<Libro?> obtenerDetalles(String id) async {
    try {
      final idLimpio = id.replaceFirst('ia_', '');
      final url = 'https://archive.org/metadata/$idLimpio';
      final respuesta = await http.get(Uri.parse(url));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final metadata = datos['metadata'];
        if (metadata != null) {
          return _mapearLibro({...metadata, 'identifier': idLimpio});
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo detalles en Internet Archive: $e');
      return null;
    }
  }

  Libro _mapearLibro(Map<String, dynamic> doc) {
    final identifier = doc['identifier'];
    
    List<String> autores = [];
    if (doc['creator'] != null) {
      if (doc['creator'] is List) {
        autores = List<String>.from(doc['creator']);
      } else {
        autores = [doc['creator'].toString()];
      }
    }

    return Libro(
      id: 'ia_$identifier',
      titulo: doc['title'] ?? 'Sin título',
      autores: autores,
      descripcion: _limpiarHtml(doc['description']),
      urlMiniatura: 'https://archive.org/services/img/$identifier',
      fechaPublicacion: doc['date']?.toString().split('-')[0],
      categorias: doc['subject'] is List ? List<String>.from(doc['subject'].take(3)) : [],
      urlLectura: 'https://archive.org/details/$identifier',
    );
  }

  String? _limpiarHtml(dynamic texto) {
    if (texto == null) return null;
    return texto.toString().replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }
}
