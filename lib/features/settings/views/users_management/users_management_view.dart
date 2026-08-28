import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/users_management_provider.dart';
import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Solo accesible para el rol `megadmin` (ver [AuthorizationRole.megadmin]
/// en `authorization_service.dart`, gateado desde `settings_view.dart`).
class UsersManagementView extends ConsumerWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersManagementProvider);
    final notifier = ref.read(usersManagementProvider.notifier);

    ref.listen(usersManagementProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Aviso', type: SnackbarEnum.info),
          next.errorMessage,
        );
        Future.microtask(notifier.clearErrorMessage);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              const Text(
                'Gestionar usuarios',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.zinc900,
                ),
              ),
              Text(
                'Restablece la contraseña de cualquier usuario sin depender de su email',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (state.isLoading && state.users.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (state.users.isEmpty)
            const EmptyState(label: 'No hay usuarios registrados')
          else
            Column(
              spacing: 12,
              children: [
                for (final user in state.users)
                  _UserRow(
                    user: user,
                    loading: state.isLoading,
                    onResetPassword:
                        () => _showResetPasswordDialog(context, user, notifier),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _showResetPasswordDialog(
    BuildContext context,
    ProfileModel user,
    UsersManagement notifier,
  ) {
    return showShadDialog<void>(
      context: context,
      builder: (context) => _ResetPasswordDialog(user: user, notifier: notifier),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.loading,
    required this.onResetPassword,
  });

  final ProfileModel user;
  final bool loading;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.zinc200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  user.name?.isNotEmpty == true ? user.name! : 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc900,
                  ),
                ),
                Text(
                  user.email?.isNotEmpty == true ? user.email! : 'Sin email',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  '${user.branchName ?? '-'} · ${user.role ?? '-'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          ShadButton.outline(
            onPressed: loading ? null : onResetPassword,
            child: const Text('Restablecer contraseña'),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.user, required this.notifier});

  final ProfileModel user;
  final UsersManagement notifier;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden.');
      return;
    }

    final userId = widget.user.id;
    if (userId == null) {
      setState(() => _errorMessage = 'Usuario inválido.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final ok = await widget.notifier.resetPassword(
      userId: userId,
      newPassword: password,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo restablecer la contraseña.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      closeIcon: const SizedBox.shrink(),
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.sizeOf(context).width * 0.85).clamp(280, 420),
      ),
      title: const Text('Restablecer contraseña'),
      description: Text('Nueva contraseña para ${widget.user.name ?? 'este usuario'}.'),
      actions: [
        ShadButton(
          onPressed: _loading ? null : _submit,
          child:
              _loading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Guardar'),
        ),
        ShadButton.outline(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ShadInputFormField(
            label: const Text('Nueva contraseña'),
            controller: _passwordController,
            obscureText: _obscure,
            placeholder: const Text('••••••••'),
            trailing: ShadButton.ghost(
              width: 28,
              height: 28,
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 16,
                color: AppColors.zinc500,
              ),
            ),
          ),
          ShadInputFormField(
            label: const Text('Confirmar contraseña'),
            controller: _confirmController,
            obscureText: _obscure,
            placeholder: const Text('••••••••'),
            onSubmitted: (_) => _loading ? null : _submit(),
          ),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
