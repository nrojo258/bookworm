import 'package:flutter/material.dart';

const Color _kBlockColor = Color(0xFFE0E0E0);
const TextStyle _kLinkStyle = TextStyle(fontSize: 18, color: Colors.black54);
const TextStyle _kHeaderStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54);
const double _kSpacing = 20.0; 

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
                      'Completa la información',
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
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        prefixIcon: Icon(Icons.group, color: Colors.purple),
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
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        
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
                        color: _generoSeleccionado == null ? Colors.orange : Colors.green,
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
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
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
        backgroundColor: Colors.green,
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
      appBar: AppBar(
        title: const Text(
          'BookWorm',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.popAndPushNamed(context, '/search'), 
            child: const Text('Buscar', style: _kLinkStyle)
          ),
          TextButton(
            onPressed: () {}, 
            child: const Text('Clubs', style: TextStyle(fontSize: 18, color: Colors.black))
          ), 
          TextButton(
            onPressed: () => Navigator.popAndPushNamed(context, '/perfil'), 
            child: const Text('Perfil', style: _kLinkStyle)
          ),
          const SizedBox(width: _kSpacing),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Clubs de lectura',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kBlockColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: _mostrarCrearClub, 
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '+ Crear club',
                      style: TextStyle(fontSize: 16, color: Colors.black54)
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),

            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 50,
                    color: _kBlockColor,
                    child: Center( 
                      child: TextField(
                        controller: _searchController, 
                        decoration: const InputDecoration(
                          hintText: 'Buscar clubs', 
                          hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.symmetric(horizontal: _kSpacing), 
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black), 
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                TextButton(
                  onPressed: () {
                  },
                  child: const Text('Buscar', style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSection = 0;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedSection == 0 ? Colors.black12 : Colors.transparent,
                    ),
                    child: Text(
                      'Descubrir clubs',
                      style: _selectedSection == 0 
                          ? const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
                          : _kLinkStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSection = 1;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedSection == 1 ? Colors.black12 : Colors.transparent,
                    ),
                    child: Text(
                      'Mis clubs',
                      style: _selectedSection == 1 
                          ? const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
                          : _kLinkStyle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),

            _selectedSection == 0 ? _buildDiscoverClubs() : _buildMyClubs(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverClubs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clubs recomendados',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: _kSpacing),
        
        Container(
          padding: const EdgeInsets.all(_kSpacing),
          decoration: BoxDecoration(
            color: _kBlockColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'No se encontraron clubs',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyClubs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis clubs activos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: _kSpacing),
        
        Container(
          padding: const EdgeInsets.all(_kSpacing),
          decoration: BoxDecoration(
            color: _kBlockColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'No tienes clubs activos',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}