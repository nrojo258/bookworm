class Libro {
  final String id;
  final String titulo;
  final List<String> autores;
  final String? descripcion;
  final String? urlMiniatura;
  final String? fechaPublicacion;
  final int? numeroPaginas;
  final List<String> categorias;
  final double? calificacionPromedio;
  final int? numeroCalificaciones;
  final String? urlLectura;
  final bool esAudiolibro;
  final String? urlVistaPrevia;

  Libro({
    required this.id,
    required this.titulo,
    required this.autores,
    this.descripcion,
    this.urlMiniatura,
    this.fechaPublicacion,
    this.numeroPaginas,
    this.categorias = const [],
    this.calificacionPromedio,
    this.numeroCalificaciones,
    this.urlLectura,
    this.esAudiolibro = false,
    this.urlVistaPrevia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'autores': autores,
      'descripcion': descripcion,
      'urlMiniatura': urlMiniatura,
      'fechaPublicacion': fechaPublicacion,
      'numeroPaginas': numeroPaginas,
      'categorias': categorias,
      'calificacionPromedio': calificacionPromedio,
      'numeroCalificaciones': numeroCalificaciones,
      'urlLectura': urlLectura,
      'esAudiolibro': esAudiolibro,
      'urlVistaPrevia': urlVistaPrevia,
    };
  }

  factory Libro.fromJson(Map<String, dynamic> json) {
  final informacionVolumen = json['volumeInfo'] ?? {};
  final enlacesImagen = informacionVolumen['imageLinks'] ?? {};

  return Libro(
    id: json['id'] ?? '',  
    titulo: informacionVolumen['title'] ?? 'Título no disponible',  
    autores: List<String>.from(informacionVolumen['authors'] ?? []), 
    descripcion: informacionVolumen['description'], 
    urlMiniatura: enlacesImagen['thumbnail'] ?? enlacesImagen['smallThumbnail'],  
    fechaPublicacion: informacionVolumen['publishedDate'],  
    numeroPaginas: informacionVolumen['pageCount'],  
    categorias: List<String>.from(informacionVolumen['categories'] ?? []), 
    calificacionPromedio: informacionVolumen['averageRating']?.toDouble(),  
    numeroCalificaciones: informacionVolumen['ratingsCount'],  
  );
}
}
