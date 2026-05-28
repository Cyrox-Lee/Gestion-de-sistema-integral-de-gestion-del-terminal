import 'package:flutter/material.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/presentation/widgets/common/custom_button.dart';

class FormDialog extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String saveButtonText;

  const FormDialog({
    Key? key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.saveButtonText = 'Guardar',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...fields.asMap().entries.map((entry) {
              return Column(
                children: [
                  entry.value,
                  if (entry.key < fields.length - 1)
                    const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        CustomButton(
          label: saveButtonText,
          onPressed: () {
            onSave();
            Navigator.of(context).pop();
          },
          isLoading: isLoading,
          width: 100,
        ),
      ],
    );
  }
}
