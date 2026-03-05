import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'duolingo_building.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa del Campus',
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ScrollController _scrollController;
  int _currentPage = 0;
  final double _buildingWidth = 260.0;
  final double _stairsWidth = 35.0;
  bool _showContacts = false;
  String _selectedFilter = 'Todos';

  final List<Map<String, String>> _allContacts = [
    {'nombre': 'Juan Pérez', 'lugar': 'Edificio A', 'contacto': 'juan@univ.edu', 'horario': '08:00 - 16:00', 'tipo': 'Administrativos'},
    {'nombre': 'María García', 'lugar': 'N/A', 'contacto': 'mgarcia@univ.edu', 'horario': '10:00 - 14:00', 'tipo': 'Maestros'},
    {'nombre': 'Carlos López', 'lugar': 'Edificio B', 'contacto': 'clopez@univ.edu', 'horario': '09:00 - 17:00', 'tipo': 'Maestros'},
    {'nombre': 'Ana Martínez', 'lugar': 'Edificio D', 'contacto': 'ana@univ.edu', 'horario': '07:30 - 15:30', 'tipo': 'Administrativos'},
    {'nombre': 'Luis Rodríguez', 'lugar': 'Laboratorio', 'contacto': 'luis@univ.edu', 'horario': '11:00 - 19:00', 'tipo': 'Maestros'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPage(int page) {
    final double blockWidth = _buildingWidth + _stairsWidth;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        page * blockWidth,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildBuildingInfo(int page) {
    switch (page) {
      case 0:
        return Row(children: const [Expanded(child: _LocationButton(label: 'D1 - Lab. Pesado', icon: Icons.science)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'D2 - Sala Juntas', icon: Icons.meeting_room))]);
      case 1:
        return Row(children: const [Expanded(child: _LocationButton(label: 'C1 - Biblioteca', icon: Icons.menu_book)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'C2 - Cafetería', icon: Icons.coffee))]);
      case 2:
        return Row(children: const [Expanded(child: _LocationButton(label: 'B1 - Dirección', icon: Icons.admin_panel_settings)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'B2 - Control', icon: Icons.assignment_ind))]);
      case 3:
        return Row(children: const [Expanded(child: _LocationButton(label: 'A1 - Servicios', icon: Icons.location_on)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'A2 - Lab. Cómputo', icon: Icons.computer))]);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double initialPadding = math.max(0.0, (screenWidth / 2) - (_buildingWidth / 2) - _stairsWidth);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Mapa del Campus', style: TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildMapView(screenWidth, initialPadding)),
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFE8F5E9),
                child: Column(
                  children: [
                    Text('Edificio ${["D", "C", "B", "A"][_currentPage]} - Información', style: const TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildBuildingInfo(_currentPage),
                  ],
                ),
              ),
            ],
          ),
          
          if (_showContacts)
            GestureDetector(
              onTap: () => setState(() => _showContacts = false),
              child: Container(color: Colors.black26, child: Center(child: GestureDetector(onTap: () {}, child: _buildContactsBubble()))),
            ),

          // BOTÓN DE CAMBIO DE MODO (Movido a la parte superior derecha)
          Positioned(
            right: 20,
            top: 20,
            child: GestureDetector(
              onTap: () => setState(() => _showContacts = !_showContacts),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                  ),
                  Icon(_showContacts ? Icons.map_rounded : Icons.contacts_rounded, size: 30, color: const Color(0xFF1CB0F6)),
                  Positioned(
                    top: 2, 
                    right: 2, 
                    child: Container(
                      padding: const EdgeInsets.all(4), 
                      decoration: const BoxDecoration(color: Color(0xFF58CC02), shape: BoxShape.circle), 
                      child: Icon(_showContacts ? Icons.location_on : Icons.person, size: 12, color: Colors.white)
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(double screenWidth, double initialPadding) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0xFFCEF1FF))),
        Align(alignment: Alignment.bottomCenter, child: Container(height: 200, decoration: const BoxDecoration(color: Color(0xFF58CC02)))),
        Center(
          child: Container(
            height: 550, alignment: const Alignment(0, 0.2),
            child: SingleChildScrollView(
              controller: _scrollController, scrollDirection: Axis.horizontal, physics: const NeverScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(width: initialPadding),
                  const BuildingStairs(key: ValueKey('D_s'), roundLeft: true, totalSteps: 15),
                  const DuolingoBuilding(key: ValueKey('D_b'), label: 'D', extraFloors: 1),
                  const BuildingStairs(key: ValueKey('C_s'), totalSteps: 10),
                  const DuolingoBuilding(key: ValueKey('C_b'), label: 'C'),
                  const BuildingStairs(key: ValueKey('B_s'), totalSteps: 10),
                  const DuolingoBuilding(key: ValueKey('B_b'), label: 'B'),
                  const BuildingStairs(key: ValueKey('A_s'), totalSteps: 10),
                  const DuolingoBuilding(key: ValueKey('A_b'), label: 'A'),
                  const BuildingStairs(key: ValueKey('end_s'), roundRight: true, totalSteps: 10),
                  SizedBox(width: screenWidth / 2),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20, left: 20, right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(icon: Icons.arrow_back_rounded, onPressed: _currentPage > 0 ? () => _scrollToPage(_currentPage - 1) : null),
              _NavButton(icon: Icons.arrow_forward_rounded, onPressed: _currentPage < 3 ? () => _scrollToPage(_currentPage + 1) : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsBubble() {
    final List<Map<String, String>> filteredContacts = _selectedFilter == 'Todos' ? _allContacts : _allContacts.where((c) => c['tipo'] == _selectedFilter).toList();
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Text('Directorio: $_selectedFilter', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B6350))),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20, headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F8E9)),
                  columns: const [
                    DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B6350)))),
                    DataColumn(label: Text('Lugar', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B6350)))),
                    DataColumn(label: Text('Contacto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B6350)))),
                    DataColumn(label: Text('Horario', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B6350)))),
                  ],
                  rows: filteredContacts.map((contact) {
                    return DataRow(cells: [DataCell(Text(contact['nombre']!)), DataCell(Text(contact['lugar']!)), DataCell(Text(contact['contacto']!)), DataCell(Text(contact['horario']!))]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const _LocationButton({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Color(0xFF81C784), offset: Offset(0, 3))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _NavButton({required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.3 : 1.0,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 60, height: 50,
          decoration: BoxDecoration(color: const Color(0xFFAED581), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0xFF8BC34A), offset: Offset(0, 4))]),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
