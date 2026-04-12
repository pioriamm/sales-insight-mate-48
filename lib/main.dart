import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controller/sales_controller.dart';
import 'firebase_options.dart';
import 'view/sales_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(SalesController.costCatalogBoxName);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
