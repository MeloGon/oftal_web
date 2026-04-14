import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/app_strings.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/login/viewmodels/login_provider.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _kBrand = Color(0xff7A6BF5);

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: ShadForm(
            key: _formKey,
            autovalidateMode: ShadAutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                // ─── Header ──────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _kBrand.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bubble_chart_outlined,
                            color: _kBrand,
                            size: 20,
                          ),
                        ),
                        const Text(
                          'OFTALWEB',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: Color(0xff18181B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.begin,
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                    Text(
                      'Ingresa tus credenciales para continuar',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                // ─── Fields ──────────────────────────────────
                Column(
                  spacing: 16,
                  children: [
                    ShadInputFormField(
                      label: Text(AppStrings.email),
                      placeholder: Text(AppStrings.emailExample),
                      controller: loginNotifier.emailController,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted:
                          (_) => loginNotifier.onFormSubmit(
                            isValid: _formKey.currentState?.validate() ?? false,
                          ),
                      validator: (value) {
                        if (!EmailValidator.validate(value)) {
                          return AppStrings.emailInvalid;
                        }
                        return null;
                      },
                    ),
                    ShadInputFormField(
                      obscureText: loginState.isPasswordVisible,
                      trailing: ShadButton.ghost(
                        width: 28,
                        height: 28,
                        padding: EdgeInsets.zero,
                        onPressed: loginNotifier.togglePasswordVisibility,
                        child: Icon(
                          loginState.isPasswordVisible
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 16,
                        ),
                      ),
                      label: Text(AppStrings.password),
                      placeholder: Text(AppStrings.passwordExample),
                      controller: loginNotifier.passwordController,
                      onSubmitted:
                          (_) => loginNotifier.onFormSubmit(
                            isValid: _formKey.currentState?.validate() ?? false,
                          ),
                      validator: (value) {
                        if (value.isEmpty) return AppStrings.passwordRequired;
                        if (value.length < 6) {
                          return AppStrings.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                // ─── Submit ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed:
                        loginState.isLoading
                            ? null
                            : () => loginNotifier.onFormSubmit(
                              isValid:
                                  _formKey.currentState?.validate() ?? false,
                            ),
                    child:
                        loginState.isLoading
                            ? const AppSpinner(size: 16, color: Colors.white)
                            : Text(AppStrings.loginButton),
                  ),
                ),

                // ─── Version ─────────────────────────────────
                Center(
                  child: Text(
                    'v1.0.1',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
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
