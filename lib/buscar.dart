import 'package:flutter/material.dart';

const Color _kBlockColor = Color(0xFFE0E0E0);
const TextStyle _kLinkStyle = TextStyle(fontSize: 18, color: Colors.black54);
const TextStyle _kHeaderStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54);
const double _kSpacing = 20.0; 

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {

  final TextEditingController _searchController = TextEditingController();

  final List<String> formatos = ['Todos los formatos', 'Libro físico', 'Audiolibro'];
  String? formatoSeleccionado = 'Todos los formatos'; 

  final List<String> generos = ['Todos los géneros', 'Ficción', 'Thriller', 'Ciencia Ficción', 'Biografía'];
  String? generoSeleccionado = 'Todos los géneros'; 

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BookWorm',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(onPressed: () {}, child: const Text('Buscar', style: TextStyle(fontSize: 18, color: Colors.black))), 
          TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/clubs'), child: const Text('Clubs', style: _kLinkStyle)), 
          TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/perfil'), child: const Text('Perfil', style: _kLinkStyle)), 
          const SizedBox(width: _kSpacing),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
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
                          hintText: 'Buscar libros o audiolibro', 
                          hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.symmetric(horizontal: _kSpacing), 
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black
                        ), 
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  child: const Text('Buscar', style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),

            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _kBlockColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: formatoSeleccionado,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      
                      items: formatos.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      
                      onChanged: (String? newValue) {
                        setState(() {
                          formatoSeleccionado = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _kBlockColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: generoSeleccionado,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      
                      items: generos.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      
                      onChanged: (String? newValue) {
                        setState(() {
                          generoSeleccionado = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),
          ],
        ),
      ),
    );
  }
}