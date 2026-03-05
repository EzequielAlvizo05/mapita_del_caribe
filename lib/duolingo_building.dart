import 'package:flutter/material.dart';

class DuolingoBuilding extends StatelessWidget {
  const DuolingoBuilding({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Roof
          const BuildingFloor(
            color: Color(0xFF58CC02),
            shadowColor: Color(0xFF46A302),
            isRoof: true,
          ),
          // 3rd Floor
          const BuildingFloor(
            color: Color(0xFF58CC02),
            shadowColor: Color(0xFF46A302),
            child: WindowRow(),
          ),
          // 2nd Floor
          const BuildingFloor(
            color: Color(0xFF58CC02),
            shadowColor: Color(0xFF46A302),
            child: WindowRow(),
          ),
          // 1st Floor (Ground)
          const BuildingFloor(
            color: Color(0xFF58CC02),
            shadowColor: Color(0xFF46A302),
            isGround: true,
            child: Door(),
          ),
        ],
      ),
    );
  }
}

class BuildingFloor extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  final Widget? child;
  final bool isRoof;
  final bool isGround;

  const BuildingFloor({
    super.key,
    required this.color,
    required this.shadowColor,
    this.child,
    this.isRoof = false,
    this.isGround = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: isRoof ? 40 : 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: isRoof ? const Radius.circular(20) : Radius.zero,
          topRight: isRoof ? const Radius.circular(20) : Radius.zero,
          bottomLeft: isGround ? const Radius.circular(20) : Radius.zero,
          bottomRight: isGround ? const Radius.circular(20) : Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 6),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class WindowRow extends StatelessWidget {
  const WindowRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Window(),
        Window(),
      ],
    );
  }
}

class Window extends StatelessWidget {
  const Window({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5E5E5),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }
}

class Door extends StatelessWidget {
  const Door({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 70,
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF84D8FF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1CB0F6),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
