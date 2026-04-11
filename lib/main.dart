import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/sales_controller.dart';
import 'view/sales_widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SalesController(),
      child: const SalesInsightApp(),
    ),
  );
}

class SalesInsightApp extends StatelessWidget {
  const SalesInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Vendas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF194C51)),
        scaffoldBackgroundColor: const Color(0xFFF2F3F5),
        useMaterial3: true,
      ),
      home: const SalesDashboardPage(),
    );
  }
}
