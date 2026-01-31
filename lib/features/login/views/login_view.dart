import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/app_strings.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/login/viewmodels/login_provider.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.watch(loginProvider.notifier);

    ref.listen(loginProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(loginProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return Container(
      margin: EdgeInsets.only(top: 100),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 370),
          child: ShadForm(
            key: loginState.formKey,
            autovalidateMode: ShadAutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Text(
                  AppStrings.begin,
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                Text(
                  'Version 1.0.1',
                  style: ShadTheme.of(context).textTheme.h2,
                ),
                ShadInputFormField(
                  label: Text(AppStrings.email),
                  placeholder: Text(AppStrings.emailExample),
                  controller: loginNotifier.emailController,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => loginNotifier.onFormSubmit(),
                  validator: (value) {
                    if (!EmailValidator.validate(value)) {
                      return AppStrings.emailInvalid;
                    }
                    return null;
                  },
                ),
                ShadInputFormField(
                  obscureText: loginState.isPasswordVisible,
                  trailing: ShadButton(
                    width: 24,
                    height: 24,
                    padding: EdgeInsets.zero,
                    child: Icon(
                      loginState.isPasswordVisible
                          ? LucideIcons.eyeOff
                          : LucideIcons.eye,
                    ),
                    onPressed: () {
                      loginNotifier.togglePasswordVisibility();
                    },
                  ),
                  label: Text(AppStrings.password),
                  placeholder: Text(AppStrings.passwordExample),
                  controller: loginNotifier.passwordController,
                  onSubmitted: (_) => loginNotifier.onFormSubmit(),
                  validator: (value) {
                    if (value.isEmpty) return AppStrings.passwordRequired;
                    if (value.length < 6) {
                      return AppStrings.passwordMinLength;
                    }
                    return null;
                  },
                ),
                ShadButton(
                  child: Text(AppStrings.loginButton),
                  onPressed: () => loginNotifier.onFormSubmit(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
