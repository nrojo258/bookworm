import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'app_components.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  final TextEditingController _searchController = TextEditingController();
  String? formatoSeleccionado = 'Todos los formatos';
  String? generoSeleccionado = 'Todos los géneros';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BookWorm', style: AppStyles.titleLarge),
        backgroundColor: AppColors.primary,
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
                  const Text('Encuentra tu próximo libro', style: AppStyles.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Busca entre miles de libros y audiolibros', style: AppStyles.bodyMedium),
                  const SizedBox(height: 20),
                  
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Buscar libros o audiolibros...',
                    onSearch: () {},
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: DropdownFilter(
                        value: formatoSeleccionado,
                        items: const ['Todos los formatos', 'Libro físico', 'Audiolibro'],
                        hint: 'Formato',
                        onChanged: (value) => setState(() => formatoSeleccionado = value),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: DropdownFilter(
                        value: generoSeleccionado,
                        items: AppData.generos,
                        hint: 'Género',
                        onChanged: (value) => setState(() => generoSeleccionado = value),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resultados de búsqueda', style: AppStyles.titleMedium),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Ingresa términos de búsqueda para encontrar libros', 
                      style: AppStyles.bodyMedium
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}