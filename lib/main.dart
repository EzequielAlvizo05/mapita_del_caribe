import 'package:flutter/material.dart';
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
      title: 'Duolingo Style City',
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double initialPadding = (screenWidth / 2) - (_buildingWidth / 2) - _stairsWidth;

    return Scaffold(
      body: Stack(
        children: [
          // Cielo
          Positioned.fill(child: Container(color: const Color(0xFFCEF1FF))),
          
          // Pasto
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.58, 
              decoration: const BoxDecoration(
                color: Color(0xFF58CC02),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF46A302),
                    offset: Offset(0, -10),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          // Ciudad Continua
          Center(
            child: Container(
              height: 600,
              alignment: const Alignment(0, -0.2),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: initialPadding > 0 ? initialPadding : 0),
                    
                    const BuildingStairs(key: ValueKey('stairs_D'), roundLeft: true, totalSteps: 15),
                    const DuolingoBuilding(key: ValueKey('building_D'), label: 'D', extraFloors: 1),
                    
                    const BuildingStairs(key: ValueKey('stairs_C'), totalSteps: 10),
                    const DuolingoBuilding(key: ValueKey('building_C'), label: 'C'),
                    
                    const BuildingStairs(key: ValueKey('stairs_B'), totalSteps: 10),
                    const DuolingoBuilding(key: ValueKey('building_B'), label: 'B'),
                    
                    const BuildingStairs(key: ValueKey('stairs_A'), totalSteps: 10),
                    const DuolingoBuilding(key: ValueKey('building_A'), label: 'A'),
                    
                    const BuildingStairs(key: ValueKey('stairs_end'), roundRight: true, totalSteps: 10),

                    SizedBox(width: screenWidth / 2),
                  ],
                ),
              ),
            ),
          ),

          // Botones
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: _currentPage > 0 
                    ? () => _scrollToPage(_currentPage - 1) 
                    : null,
                ),
                _NavButton(
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _currentPage < 3 
                    ? () => _scrollToPage(_currentPage + 1) 
                    : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE5E5E5),
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 30, color: const Color(0xFF1CB0F6)),
        ),
      ),
    );
  }
}
