import 'package:flutter/material.dart';

import '../../../controller/sales_controller.dart';
import '../../cost_catalog_page.dart';

class SideActionsDrawer extends StatelessWidget {
  const SideActionsDrawer({
    super.key,
    required this.controller,
    required this.isCollapsed,
    required this.onToggle,
  });

  final SalesController controller;
  final bool isCollapsed;
  final VoidCallback onToggle;

  static const double _expandedWidth = 250;
  static const double _collapsedWidth = 84;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      width: isCollapsed ? _collapsedWidth : _expandedWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF194C51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: isCollapsed ? Alignment.center : Alignment.centerRight,
              child: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                  color: Colors.white,
                ),
                tooltip: isCollapsed ? 'Expandir menu' : 'Recolher menu',
              ),
            ),
            const SizedBox(height: 8),
            _DrawerActionButton(
              isCollapsed: isCollapsed,
              icon: Icons.upload_file,
              label: 'Importar vendas',
              onPressed: controller.isLoadingAny
                  ? null
                  : () => controller.pickSalesFile(context),
            ),
            const SizedBox(height: 12),
            _DrawerActionButton(
              isCollapsed: isCollapsed,
              icon: Icons.list_alt,
              label: 'Lista de custos',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CostCatalogPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerActionButton extends StatelessWidget {
  const _DrawerActionButton({
    required this.isCollapsed,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool isCollapsed;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF194C51),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: isCollapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            if (!isCollapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
