import 'package:flutter/material.dart';

class SpecialistProfileScreen extends StatelessWidget {
  const SpecialistProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(radius: 14, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
            const SizedBox(width: 8),
            Text('UBICACIÓN', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(40),
                        ),
                        border: Border.all(color: theme.colorScheme.secondary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?img=33'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          children: [
                            const TextSpan(text: 'JULIAN\n'),
                            TextSpan(text: 'VARGAS', style: TextStyle(color: theme.colorScheme.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('EXPERTO ARQUITECTO DE INTERIORES', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Especializado en la creación de espacios minimalistas con un enfoque en la iluminación cinética y el diseño estructural contemporáneo.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.star, value: '4.9', label: 'CALIFICACIÓN')),
                SizedBox(width: 8),
                Expanded(child: _StatCard(icon: Icons.check_circle_outline, value: '128', label: 'TRABAJOS', isCenter: true)),
                SizedBox(width: 8),
                Expanded(child: _StatCard(icon: Icons.access_time, value: '8a', label: 'EXP.')),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PORTAFOLIO', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('VER TODO', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: const [
                _PortfolioImage('https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80', isTopLeftCurved: true),
                _PortfolioImage('https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80', isTopRightCurved: true),
                _PortfolioImage('https://images.unsplash.com/photo-1600566753086-00f18efc2291?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80', isBottomLeftCurved: true),
                _PortfolioImage('https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80', isBottomRightCurved: true),
              ],
            ),
            const SizedBox(height: 32),
            Text('TESTIMONIOS', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const _TestimonialCard(
              name: 'Elena Rossi',
              image: 'https://i.pravatar.cc/100?img=5',
              text: '«Julian transformó nuestro loft en una obra maestra. Su ojo para el detalle y la forma en que maneja la luz es simplemente incomparable.»',
            ),
            const SizedBox(height: 16),
            const _TestimonialCard(
              name: 'Marco Chen',
              image: 'https://i.pravatar.cc/100?img=12',
              text: '«Altamente profesional y con una visión futurista. Recomendación 10/10 para cualquier proyecto de alta gama.»',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SOLICITAR SERVICIO'),
                    SizedBox(width: 8),
                    Icon(Icons.bolt),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isCenter;

  const _StatCard({required this.icon, required this.value, required this.label, this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: isCenter ? BorderRadius.circular(40) : const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1.0)),
        ],
      ),
    );
  }
}

class _PortfolioImage extends StatelessWidget {
  final String url;
  final bool isTopLeftCurved;
  final bool isTopRightCurved;
  final bool isBottomLeftCurved;
  final bool isBottomRightCurved;

  const _PortfolioImage(this.url, {
    this.isTopLeftCurved = false,
    this.isTopRightCurved = false,
    this.isBottomLeftCurved = false,
    this.isBottomRightCurved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTopLeftCurved ? 40 : 10),
          topRight: Radius.circular(isTopRightCurved ? 40 : 10),
          bottomLeft: Radius.circular(isBottomLeftCurved ? 40 : 10),
          bottomRight: Radius.circular(isBottomRightCurved ? 40 : 10),
        ),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String image;
  final String text;

  const _TestimonialCard({required this.name, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(image)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFF86EFAC), size: 14),
                      Icon(Icons.star, color: Color(0xFF86EFAC), size: 14),
                      Icon(Icons.star, color: Color(0xFF86EFAC), size: 14),
                      Icon(Icons.star, color: Color(0xFF86EFAC), size: 14),
                      Icon(Icons.star, color: Color(0xFF86EFAC), size: 14),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.format_quote, size: 40, color: Colors.white10),
            ],
          ),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
