import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';

Widget appDropdownField<T>({
  Key? key,
  required String label,
  required List<T> items,
  required String Function(T item) itemLabel,
  required ValueChanged<T?> onChanged,
  T? initialValue,
  String? hint,
  FormFieldValidator<T>? validator,
  IconData? prefixIcon,
  bool isRequired = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      appFieldLabel(label, isRequired: isRequired),
      DropdownButtonFormField<T>(
        key: key,
        initialValue: initialValue,
        validator: validator,
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.inkMid,
        ),
        style: AppTextStyles.bodyLarge,
        dropdownColor: Colors.white,
        borderRadius: AppRadius.fieldBorder,
        decoration: appInputDecoration(hint: hint, prefixIcon: prefixIcon),
        items: [
          for (final item in items)
            DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
        ],
      ),
    ],
  );
}
