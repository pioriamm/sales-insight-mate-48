import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/sales_controller.dart';
import '../models/cost_catalog_item.dart';

class CostCatalogPage extends StatefulWidget {
  const CostCatalogPage({super.key});

  @override
  State<CostCatalogPage> createState() => _CostCatalogPageState();
}

class _CostCatalogPageState extends State<CostCatalogPage> {
  static const int _itemsPerPage = 30;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;
    setState(() => _currentPage -= 1);
  }

  void _goToNextPage(int totalPages) {
    if (_currentPage >= totalPages - 1) return;
    setState(() => _currentPage += 1);
  }

  void _ensureCurrentPageIsValid(int totalPages) {
    final int lastPageIndex = totalPages - 1;
    if (_currentPage <= lastPageIndex) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentPage = lastPageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de custos'),
      ),
      body: Consumer<SalesController>(
        builder: (context, controller, _) {
          final sortedItems = [...controller.catalogItems]
            ..sort(
              (a, b) => a.descricao.toLowerCase().compareTo(
                    b.descricao.toLowerCase(),
                  ),
            );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final int insertedCount = await controller.importCatalogFromJson();
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
                  horizontal: MediaQuery.sizeOf(context).width * 0.20,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar item da lista',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                      _currentPage = 0;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.20,
                  ),
                  child: _buildCatalogList(context, sortedItems),
                ),
              ),
            ],
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

  Widget _buildCatalogList(BuildContext context, List<CostCatalogItem> sortedItems) {
    final filteredItems = sortedItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.descricao.toLowerCase().contains(_searchQuery);
    }).toList();

    final int totalPages = filteredItems.isEmpty
        ? 1
        : ((filteredItems.length - 1) ~/ _itemsPerPage) + 1;
    _ensureCurrentPageIsValid(totalPages);

    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredItems.length,
    );
    final pagedItems = filteredItems.sublist(startIndex, endIndex);

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text('Nenhum item encontrado para a pesquisa informada.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: pagedItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = pagedItems[index];
              final TextStyle? itemTextStyle = Theme.of(context).textTheme.titleMedium;

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
              'Página ${_currentPage + 1} de $totalPages • ${filteredItems.length} itens',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _currentPage == 0 ? null : _goToPreviousPage,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
            ),
            IconButton(
              onPressed: _currentPage >= totalPages - 1
                  ? null
                  : () => _goToNextPage(totalPages),
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
        const SnackBar(content: Text('Lista de custos atualizada com sucesso.')),
      );
    }
  }
}
