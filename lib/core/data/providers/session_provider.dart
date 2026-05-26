// lib/core/data/providers/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notifiers/auth_notifier.dart';

/// Modelo que contiene información resumida de la sesión del usuario.
class SessionInfo {
  final String name;
  final String email;
  final bool isProfessional;
  final bool hasProfessionalSubscription;
  final String? plan; // e.g., 'free', 'standard', 'premium'
  final bool isActive; // overall session active flag

  const SessionInfo({
    required this.name,
    required this.email,
    required this.isProfessional,
    required this.hasProfessionalSubscription,
    this.plan,
    required this.isActive,
  });
}

/// Provider que expone [SessionInfo] calculado a partir de [authNotifierProvider].
///
/// La lógica replica la del frontend web (AuthContext) para determinar si el
/// usuario tiene una suscripción profesional activa.
final sessionInfoProvider = Provider<SessionInfo>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final session = authState.session ?? {};
  final user = session['user'] as Map<String, dynamic>?;
  final sessionStatus = session['sessionStatus'] as Map<String, dynamic>?;

  // Nombre y email
  final name = sessionStatus?['full_name'] ??
      user?['user_metadata']?['full_name'] ??
      'Usuario';
  final email = user?['email'] ?? '';

  // Determinar el id profesional (si lo hay)
  final professionalId =
      (sessionStatus?['subscription']?['professional_id'] as int?) ??
          (sessionStatus?['professional_id'] as int?);
  final isProfessional = professionalId != null;

  // Lógica de suscripción activa (similar a la web)
  final bool hasProfessionalSubscription = (() {
    final bool isProf = sessionStatus?['is_professional'] == true;
    final bool professionalActive =
        sessionStatus?['professional_active'] == true;
    final String? subStatus =
        sessionStatus?['subscription']?['status'] as String?;
    return isProf && (professionalActive || subStatus == 'active');
  })();

  // Plan y activo global
  final String? plan = sessionStatus?['subscription']?['plan'] as String?;
  final bool isActive = sessionStatus?['professional_active'] == true;

  return SessionInfo(
    name: name,
    email: email,
    isProfessional: isProfessional,
    hasProfessionalSubscription: hasProfessionalSubscription,
    plan: plan,
    isActive: isActive,
  );
});
