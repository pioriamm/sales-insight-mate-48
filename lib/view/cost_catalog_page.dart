import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/sales_controller.dart';
import '../models/hive_cost_item.dart';

class CostCatalogPage extends StatelessWidget {
  const CostCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banco de custos (Hive)')),
      body: Consumer<SalesController>(
        builder: (context, controller, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showImportJsonDialog(context, controller),
                      icon: const Icon(Icons.data_object),
                      label: const Text('Importar JSON'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showEditDialog(context, controller),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo item'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Itens cadastrados: ${controller.catalogItems.length}'),
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    child: ListView.separated(
                      itemCount: controller.catalogItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = controller.catalogItems[index];
                        return ListTile(
                          title: Text(item.descricao),
                          subtitle: Text('ID: ${item.id}'),
                          trailing: TextButton.icon(
                            onPressed: () => _showEditDialog(context, controller, item: item),
                            icon: const Icon(Icons.edit),
                            label: Text('R\$ ${item.custo.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showImportJsonDialog(BuildContext context, SalesController controller) async {
    final textController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Importar JSON'),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: textController,
              maxLines: 12,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '[{"id":"1","descricao":"Produto X","custo":49.9}]',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await controller.importCatalogFromJson(textController.text);
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON importado com sucesso.')));
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON inválido. Verifique o formato.')));
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    SalesController controller, {
    HiveCostItem? item,
  }) async {
    final descricaoController = TextEditingController(text: item?.descricao ?? '');
    final custoController = TextEditingController(
      text: item == null ? '' : item.custo.toStringAsFixed(2),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item == null ? 'Novo item' : 'Editar item'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: custoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Custo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final custo = double.tryParse(custoController.text.replaceAll(',', '.')) ?? 0;
                await controller.saveCatalogItem(
                  id: item?.id,
                  descricao: descricaoController.text,
                  custo: custo,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
