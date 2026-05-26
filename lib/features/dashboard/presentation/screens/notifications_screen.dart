import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Model ──────────────────────────────────────────────────────────────────

enum _NotiCategory { all, proposals, messages, promotions, analytics }

class _Notification {
  final String id;
  final String title;
  final String description;
  final String time;
  final String date;
  final _NotiCategory category;
  final Color iconColor;
  bool unread;

  _Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.category,
    required this.iconColor,
    this.unread = true,
  });
}

// ─── Demo data ──────────────────────────────────────────────────────────────

final _demoNotifications = <_Notification>[
  _Notification(
    id: '1',
    title: 'Nueva propuesta recibida',
    description: 'Juan López te envió una propuesta de trabajo.',
    time: 'Hace 5 min',
    date: 'Hoy',
    category: _NotiCategory.proposals,
    iconColor: Colors.blue,
    unread: true,
  ),
  _Notification(
    id: '2',
    title: '¡Promoción activa!',
    description: 'Tu promoción bancaria con Banco Galicia entró en vigencia.',
    time: 'Hace 1 h',
    date: 'Hoy',
    category: _NotiCategory.promotions,
    iconColor: Colors.orange,
    unread: true,
  ),
  _Notification(
    id: '3',
    title: 'Mensaje nuevo',
    description: 'María García te envió un mensaje sobre el presupuesto.',
    time: 'Hace 3 h',
    date: 'Hoy',
    category: _NotiCategory.messages,
    iconColor: Colors.green,
    unread: false,
  ),
  _Notification(
    id: '4',
    title: 'Estadísticas del mes',
    description: 'Revisá tu resumen de visitas y contactos de mayo.',
    time: '10:00',
    date: 'Ayer',
    category: _NotiCategory.analytics,
    iconColor: Colors.purple,
    unread: false,
  ),
  _Notification(
    id: '5',
    title: 'Propuesta aceptada',
    description: 'Carlos Pérez aceptó tu propuesta. ¡A trabajar!',
    time: '09:15',
    date: 'Ayer',
    category: _NotiCategory.proposals,
    iconColor: Colors.teal,
    unread: false,
  ),
];

// ─── Providers ───────────────────────────────────────────────────────────────

final _notisProvider =
    StateProvider<List<_Notification>>((ref) => _demoNotifications);
final _notiFilterProvider =
    StateProvider<_NotiCategory>((ref) => _NotiCategory.all);

// ─── Screen ──────────────────────────────────────────────────────────────────

class DashboardNotificationsScreen extends ConsumerWidget {
  const DashboardNotificationsScreen({super.key});

  static const _filterOptions = [
    (key: _NotiCategory.all, label: 'Todas'),
    (key: _NotiCategory.proposals, label: 'Propuestas'),
    (key: _NotiCategory.messages, label: 'Mensajes'),
    (key: _NotiCategory.promotions, label: 'Promociones'),
    (key: _NotiCategory.analytics, label: 'Analíticas'),
  ];

  static IconData _iconFor(_NotiCategory cat) => switch (cat) {
        _NotiCategory.proposals => Icons.description_outlined,
        _NotiCategory.messages => Icons.chat_bubble_outline_rounded,
        _NotiCategory.promotions => Icons.local_offer_outlined,
        _NotiCategory.analytics => Icons.trending_up_rounded,
        _NotiCategory.all => Icons.notifications_none_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notis = ref.watch(_notisProvider);
    final filter = ref.watch(_notiFilterProvider);
    final unreadCount = notis.where((n) => n.unread).length;

    final filtered = filter == _NotiCategory.all
        ? notis
        : notis.where((n) => n.category == filter).toList();

    // Group by date
    final grouped = <String, List<_Notification>>{};
    for (final n in filtered) {
      (grouped[n.date] ??= []).add(n);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Row(
          children: [
            const Text('Notificaciones'),
            if (unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                final updated = ref
                    .read(_notisProvider)
                    .map((n) {
                      n.unread = false;
                      return n;
                    })
                    .toList();
                ref.read(_notisProvider.notifier).state = [...updated];
              },
              icon: Icon(Icons.done_all_rounded,
                  size: 16.r, color: theme.colorScheme.primary),
              label: Text('Leer todo',
                  style: TextStyle(
                      fontSize: 12.sp, color: theme.colorScheme.primary)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: _filterOptions.map((opt) {
                final isActive = filter == opt.key;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    selected: isActive,
                    label: Text(opt.label,
                        style: TextStyle(fontSize: 12.sp)),
                    onSelected: (_) => ref
                        .read(_notiFilterProvider.notifier)
                        .state = opt.key,
                    selectedColor:
                        theme.colorScheme.primary.withAlpha(30),
                    checkmarkColor: theme.colorScheme.primary,
                    side: BorderSide(
                        color: isActive
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.white24
                                : Colors.black12)),
                    labelStyle: TextStyle(
                        color: isActive
                            ? theme.colorScheme.primary
                            : null,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                );
              }).toList(),
            ),
          ),

          // List
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 56.r,
                            color: Colors.grey.withAlpha(80)),
                        SizedBox(height: 14.h),
                        Text('No hay notificaciones en esta categoría.',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14.sp),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...entry.value.map((notif) => _NotifCard(
                                notif: notif,
                                iconData: _iconFor(notif.category),
                                onTap: () {
                                  if (notif.unread) {
                                    notif.unread = false;
                                    ref
                                        .read(_notisProvider.notifier)
                                        .state = [...ref.read(_notisProvider)];
                                  }
                                },
                              )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _Notification notif;
  final IconData iconData;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notif,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: notif.unread
              ? theme.colorScheme.primary.withAlpha(isDark ? 18 : 10)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: notif.unread
                ? theme.colorScheme.primary.withAlpha(40)
                : (isDark ? Colors.white10 : Colors.black.withAlpha(13)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                color: notif.iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(iconData,
                  color: notif.iconColor, size: 18.r),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: notif.unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(notif.time,
                          style: TextStyle(
                              fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    notif.description,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread dot
            if (notif.unread)
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 4.h),
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
