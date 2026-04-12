import 'package:flutter/material.dart';

import '../models/cost_catalog_item.dart';

class CostCatalogPageController extends ChangeNotifier {
  static const int itemsPerPage = 30;

  final TextEditingController searchController = TextEditingController();

  String _searchQuery = '';
  int _currentPage = 0;

  int get currentPage => _currentPage;

  List<CostCatalogItem> getSortedItems(List<CostCatalogItem> items) {
    final sorted = [...items]
      ..sort(
        (a, b) => a.descricao.toLowerCase().compareTo(
              b.descricao.toLowerCase(),
            ),
      );
    return sorted;
  }

  CostCatalogPageData getPageData(List<CostCatalogItem> sortedItems) {
    final filteredItems = sortedItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.descricao.toLowerCase().contains(_searchQuery);
    }).toList();

    final int totalPages = filteredItems.isEmpty
        ? 1
        : ((filteredItems.length - 1) ~/ itemsPerPage) + 1;

    _ensureCurrentPageIsValid(totalPages);

    final int startIndex = _currentPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage).clamp(0, filteredItems.length);
    final pagedItems = filteredItems.sublist(startIndex, endIndex);

    return CostCatalogPageData(
      filteredItems: filteredItems,
      pagedItems: pagedItems,
      totalPages: totalPages,
      currentPage: _currentPage,
    );
  }

  void onSearchChanged(String value) {
    _searchQuery = value.trim().toLowerCase();
    _currentPage = 0;
    notifyListeners();
  }

  void goToPreviousPage() {
    if (_currentPage == 0) return;
    _currentPage -= 1;
    notifyListeners();
  }

  void goToNextPage(int totalPages) {
    if (_currentPage >= totalPages - 1) return;
    _currentPage += 1;
    notifyListeners();
  }

  void _ensureCurrentPageIsValid(int totalPages) {
    final int lastPageIndex = totalPages - 1;
    if (_currentPage <= lastPageIndex) return;
    _currentPage = lastPageIndex;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class CostCatalogPageData {
  const CostCatalogPageData({
    required this.filteredItems,
    required this.pagedItems,
    required this.totalPages,
    required this.currentPage,
  });

  final List<CostCatalogItem> filteredItems;
  final List<CostCatalogItem> pagedItems;
  final int totalPages;
  final int currentPage;
}
