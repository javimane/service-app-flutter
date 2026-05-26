import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCalendarScreen extends ConsumerStatefulWidget {
  const DashboardCalendarScreen({super.key});

  @override
  ConsumerState<DashboardCalendarScreen> createState() =>
      _DashboardCalendarScreenState();
}

class _DashboardCalendarScreenState extends ConsumerState<DashboardCalendarScreen> {
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: const Text('Calendario'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (_connected)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                // TODO: Show add event modal
              },
            )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.colorScheme.primary.withAlpha(40),
                        theme.colorScheme.surface,
                      ]
                    : [
                        theme.colorScheme.primary.withAlpha(15),
                        Colors.white,
                      ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border:
                  Border.all(color: theme.colorScheme.primary.withAlpha(40)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agenda de turnos',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Gestioná tus citas y sincronizalas con Google Calendar.',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          if (!_connected)
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 48.r, color: Colors.grey.withAlpha(100)),
                  SizedBox(height: 16.h),
                  Text('Conectá tu Google Calendar',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(
                    'Sincronizá tus citas y agendá nuevas directamente desde tu dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Simulate connect
                        setState(() => _connected = true);
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Conectar con Google'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            )
          else ...[
            // View switcher (mock)
            Row(
              children: [
                _ViewBtn(icon: Icons.calendar_view_month_rounded, label: 'Mes', active: true),
                SizedBox(width: 8.w),
                _ViewBtn(icon: Icons.calendar_view_week_rounded, label: 'Semana'),
                SizedBox(width: 8.w),
                _ViewBtn(icon: Icons.calendar_view_day_rounded, label: 'Día'),
              ],
            ),
            SizedBox(height: 16.h),

            // Mock Calendar grid
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () {}),
                      Text('Mayo 2026',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                        .map((d) => Text(d,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12.sp)))
                        .toList(),
                  ),
                  SizedBox(height: 8.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7, childAspectRatio: 1),
                    itemCount: 31,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isToday = day == 26; // Mock today
                      final hasEvent = day == 28 || day == 15;
                      return Container(
                        margin: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(
                          color: isToday
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isToday ? Colors.white : null,
                                  fontWeight:
                                      isToday ? FontWeight.bold : FontWeight.normal,
                                )),
                            if (hasEvent && !isToday)
                              Container(
                                margin: EdgeInsets.only(top: 2.h),
                                width: 4.r,
                                height: 4.r,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Upcoming events
            Text('Próximas Citas',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
              ),
              child: Column(
                children: [
                  _UpcomingEvent(
                      title: 'Visita Cliente A',
                      time: 'Jue 28 May - 10:00',
                      location: 'Calle Falsa 123'),
                  Divider(color: theme.dividerColor.withAlpha(50)),
                  _UpcomingEvent(
                      title: 'Revisión técnica',
                      time: 'Vie 29 May - 15:30',
                      location: 'Videollamada'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () {
                setState(() => _connected = false);
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Desconectar Google Calendar',
                  style: TextStyle(color: Colors.red)),
            )
          ]
        ],
      ),
    );
  }
}

class _ViewBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _ViewBtn(
      {required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withAlpha(20)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
              color: active
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16.r,
                color: active ? theme.colorScheme.primary : Colors.grey),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: active ? theme.colorScheme.primary : Colors.grey,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _UpcomingEvent extends StatelessWidget {
  final String title;
  final String time;
  final String location;

  const _UpcomingEvent({
    required this.title,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 40.h,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 12.r, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(time,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    SizedBox(width: 12.w),
                    Icon(Icons.location_on_rounded, size: 12.r, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(location,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20.r),
        ],
      ),
    );
  }
}
