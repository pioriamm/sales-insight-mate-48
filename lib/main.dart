import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/sales_controller.dart';

import 'firebase_options.dart';
import 'view/sales_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final controller = SalesController();
  await controller.init();

  runApp(
    ChangeNotifierProvider.value(
      value: controller,
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
