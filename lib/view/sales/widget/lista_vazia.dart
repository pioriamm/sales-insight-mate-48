import 'package:flutter/material.dart';

import '../../../controller/sales_controller.dart';

class Listavazia extends StatelessWidget {
  const Listavazia({required this.controller});

  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 100),
        child: Text(
          'Nenhuma planilha importada ainda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
