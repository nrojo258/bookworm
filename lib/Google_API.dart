import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelos.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/';
  final String apiKey;

  GoogleBooksService({required this.apiKey});

  Future<List<Book>> searchBooks({
    required String query,
    String? format,
    String? genre,
    int maxResults = 20,
    int startIndex = 0,
  }) async {
    try {
      String searchQuery = query;
      
      if (genre != null && genre != 'Todos los géneros') {
        searchQuery += '+subject:$genre';
      }

      final url = Uri.parse(
        '${_baseUrl}volumes?q=$searchQuery&maxResults=$maxResults&startIndex=$startIndex'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items == null) return [];
        
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        throw Exception('Error al buscar libros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Book?> getBookDetails(String bookId) async {
    try {
      final url = Uri.parse('${_baseUrl}volumes/$bookId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Error al obtener detalles del libro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Book>> getBooksByGenre(String genre, {int maxResults = 20}) async {
    try {
      final url = Uri.parse(
        '${_baseUrl}volumes?q=subject:$genre&maxResults=$maxResults'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items == null) return [];
        
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        throw Exception('Error al buscar por género: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}