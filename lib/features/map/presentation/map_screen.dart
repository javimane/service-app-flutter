import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/data/models/professional_model.dart';
import '../../../core/data/models/categories.model.dart';
import '../../../core/data/models/location_model.dart';
import '../providers/map_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? mapController;
  final TextEditingController _searchController = TextEditingController();

  final LatLng _defaultCenter =
      const LatLng(-34.6037, -58.3816); // Centro por defecto (Buenos Aires)
  // Map style: hide POIs and transit stations (paradas de bus)
  final String _mapStyle = '''
    [
      {
        "featureType": "poi",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "transit.station",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "transit",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    ]
    ''';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showProfessionalDetails(ProfessionalModel professional) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          CachedNetworkImageProvider(professional.avatar),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            professional.name,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (professional.companyName != null &&
                              professional.companyName !=
                                  professional.displayName)
                            Text(
                              professional.companyName!,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            professional.specialty ?? 'Especialista',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${professional.ratingAvg ?? 0.0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    if (professional.isVerified) ...[
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                      const SizedBox(width: 4),
                      const Text(
                        'Verificado',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ] else ...[
                      Icon(Icons.info_outline,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Sin verificar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.pop(); // Close bottom sheet
                      context.push('/specialist/${professional.id}');
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('Ver Perfil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProvincesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Consumer(
              builder: (context, ref, child) {
                final asyncData = ref.watch(mapProvincesProvider);
                return asyncData.when(
                  data: (data) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text('Selecciona Provincia', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return ListTile(
                              title: Text(item.name),
                              onTap: () {
                                ref.read(mapFiltersProvider.notifier).state =
                                    ref.read(mapFiltersProvider).copyWith(provinceId: item.id, clearDepartment: true);
                                context.pop();
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(mapFiltersProvider.notifier).state = ref.read(mapFiltersProvider).copyWith(clearProvince: true, clearDepartment: true);
                            context.pop();
                          },
                          child: const Center(child: Text('Limpiar Filtro')),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const Center(child: Text('Error al cargar')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDepartmentsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Consumer(
              builder: (context, ref, child) {
                final filters = ref.watch(mapFiltersProvider);
                if (filters.provinceId == null) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Selecciona un Departamento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text('Primero debes seleccionar una provincia.'),
                      ],
                    ),
                  );
                }
                final asyncData = ref.watch(mapDepartmentsProvider);
                return asyncData.when(
                  data: (data) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text('Selecciona Departamento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return ListTile(
                              title: Text(item.name),
                              onTap: () {
                                ref.read(mapFiltersProvider.notifier).state =
                                    ref.read(mapFiltersProvider).copyWith(departmentId: item.id);
                                context.pop();
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(mapFiltersProvider.notifier).state = ref.read(mapFiltersProvider).copyWith(clearDepartment: true);
                            context.pop();
                          },
                          child: const Center(child: Text('Limpiar Filtro')),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const Center(child: Text('Error al cargar')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Consumer(
              builder: (context, ref, child) {
                final asyncData = ref.watch(mapCategoriesProvider);
                return asyncData.when(
                  data: (data) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text('Selecciona Categoría', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return ListTile(
                              title: Text(item.name),
                              onTap: () {
                                ref.read(mapFiltersProvider.notifier).state =
                                    ref.read(mapFiltersProvider).copyWith(categoryId: item.id);
                                context.pop();
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(mapFiltersProvider.notifier).state = ref.read(mapFiltersProvider).copyWith(clearCategory: true);
                            context.pop();
                          },
                          child: const Center(child: Text('Limpiar Filtro')),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const Center(child: Text('Error al cargar')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<ProfessionalModel>>>(mapProfessionalsProvider, (previous, next) {
      if (next is AsyncData && next.value != null && next.value!.isNotEmpty) {
        if (mapController != null) {
          final professionals = next.value!;
          double minLat = professionals.first.latitude!;
          double maxLat = professionals.first.latitude!;
          double minLng = professionals.first.longitude!;
          double maxLng = professionals.first.longitude!;

          for (final p in professionals) {
            if (p.latitude! < minLat) minLat = p.latitude!;
            if (p.latitude! > maxLat) maxLat = p.latitude!;
            if (p.longitude! < minLng) minLng = p.longitude!;
            if (p.longitude! > maxLng) maxLng = p.longitude!;
          }

          final bounds = LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          );

          // Use a small delay to ensure the map has been fully laid out
          Future.delayed(const Duration(milliseconds: 150), () {
            mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
          });
        }
      }
    });

    final theme = Theme.of(context);
    final professionalsAsync = ref.watch(mapProfessionalsProvider);
    final filters = ref.watch(mapFiltersProvider);

    final Set<Marker> markers = professionalsAsync.maybeWhen(
      data: (professionals) {
        return professionals.map((prof) {
          return Marker(
            markerId: MarkerId(prof.id.toString()),
            position: LatLng(prof.latitude!, prof.longitude!),
            onTap: () => _showProfessionalDetails(prof),
          );
        }).toSet();
      },
      orElse: () => {},
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            style: _mapStyle,
            initialCameraPosition: CameraPosition(
              target: _defaultCenter,
              zoom: 14.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar profesional...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        ref.read(mapFiltersProvider.notifier).state =
                            filters.copyWith(query: value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: filters.provinceId != null
                              ? 'Provincia Activa'
                              : 'Provincia',
                          isActive: filters.provinceId != null,
                          onTap: _showProvincesSheet,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: filters.departmentId != null
                              ? 'Depto Activo'
                              : 'Departamento',
                          isActive: filters.departmentId != null,
                          onTap: _showDepartmentsSheet,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: filters.categoryId != null
                              ? 'Categoría Activa'
                              : 'Categorías',
                          isActive: filters.categoryId != null,
                          onTap: _showCategoriesSheet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (professionalsAsync.isLoading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 100, // Above bottom nav
            right: 16,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              backgroundColor: theme.colorScheme.surface,
              child: Icon(Icons.my_location, color: theme.colorScheme.primary),
              onPressed: () {
                mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_defaultCenter, 14.0));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isActive ? theme.colorScheme.onPrimaryContainer : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? theme.colorScheme.onPrimaryContainer : null,
            ),
          ],
        ),
      ),
    );
  }
}
