import 'package:flutter/material.dart';

const Color _kPrimaryColor = Color(0xFF7E57C2);
const Color _kSecondaryColor = Color(0xFF26A69A);
const Color _kBackgroundColor = Color(0xFFF8F9FA);

class Clubs extends StatefulWidget {
  const Clubs({super.key});

  @override
  State<Clubs> createState() => _ClubsState();
}

class _ClubsState extends State<Clubs> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSection = 0; 
  
  final List<String> _generos = [
    'Ficción',
    'Thriller',
    'Ciencia Ficción',
    'Biografía',
    'Romance',
    'Fantasía',
    'Misterio',
    'Histórica',
    'Aventura',
    'Terror',
    'Desarrollo Personal',
    'Poesía',
    'Ensayo',
    'Infantil',
    'Juvenil'
  ];
  String? _generoSeleccionado;
  
  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarCrearClub() {
    final TextEditingController _nombreController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Crear Nuevo Club',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Completa la información del club',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del club',
                        hintText: 'Ej: Club de Lectura de Ciencia Ficción',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _kPrimaryColor),
                        ),
                        prefixIcon: Icon(Icons.group, color: _kPrimaryColor),
                      ),
                      maxLength: 50,
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Género del club',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _generoSeleccionado,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text(
                          'Selecciona un género',
                          style: TextStyle(color: Colors.grey),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        icon: const Icon(Icons.arrow_drop_down, color: _kPrimaryColor),
                        
                        items: _generos.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        
                        onChanged: (String? newValue) {
                          setState(() {
                            _generoSeleccionado = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _generoSeleccionado == null 
                          ? 'Selecciona el género principal del club'
                          : 'Género seleccionado: $_generoSeleccionado',
                      style: TextStyle(
                        fontSize: 12,
                        color: _generoSeleccionado == null ? Colors.orange : _kPrimaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nombreController.text.isEmpty || _generoSeleccionado == null
                      ? null
                      : () {
                          _crearClub(_nombreController.text, _generoSeleccionado!);
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Crear Club'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _crearClub(String nombre, String genero) {
    print('Creando club: $nombre - Género: $genero');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Club "$nombre" creado exitosamente'),
        backgroundColor: _kSecondaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    
    setState(() {
      _generoSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'BookWorm',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          _buildAppBarButton('Buscar', () => Navigator.popAndPushNamed(context, '/search')),
          _buildAppBarButton('Clubs', () {}, isActive: true),
          _buildAppBarButton('Perfil', () => Navigator.popAndPushNamed(context, '/perfil')),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Clubs de lectura',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black87
                        )
                      ),
                      ElevatedButton(
                        onPressed: _mostrarCrearClub,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Crear club',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre y únete a clubs de lectura con intereses similares',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _kBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center( 
                            child: TextField(
                              controller: _searchController, 
                              decoration: const InputDecoration(
                                hintText: 'Buscar clubs...', 
                                hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
                                border: InputBorder.none, 
                                contentPadding: EdgeInsets.symmetric(horizontal: 16), 
                                prefixIcon: Icon(Icons.search, color: _kPrimaryColor),
                              ),
                              style: const TextStyle(fontSize: 16, color: Colors.black), 
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Buscar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildSectionButton(
                      'Descubrir clubs',
                      0,
                      Icons.explore,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSectionButton(
                      'Mis clubs',
                      1,
                      Icons.group,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _selectedSection == 0 ? _buildDiscoverClubs() : _buildMyClubs(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton(String text, VoidCallback onPressed, {bool isActive = false}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.white : Colors.white70,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSectionButton(String text, int sectionIndex, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedSection = sectionIndex;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedSection == sectionIndex ? _kPrimaryColor : Colors.transparent,
        foregroundColor: _selectedSection == sectionIndex ? Colors.white : _kPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _selectedSection == sectionIndex ? _kPrimaryColor : Colors.grey.shade300,
          ),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverClubs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clubs recomendados',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Explora clubs basados en tus intereses de lectura',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.group,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron clubs',
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Intenta con otros términos de búsqueda',
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyClubs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis clubs activos',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gestiona tus clubs de lectura actuales',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.group_add,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes clubs activos',
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Únete a un club o crea uno nuevo',
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}