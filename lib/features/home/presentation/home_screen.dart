import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header (Logo + Actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'SERCIO',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => context.push('/chat'),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Hero Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'TU PLATAFORMA DE SERVICIOS PROFESIONALES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 32,
                          ),
                          children: [
                            const TextSpan(text: '¿Qué necesitas '),
                            TextSpan(
                              text: 'hoy?',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Encontrá al profesional ideal cerca tuyo. Electricistas, plomeros, diseñadores y más — todo en un solo lugar.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Busca servicios, profesionales, productos...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Buscar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Categories Carousel
              _SectionTitle(title: 'Carrusel de Categorías', onSeeAll: () => context.push('/categories')),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _CategoryIcon(title: 'Interior Design', icon: Icons.palette, color: Colors.purple),
                    _CategoryIcon(title: 'Engineering', icon: Icons.handyman, color: Colors.blue),
                    _CategoryIcon(title: 'Smart Systems', icon: Icons.memory, color: Colors.teal),
                    _CategoryIcon(title: 'Paisajismo', icon: Icons.eco, color: Colors.green),
                    _CategoryIcon(title: 'Urbanismo', icon: Icons.map, color: Colors.orange),
                    _CategoryIcon(title: 'Iluminación', icon: Icons.lightbulb, color: Colors.yellow),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Imperdible Promotions
              _SectionTitle(title: 'Promociones Imperdibles', onSeeAll: () {}),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _PromoCard(
                      title: 'Gran Inauguración',
                      subtitle: 'Carlos Plomería',
                      tag: '30% OFF',
                      imageUrl: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                    ),
                    _PromoCard(
                      title: 'Combo Limpieza',
                      subtitle: 'Limpieza Profunda Ana',
                      tag: '2x1',
                      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Bank Promotions
              _SectionTitle(title: 'Promociones Bancarias de Hoy', onSeeAll: () {}),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _BankPromoCard(bank: 'Banco Galicia', discount: '20% OFF', day: 'Lunes'),
                    _BankPromoCard(bank: 'Banco Santander', discount: '3 Cuotas Sin Interés', day: 'Lunes'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Services Near You
              _SectionTitle(title: 'Servicios Cerca de Ti', onSeeAll: () => context.push('/services')),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _ServiceCard(title: 'Reparación de AA', price: '\$50', rating: '4.8'),
                    _ServiceCard(title: 'Instalación Eléctrica', price: '\$80', rating: '4.9'),
                    _ServiceCard(title: 'Pintura Interior', price: '\$120', rating: '4.7'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Featured Professionals
              _SectionTitle(title: 'Profesionales Destacados', onSeeAll: () {}),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _ProCard(name: 'Julian Vargas', role: 'Arquitecto de Interiores', rating: '4.9', jobs: '128'),
                    _ProCard(name: 'Elena Rossi', role: 'Diseñadora UX/UI', rating: '5.0', jobs: '84'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // App Products
              _SectionTitle(title: 'Productos de la App', onSeeAll: () => context.push('/products')),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _ProductCard(title: 'Kit de Herramientas Básicas', price: '\$25.00', imageUrl: 'https://images.unsplash.com/photo-1540104539506-614777519504?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80'),
                    _ProductCard(title: 'Pintura Interior 20L', price: '\$45.00', imageUrl: 'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Reels
              _SectionTitle(title: 'Reels y Trabajos Recientes', onSeeAll: () => context.push('/reels')),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _ReelThumbnail(),
                    _ReelThumbnail(),
                    _ReelThumbnail(),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Fab space
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const _ProductCard({required this.title, required this.price, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Text(price, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionTitle({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Ver todo >',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryIcon({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;

  const _PromoCard({required this.title, required this.subtitle, required this.tag, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(tag, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BankPromoCard extends StatelessWidget {
  final String bank;
  final String discount;
  final String day;

  const _BankPromoCard({required this.bank, required this.discount, required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance, color: theme.colorScheme.primary),
          const Spacer(),
          Text(bank, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$discount - $day', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String price;
  final String rating;

  const _ServiceCard({required this.title, required this.price, required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.grey,
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(rating, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  final String name;
  final String role;
  final String rating;
  final String jobs;

  const _ProCard({required this.name, required this.role, required this.rating, required this.jobs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/specialist'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(role, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.work_outline, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(jobs, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReelThumbnail extends StatelessWidget {
  const _ReelThumbnail();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/reels'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black87,
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1542044896530-05d85be9b11a?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          ),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
        ),
      ),
    );
  }
}
