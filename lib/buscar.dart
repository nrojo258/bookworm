import 'package:flutter/material.dart';
import 'diseño.dart';
import 'componentes.dart';
import 'modelos.dart';
import 'open_library.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  final TextEditingController _searchController = TextEditingController();
  final OpenLibrary _openLibraryService = OpenLibrary();
  
  String? _formatoSeleccionado = 'Todos los formatos';
  String? _generoSeleccionado = 'Todos los géneros';
  
  List<Book> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _generoSeleccionado = AppData.generos.isNotEmpty ? AppData.generos.first : null;
    _formatoSeleccionado = 'Todos los formatos';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) {
      _showErrorSnackBar('Por favor ingresa un término de búsqueda');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      List<Book> results;
      
      print('Buscando');
      print('Término: ${_searchController.text}');
      print('Género: $_generoSeleccionado');
      
      results = await _openLibraryService.searchBooks(
        query: _searchController.text,
        genre: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        limit: 20,
      );
      
      print('Resultados encontrados: ${results.length}');
      
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error en búsqueda: $e');
      _showErrorSnackBar('Error al buscar: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBookItem(Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: book.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.thumbnailUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.book, size: 40, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.book, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                if (book.authors.isNotEmpty)
                  Text(
                    'Por ${book.authors.join(', ')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                if (book.publishedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Publicado: ${book.publishedDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
                
                if (book.averageRating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${book.averageRating!.toStringAsFixed(1)} (${book.ratingsCount ?? 0})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
                
                if (book.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    book.description!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            SizedBox(height: 16),
            Text('Buscando libros...', style: AppStyles.bodyMedium),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Busca tu próximo libro favorito', 
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Ingresa un título, autor o género', 
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No se encontraron libros',
        description: 'Intenta con otros términos de búsqueda',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_searchResults.length} resultados encontrados',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._searchResults.map(_buildBookItem).toList(),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BookWorm', style: AppStyles.titleLarge),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: const [AppBarButtons(currentRoute: '/search')],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Encuentra tu próximo libro',
                    style: AppStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Busca entre miles de libros y audiolibros',
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Ej: Harry Potter, Stephen King, Ciencia Ficción...',
                    onSearch: _performSearch,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownFilter(
                          value: _formatoSeleccionado,
                          items: const ['Todos los formatos', 'Libros', 'Audiolibros'],
                          hint: 'Formato',
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _formatoSeleccionado = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownFilter(
                          value: _generoSeleccionado,
                          items: AppData.generos,
                          hint: 'Género',
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _generoSeleccionado = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados de búsqueda',
                    style: AppStyles.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildResultsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}