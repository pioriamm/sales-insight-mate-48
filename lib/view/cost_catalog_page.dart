import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/sales_controller.dart';
import '../models/cost_catalog_item.dart';

class CostCatalogPage extends StatelessWidget {
  const CostCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de custos (Hive)'),
      ),
      body: Consumer<SalesController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final inserted = await controller.importCatalogFromJson();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$inserted item(ns) importado(s) do JSON.')),
                        );
                      },
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Importar JSON'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openEditDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo item'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.catalogItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.catalogItems[index];
                    return ListTile(
                      title: Text(item.descricao),
                      subtitle: Text('ID: ${item.id}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Text('R\$ ${item.custo.toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openEditDialog(context, item: item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, {CostCatalogItem? item}) async {
    final descricaoCtrl = TextEditingController(text: item?.descricao ?? '');
    final custoCtrl = TextEditingController(text: item == null ? '' : item.custo.toStringAsFixed(2));

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Novo item' : 'Editar item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descricaoCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: custoCtrl,
                decoration: const InputDecoration(labelText: 'Custo'),
              ),
            ],
          ),
          actions: [
            if (item != null)
              TextButton(
                onPressed: () async {
                  await context.read<SalesController>().deleteCatalogItem(item.id);
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: const Text('Excluir'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final custo = double.tryParse(custoCtrl.text.replaceAll(',', '.')) ?? 0;
                final descricao = descricaoCtrl.text.trim();
                if (descricao.isEmpty) return;

                if (item == null) {
                  await context.read<SalesController>().addCatalogItem(descricao, custo);
                } else {
                  await context.read<SalesController>().updateCatalogItem(
                        item.copyWith(descricao: descricao, custo: custo),
                      );
                }

                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco Hive atualizado com sucesso.')),
      );
    }
  }
}
