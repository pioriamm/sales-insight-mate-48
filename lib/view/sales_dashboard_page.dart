
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


















