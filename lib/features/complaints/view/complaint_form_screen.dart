import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/validators.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_dropdown_field.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/complaints/view_model/complaints_view_model.dart';

class ComplaintFormScreen extends ConsumerStatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  ConsumerState<ComplaintFormScreen> createState() =>
      _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends ConsumerState<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  ComplaintCategory? _category;
  bool _isSubmitting = false;
  bool _isDone = false;

  bool get _hasChanges =>
      _category != null ||
      _subject.text.isNotEmpty ||
      _description.text.isNotEmpty;

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(
        context,
        'Please fix the highlighted fields',
        isError: true,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final complaint = await ref
        .read(complaintsProvider.notifier)
        .submit(
          category: _category!,
          subject: _subject.text,
          description: _description.text,
        );
    if (!mounted) return;

    _isDone = true;
    context.pushReplacement(AppRoutes.complaintSubmitted(complaint.id));
  }

  Future<void> _confirmDiscard() async {
    final discard = await showAppConfirmDialog(
      context: context,
      title: 'Discard this complaint?',
      message: "What you've written won't be sent.",
      confirmLabel: 'Discard',
      cancelLabel: 'Keep writing',
      isDestructive: true,
    );
    if (discard && mounted) {
      _isDone = true;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    void onChanged(String _) => setState(() {});

    return PopScope(
      canPop: _isDone || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: Text('New complaint', style: AppTextStyles.title),
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        body: Form(
          key: _formKey,
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
                    Text(
                      'Sent to the PhysioGhar admin team.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.inkMid,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    appDropdownField<ComplaintCategory>(
                      label: 'Category',
                      isRequired: true,
                      hint: 'Choose a category',
                      items: ComplaintCategory.values,
                      itemLabel: (c) => c.label,
                      initialValue: _category,
                      onChanged: (value) => setState(() => _category = value),
                      validator: (value) =>
                          value == null ? 'Please choose a category' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    appTextField(
                      label: 'Subject',
                      isRequired: true,
                      controller: _subject,
                      hint: 'e.g. Patient not at home for the visit',
                      maxLength: 80,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: onChanged,
                      validator: (v) =>
                          validateLength(v, min: 5, max: 80, field: 'subject'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    appTextField(
                      label: 'Description',
                      isRequired: true,
                      controller: _description,
                      hint: 'What happened, when, and who was involved?',
                      helperText: 'At least 20 characters',
                      minLines: 6,
                      maxLines: 12,
                      maxLength: 1000,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: onChanged,
                      validator: (v) => validateLength(
                        v,
                        min: 20,
                        max: 1000,
                        field: 'description',
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                label: 'Submit complaint',
                icon: Icons.send_rounded,
                expand: true,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
