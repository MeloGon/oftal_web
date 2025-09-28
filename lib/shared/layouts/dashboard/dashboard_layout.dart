import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/providers/navigation/navigation_provider.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final navigationState = ref.watch(navigationProvider);
    final navigationNotifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xffEDF1F2),
      body: Stack(
        children: [
          Row(
            children: [
              if (size.width >= 700) Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    Navbar(onMenuTap: navigationNotifier.openMenu),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (size.width < 700)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                navigationState.isMenuOpen ? 0 : -210,
                0,
                0,
              ),
              child: Stack(
                children: [
                  if (navigationState.isMenuOpen)
                    Opacity(
                      opacity: navigationState.isMenuOpen ? 1.0 : 0.0,
                      child: GestureDetector(
                        onTap: navigationNotifier.closeMenu,
                        child: Container(
                          width: size.width,
                          height: size.height,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  Sidebar(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
