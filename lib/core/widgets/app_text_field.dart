import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

Widget appFieldLabel(String text, {bool isRequired = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text.rich(
      TextSpan(
        text: text,
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.danger),
            ),
        ],
      ),
      style: AppTextStyles.label,
    ),
  );
}

InputDecoration appInputDecoration({
  String? hint,
  String? helperText,
  IconData? prefixIcon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: AppRadius.fieldBorder,
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    helperText: helperText,
    helperMaxLines: 2,
    errorMaxLines: 2,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: AppColors.inkMid),
    suffixIcon: suffix,
    hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMute),
    helperStyle: AppTextStyles.bodySmall,
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
    counterStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.inkMute),
    enabledBorder: border(AppColors.mist, 1.5),
    focusedBorder: border(AppColors.pine, 1.5),
    errorBorder: border(AppColors.danger, 1.5),
    focusedErrorBorder: border(AppColors.danger, 2),
    disabledBorder: border(AppColors.mist),
  );
}

Widget appTextField({
  Key? key,
  required String label,
  TextEditingController? controller,
  String? initialValue,
  String? hint,
  String? helperText,
  FormFieldValidator<String>? validator,
  ValueChanged<String>? onChanged,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  List<TextInputFormatter>? inputFormatters,
  IconData? prefixIcon,
  int? maxLength,
  int? minLines,
  int? maxLines = 1,
  bool enabled = true,
  bool isRequired = false,
  Iterable<String>? autofillHints,
  TextCapitalization textCapitalization = TextCapitalization.none,
  bool obscureText = false,
  Widget? suffix,
  ValueChanged<String>? onFieldSubmitted,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      appFieldLabel(label, isRequired: isRequired),
      TextFormField(
        key: key,
        controller: controller,
        initialValue: initialValue,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        minLines: minLines,
        maxLines: maxLines,
        enabled: enabled,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        enableSuggestions: !obscureText,
        autocorrect: !obscureText,
        onFieldSubmitted: onFieldSubmitted,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: AppTextStyles.bodyLarge,
        cursorColor: AppColors.pine,
        decoration: appInputDecoration(
          hint: hint,
          helperText: helperText,
          prefixIcon: prefixIcon,
          suffix: suffix,
        ),
      ),
    ],
  );
}
