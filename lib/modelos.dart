class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedDate;
  final int? pageCount;
  final List<String> categories;
  final double? averageRating;
  final int? ratingsCount;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.thumbnailUrl,
    this.publishedDate,
    this.pageCount,
    this.categories = const [],
    this.averageRating,
    this.ratingsCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
  final volumeInfo = json['volumeInfo'] ?? {};
  final imageLinks = volumeInfo['imageLinks'] ?? {};

  return Book(
    id: json['id'] ?? '',  
    title: volumeInfo['title'] ?? 'Título no disponible',  
    authors: List<String>.from(volumeInfo['authors'] ?? []), 
    description: volumeInfo['description'], 
    thumbnailUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'],  
    publishedDate: volumeInfo['publishedDate'],  
    pageCount: volumeInfo['pageCount'],  
    categories: List<String>.from(volumeInfo['categories'] ?? []), 
    averageRating: volumeInfo['averageRating']?.toDouble(),  
    ratingsCount: volumeInfo['ratingsCount'],  
  );
}
}