import 'package:flutter/material.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class Sidebar extends StatelessWidget {
  // void navigateTo(String routeName) {
  //   NavigationService.replaceTo(routeName);
  //   SideMenuProvider.closeMenu();
  // }

  @override
  Widget build(BuildContext context) {
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
            text: 'Buscar paciente',
            icon: Icons.search_rounded,
            onPressed: () {},
            // onPressed: () => navigateTo(Flurorouter.dashboardRoute),
            // isActive:
            //     sideMenuProvider.currentPage == Flurorouter.dashboardRoute,
          ),

          MenuItem(
            text: 'Nuevo paciente',
            icon: Icons.add_reaction_outlined,
            onPressed: () {},
          ),
          MenuItem(
            text: 'Configuración',
            icon: Icons.settings_outlined,
            onPressed: () {},
          ),

          MenuItem(
            text: 'Agenda',
            icon: Icons.contacts_outlined,
            onPressed: () {},
            // onPressed: () => navigateTo(Flurorouter.categoriesRoute),
            // isActive:
            //     sideMenuProvider.currentPage == Flurorouter.categoriesRoute,
          ),
          SizedBox(height: 30),
          TextSeparator(text: 'UI Elements'),
          MenuItem(
            text: 'Blank',
            icon: Icons.post_add_outlined,
            onPressed: () {},
            // onPressed: () => navigateTo(Flurorouter.blankRoute),
            // isActive: sideMenuProvider.currentPage == Flurorouter.blankRoute,
          ),

          SizedBox(height: 50),
          TextSeparator(text: 'Exit'),
          MenuItem(
            text: 'Logout',
            icon: Icons.exit_to_app_outlined,
            onPressed: () {},
            // onPressed: () {
            //   Provider.of<AuthProvider>(context, listen: false).logout();
            // },
          ),
        ],
      ),
    );
  }

  BoxDecoration buildBoxDecoration() => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xff092044),
        Color(0xff092042),
      ],
    ),
    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
  );
}
