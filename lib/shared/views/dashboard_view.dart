import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oftal_web/shared/providers/providers.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.read(authProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          Text('Dashboard'),
        ],
      ),
    );
  }
}
