import 'package:flutter/material.dart';
import '../../../models/sales_parser.dart';
import '../utils/currency_formatter.dart';
import 'editable_field.dart';

class SummaryCardCustos extends StatefulWidget {
  const SummaryCardCustos({
    super.key,
    required this.summary,
    required this.currency,
    required this.onChange,
  });

  final SummaryData summary;
  final CurrencyFormatter currency;
  final void Function(String field, double value) onChange;

  @override
  State<SummaryCardCustos> createState() => _SummaryCardCustosState();
}

class _SummaryCardCustosState extends State<SummaryCardCustos> {
  final List<_FieldItem> extraFields = [];

  Future<void> _addFieldDialog() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo campo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nome do campo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() {
        extraFields.add(
          _FieldItem(
            key: name.toUpperCase(),
            label: name.toUpperCase(),
            value: 0,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dispesas Adicionais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: _addFieldDialog,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF194C51),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 🔹 Campos fixos
            _editRow('antecipacao', 'ANTECIPAÇÃO', widget.summary.antecipacao),
            const Divider(),
            _editRow('publicidade', 'PUBLICIDADE', widget.summary.publicidade),
            const Divider(),
            _editRow('simples', 'SIMPLES', widget.summary.simples),
            const Divider(),
            _editRow('tarifasFull', 'TARIFAS FULL', widget.summary.tarifasFull),
            const Divider(),
            _editRow('pagina', 'PÁGINA', widget.summary.pagina),

            /// 🔹 Campos dinâmicos
            if (extraFields.isNotEmpty) const Divider(),

            ...List.generate(extraFields.length, (index) {
              final item = extraFields[index];
              final isLast = index == extraFields.length - 1;

              return Column(
                children: [
                  _editRow(item.key, item.label, item.value),
                  if (!isLast) const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _editRow(String field, String label, double value) {
    return EditableField(
      label: label,
      initialValue: value,
      onSubmit: (v) => widget.onChange(field, v),
    );
  }
}

class _FieldItem {
  final String key;
  final String label;
  double value;

  _FieldItem({
    required this.key,
    required this.label,
    required this.value,
  });
}