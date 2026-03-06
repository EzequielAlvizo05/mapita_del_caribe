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
    const buildingWidth = 550.0;

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
              return Opening(label: doorLabel, buildingLabel: prefix);
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
  final String buildingLabel;
  const Opening({super.key, required this.label, required this.buildingLabel});

  String _getImagePath(String name) {
    final String n = name.toLowerCase();
    if (n.contains('biblioteca')) return 'lib/assets/Biblio.jpg';
    if (n.contains('prácticas')) return 'lib/assets/Practicas.jpg';
    if (n.contains('gastronomía')) return 'lib/assets/Tallercocina.jpg';
    return 'lib/assets/C11_2.jpg';
  }

  void _showScheduleTable(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Horario - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(80),
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: ['Hora', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie']
                        .map((day) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                            ))
                        .toList(),
                  ),
                  ...List.generate(16, (index) {
                    int hour = 7 + index;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${hour.toString().padLeft(2, '0')}:00", textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
                        ),
                        ...List.generate(5, (day) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("-", textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                        )),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Volver")),
        ],
      ),
    );
  }

  void _showSalonDialog(BuildContext context) {
    final String imagePath = _getImagePath(label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Detalles del Salón"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Nombre:", label),
            _infoRow("Edificio:", "Edificio $buildingLabel"),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showScheduleTable(context),
                icon: const Icon(Icons.calendar_month),
                label: const Text("Ver Horario Semanal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB0F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PanoramaViewPage(imagePath: imagePath)),
              );
            },
            child: const Text("Ver Panorama 360"),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
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
            width: 30,
            child: Text(
              label,
              style: const TextStyle(fontSize: 5.5, fontWeight: FontWeight.bold, color: Color(0xFF1CB0F6)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 22, height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFF84D8FF),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              boxShadow: [BoxShadow(color: Color(0xFF1CB0F6), offset: Offset(0, 3), blurRadius: 0)],
            ),
          ),
        ],
      ),
    );
  }
}

class BuildingStairs extends StatelessWidget {
  final int totalSteps;
  const BuildingStairs({super.key, this.totalSteps = 10});

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
        return Container(
          width: 35, height: 17.2,
          decoration: BoxDecoration(
            color: currentColor,
            border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 0.5)),
          ),
        );
      }),
    );
  }
}
