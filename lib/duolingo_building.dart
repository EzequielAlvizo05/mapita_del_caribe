import 'package:flutter/material.dart';
import 'panorama_view.dart';

class DuolingoBuilding extends StatelessWidget {
  final String label;
  final int extraFloors;
  final Map<int, List<String>>? customSalons;

  const DuolingoBuilding({
    super.key,
    required this.label,
    this.extraFloors = 0,
    this.customSalons,
  });

  @override
  Widget build(BuildContext context) {
    const beigeColor = Color(0xFFF1E5D1);
    const beigeShadow = Color(0xFFD6C8B0);
    const buildingWidth = 450.0;

    int totalPisos = 3 + extraFloors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD6C8B0),
          ),
        ),
        const SizedBox(height: 10),
        const BuildingFloor(
          color: beigeColor,
          shadowColor: beigeShadow,
          isRoof: true,
          width: buildingWidth,
        ),
        ...List.generate(totalPisos, (index) {
          int floorNum = totalPisos - index;
          bool isGround = floorNum == 1;
          
          List<String>? salonsForFloor = customSalons?[floorNum];
          int doorCount = salonsForFloor?.length ?? (isGround ? 8 : 6);

          return BuildingFloor(
            color: beigeColor,
            shadowColor: beigeShadow,
            width: buildingWidth,
            isGround: isGround,
            child: OpeningRow(
              count: doorCount,
              hasRailing: !isGround,
              prefix: label,
              floor: floorNum,
              customNames: salonsForFloor,
            ),
          );
        }),
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
  final List<String>? customNames;

  const OpeningRow({
    super.key,
    required this.count,
    required this.hasRailing,
    required this.prefix,
    required this.floor,
    this.customNames,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: count <= 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(count, (index) {
              String doorLabel;
              if (customNames != null && index < customNames!.length) {
                doorLabel = customNames![index];
              } else {
                doorLabel = "$prefix$floor-${index + 1}";
              }
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
                  color: Colors.white.withValues(alpha: 0.3),
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
                    20,
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

  // Mapeo dinámico de fotos corregido según especificaciones exactas
  String _getImagePath(String salonLabel) {
    final String cleanLabel = salonLabel.toLowerCase();
    
    // 1. Salón de Prácticas
    if (cleanLabel.contains('prácticas')) return 'lib/assets/Practicas.jpg';
    
    // 2. Biblioteca
    if (cleanLabel.contains('biblioteca')) return 'lib/assets/Biblio.jpg';
    
    // 3. Gastronomía
    if (cleanLabel.contains('gastronomía')) return 'lib/assets/Tallercocina.jpg';
    
    // 4. Todos los demás
    return 'lib/assets/C11_2.jpg';
  }

  void _showSalonDialog(BuildContext context) {
    final String imagePath = _getImagePath(label);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label),
        content: Text("Hola, este es el espacio: $label"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PanoramaViewPage(imagePath: imagePath)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1CB0F6)),
            child: const Text("Ver Panorama 360"),
          ),
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
          SizedBox(
            width: 28,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 4.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1CB0F6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
            ),
          ),
        );
      }),
    );
  }
}
