import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/patients/view_model/notes_view_model.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/patients/view_model/patients_view_model.dart';

const _bodyHint = 'Patient reported…\n\nExercise:\n- …\n\nNext session:\n…';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.patientId, this.noteId});

  final String patientId;
  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final String _initialTitle;
  late final String _initialBody;
  bool _isSaving = false;
  bool _isSaved = false;

  bool get _isEditing => widget.noteId != null;

  bool get _hasChanges =>
      _title.text != _initialTitle || _body.text != _initialBody;

  @override
  void initState() {
    super.initState();
    final loaded = ref.read(appDataProvider).hasValue;
    final note = loaded && _isEditing
        ? ref.read(notesProvider.notifier).byId(widget.noteId!)
        : null;
    _initialTitle = note?.title ?? 'Session Note';
    _initialBody = note?.body ?? '';
    _title = TextEditingController(text: _initialTitle);
    _body = TextEditingController(text: _initialBody);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final added = await saveNote(
      ref,
      patientId: widget.patientId,
      noteId: widget.noteId,
      title: _title.text,
      body: _body.text,
    );
    if (!mounted) return;

    _isSaved = true;
    showAppSnackBar(context, added ? 'Note saved' : 'Note updated');
    context.pop();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showAppConfirmDialog(
      context: context,
      title: 'Discard changes?',
      message: "Your changes to this note haven't been saved.",
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
    final loaded = ref.watch(appDataProvider).hasValue;
    final patient = loaded
        ? ref.watch(patientByIdProvider(widget.patientId))
        : null;
    final noteMissing =
        loaded &&
        _isEditing &&
        ref.watch(notesProvider.notifier).byId(widget.noteId!) == null;

    return PopScope(
      canPop: _isSaved || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Edit note' : 'New note',
            style: AppTextStyles.title,
          ),
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        body: patient == null || noteMissing
            ? emptyState(
                icon: Icons.sticky_note_2_outlined,
                title: noteMissing ? 'Note not found' : 'Patient not found',
                actionLabel: 'Go back',
                onAction: () => context.pop(),
              )
            : Form(
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
                          appEyebrow(
                            'Note for ${ref.watch(stringsProvider).name(patient.name)}',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          appTextField(
                            label: 'Title',
                            isRequired: true,
                            controller: _title,
                            maxLength: 80,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (_) => setState(() {}),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Give the note a title'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          appTextField(
                            label: 'Note',
                            isRequired: true,
                            controller: _body,
                            hint: _bodyHint,
                            minLines: 10,
                            maxLines: 20,
                            maxLength: 2000,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (_) => setState(() {}),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Please write a note'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: patient == null || noteMissing
            ? null
            : DecoratedBox(
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
                      label: _isEditing ? 'Save changes' : 'Save note',
                      icon: Icons.check_rounded,
                      expand: true,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
