import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/utils/validators.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/features/auth/view/widgets/auth_layout.dart';
import 'package:physio_ghar/features/auth/view_model/auth_view_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final error = await ref
        .read(authProvider.notifier)
        .register(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
        );
    if (!mounted || error == null) return;
    setState(() {
      _isLoading = false;
      _error = switch (error) {
        RegisterError.emailTaken =>
          'An account with this email already exists. Try logging in.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final toggle = passwordVisibilityToggle(
      isHidden: _hidePassword,
      onToggle: () => setState(() => _hidePassword = !_hidePassword),
    );

    return authLayout(
      title: 'Create account',
      subtitle: 'Join PhysioGhar to receive home and clinic bookings.',
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
                  label: 'Full name',
                  isRequired: true,
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  maxLength: 60,
                  validator: validateName,
                ),
                const SizedBox(height: AppSpacing.md),
                appTextField(
                  label: 'Email',
                  isRequired: true,
                  controller: _email,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                appTextField(
                  label: 'Phone',
                  isRequired: true,
                  controller: _phone,
                  prefixIcon: Icons.phone_outlined,
                  hint: '98XXXXXXXX',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                  ],
                  validator: validatePhone,
                ),
                const SizedBox(height: AppSpacing.md),
                appTextField(
                  label: 'Password',
                  isRequired: true,
                  controller: _password,
                  prefixIcon: Icons.lock_outline_rounded,
                  helperText:
                      'At least 8 characters, with a letter and a number',
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  suffix: toggle,
                  validator: validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),
                appTextField(
                  label: 'Confirm password',
                  isRequired: true,
                  controller: _confirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _password.text ? "Passwords don't match" : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                appButton(
                  label: 'Create account',
                  icon: Icons.person_add_alt_1_rounded,
                  expand: true,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        authSwitchLink(
          prompt: 'Already have an account?',
          action: 'Log in',
          onTap: () => context.go(AppRoutes.login),
        ),
      ],
    );
  }
}
