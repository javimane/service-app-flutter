import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String? initialMessage;

  const ChatScreen({super.key, required this.chatId, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFE85D35); // Naranja de la imagen

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: primaryColor,
                  child: Text(
                    'JV',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E), // Verde online
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Julian Vargas',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    'En línea • Arquitecto & Diseñador',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {},
            color: Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
            color: Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: Colors.grey[600],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? Colors.white10 : Colors.black12,
            height: 1,
          ),
        ),
      ),
      body: CustomPaint(
        painter: _DottedBackgroundPainter(
          color: isDark
              ? Colors.white10
              : Colors.black.withAlpha((0.05 * 255).round()),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                children: [
                  // Fecha
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color:
                                  Colors.black.withAlpha((0.02 * 255).round()),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        'MARTES, 24 OCT',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Mensaje Recibido
                  _buildReceivedMessage(
                    text:
                        '¡Hola! Acabo de finalizar los conceptos estructurales del proyecto Obsidian Tower. ¿Te gustaría revisar los renders 3D iniciales ahora?',
                    time: '10:42 AM',
                    isDark: isDark,
                  ),
                  SizedBox(height: 24.h),

                  // Mensaje Enviado
                  _buildSentMessage(
                    text:
                        'Suena perfecto, Julian. La precisión arquitectónica es exactamente lo que buscamos. Adelante, compártelos.',
                    time: '10:42 AM',
                    isRead: true,
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 24.h),

                  // Mensaje Recibido con Tarjeta
                  _buildCardMessage(
                    time: '10:45 AM',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            _buildBottomInput(isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage({
    required String text,
    required String time,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: 60.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(4.r), // Punta de burbuja
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha((0.03 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildSentMessage({
    required String text,
    required String time,
    required bool isRead,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(left: 60.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(4.r), // Punta de burbuja
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha((0.3 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '$time - ${isRead ? 'LEÍDO' : 'ENVIADO'}',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardMessage({
    required String time,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: 40.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(4.r),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha((0.03 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenido de la Tarjeta
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFFF0EC), // Fondo naranja muy claro
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFFFA58C),
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Vista del Proyecto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Entrada del lobby',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Aquí tienes un adelanto de la entrada principal del lobby. Observa cómo el acabado de obsidiana interactúa con las matrices de luz lavanda.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInput(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {},
              color: Colors.grey[500],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.transparent,
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    Icon(Icons.mic_none, color: Colors.grey[400], size: 20.r),
                    SizedBox(width: 12.w),
                    Icon(Icons.sentiment_satisfied_alt,
                        color: Colors.grey[400], size: 20.r),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha((0.4 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
                color: Colors.white,
                iconSize: 20.r,
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  final Color color;

  _DottedBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
