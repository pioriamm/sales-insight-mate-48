import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_insight_mate/view/sales/widget/side_actions_drawer.dart';

import '../controller/cost_catalog_page_controller.dart';
import '../controller/sales_controller.dart';
import '../models/cost_catalog_item.dart';

class CostCatalogPage extends StatefulWidget {
  const CostCatalogPage({super.key});

  @override
  State<CostCatalogPage> createState() => _CostCatalogPageState();
}

class _CostCatalogPageState extends State<CostCatalogPage> {
  bool _isDrawerCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CostCatalogPageController(),
      child: _CostCatalogPageView(
        isDrawerCollapsed: _isDrawerCollapsed,
        onToggleDrawer: () => setState(
          () => _isDrawerCollapsed = !_isDrawerCollapsed,
        ),
      ),
    );
  }
}

class _CostCatalogPageView extends StatelessWidget {
  const _CostCatalogPageView({
    required this.isDrawerCollapsed,
    required this.onToggleDrawer,
  });

  final bool isDrawerCollapsed;
  final VoidCallback onToggleDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<SalesController, CostCatalogPageController>(
        builder: (context, salesController, pageController, _) {
          final sortedItems =
              pageController.getSortedItems(salesController.catalogItems);
          final pageData = pageController.getPageData(sortedItems);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SideActionsDrawer(
                  controller: salesController,
                  isCollapsed: isDrawerCollapsed,
                  onToggle: onToggleDrawer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const _CatalogHeroPanel(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final int insertedCount =
                                    await salesController
                                        .importCatalogFromJson();
                                if (!context.mounted) return;
                                final String message = insertedCount == 1
                                    ? '1 item importado do JSON.'
                                    : '$insertedCount itens importados do JSON.';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                              icon: const Icon(Icons.file_upload_outlined),
                              label: const Text('Importar JSON'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: sortedItems.isEmpty
                                  ? null
                                  : () => _confirmClearCatalog(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              icon: const Icon(Icons.delete_sweep_outlined),
                              label: const Text('Limpar base'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.sizeOf(context).width * 0.12,
                        ),
                        child: TextField(
                          controller: pageController.searchController,
                          decoration: InputDecoration(
                            hintText: 'Pesquisar item da lista',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onChanged: pageController.onSearchChanged,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.sizeOf(context).width * 0.12,
                          ),
                          child:
                              _buildCatalogList(context, pageData, pageController),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCatalogList(
    BuildContext context,
    CostCatalogPageData pageData,
    CostCatalogPageController pageController,
  ) {
    if (pageData.filteredItems.isEmpty) {
      return const Center(
        child: Text('Nenhum item encontrado para a pesquisa informada.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: pageData.pagedItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = pageData.pagedItems[index];
              final TextStyle? itemTextStyle =
                  Theme.of(context).textTheme.titleMedium;

              return ListTile(
                title: Text(
                  item.descricao.toUpperCase(),
                  style: itemTextStyle,
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    Text(
                      'R\$ ${item.custo.toStringAsFixed(2)}',
                      style: itemTextStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openEditDialog(context, item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDeleteItem(context, item),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Página ${pageData.currentPage + 1} de ${pageData.totalPages} • ${pageData.filteredItems.length} itens',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: pageData.currentPage == 0
                  ? null
                  : pageController.goToPreviousPage,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
            ),
            IconButton(
              onPressed: pageData.currentPage >= pageData.totalPages - 1
                  ? null
                  : () => pageController.goToNextPage(pageData.totalPages),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Próxima página',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDeleteItem(BuildContext context, CostCatalogItem item) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir item'),
          content: Text('Deseja excluir "${item.descricao}" da base de custos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    await context.read<SalesController>().deleteCatalogItem(item.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item excluído com sucesso.')),
    );
  }

  Future<void> _confirmClearCatalog(BuildContext context) async {
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar base de custos'),
          content: const Text('Deseja remover todos os itens do banco de custos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpar base'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !context.mounted) return;

    await context.read<SalesController>().clearCatalog();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Base de custos limpa com sucesso.')),
    );
  }

  Future<void> _openEditDialog(BuildContext context, {CostCatalogItem? item}) async {
    final descricaoCtrl = TextEditingController(text: item?.descricao ?? '');
    final custoCtrl =
        TextEditingController(text: item == null ? '' : item.custo.toStringAsFixed(2));

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
        const SnackBar(content: Text('Lista de custos atualizada com sucesso.')),
      );
    }
  }
}

class _CatalogHeroPanel extends StatelessWidget {
  const _CatalogHeroPanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF194C51),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cadastro de custo',
              style: TextStyle(fontSize: 36, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Gerencie e mantenha a base de custos atualizada.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
