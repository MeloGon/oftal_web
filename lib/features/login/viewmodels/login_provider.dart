import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/login/viewmodels/login_notifier.dart';
import 'package:oftal_web/features/login/viewmodels/login_state.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) {
    return LoginNotifier();
  },
);
