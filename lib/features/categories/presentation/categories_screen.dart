import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/categories_providers.dart';
import '../../../core/data/models/professional_model.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _isFiltersExpanded = false;
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filterState = ref.watch(categoriesFilterProvider);
    final professionalsAsync = ref.watch(categoriesProfessionalsProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    // Encuentra la categoría seleccionada para el título y portada
    final categoryName = filterState.categoryId != null
        ? categoriesAsync.value
            ?.firstWhere((c) => c.id == filterState.categoryId,
                orElse: () => categoriesAsync.value!.first)
            .name
        : 'Todas';

    final categoryImage = filterState.categoryId != null
        ? categoriesAsync.value
            ?.firstWhere((c) => c.id == filterState.categoryId,
                orElse: () => categoriesAsync.value!.first)
            .imageUrl
        : 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&q=80';

    final professionalsCount = professionalsAsync.value?.length ?? 0;

    final topPadding = MediaQuery.of(context).padding.top;
    final pinnedHeight = kToolbarHeight + topPadding;
    final maxAppBarHeight = 200.h;

    // Calculate the top position of the filter card
    final filterTop =
        (maxAppBarHeight - _scrollOffset).clamp(pinnedHeight, maxAppBarHeight) +
            12.h;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: maxAppBarHeight,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(categoryName ?? 'Todas',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (categoryImage != null)
                        CachedNetworkImage(
                          imageUrl: categoryImage,
                          fit: BoxFit.cover,
                          color: Colors.black.withAlpha((0.4 * 255).round()),
                          colorBlendMode: BlendMode.darken,
                        ),
                      Positioned(
                        bottom: 60.h,
                        left: 16.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '$professionalsCount PERFILES DISPONIBLES',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              // Placeholder para la tarjeta de filtros en estado colapsado
              SliverToBoxAdapter(
                child: SizedBox(height: 90.h),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RESULTADOS',
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              letterSpacing: 1.2)),
                      SizedBox(height: 4.h),
                      Text(
                        professionalsAsync.isLoading
                            ? 'Buscando especialistas...'
                            : '$professionalsCount especialistas encontrados',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
              professionalsAsync.when(
                data: (professionals) {
                  if (professionals.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off,
                                  size: 48.w, color: Colors.grey),
                              SizedBox(height: 16.h),
                              Text('No hay resultados con esos filtros',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp)),
                              SizedBox(height: 8.h),
                              Text(
                                  'Probá con otra categoría, provincia o desactivá urgencias.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final prof = professionals[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: _buildProfessionalCard(
                                context, prof, theme, isDark),
                          );
                        },
                        childCount: professionals.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SliverFillRemaining(
                    child: Center(child: Text('Error: $e'))),
              ),
            ],
          ),
          // Background oscuro opcional cuando está expandido (para enfocarse en el filtro)
          if (_isFiltersExpanded)
            Positioned.fill(
              top: filterTop + 90.h, // starts below the collapsed header part
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFiltersExpanded = false;
                  });
                },
                child: Container(
                  color: Colors.black.withAlpha(100),
                ),
              ),
            ),
          // Overlay de filtros (se pinta encima del contenido pero por debajo del overlay oscuro)
          Positioned(
            top: filterTop,
            left: 0,
            right: 0,
            child: _buildFilterCard(context, ref, filterState, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context, WidgetRef ref,
      CategoriesFilterState filterState, ThemeData theme, bool isDark) {
    final maxExpandedHeight = MediaQuery.of(context).size.height * 0.45;

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header colapsable
          InkWell(
            onTap: () {
              setState(() {
                _isFiltersExpanded = !_isFiltersExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Encontrá a tu profesional',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      if (!_isFiltersExpanded)
                        Text('Filtros aplicados. Toca para editar.',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12.sp)),
                    ],
                  ),
                  Icon(_isFiltersExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          // Contenido de filtros (expandible y con altura limitada para caber en pantalla)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxExpandedHeight),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Buscador
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Buscar nombre, rubro, o especia...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: 20),
                          ),
                          onSubmitted: (val) {
                            ref.read(categoriesFilterProvider.notifier).state =
                                filterState.copyWith(query: val);
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Categoría
                      Text('CATEGORÍA:',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      SizedBox(height: 8.h),
                      _buildCategoryDropdown(ref, filterState, isDark),
                      SizedBox(height: 12.h),

                      // Ubicación
                      Text('UBICACIÓN:',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                              child: _buildProvinceDropdown(
                                  ref, filterState, isDark)),
                          SizedBox(width: 8.w),
                          Expanded(
                              child: _buildDepartmentDropdown(
                                  ref, filterState, isDark)),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Tipo de perfil
                      Text('TIPO DE PERFIL:',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      SizedBox(height: 8.h),
                      _buildAccountTypeToggle(ref, filterState, theme),
                      SizedBox(height: 12.h),

                      // Preferencias
                      Text('PREFERENCIAS:',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      SizedBox(height: 8.h),
                      _buildSwitch('SOLO URGENCIAS', filterState.urgentOnly,
                          (val) {
                        ref.read(categoriesFilterProvider.notifier).state =
                            filterState.copyWith(urgentOnly: val);
                      }, theme),
                      _buildSwitch(
                          'COMERCIO AL PÚBLICO', filterState.publicStoreOnly,
                          (val) {
                        ref.read(categoriesFilterProvider.notifier).state =
                            filterState.copyWith(publicStoreOnly: val);
                      }, theme),
                      _buildSwitch('SOLO VERIFICADOS', filterState.verifiedOnly,
                          (val) {
                        ref.read(categoriesFilterProvider.notifier).state =
                            filterState.copyWith(verifiedOnly: val);
                      }, theme),
                      _buildSwitch(
                          'SOLO MATRICULADOS', filterState.matriculatedOnly,
                          (val) {
                        ref.read(categoriesFilterProvider.notifier).state =
                            filterState.copyWith(matriculatedOnly: val);
                      }, theme),
                    ],
                  ),
                ),
              ),
            ),
            crossFadeState: _isFiltersExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(
      WidgetRef ref, CategoriesFilterState filterState, bool isDark) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: filterState.categoryId,
          hint: const Text('Profesiones y Oficios'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas')),
            if (categoriesAsync.value != null)
              ...categoriesAsync.value!.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
          ],
          onChanged: (val) {
            ref.read(categoriesFilterProvider.notifier).state =
                filterState.copyWith(
              categoryId: val,
              clearCategory: val == null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown(
      WidgetRef ref, CategoriesFilterState filterState, bool isDark) {
    final provincesAsync = ref.watch(categoriesProvincesProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: filterState.provinceId,
          hint: const Text('Provincia'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas')),
            if (provincesAsync.value != null)
              ...provincesAsync.value!.map(
                  (p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
          ],
          onChanged: (val) {
            ref.read(categoriesFilterProvider.notifier).state =
                filterState.copyWith(
              provinceId: val,
              clearProvince: val == null,
              clearDepartment: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown(
      WidgetRef ref, CategoriesFilterState filterState, bool isDark) {
    final deptsAsync = ref.watch(categoriesDepartmentsProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: filterState.departmentId,
          hint: const Text('Ciudad'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas')),
            if (deptsAsync.value != null)
              ...deptsAsync.value!.map(
                  (d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
          ],
          onChanged: filterState.provinceId == null
              ? null
              : (val) {
                  ref.read(categoriesFilterProvider.notifier).state =
                      filterState.copyWith(
                    departmentId: val,
                    clearDepartment: val == null,
                  );
                },
        ),
      ),
    );
  }

  Widget _buildAccountTypeToggle(
      WidgetRef ref, CategoriesFilterState filterState, ThemeData theme) {
    final types = ['Todos', 'Comercio', 'Autónomo'];
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected =
              (filterState.accountType == 'Todos' && type == 'Todos') ||
                  filterState.accountType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(categoriesFilterProvider.notifier).state =
                    filterState.copyWith(accountType: type);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFEF4444) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (theme.brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitch(
      String label, bool value, ValueChanged<bool> onChanged, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(BuildContext context, ProfessionalModel prof,
      ThemeData theme, bool isDark) {
    // Se elimina la imagen de portada y la etiqueta de precio solicitada.

    return GestureDetector(
      onTap: () => context.push('/specialist/${prof.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Se quita la imagen superior; dejar un pequeño espacio entre borde y contenido
            SizedBox(height: 8.h),
            // Body
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundImage:
                            CachedNetworkImageProvider(prof.avatar),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                prof.companyName ??
                                    prof.displayName ??
                                    'Profesional',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp)),
                            Text(prof.specialty ?? 'Especialista',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildTag(Icons.location_on, 'Desconocida, Provincia',
                          Colors.grey[200]!, Colors.black54),
                      _buildTag(
                          Icons.store,
                          prof.accountType == 'company'
                              ? 'Comercio'
                              : 'Autónomo',
                          Colors.grey[200]!,
                          Colors.black54),
                      if (prof.emergency == true)
                        _buildTag(Icons.flash_on, 'Urgencias',
                            const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
                      if (prof.isVerified)
                        _buildTag(Icons.verified, 'Verificado',
                            const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
                      if (prof.isMatriculate == true)
                        _buildTag(Icons.badge, 'Matriculado',
                            const Color(0xFFE0E7FF), const Color(0xFF4F46E5)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    prof.bio ?? 'Sin descripción disponible.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 12.sp),
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: Colors.grey[200]),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('${prof.ratingAvg ?? 0.0}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            SizedBox(width: 8.w),
                            Text('${prof.completedJobs} TRABAJOS',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                    letterSpacing: 1.1)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/specialist/${prof.id}'),
                        icon: Icon(Icons.person,
                            size: 16.sp, color: Colors.white),
                        label: Text('Ver perfil',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1E293B), // Dark slate
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(
      IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp)),
        ],
      ),
    );
  }
}
