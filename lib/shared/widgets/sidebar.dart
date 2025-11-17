import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Container(
      width: 230,
      height: double.infinity,
      decoration: buildBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Logo(),
          TextSeparator(text: 'Opciones'),
          MenuItem(
            text: 'Agregar paciente',
            icon: Icons.add_reaction_outlined,
            onPressed: () {
              ref.read(appRouterProvider).go(RouterName.addPatient);
            },
            isActive: navigationState.currentPage == RouterName.addPatient,
          ),
          MenuItem(
            text: 'Buscar paciente',
            icon: Icons.search_outlined,
            onPressed: () {
              ref.read(appRouterProvider).go(RouterName.searchPatient);
            },
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
            text: 'Ventas realizadas',
            icon: Icons.history_outlined,
            onPressed: () {
              ref.read(appRouterProvider).go(RouterName.salesHistory);
            },
            isActive: navigationState.currentPage == RouterName.salesHistory,
          ),
          if (ref.read(navigationProvider).isAdmin)
            MenuItem(
              text: 'Configuración',
              icon: Icons.settings_outlined,
              onPressed: () {
                ref.read(appRouterProvider).go(RouterName.settings);
              },
              isActive: navigationState.currentPage == RouterName.settings,
            ),
          Spacer(),
          MenuItem(
            text: 'Cerrar sesión',
            icon: Icons.login_outlined,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              ref.read(appRouterProvider).go(RouterName.login);
            },
          ).paddingOnly(bottom: 20),
        ],
      ),
    ).paddingOnly(top: 10, bottom: 10, left: 7, right: 7);
  }

  BoxDecoration buildBoxDecoration() => BoxDecoration(
    gradient: LinearGradient(colors: [Colors.black, Colors.black54]),
    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
    borderRadius: BorderRadius.all(
      Radius.circular(22),
    ),
  );
}
