import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_notifier.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
