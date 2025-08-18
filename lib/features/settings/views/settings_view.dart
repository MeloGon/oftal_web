import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 370),
          child: ShadForm(
            autovalidateMode: ShadAutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Text(
                  'Configuración',
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                Text(
                  'Configuración',
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                Text(
                  'Configuración',
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                Text(
                  'Configuración',
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                Text(
                  'Configuración',
                  style: ShadTheme.of(context).textTheme.h1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
