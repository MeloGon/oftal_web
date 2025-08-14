import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class Sidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final navigationNotifier = ref.read(navigationProvider.notifier);

    void navigateTo(String routeName) {
      // Usar el nuevo sistema de navegación
      navigationNotifier.navigateTo(routeName);

      // Navegar usando el router
      Navigator.pushNamed(context, routeName);
    }

    return Container(
      width: 200,
      height: double.infinity,
      decoration: buildBoxDecoration(),
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          // Logo(),
          SizedBox(height: 50),

          TextSeparator(text: 'Opciones'),

          MenuItem(
            text: 'Dashboard',
            icon: Icons.dashboard_outlined,
            onPressed: () => navigateTo(Flurorouter.dashboardRoute),
            isActive: currentPage == Flurorouter.dashboardRoute,
          ),

          MenuItem(
            text: 'Nuevo paciente',
            icon: Icons.add_reaction_outlined,
            onPressed: () => navigateTo(Flurorouter.addPatientRoute),
            isActive: currentPage == Flurorouter.addPatientRoute,
          ),

          MenuItem(
            text: 'Buscar paciente',
            icon: Icons.search_rounded,
            onPressed: () {},
            // isActive: currentPage == Flurorouter.searchRoute,
          ),

          MenuItem(
            text: 'Configuración',
            icon: Icons.settings_outlined,
            onPressed: () {},
            // isActive: currentPage == Flurorouter.settingsRoute,
          ),

          MenuItem(
            text: 'Agenda',
            icon: Icons.contacts_outlined,
            onPressed: () {},
            // isActive: currentPage == Flurorouter.agendaRoute,
          ),

          SizedBox(height: 30),
          TextSeparator(text: 'UI Elements'),
          MenuItem(
            text: 'Blank',
            icon: Icons.post_add_outlined,
            onPressed: () {},
            // isActive: currentPage == Flurorouter.blankRoute,
          ),

          SizedBox(height: 50),
          TextSeparator(text: 'Exit'),
          MenuItem(
            text: 'Logout',
            icon: Icons.exit_to_app_outlined,
            onPressed: () {
              // TODO: Implementar logout
              // navigationNotifier.setAuthenticationStatus(false);
            },
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
