import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/100?img=11'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UBICACIÓN',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    isDark ? Colors.white54 : Colors.black54)),
                        Text('SAN FRANCISCO',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            const SizedBox(height: 32),
            RichText(
              text: TextSpan(
                style: theme.textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                children: [
                  const TextSpan(text: '¿Qué '),
                  TextSpan(
                      text: 'necesitas',
                      style: TextStyle(color: theme.colorScheme.primary)),
                  const TextSpan(text: ' hoy?'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border:
                    Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(Icons.search,
                      color: isDark ? Colors.white54 : Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Buscar servicios (ej. plomería)',
                        style: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black38)),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CATEGORÍAS',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                TextButton(
                  onPressed: () {},
                  child: Text('VER TODO',
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _CategoryCard(
                    title: 'Plomería',
                    subtitle: '24 Especialistas',
                    icon: Icons.plumbing,
                    color: Color(0xFF9080FF),
                    image:
                        'https://images.unsplash.com/photo-1607472586893-edb57cb313be?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                  ),
                  SizedBox(width: 16),
                  _CategoryCard(
                    title: 'Electricidad',
                    subtitle: '18 Especialistas',
                    icon: Icons.electric_bolt,
                    color: Color(0xFF86EFAC),
                    image:
                        'https://images.unsplash.com/photo-1621905252876-056a2f81bd6b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('REELS Y TRABAJOS',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => context.push('/reels'),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1542044896530-05d85be9b11a?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                          child: Icon(Icons.play_circle_outline,
                              color: Colors.white, size: 40)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text('ESPECIALISTAS DESTACADOS',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            const _SpecialistCard(
              name: 'Marcus Thorne',
              title: 'Electricista Maestro • 12 años exp.',
              tag: 'RÁPIDO',
              price: '\$85/HR',
              rating: '4.9',
              image: 'https://i.pravatar.cc/100?img=33',
            ),
            const SizedBox(height: 16),
            const _SpecialistCard(
              name: 'Elena Vance',
              title: 'Diseñadora de Interiores',
              tag: 'NIVEL PRO',
              tagColor: Color(0xFF86EFAC),
              price: '\$120/HR',
              rating: '5.0',
              image: 'https://i.pravatar.cc/100?img=47',
            ),
            const SizedBox(height: 80), // Fab space
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String image;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final String name;
  final String title;
  final String tag;
  final Color? tagColor;
  final String price;
  final String rating;
  final String image;

  const _SpecialistCard({
    required this.name,
    required this.title,
    required this.tag,
    this.tagColor,
    required this.price,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/specialist'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(image),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                      color: const Color(0xFF86EFAC),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.colorScheme.surface, width: 2)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFF86EFAC), size: 16),
                          const SizedBox(width: 4),
                          Text(rating,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(title,
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (tagColor ?? theme.colorScheme.primary)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: tagColor ?? theme.colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(price,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
