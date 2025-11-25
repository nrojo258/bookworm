import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelos.dart';

class OpenLibrary {
  static const String _baseUrl = 'https://openlibrary.org';

  Future<List<Book>> searchBooks({
    required String query,
    String? genre,
    int limit = 20,
  }) async {
    try {
      String searchUrl = '$_baseUrl/search.json?q=$query&limit=$limit';
      
      if (genre != null && genre != 'Todos los géneros') {
        searchUrl += '&subject=$genre';
      }

      final response = await http.get(Uri.parse(searchUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List?;
        
        if (docs == null) return [];
        
        return docs.map((doc) => _bookFromOpenLibraryDoc(doc)).toList();
      } else {
        throw Exception('Error al buscar libros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Book?> getBookDetails(String bookId) async {
    try {
      final url = Uri.parse('$_baseUrl/books/$bookId.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _bookFromOpenLibraryJson(data);
      } else {
        throw Exception('Error al obtener detalles del libro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Book>> getBooksByGenre(String genre, {int limit = 20}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/subjects/${genre.toLowerCase()}.json?limit=$limit'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final works = data['works'] as List?;
        
        if (works == null) return [];
        
        return works.map((work) => _bookFromOpenLibraryWork(work)).toList();
      } else {
        throw Exception('Error al buscar por género: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Book?> searchByISBN(String isbn) async {
    try {
      final url = Uri.parse('$_baseUrl/isbn/$isbn.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _bookFromOpenLibraryJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Book _bookFromOpenLibraryDoc(Map<String, dynamic> doc) {
    String? thumbnailUrl;
    if (doc['cover_i'] != null) {
      thumbnailUrl = 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg';
    }

    List<String> authors = [];
    if (doc['author_name'] != null) {
      authors = List<String>.from(doc['author_name']);
    }

    List<String> categories = [];
    if (doc['subject'] != null) {
      categories = List<String>.from(doc['subject'].take(5));
    }

    return Book(
      id: doc['key'] ?? '',
      title: doc['title'] ?? 'Título no disponible',
      authors: authors,
      description: _truncateDescription(doc['first_sentence'] ?? doc['description']),
      thumbnailUrl: thumbnailUrl,
      publishedDate: doc['first_publish_year']?.toString(),
      pageCount: doc['number_of_pages_median'],
      categories: categories,
      averageRating: doc['ratings_average']?.toDouble(),
      ratingsCount: doc['ratings_count'],
    );
  }

  Book _bookFromOpenLibraryJson(Map<String, dynamic> json) {
    return Book(
      id: json['key'] ?? '',
      title: json['title'] ?? 'Título no disponible',
      authors: _extractAuthors(json),
      description: _truncateDescription(json['description']),
      thumbnailUrl: _getCoverUrl(json),
      publishedDate: _extractPublishDate(json),
      pageCount: json['number_of_pages'],
      categories: _extractSubjects(json),
      averageRating: json['ratings']?['average']?.toDouble(),
      ratingsCount: json['ratings']?['count'],
    );
  }

  Book _bookFromOpenLibraryWork(Map<String, dynamic> work) {
    return Book(
      id: work['key'] ?? '',
      title: work['title'] ?? 'Título no disponible',
      authors: _extractAuthorsFromWork(work),
      description: _truncateDescription(work['description']),
      thumbnailUrl: _getCoverUrlFromWork(work),
      publishedDate: work['first_publish_date']?.toString().substring(0, 4),
      categories: _extractSubjectsFromWork(work),
      averageRating: work['rating']?.toDouble(),
    );
  }

  List<String> _extractAuthors(Map<String, dynamic> json) {
    if (json['authors'] != null) {
      final authors = json['authors'] as List;
      return authors.map<String>((author) {
        return author['name'] ?? 'Autor desconocido';
      }).toList();
    }
    return [];
  }

  List<String> _extractAuthorsFromWork(Map<String, dynamic> work) {
    if (work['authors'] != null) {
      final authors = work['authors'] as List;
      return authors.map<String>((author) {
        return author['name'] ?? 'Autor desconocido';
      }).toList();
    }
    return [];
  }

  String? _getCoverUrl(Map<String, dynamic> json) {
    if (json['covers'] != null && json['covers'].isNotEmpty) {
      final coverId = json['covers'][0];
      return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    return null;
  }

  String? _getCoverUrlFromWork(Map<String, dynamic> work) {
    if (work['cover_id'] != null) {
      return 'https://covers.openlibrary.org/b/id/${work['cover_id']}-M.jpg';
    }
    return null;
  }

  String? _extractPublishDate(Map<String, dynamic> json) {
    if (json['publish_date'] != null) {
      return json['publish_date'];
    } else if (json['first_publish_date'] != null) {
      return json['first_publish_date'];
    }
    return null;
  }

  List<String> _extractSubjects(Map<String, dynamic> json) {
    if (json['subjects'] != null) {
      return List<String>.from(json['subjects'].take(5));
    }
    return [];
  }

  List<String> _extractSubjectsFromWork(Map<String, dynamic> work) {
    if (work['subject'] != null) {
      return List<String>.from(work['subject'].take(5));
    }
    return [];
  }

  String? _truncateDescription(dynamic description) {
    if (description == null) return null;
    
    String descText;
    if (description is String) {
      descText = description;
    } else if (description is Map) {
      descText = description['value'] ?? '';
    } else {
      descText = description.toString();
    }
    
    if (descText.length > 200) {
      return '${descText.substring(0, 200)}...';
    }
    return descText;
  }
}