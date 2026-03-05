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
  bool _isIsometric = true; 
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

  void _goToBuilding(int index) {
    setState(() {
      _isIsometric = false;
      _currentPage = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToPage(index);
    });
  }

  Widget _buildBuildingInfo(int page) {
    switch (page) {
      case 0: return Row(children: const [Expanded(child: _LocationButton(label: 'E1 - Rectoría', icon: Icons.account_balance)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'E2 - Auditorio', icon: Icons.theater_comedy))]);
      case 1: return Row(children: const [Expanded(child: _LocationButton(label: 'D1 - Lab. Pesado', icon: Icons.science)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'D2 - Sala Juntas', icon: Icons.meeting_room))]);
      case 2: return Row(children: const [Expanded(child: _LocationButton(label: 'C1 - Biblioteca', icon: Icons.menu_book)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'C2 - Cafetería', icon: Icons.coffee))]);
      case 3: return Row(children: const [Expanded(child: _LocationButton(label: 'B1 - Dirección', icon: Icons.admin_panel_settings)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'B2 - Control', icon: Icons.assignment_ind))]);
      case 4: return Row(children: const [Expanded(child: _LocationButton(label: 'A1 - Servicios', icon: Icons.location_on)), SizedBox(width: 8), Expanded(child: _LocationButton(label: 'A2 - Lab. Cómputo', icon: Icons.computer))]);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double initialPadding = math.max(0.0, (screenWidth / 2) - (_buildingWidth / 2) - _stairsWidth);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: Text(_isIsometric ? 'Vista del Campus' : 'Mapa Detallado', 
          style: const TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        centerTitle: true,
        leading: !_isIsometric ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B6350)),
          onPressed: () => setState(() => _isIsometric = true),
        ) : null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isIsometric 
                    ? _buildIsometricView() 
                    : _buildMapView(screenWidth, initialPadding),
                ),
              ),
              if (!_isIsometric)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFE8F5E9),
                  child: Column(
                    children: [
                      Text('Edificio ${["E", "D", "C", "B", "A"][_currentPage]} - Información', 
                        style: const TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold)),
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

          Positioned(
            right: 20,
            top: 10,
            child: GestureDetector(
              onTap: () => setState(() => _showContacts = !_showContacts),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
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

  Widget _buildIsometricView() {
    return Container(
      color: const Color(0xFFCEF1FF),
      child: Stack(
        children: [
          // Terreno
          Align(
            alignment: Alignment.center,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(math.pi / 3.5)
                ..rotateZ(-math.pi / 4),
              alignment: Alignment.center,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF46A302), offset: Offset(10, 10), blurRadius: 0),
                  ],
                ),
              ),
            ),
          ),
          // Edificios alineados verticalmente
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IsometricBuildingBox(label: 'E', floors: 4, onTap: () => _goToBuilding(0)),
                  const SizedBox(height: 20),
                  _IsometricBuildingBox(label: 'D', floors: 3, onTap: () => _goToBuilding(1)),
                  const SizedBox(height: 20),
                  _IsometricBuildingBox(label: 'C', floors: 3, onTap: () => _goToBuilding(2)),
                  const SizedBox(height: 20),
                  _IsometricBuildingBox(label: 'B', floors: 3, onTap: () => _goToBuilding(3)),
                  const SizedBox(height: 20),
                  _IsometricBuildingBox(label: 'A', floors: 3, onTap: () => _goToBuilding(4)),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text('Selecciona un edificio para explorar', 
                style: TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold, fontSize: 14)),
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
                  const BuildingStairs(key: ValueKey('E_s'), roundLeft: true, totalSteps: 15),
                  const DuolingoBuilding(key: ValueKey('E_b'), label: 'E', extraFloors: 1),
                  const BuildingStairs(key: ValueKey('D_s'), totalSteps: 10),
                  const DuolingoBuilding(key: ValueKey('D_b'), label: 'D'),
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
              _NavButton(icon: Icons.arrow_forward_rounded, onPressed: _currentPage < 4 ? () => _scrollToPage(_currentPage + 1) : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsBubble() {
    final filteredContacts = _selectedFilter == 'Todos' ? _allContacts : _allContacts.where((c) => c['tipo'] == _selectedFilter).toList();
    return Container(
      width: MediaQuery.of(context).size.width * 0.95, 
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('Directorio del Campus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B6350))),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FilterChip(label: 'Todos', icon: Icons.filter_list, isSelected: _selectedFilter == 'Todos', onTap: () => setState(() => _selectedFilter = 'Todos')),
                _FilterChip(label: 'Maestros', icon: Icons.school_outlined, isSelected: _selectedFilter == 'Maestros', onTap: () => setState(() => _selectedFilter = 'Maestros')),
                _FilterChip(label: 'Admin.', icon: Icons.work_outline, isSelected: _selectedFilter == 'Administrativos', onTap: () => setState(() => _selectedFilter = 'Administrativos')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 15, headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F8E9)),
                  columns: const [
                    DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Lugar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Horario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: filteredContacts.map((contact) {
                    return DataRow(cells: [
                      DataCell(Text(contact['nombre']!, style: const TextStyle(fontSize: 11))),
                      DataCell(Text(contact['lugar']!, style: const TextStyle(fontSize: 11))),
                      DataCell(Text(contact['contacto']!, style: const TextStyle(fontSize: 11))),
                      DataCell(Text(contact['horario']!, style: const TextStyle(fontSize: 11))),
                    ]);
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

class _IsometricBuildingBox extends StatelessWidget {
  final String label;
  final int floors;
  final VoidCallback onTap;

  const _IsometricBuildingBox({required this.label, required this.floors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double w = 40.0;
    final double h = floors * 25.0;
    const double angle = 0.3;
    final double totalHeight = 30 + (w * angle * 2) + h + 10;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        size: Size(w * 2 + 20, totalHeight),
        painter: _BuildingBoxPainter(label: label, floors: floors),
      ),
    );
  }
}

class _BuildingBoxPainter extends CustomPainter {
  final String label;
  final int floors;
  _BuildingBoxPainter({required this.label, required this.floors});

  @override
  void paint(Canvas canvas, Size size) {
    const double w = 40.0; 
    final double h = floors * 25.0;
    const double angle = 0.3; // Factor de inclinación para perspectiva desde arriba

    final Paint paintFront = Paint()..color = const Color(0xFFF1E5D1);
    final Paint paintSide = Paint()..color = const Color(0xFFD6C8B0);
    final Paint paintTop = Paint()..color = const Color(0xFFFAF3E0);

    double cx = size.width / 2;
    double cy = 20;

    // 1. CARA SUPERIOR (Azotea)
    Path top = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + w, cy + w * angle)
      ..lineTo(cx, cy + w * angle * 2)
      ..lineTo(cx - w, cy + w * angle)
      ..close();
    canvas.drawPath(top, paintTop);

    // 2. CARA DERECHA (Frontal)
    Path right = Path()
      ..moveTo(cx, cy + w * angle * 2)
      ..lineTo(cx + w, cy + w * angle)
      ..lineTo(cx + w, cy + w * angle + h)
      ..lineTo(cx, cy + w * angle * 2 + h)
      ..close();
    canvas.drawPath(right, paintFront);

    // 3. CARA IZQUIERDA (Lateral)
    Path left = Path()
      ..moveTo(cx, cy + w * angle * 2)
      ..lineTo(cx - w, cy + w * angle)
      ..lineTo(cx - w, cy + w * angle + h)
      ..lineTo(cx, cy + w * angle * 2 + h)
      ..close();
    canvas.drawPath(left, paintSide);

    // 4. TEXTO EN LA AZOTEA
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold, fontSize: 18),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy + w * angle - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.icon, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC8E6C9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF58CC02) : const Color(0xFFD1D9D1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF4B6350)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
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
