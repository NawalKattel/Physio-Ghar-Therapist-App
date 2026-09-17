import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/validators.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/features/auth/view/widgets/auth_layout.dart';
import 'package:physio_ghar/features/auth/view_model/auth_view_model.dart';

const _demoEmail = 'aarati.joshi@example.com';
const _demoPassword = 'physio123';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final ok = await ref
        .read(authProvider.notifier)
        .login(email: _email.text, password: _password.text);
    if (!mounted || ok) return;
    setState(() {
      _isLoading = false;
      _error = 'Incorrect email or password. Please try again.';
    });
  }

  void _useDemoAccount() {
    _email.text = _demoEmail;
    _password.text = _demoPassword;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return authLayout(
      title: 'Welcome back',
      subtitle: 'Log in to manage your sessions, schedule and patients.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  authErrorBanner(_error!),
                  const SizedBox(height: AppSpacing.md),
                ],
                appTextField(
                  label: 'Email',
                  controller: _email,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                appTextField(
                  label: 'Password',
                  controller: _password,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  suffix: passwordVisibilityToggle(
                    isHidden: _hidePassword,
                    onToggle: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                  validator: (v) => validateRequired(v, 'Enter your password'),
                ),
                const SizedBox(height: AppSpacing.xl),
                appButton(
                  label: 'Log in',
                  icon: Icons.login_rounded,
                  expand: true,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _demoHint(onUse: _isLoading ? null : _useDemoAccount),
        const SizedBox(height: AppSpacing.md),
        authSwitchLink(
          prompt: "Don't have an account?",
          action: 'Create one',
          onTap: () => context.go(AppRoutes.register),
        ),
      ],
    );
  }
}

Widget _demoHint({required VoidCallback? onUse}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.xs,
      AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.pinePale,
      borderRadius: AppRadius.fieldBorder,
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.pine),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Demo account\n$_demoEmail · $_demoPassword',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink),
          ),
        ),
        TextButton(
          onPressed: onUse,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pine,
            minimumSize: const Size(kMinTapTarget, kMinTapTarget),
            textStyle: AppTextStyles.label,
          ),
          child: const Text('Use'),
        ),
      ],
    ),
  );
}
