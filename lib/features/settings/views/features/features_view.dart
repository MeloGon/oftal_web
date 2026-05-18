import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/settings/views/widgets/features_toggle_section.dart';

class FeaturesView extends ConsumerWidget {
  const FeaturesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // ─── Header ──────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              const Text(
                'Funcionalidades',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff18181B),
                ),
              ),
              Text(
                'Activa o desactiva funcionalidades del sistema',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),

          // ─── Section label ───────────────────────────────
          const Text(
            'Historial de ventas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff52525B),
              letterSpacing: 0.3,
            ),
          ),

          // ─── Toggles ─────────────────────────────────────
          const FeaturesToggleSection(),
        ],
      ),
    );
  }
}
