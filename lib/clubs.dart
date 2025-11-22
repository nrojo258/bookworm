import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'app_components.dart';

class Clubs extends StatefulWidget {
  const Clubs({super.key});

  @override
  State<Clubs> createState() => _ClubsState();
}

class _ClubsState extends State<Clubs> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSection = 0;
  String? _generoSeleccionado;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarCrearClub() {
    final nombreController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear Nuevo Club', style: AppStyles.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Completa la información del club', style: AppStyles.bodyMedium),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del club', 
                    prefixIcon: Icon(Icons.group, color: AppColors.primary)
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Género del club', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
                DropdownFilter(
                  value: _generoSeleccionado,
                  items: AppData.generos,
                  hint: 'Selecciona un género',
                  onChanged: (value) => setState(() => _generoSeleccionado = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: nombreController.text.isEmpty || _generoSeleccionado == null ? null : () {
                _crearClub(nombreController.text, _generoSeleccionado!);
                Navigator.pop(context);
              },
              style: AppStyles.primaryButton,
              child: const Text('Crear Club'),
            ),
          ],
        ),
      ),
    );
  }

  void _crearClub(String nombre, String genero) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Club "$nombre" creado exitosamente'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _generoSeleccionado = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BookWorm', style: AppStyles.titleLarge),
        backgroundColor: AppColors.primary,
        actions: const [AppBarButtons(currentRoute: '/clubs')],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Clubs de lectura', style: AppStyles.titleMedium),
                      ElevatedButton(
                        onPressed: _mostrarCrearClub,
                        style: AppStyles.primaryButton,
                        child: const Row(children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 4),
                          Text('Crear club', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre y únete a clubs con intereses similares', 
                    style: AppStyles.bodyMedium
                  ),
                  const SizedBox(height: 20),
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Buscar clubs...',
                    onSearch: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Row(children: [
                Expanded(child: SectionButton(
                  text: 'Descubrir clubs',
                  isSelected: _selectedSection == 0,
                  icon: Icons.explore,
                  onPressed: () => setState(() => _selectedSection = 0),
                )),
                const SizedBox(width: 12),
                Expanded(child: SectionButton(
                  text: 'Mis clubs',
                  isSelected: _selectedSection == 1,
                  icon: Icons.group,
                  onPressed: () => setState(() => _selectedSection = 1),
                )),
              ]),
            ),
            const SizedBox(height: 20),

            _selectedSection == 0 ? _buildDiscoverClubs() : _buildMyClubs(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverClubs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clubs recomendados', style: AppStyles.titleMedium),
          SizedBox(height: 16),
          Text('Explora clubs basados en tus intereses', style: AppStyles.bodyMedium),
          SizedBox(height: 20),
          EmptyState(
            icon: Icons.group,
            title: 'No se encontraron clubs',
            description: 'Intenta con otros términos de búsqueda',
          ),
        ],
      ),
    );
  }

  Widget _buildMyClubs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mis clubs activos', style: AppStyles.titleMedium),
          SizedBox(height: 16),
          Text('Gestiona tus clubs de lectura actuales', style: AppStyles.bodyMedium),
          SizedBox(height: 20),
          EmptyState(
            icon: Icons.group_add,
            title: 'No tienes clubs activos',
            description: 'Únete a un club o crea uno nuevo',
          ),
        ],
      ),
    );
  }
}