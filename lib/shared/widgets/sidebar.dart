import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Container(
      width: 200,
      height: double.infinity,
      decoration: buildBoxDecoration(),
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          Logo(),
          TextSeparator(text: 'Opciones'),
          MenuItem(
            text: 'Nuevo paciente',
            icon: Icons.add_reaction_outlined,
            onPressed: () {
              ref.read(appRouterProvider).go(RouterName.addPatient);
            },
            isActive: navigationState.currentPage == RouterName.addPatient,
          ),
          MenuItem(
            text: 'Vender',
            icon: Icons.sell_outlined,
            onPressed: () {
              ref.read(appRouterProvider).go(RouterName.sell);
            },
            isActive: navigationState.currentPage == RouterName.sell,
          ),
          MenuItem(
            text: 'Configuración',
            icon: Icons.settings_outlined,
            onPressed: () {
              ref.read(appRouterProvider).go(RouterName.settings);
            },
            isActive: navigationState.currentPage == RouterName.settings,
          ),
        ],
      ),
    );
  }

  BoxDecoration buildBoxDecoration() => BoxDecoration(
    gradient: LinearGradient(colors: [Colors.black, Colors.black54]),
    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
  );
}
