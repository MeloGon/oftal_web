import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    ref.read(sideMenuProvider(this).notifier);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final state = ref.watch(sideMenuProvider(this));
    final menu = ref.read(sideMenuProvider(this).notifier);

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
                    Navbar(onMenuTap: menu.openMenu),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),

          if (size.width < 700)
            AnimatedBuilder(
              animation: menu.controller,
              builder:
                  (context, _) => Stack(
                    children: [
                      if (state.isOpen)
                        Opacity(
                          opacity: menu.opacity.value,
                          child: GestureDetector(
                            onTap: menu.closeMenu,
                            child: Container(
                              width: size.width,
                              height: size.height,
                              color: Colors.black26,
                            ),
                          ),
                        ),
                      Transform.translate(
                        offset: Offset(menu.movement.value, 0),
                        child: Sidebar(),
                      ),
                    ],
                  ),
            ),
        ],
      ),
    );
  }
}
