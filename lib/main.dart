import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'duolingo_building.dart';
import 'panorama_view.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        }),
      ),
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
  late final TransformationController _transformationController;
  int _currentPage = 0;
  final double _buildingWidth = 550.0;
  final double _stairsWidth = 35.0;
  bool _showContacts = false;
  bool _isIsometric = true;
  String _selectedFilter = 'Todos';

  // Nuevo Orden Real (2D): E, C, B, A, D
  final List<String> _buildingOrder = ["E", "C", "B", "A", "D"];

  final List<Map<String, String>> _allContacts = [
    {'nombre': 'Juan Pérez', 'lugar': 'Edificio A', 'contacto': 'juan@univ.edu', 'horario': '08:00 - 16:00', 'tipo': 'Administrativos'},
    {'nombre': 'María García', 'lugar': 'N/A', 'contacto': 'mgarcia@univ.edu', 'horario': '10:00 - 14:00', 'tipo': 'Maestros'},
    {'nombre': 'Carlos López', 'lugar': 'Edificio B', 'contacto': 'clopez@univ.edu', 'horario': '09:00 - 17:00', 'tipo': 'Maestros'},
    {'nombre': 'Ana Martínez', 'lugar': 'Edificio D', 'contacto': 'ana@univ.edu', 'horario': '07:30 - 15:30', 'tipo': 'Administrativos'},
    {'nombre': 'Luis Rodríguez', 'lugar': 'Laboratorio', 'contacto': 'luis@univ.edu', 'horario': '11:00 - 19:00', 'tipo': 'Maestros'},
  ];

  final Map<int, List<String>> _buildingDSalons = {
    1: ['Explanada', 'Auditorio Principal', 'Sec. Extensión', 'Vinculación', 'Serv. Social', 'Comunicación', 'Sostenibilidad', 'Prácticas', 'Tienda Uni.', 'Patronato'],
    2: ['Biblioteca'],
    3: ['Centro Inv. Aplicada']
  };

  final Map<int, List<String>> _buildingASalons = {
    1: ['Rectoria', 'Jurídico', 'Transparencia', 'Inclusión', 'Coord. Admin', 'R. Humanos', 'Compras', 'Auditorio Al', 'Gastronomía', '3A', '4A', '5A', '6A', '7A'],
    2: ['EyN', 'Maestros EyN', 'SITE A', '8A', '9A', '10A', '11A', '12A', '13A', '14A'],
    3: ['Radio', 'Orientación', '15A', '16A', '17A', '18A', '19A', '20A', '21A', '22A', '23A', '24A']
  };

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_updateCurrentPageByScroll);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_updateCurrentPageByScroll);
    _transformationController.dispose();
    super.dispose();
  }

  void _updateCurrentPageByScroll() {
    if (_isIsometric) return;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    final double xOffset = _transformationController.value.getTranslation().x;
    final double mapCenterX = (screenWidth / 2 - xOffset) / scale;

    double minDistance = double.infinity;
    int closestBuilding = _currentPage;
    final double blockWidth = _buildingWidth + _stairsWidth;

    for (int i = 0; i < _buildingOrder.length; i++) {
      double buildingCenterX = screenWidth + (i * blockWidth) + (_buildingWidth / 2);
      double distance = (mapCenterX - buildingCenterX).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestBuilding = i;
      }
    }

    if (closestBuilding != _currentPage) {
      setState(() => _currentPage = closestBuilding);
    }
  }

  void _scrollToPage(int page) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double blockWidth = _buildingWidth + _stairsWidth;
    
    double buildingCenterX = screenWidth + (page * blockWidth) + (_buildingWidth / 2);
    double buildingCenterY = 1500 - 300 - 150; 

    double currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 0.5) currentScale = 1.0; 

    double tx = (screenWidth / 2) - (buildingCenterX * currentScale);
    double ty = (screenHeight / 2) - (buildingCenterY * currentScale);
    
    _transformationController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(currentScale);
    
    setState(() => _currentPage = page);
  }

  void _goToBuilding(int index) {
    setState(() {
      _isIsometric = false;
      _currentPage = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToPage(index));
  }

  Widget _buildBuildingInfo(int page) {
    switch (page) {
      case 0: return _infoRow('E1 - Rectoría', Icons.account_balance, 'E2 - Sala Juntas', Icons.meeting_room);
      case 1: return _infoRow('C1 - Biblioteca', Icons.menu_book, 'C2 - Cafetería', Icons.coffee);
      case 2: return _infoRow('B1 - Dirección', Icons.admin_panel_settings, 'B2 - Control', Icons.assignment_ind);
      case 3: return _infoRow('A - Rectoria', Icons.person, 'A - N1 EyN', Icons.business);
      case 4: return _infoRow('D - PB Explanada', Icons.event_seat, 'D - N1 Biblioteca', Icons.menu_book);
      default: return const SizedBox.shrink();
    }
  }

  Widget _infoRow(String l1, IconData i1, String l2, IconData i2) {
    return Row(children: [
      Expanded(child: _LocationButton(label: l1, icon: i1)),
      const SizedBox(width: 8),
      Expanded(child: _LocationButton(label: l2, icon: i2)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: Text(_isIsometric ? 'Vista del Campus' : 'Mapa Detallado', 
          style: const TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
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
                    ? _buildIsometricCampus() 
                    : _buildMapView(screenWidth),
                ),
              ),
              if (!_isIsometric)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFE8F5E9),
                  child: Column(
                    children: [
                      Text('Edificio ${_buildingOrder[_currentPage]} - Información', 
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

          if (!_isIsometric && !_showContacts)
            Positioned(
              left: 20, bottom: 120,
              child: _NavButton(icon: Icons.arrow_back_rounded, onPressed: _currentPage > 0 ? () => _scrollToPage(_currentPage - 1) : null),
            ),
          
          if (!_isIsometric && !_showContacts)
            Positioned(
              right: 20, bottom: 120,
              child: _NavButton(icon: Icons.arrow_forward_rounded, onPressed: _currentPage < 4 ? () => _scrollToPage(_currentPage + 1) : null),
            ),

          Positioned(
            right: 20, top: 10,
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
                  Positioned(top: 2, right: 2, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFF58CC02), shape: BoxShape.circle), child: Icon(_showContacts ? Icons.location_on : Icons.person, size: 12, color: Colors.white))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIsometricCampus() {
    return Container(
      color: const Color(0xFFCEF1FF),
      child: Center(
        child: CampusView(onBuildingTap: _goToBuilding),
      ),
    );
  }

  Widget _buildMapView(double screenWidth) {
    final double contentWidth = 5 * _buildingWidth + 4 * _stairsWidth;
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.1,
      maxScale: 3.0,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      child: SizedBox(
        width: contentWidth + screenWidth * 2,
        height: 1500,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFFCEF1FF))),
            Positioned(bottom: 0, left: 0, right: 0, height: 600, child: Container(color: const Color(0xFF58CC02))),
            Positioned(
              bottom: 300,
              left: screenWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ORDEN 2D: E, C, B, A, D
                  const DuolingoBuilding(key: ValueKey('E_b'), label: 'E', extraFloors: 1),
                  const BuildingStairs(key: ValueKey('EC_s'), totalSteps: 15),
                  const DuolingoBuilding(key: ValueKey('C_b'), label: 'C'),
                  const BuildingStairs(key: ValueKey('CB_s'), totalSteps: 10),
                  const DuolingoBuilding(key: ValueKey('B_b'), label: 'B'),
                  const BuildingStairs(key: ValueKey('BA_s'), totalSteps: 10),
                  DuolingoBuilding(key: const ValueKey('A_b'), label: 'A', extraFloors: 0, customSalons: _buildingASalons),
                  const BuildingStairs(key: ValueKey('AD_s'), totalSteps: 10),
                  DuolingoBuilding(key: const ValueKey('D_b'), label: 'D', extraFloors: 0, customSalons: _buildingDSalons),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsBubble() {
    final filteredContacts = _selectedFilter == 'Todos' ? _allContacts : _allContacts.where((c) => c['tipo'] == _selectedFilter).toList();
    return Container(
      width: MediaQuery.of(context).size.width * 0.95, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('Directorio del Campus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B6350))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_chip('Todos'), _chip('Maestros'), _chip('Administrativos')]),
          const SizedBox(height: 12),
          Flexible(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 15, columns: const [DataColumn(label: Text('Nombre')), DataColumn(label: Text('Lugar')), DataColumn(label: Text('Contacto')), DataColumn(label: Text('Horario'))], rows: filteredContacts.map((c) => DataRow(cells: [DataCell(Text(c['nombre']!)), DataCell(Text(c['lugar']!)), DataCell(Text(c['contacto']!)), DataCell(Text(c['horario']!))])).toList())))),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    bool sel = _selectedFilter == label;
    return GestureDetector(onTap: () => setState(() => _selectedFilter = label), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: sel ? const Color(0xFFC8E6C9) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? const Color(0xFF58CC02) : const Color(0xFFD1D9D1))), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.bold : FontWeight.normal))));
  }
}

class CampusView extends StatefulWidget {
  final Function(int) onBuildingTap;
  const CampusView({super.key, required this.onBuildingTap});

  @override
  State<CampusView> createState() => _CampusViewState();
}

class _CampusViewState extends State<CampusView> {
  // Orden Painter's Algorithm: de atrás hacia adelante para la vista 3D
  // El index mapea a la posición en el mapa 2D: E(0), C(1), B(2), A(3), D(4)
  final List<Map<String, dynamic>> buildings = [
    {'id': 'E', 'cy': 4.1, 'h': 1.6, 'w': 1.2, 'd': 1.0, 'index': 0},
    {'id': 'C', 'cy': 3.1, 'h': 1.2, 'w': 1.2, 'd': 1.0, 'index': 1},
    {'id': 'B', 'cy': 2.1, 'h': 1.2, 'w': 1.2, 'd': 1.0, 'index': 2},
    {'id': 'A', 'cy': 1.1, 'h': 1.2, 'w': 1.2, 'd': 1.0, 'index': 3},
    {'id': 'D', 'cy': 0.1, 'h': 1.2, 'w': 1.2, 'd': 1.0, 'index': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = CampusPainter(buildings: buildings);
        return GestureDetector(
          onTapUp: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPos = box.globalToLocal(details.globalPosition);
            final Size size = Size(constraints.maxWidth, constraints.maxHeight);
            for (var b in buildings.reversed) {
              if (painter.getRoofPath(b, size).contains(localPos)) {
                widget.onBuildingTap(b['index'] as int);
                break;
              }
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: painter,
          ),
        );
      }
    );
  }
}

class CampusPainter extends CustomPainter {
  final List<Map<String, dynamic>> buildings;
  CampusPainter({required this.buildings});
  final double angX = 14 * math.pi / 180, angY = -85 * math.pi / 180, scX = 80.0, scY = 80.0, scZ = 100.0;

  Offset project(double x, double y, double z, Size size) {
    double sx = size.width * 0.45 + x * math.cos(angX) * scX + y * math.cos(angY) * scY;
    double sy = size.height * 0.85 + x * math.sin(angX) * scX + y * math.sin(angY) * scY - z * scZ;
    return Offset(sx, sy);
  }

  Path getRoofPath(Map<String, dynamic> b, Size size) {
    double cy = b['cy'], h = b['h'], w = b['w'], d = b['d'];
    return Path()..addPolygon([project(-w/2, cy-d/2, h, size), project(w/2, cy-d/2, h, size), project(w/2, cy+d/2, h, size), project(-w/2, cy+d/2, h, size)], true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pTop = Paint()..color = const Color(0xFFFFFDF9), pL = Paint()..color = const Color(0xFFEAE0D5), pR = Paint()..color = const Color(0xFFD8C6B6), pLine = Paint()..color = const Color.fromRGBO(140, 110, 90, 0.35)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..addPolygon([project(-2,-1,0,size), project(2,-1,0,size), project(2,7,0,size), project(-2,7,0,size)], true), Paint()..color = const Color(0xFF58CC02));
    for (var b in buildings) {
      double cy = b['cy'], h = b['h'], w = b['w'], d = b['d'];
      Offset p0 = project(-w/2, cy-d/2, 0, size), p1 = project(w/2, cy-d/2, 0, size), p2 = project(w/2, cy+d/2, 0, size), p4 = project(-w/2, cy-d/2, h, size), p5 = project(w/2, cy-d/2, h, size), p6 = project(w/2, cy+d/2, h, size), p7 = project(-w/2, cy+d/2, h, size);
      canvas.drawPath(Path()..addPolygon([p0, p1, p5, p4], true), pL); canvas.drawPath(Path()..addPolygon([p0, p1, p5, p4], true), pLine);
      canvas.drawPath(Path()..addPolygon([p1, p2, p6, p5], true), pR); canvas.drawPath(Path()..addPolygon([p1, p2, p6, p5], true), pLine);
      canvas.drawPath(getRoofPath(b, size), pTop); canvas.drawPath(getRoofPath(b, size), pLine);
      _drawLabel(canvas, b['id'], project(0, cy, h, size), size);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center, Size size) {
    Offset O = project(0,0,0,size), pX = project(1,0,0,size), pY = project(0,1,0,size);
    double vx_x = pX.dx-O.dx, vx_y = pX.dy-O.dy, vy_x = pY.dx-O.dx, vy_y = pY.dy-O.dy, lX = math.sqrt(vx_x*vx_x+vx_y*vx_y), lY = math.sqrt(vy_x*vy_y+vy_y*vy_y);
    final Matrix4 m = Matrix4.identity(); m.setEntry(0,0,vx_x/lX); m.setEntry(1,0,vx_y/lX); m.setEntry(0,1,-vy_x/lY); m.setEntry(1,1,-vy_y/lY);
    TextPainter tp = TextPainter(text: TextSpan(text: text, style: const TextStyle(color: Color(0xFF4B6350), fontWeight: FontWeight.bold, fontSize: 14)), textDirection: TextDirection.ltr)..layout();
    canvas.save(); canvas.translate(center.dx, center.dy); canvas.transform(m.storage); tp.paint(canvas, Offset(-tp.width/2, -tp.height/2)); canvas.restore();
  }

  @override
  bool shouldRepaint(CampusPainter oldDelegate) => false;
}

class _LocationButton extends StatelessWidget {
  final String label; final IconData icon;
  const _LocationButton({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Color(0xFF81C784), offset: Offset(0, 3))]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: const Color(0xFF2E7D32)), const SizedBox(width: 4), Flexible(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)), overflow: TextOverflow.ellipsis))]));
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon; final VoidCallback? onPressed;
  const _NavButton({required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: onPressed == null ? 0.3 : 1.0, child: GestureDetector(onTap: onPressed, child: Container(width: 60, height: 50, decoration: BoxDecoration(color: const Color(0xFFAED581), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0xFF8BC34A), offset: Offset(0, 4))]), child: Icon(icon, color: Colors.white))));
  }
}
