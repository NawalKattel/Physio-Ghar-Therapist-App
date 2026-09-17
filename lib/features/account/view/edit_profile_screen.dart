import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/validators.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/account/view_model/account_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, String> _initial;
  late final _name = TextEditingController();
  late final _phone = TextEditingController();
  late final _email = TextEditingController();
  late final _experience = TextEditingController();
  late final _specialization = TextEditingController();
  late final _address = TextEditingController();
  bool _isSaving = false;
  bool _isSaved = false;

  Map<String, TextEditingController> get _fields => {
    'name': _name,
    'phone': _phone,
    'email': _email,
    'experience': _experience,
    'specialization': _specialization,
    'address': _address,
  };

  bool get _hasChanges =>
      _fields.entries.any((e) => e.value.text != _initial[e.key]);

  @override
  void initState() {
    super.initState();
    final t = ref.read(therapistProvider);
    _initial = {
      'name': t.name,
      'phone': t.phone,
      'email': t.email,
      'experience': '${t.experienceYears}',
      'specialization': t.specialization,
      'address': t.address,
    };
    for (final MapEntry(:key, :value) in _fields.entries) {
      value.text = _initial[key]!;
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(
        context,
        'Please fix the highlighted fields',
        isError: true,
      );
      return;
    }
    setState(() => _isSaving = true);

    await saveProfile(
      ref,
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      experienceYears: _experience.text,
      specialization: _specialization.text,
      address: _address.text,
    );
    if (!mounted) return;

    _isSaved = true;
    showAppSnackBar(context, 'Profile updated');
    context.pop();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showAppConfirmDialog(
      context: context,
      title: 'Discard changes?',
      message: "Your profile changes haven't been saved.",
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      isDestructive: true,
    );
    if (discard && mounted) {
      _isSaved = true;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    void onChanged(String _) => setState(() {});

    return PopScope(
      canPop: _isSaved || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: Text(strings.editProfile, style: AppTextStyles.title),
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        body: Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                responsiveCenter(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.xs,
                    AppSpacing.pageGutter,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      appTextField(
                        label: 'Full name',
                        isRequired: true,
                        controller: _name,
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        maxLength: 60,
                        onChanged: onChanged,
                        validator: validateName,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      appTextField(
                        label: 'Phone',
                        isRequired: true,
                        controller: _phone,
                        prefixIcon: Icons.phone_outlined,
                        hint: '98XXXXXXXX',
                        helperText:
                            '10-digit mobile number starting with 97 or 98',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\s-]'),
                          ),
                        ],
                        onChanged: onChanged,
                        validator: validatePhone,
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
                        onChanged: onChanged,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      appTextField(
                        label: 'Experience (years)',
                        isRequired: true,
                        controller: _experience,
                        prefixIcon: Icons.workspace_premium_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: onChanged,
                        validator: validateExperience,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      appTextField(
                        label: 'Specialization',
                        isRequired: true,
                        controller: _specialization,
                        prefixIcon: Icons.medical_services_outlined,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 80,
                        onChanged: onChanged,
                        validator: validateRequired,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      appTextField(
                        label: 'Address',
                        isRequired: true,
                        controller: _address,
                        prefixIcon: Icons.place_outlined,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.fullStreetAddress],
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 120,
                        onChanged: onChanged,
                        validator: validateRequired,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.mist)),
          ),
          child: SafeArea(
            top: false,
            child: responsiveCenter(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.sm,
                AppSpacing.pageGutter,
                AppSpacing.sm,
              ),
              child: appButton(
                label: 'Save changes',
                icon: Icons.check_rounded,
                expand: true,
                isLoading: _isSaving,
                onPressed: _hasChanges ? _save : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
