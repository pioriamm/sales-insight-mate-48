import 'package:flutter/material.dart';

import '../../../controller/sales_controller.dart';

class HeroPanel extends StatelessWidget {
  HeroPanel({required this.controller});

  final SalesController controller;

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
            if (controller.sales.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
