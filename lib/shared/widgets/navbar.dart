import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/providers/providers.dart';

class Navbar extends ConsumerWidget {
  const Navbar({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authProvider);
    return Container(
      width: double.infinity,
      height: 50,
      decoration: buildBoxDecoration(),
      child: Row(
        children: [
          if (size.width <= 700)
            IconButton(
              icon: const Icon(Icons.menu_outlined),
              onPressed: onMenuTap,
            ),

          const SizedBox(width: 5),

          if (size.width > 390)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Text(
                'Bienvenid@, ${authState.profile?.name ?? ''}',
                style: ShadTheme.of(context).textTheme.h3,
              ),
            ).paddingOnly(left: 15),

          const Spacer(),
          // const NotificationsIndicator(),
          const SizedBox(width: 10),
          // const NavbarAvatar(),
          const SizedBox(width: 10),
        ],
      ),
    ).paddingAll(15);
  }

  BoxDecoration buildBoxDecoration() => const BoxDecoration(
    color: Colors.white,
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
}
