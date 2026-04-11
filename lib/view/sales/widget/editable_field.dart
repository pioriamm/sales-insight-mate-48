import 'package:flutter/material.dart';

class EditableField extends StatefulWidget {
  const EditableField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSubmit,
  });

  final String label;
  final double initialValue;
  final Function(double) onSubmit;

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.initialValue == 0
          ? ''
          : widget.initialValue.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(covariant EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// evita sobrescrever enquanto o usuário digita
    if (oldWidget.initialValue != widget.initialValue) {
      controller.text = widget.initialValue == 0
          ? ''
          : widget.initialValue.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    controller.dispose(); // 🔥 evita memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            onSubmitted: (text) {
              final value =
                  double.tryParse(text.replaceAll(',', '.')) ?? 0;
              widget.onSubmit(value);
            },
            decoration: const InputDecoration(
              hintText: '0,00',
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}