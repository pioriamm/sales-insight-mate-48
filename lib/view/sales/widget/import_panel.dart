import 'package:flutter/material.dart';

import '../../../controller/sales_controller.dart';

class ImportPanel extends StatelessWidget {
  const ImportPanel({required this.controller});

  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Nenhuma planilha importada ainda'),
        ),
      ),
    );
  }
}