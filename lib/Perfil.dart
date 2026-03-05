import 'package:flutter/material.dart';

// Paquetes estilo Duolingo:
import 'package:chiclet/chiclet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

void main() => runApp(const MyApp());

/// ======================================================
/// WIDGET "DUOLINGO BUILDING" (ilustración simple)
/// ======================================================
class DuolingoBuilding extends StatelessWidget {
  const DuolingoBuilding({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F7FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Stack(
          children: const [
            Positioned(top: 10, left: 10, child: _Cloud(width: 26)),
            Positioned(top: 22, right: 8, child: _Cloud(width: 34)),
            Positioned(left: 0, right: 0, bottom: 0, height: 22, child: _Grass()),
            Center(child: _Building()),
          ],
        ),
      ),
    );
  }
}

class _Grass extends StatelessWidget {
  const _Grass();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFB9F27C)),
    );
  }
}

class _Building extends StatelessWidget {
  const _Building();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF58CC02),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF46A302),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: List.generate(
                  4,
                  (_) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: 12,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF1F7A00),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.width});
  final double width;

  Widget _bubble(double s) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(999),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.6,
      child: Stack(
        children: [
          Positioned(left: 0, bottom: 0, child: _bubble(width * 0.5)),
          Positioned(left: width * 0.25, bottom: width * 0.08, child: _bubble(width * 0.55)),
          Positioned(left: width * 0.5, bottom: 0, child: _bubble(width * 0.45)),
        ],
      ),
    );
  }
}

/// ======================================================
/// MODELOS: Place / Person
/// ======================================================
enum PersonType { teacher, admin, student }

class Person {
  final String name;
  final String? email;
  final PersonType type;
  final String? schedule; // Maestro
  final String? area; // Administrativo
  final String? matricula; // Estudiante

  const Person({
    required this.name,
    required this.type,
    this.email,
    this.schedule,
    this.area,
    this.matricula,
  });
}

class Place {
  final String id;
  final String name;
  final List<String> spaces;
  final String hours;
  final List<Person> people;

  const Place({
    required this.id,
    required this.name,
    required this.spaces,
    required this.hours,
    required this.people,
  });
}

/// ======================================================
/// APP
/// ======================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF58CC02);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa Uni',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
      home: const MapHomeScreen(),
    );
  }
}

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  PersonType? selectedFilter; // null = Todos

  final List<Place> places = const [
    Place(
      id: 'edif_a',
      name: 'Edificio A - Servicios Escolares',
      hours: 'Lun–Vie 08:00–18:00',
      spaces: ['Ventanillas', 'Sala de espera', 'Acceso principal'],
      people: [
        Person(
          name: 'Lic. Laura Méndez',
          type: PersonType.admin,
          email: 'laura.mendez@uni.mx',
          area: 'Servicios Escolares (Ventanilla 2)',
        ),
        Person(
          name: 'Mtro. Carlos Reyes',
          type: PersonType.teacher,
          email: 'carlos.reyes@uni.mx',
          schedule: 'Mar/Jue 10:00–12:00 (Cubículo A-12)',
        ),
        Person(
          name: 'Sofía Ruiz',
          type: PersonType.student,
          matricula: '20231234',
        ),
      ],
    ),
    Place(
      id: 'lab_comp',
      name: 'Laboratorio de Cómputo',
      hours: 'Lun–Sáb 09:00–20:00',
      spaces: ['Lab 1', 'Lab 2', 'Soporte TI'],
      people: [
        Person(
          name: 'Ing. José Pérez',
          type: PersonType.admin,
          email: 'jose.perez@uni.mx',
          area: 'Soporte TI (Lab 2)',
        ),
        Person(
          name: 'Mtra. Andrea Gómez',
          type: PersonType.teacher,
          email: 'andrea.gomez@uni.mx',
          schedule: 'Lun/Mie 14:00–16:00 (Lab 1)',
        ),
        Person(
          name: 'Diego Chan',
          type: PersonType.student,
          matricula: '20227890',
        ),
      ],
    ),
  ];

  List<Person> _filteredPeople(Place place) {
    if (selectedFilter == null) return place.people;
    return place.people.where((p) => p.type == selectedFilter).toList();
  }

  String _filterLabel(PersonType? t) {
    if (t == null) return 'Todos';
    switch (t) {
      case PersonType.teacher:
        return 'Maestros';
      case PersonType.admin:
        return 'Administrativos';
      case PersonType.student:
        return 'Estudiantes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa del Campus')),
      body: Stack(
        children: [
          // “Mapa” placeholder con animación suave
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [cs.primaryContainer.withOpacity(0.35), const Color(0xFFF7F7F7)],
                ),
              ),
              child: Center(
                child: Text(
                  'MAPA / PLANO (placeholder)\n\nArriba: filtro\nAbajo: lugares (demo)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.05, end: 0, duration: 350.ms),
              ),
            ),
          ),

          // Filtro superior con animación
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _TopFilterBar(
              selected: selectedFilter,
              onSelected: (v) => setState(() => selectedFilter = v),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .slideY(begin: -0.2, end: 0, duration: 250.ms),
          ),

          // Lista de lugares “demo” con transición OpenContainer + botones Chiclet
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Demo: elige un lugar',
                      style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: places.map((p) {
                        return OpenContainer(
                          transitionType: ContainerTransitionType.fadeThrough,
                          openColor: Colors.white,
                          closedColor: Colors.transparent,
                          closedElevation: 0,
                          openElevation: 0,
                          closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          openBuilder: (context, _) {
                            // Pantalla “detalle” (con lo mismo que el bottom sheet, pero en page)
                            return PlaceDetailPage(
                              place: p,
                              filterLabel: _filterLabel(selectedFilter),
                              people: _filteredPeople(p),
                            );
                          },
                          closedBuilder: (context, open) {
                            return ChicletButton(
                              onPressed: open,
                              backgroundColor: const Color(0xFF58CC02),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.15, end: 0, duration: 300.ms),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// FILTRO SUPERIOR (con micro animación)
/// ======================================================
class _TopFilterBar extends StatelessWidget {
  const _TopFilterBar({required this.selected, required this.onSelected});

  final PersonType? selected;
  final ValueChanged<PersonType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(
              label: 'Todos',
              icon: Icons.filter_alt_outlined,
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            const SizedBox(width: 8),
            _chip(
              label: 'Maestros',
              icon: Icons.school_outlined,
              isSelected: selected == PersonType.teacher,
              onTap: () => onSelected(PersonType.teacher),
            ),
            const SizedBox(width: 8),
            _chip(
              label: 'Administrativos',
              icon: Icons.badge_outlined,
              isSelected: selected == PersonType.admin,
              onTap: () => onSelected(PersonType.admin),
            ),
            const SizedBox(width: 8),
            _chip(
              label: 'Estudiantes',
              icon: Icons.person_outline,
              isSelected: selected == PersonType.student,
              onTap: () => onSelected(PersonType.student),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 18),
      label: Text(label),
      showCheckmark: false,
    )
        .animate(target: isSelected ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 120.ms);
  }
}

/// ======================================================
/// DETALLE EN PANTALLA (abierta con OpenContainer)
/// ======================================================
class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({
    super.key,
    required this.place,
    required this.filterLabel,
    required this.people,
  });

  final Place place;
  final String filterLabel;
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del lugar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const SizedBox(width: 72, height: 72, child: DuolingoBuilding()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 18, color: cs.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                place.hours,
                                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.06, end: 0, duration: 250.ms),

          const SizedBox(height: 16),

          Text('Espacios', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: cs.onSurface)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: place.spaces
                .map((s) => Chip(label: Text(s), avatar: const Icon(Icons.place_outlined, size: 18)))
                .toList(),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.06, end: 0, duration: 250.ms),

          const SizedBox(height: 18),

          Row(
            children: [
              Text(
                'Directorio ($filterLabel)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: cs.onSurface),
              ),
              const Spacer(),
              Text('${people.length}', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),

          if (people.isEmpty)
            Text('No hay personas para este filtro en este lugar.', style: TextStyle(color: cs.onSurfaceVariant)),

          ...people.map((p) => _PersonTile(person: p)).toList().animate(interval: 60.ms).fadeIn(duration: 220.ms).slideY(begin: 0.08, end: 0),

          const SizedBox(height: 14),

          // Botón tipo Duolingo (Chiclet)
          ChicletButton(
            onPressed: () {},
            backgroundColor: const Color(0xFF58CC02),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_in_ar, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Ver en Realidad Aumentada (demo)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
        ],
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    IconData icon;
    String role;

    switch (person.type) {
      case PersonType.teacher:
        icon = Icons.school_outlined;
        role = 'Maestro';
        break;
      case PersonType.admin:
        icon = Icons.badge_outlined;
        role = 'Administrativo';
        break;
      case PersonType.student:
        icon = Icons.person_outline;
        role = 'Estudiante';
        break;
    }

    final details = <String>[];
    if (person.type == PersonType.teacher && person.schedule != null) details.add('Horario: ${person.schedule}');
    if (person.type == PersonType.admin && person.area != null) details.add('Área: ${person.area}');
    if (person.type == PersonType.student && person.matricula != null) details.add('Matrícula: ${person.matricula}');
    if (person.email != null) details.add('Correo: ${person.email}');

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(icon, color: cs.onPrimaryContainer),
        ),
        title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          '$role\n${details.join('\n')}',
          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
        isThreeLine: true,
      ),
    );
  }
}