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
                    onPressed: (){},
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