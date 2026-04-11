import 'package:flutter/material.dart';

import '../../../controller/sales_controller.dart';
import '../../cost_catalog_page.dart';

class HeroPanel extends StatelessWidget {
  HeroPanel({required this.controller});

  late final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF194C51),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestão de Vendas',
            style: TextStyle(fontSize: 36, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Importe planilhas para análise automática.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              /// IMPORTAR CUSTOS
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isLoadingAny
                      ? null
                      : () => controller.pickCostFile(context),
                  child: const Text('Importar custos'),
                ),
              ),

              const SizedBox(width: 12),

              /// IMPORTAR VENDAS
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isLoadingAny
                      ? null
                      : () => controller.pickSalesFile(context),
                  child: const Text('Importar vendas'),
                ),
              ),


              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CostCatalogPage(),
                      ),
                    );
                  },
                  child: const Text('Banco Hive'),
                ),
              ),

              /// BOTÕES EXTRAS (SÓ QUANDO TEM DADOS)
              if (controller.sales.isNotEmpty) ...[
                const SizedBox(width: 12),

                /// EXPORTAR EXCEL
                IconButton(
                  onPressed:
                  controller.isLoadingAny ? null : controller.exportExcel,
                  icon: const Icon(Icons.download),
                  tooltip: 'Exportar Excel',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF194C51),
                  ),
                ),

                const SizedBox(width: 8),

                /// RESETAR
                IconButton(
                  onPressed:
                  controller.isLoadingAny ? null : controller.resetAll,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Resetar dados',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF194C51),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}