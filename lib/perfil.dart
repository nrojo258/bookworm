import 'package:flutter/material.dart';

const Color _kBlockColor = Color(0xFFE0E0E0);
const TextStyle _kLinkStyle = TextStyle(fontSize: 18, color: Colors.black54);
const TextStyle _kHeaderStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54);
const double _kSpacing = 20.0; 

class Perfil extends StatefulWidget {
  const Perfil({super.key});

   @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSection = 0; 
  
  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
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
          TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/search'), child: const Text('Buscar', style: _kLinkStyle)),
          TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/clubs'), child: const Text('Clubs', style: _kLinkStyle)),
          TextButton(onPressed: () {}, child: const Text('Perfil', style: TextStyle(fontSize: 18, color: Colors.black))), 
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
                  'Mi Perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kBlockColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: (){},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Editar perfil',
                      style: TextStyle(fontSize: 16, color: Colors.black54)
                    ),
                  ),
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
                      'Información',
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
                      'Mi progreso',
                      style: _selectedSection == 1 
                          ? const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
                          : _kLinkStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSection = 2;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedSection == 2 ? Colors.black12 : Colors.transparent,
                    ),
                    child: Text(
                      'Estadísticas',
                      style: _selectedSection == 2 
                          ? const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
                          : _kLinkStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSection = 3;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedSection == 3 ? Colors.black12 : Colors.transparent,
                    ),
                    child: Text(
                      'Configuración',
                      style: _selectedSection == 3 
                          ? const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
                          : _kLinkStyle,
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