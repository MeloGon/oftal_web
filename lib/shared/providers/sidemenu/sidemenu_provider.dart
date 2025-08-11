import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/sidemenu/sidemenu_notifier.dart';
import 'package:oftal_web/shared/providers/sidemenu/sidemenu_state.dart';

final sideMenuProvider = StateNotifierProvider.autoDispose
    .family<SideMenuNotifier, SideMenuState, TickerProvider>((ref, vsync) {
      final notifier = SideMenuNotifier(vsync: vsync);
      ref.onDispose(() => notifier.dispose());
      return notifier;
    });
