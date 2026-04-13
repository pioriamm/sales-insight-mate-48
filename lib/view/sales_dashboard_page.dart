
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_insight_mate/view/sales/table/sales_table.dart';
import 'package:sales_insight_mate/view/sales/utils/currency_formatter.dart';
import 'package:sales_insight_mate/view/sales/widget/hero_panel.dart';
import 'package:sales_insight_mate/view/sales/widget/lista_vazia.dart';
import 'package:sales_insight_mate/view/sales/widget/loading_overlay.dart';
import 'package:sales_insight_mate/view/sales/widget/summary_card_custos.dart';
import 'package:sales_insight_mate/view/sales/widget/card_resumo.dart';
import '../controller/sales_controller.dart';


class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  Future<void> _showAddCatalogDialog(
    BuildContext context,
    SalesController controller,
    int index,
    double custoAtual,
  ) async {
    final sale = controller.sales[index];
    final custoCtrl = TextEditingController(
      text: custoAtual > 0 ? custoAtual.toStringAsFixed(2) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar item ao banco de custos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sale.titulo,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: custoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custo',
                  hintText: '0,00',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final custo = double.tryParse(custoCtrl.text.replaceAll(',', '.')) ?? 0;
                if (custo <= 0) return;
                Navigator.of(dialogContext).pop(custo);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == null || result <= 0) return;
    await controller.addMissingSaleToCatalog(index, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SalesController>(
        builder: (context, controller, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeroPanel(controller: controller),
                      const SizedBox(height: 20),
                      if (controller.sales.isEmpty)
                        Listavazia(controller: controller)
                      else ...[
                        CardResumo(
                          summary: controller.summary,
                          currency: CurrencyFormatter(),
                          salesCount: controller.sales.length,
                        ),

                        const SizedBox(height: 25),

                        SummaryCardCustos(
                          summary: controller.summary,
                          currency: CurrencyFormatter(),
                          onChange: controller.updateManualField,
                        ),

                        const SizedBox(height: 16),

                        SalesTable(
                          sales: controller.sales,
                          currency: CurrencyFormatter(),
                          onUpdateRow: controller.updateRow,
                          onAddMissingCatalogItem: controller.addSaleItemToCatalog,
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              /// OVERLAY
              if (controller.isLoadingAny)
                Positioned.fill(
                  child: LoadingOverlay(
                    progress: controller.loadingProgress,
                    percent: controller.loadingPercent,
                    message: controller.loadingMessage,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

















