import 'package:flutter/material.dart';
import 'package:oftal_web/shared/services/authorization_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Muestra un dialog que solicita credenciales de un supervisor o admin.
/// Retorna `true` si la autorización fue exitosa, `false` en caso contrario.
Future<bool> showAuthorizationDialog({
  required BuildContext context,
  required AuthorizationRole requiredRole,
  String? actionName,
}) async {
  final result = await showShadDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => _AuthorizationDialogContent(
          requiredRole: requiredRole,
          actionName: actionName,
        ),
  );
  return result ?? false;
}

class _AuthorizationDialogContent extends StatefulWidget {
  const _AuthorizationDialogContent({
    required this.requiredRole,
    this.actionName,
  });

  final AuthorizationRole requiredRole;
  final String? actionName;

  @override
  State<_AuthorizationDialogContent> createState() =>
      _AuthorizationDialogContentState();
}

class _AuthorizationDialogContentState
    extends State<_AuthorizationDialogContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  String get _roleLabel =>
      widget.requiredRole == AuthorizationRole.admin
          ? 'administrador'
          : 'supervisor';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Ingresa email y contraseña.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final authorized = await AuthorizationService.authorize(
      email: email,
      password: password,
      requiredRole: widget.requiredRole,
    );

    if (!mounted) return;

    if (authorized) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _loading = false;
        _errorMessage = 'Credenciales incorrectas o rol insuficiente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      closeIcon: const SizedBox.shrink(),
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.sizeOf(context).width * 0.85).clamp(280, 480),
      ),
      title: const Text('Autorización requerida'),
      description: Text(
        widget.actionName != null
            ? 'Para ${widget.actionName} se requieren credenciales de $_roleLabel.'
            : 'Ingresa las credenciales de un $_roleLabel para continuar.',
      ),
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
                  : const Text('Autorizar'),
        ),
        ShadButton.outline(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ShadInputFormField(
            label: const Text('Email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            placeholder: const Text('supervisor@ejemplo.com'),
          ),
          ShadInputFormField(
            label: const Text('Contraseña'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            placeholder: const Text('••••••••'),
            onSubmitted: (_) => _loading ? null : _submit(),
            trailing: ShadButton.ghost(
              width: 28,
              height: 28,
              padding: EdgeInsets.zero,
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
                color: const Color(0xff71717A),
              ),
            ),
          ),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xffEF4444),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
