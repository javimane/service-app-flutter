import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/permission_service.dart';

class RequestPermissionsButton extends ConsumerWidget {
  const RequestPermissionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lock_open),
      label: const Text('Solicitar permisos'),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final results = await PermissionService.requestAll();
        final granted =
            results.entries.where((e) => e.value).map((e) => e.key).toList();
        final denied =
            results.entries.where((e) => !e.value).map((e) => e.key).toList();
        messenger.showSnackBar(SnackBar(
          content: Text(
              'Concedidos: ${granted.join(', ')}\nDenegados: ${denied.join(', ')}'),
          duration: const Duration(seconds: 4),
        ));
      },
    );
  }
}
