import 'package:flutter/material.dart';

class DuolingoBuilding extends StatelessWidget {
  final String label;
  final int extraFloors;

  const DuolingoBuilding({
    super.key,
    required this.label,
    this.extraFloors = 0,
  });

  @override
  Widget build(BuildContext context) {
    const beigeColor = Color(0xFFF1E5D1);
    const beigeShadow = Color(0xFFD6C8B0);
    const buildingWidth = 260.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD6C8B0),
          ),
        ),
        const SizedBox(height: 10),
        // Roof
        const BuildingFloor(
          color: beigeColor,
          shadowColor: beigeShadow,
          isRoof: true,
          width: buildingWidth,
        ),
        // Extra Floors (for Building D)
        ...List.generate(extraFloors, (index) {
          int floorNum = 4 + index;
          return BuildingFloor(
            color: beigeColor,
            shadowColor: beigeShadow,
            width: buildingWidth,
            child: OpeningRow(
              count: 6,
              hasRailing: true,
              prefix: label,
              floor: floorNum,
            ),
          );
        }),
        // 3rd Floor
        BuildingFloor(
          color: beigeColor,
          shadowColor: beigeShadow,
          width: buildingWidth,
          child: OpeningRow(
            count: 6,
            hasRailing: true,
            prefix: label,
            floor: 3,
          ),
        ),
        // 2nd Floor
        BuildingFloor(
          color: beigeColor,
          shadowColor: beigeShadow,
          width: buildingWidth,
          child: OpeningRow(
            count: 6,
            hasRailing: true,
            prefix: label,
            floor: 2,
          ),
        ),
        // Ground Floor
        BuildingFloor(
          color: beigeColor,
          shadowColor: beigeShadow,
          isGround: true,
          width: buildingWidth,
          child: OpeningRow(
            count: 8,
            hasRailing: false,
            prefix: label,
            floor: 1,
          ),
        ),
      ],
    );
  }
}

class BuildingFloor extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  final Widget? child;
  final bool isRoof;
  final bool isGround;
  final double width;

  const BuildingFloor({
    super.key,
    required this.color,
    required this.shadowColor,
    this.child,
    this.isRoof = false,
    this.isGround = false,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: isRoof ? 30 : 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: isRoof ? const Radius.circular(20) : Radius.zero,
          topRight: isRoof ? const Radius.circular(20) : Radius.zero,
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
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
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }
}

class OpeningRow extends StatelessWidget {
  final int count;
  final bool hasRailing;
  final String prefix;
  final int floor;

  const OpeningRow({
    super.key,
    required this.count,
    required this.hasRailing,
    required this.prefix,
    required this.floor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(count, (index) {
              // Etiqueta tipo A3-2 (Edificio A, Piso 3, Puerta 2) o A1-5
              final String doorLabel = "$prefix$floor-${index + 1}";
              return Opening(label: doorLabel);
            }),
          ),
        ),
        if (hasRailing)
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: IgnorePointer(
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  border: const Border(
                    top: BorderSide(color: Colors.white, width: 2),
                    left: BorderSide(color: Colors.white, width: 2),
                    right: BorderSide(color: Colors.white, width: 2),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    15,
                    (index) => Container(width: 1.5, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class Opening extends StatelessWidget {
  final String label;
  const Opening({super.key, required this.label});

  void _showSalonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Salón $label"),
        content: Text("Hola, este es el salón $label"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSalonDialog(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1CB0F6),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 22,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFF84D8FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1CB0F6),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuildingStairs extends StatelessWidget {
  final bool roundLeft;
  final bool roundRight;
  final int totalSteps;

  const BuildingStairs({
    super.key,
    this.roundLeft = false,
    this.roundRight = false,
    this.totalSteps = 10,
  });

  @override
  Widget build(BuildContext context) {
    const int stepsPerFloor = 5;
    const baseColor = Color(0xFFF1E5D1);
    const darkColor = Color(0xFFD6C8B0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(totalSteps, (index) {
        int stepInCycle = (totalSteps - 1 - index) % stepsPerFloor;
        double darknessFactor = stepInCycle / (stepsPerFloor - 1);
        
        Color currentColor = Color.lerp(baseColor, darkColor, darknessFactor)!;

        BorderRadius borderRadius = BorderRadius.only(
          topLeft: roundLeft ? const Radius.circular(8) : Radius.zero,
          bottomLeft: roundLeft ? const Radius.circular(8) : Radius.zero,
          topRight: roundRight ? const Radius.circular(8) : Radius.zero,
          bottomRight: roundRight ? const Radius.circular(8) : Radius.zero,
        );

        return Container(
          width: 35,
          height: 17.2,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: borderRadius,
            border: Border(
              bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5),
            ),
          ),
        );
      }),
    );
  }
}
