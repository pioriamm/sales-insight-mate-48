import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CarPartsMosaic extends StatelessWidget {
  const CarPartsMosaic({super.key});

  static const List<_CarPartTileData> _tiles = [
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?auto=format&fit=crop&w=900&q=80',
      label: 'Volante esportivo',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1615906655593-ad0386982a0f?auto=format&fit=crop&w=900&q=80',
      label: 'Farol de LED',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80',
      label: 'Roda de liga leve',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=900&q=80',
      label: 'Disco de freio',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1613214149922-f1809c99b414?auto=format&fit=crop&w=900&q=80',
      label: 'Painel automotivo',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1514316454349-750a7fd3da3a?auto=format&fit=crop&w=900&q=80',
      label: 'Retrovisor premium',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1616788494672-ec7ca25fdda9?auto=format&fit=crop&w=900&q=80',
      label: 'Suspensão reforçada',
    ),
    _CarPartTileData(
      imageUrl:
          'https://images.unsplash.com/photo-1526726538690-5cbf956ae2fd?auto=format&fit=crop&w=900&q=80',
      label: 'Motor em destaque',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Encontre sua próxima',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1B2D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'peça automotiva para vender',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F8B79),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              for (final tile in _tiles)
                _CarPartImageTile(
                  initialTile: tile,
                  allTiles: _tiles,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarPartImageTile extends StatefulWidget {
  const _CarPartImageTile({
    required this.initialTile,
    required this.allTiles,
  });

  final _CarPartTileData initialTile;
  final List<_CarPartTileData> allTiles;

  @override
  State<_CarPartImageTile> createState() => _CarPartImageTileState();
}

class _CarPartImageTileState extends State<_CarPartImageTile> {
  static const Duration _fadeDuration = Duration(seconds: 5);

  final Random _random = Random();
  late _CarPartTileData _currentTile;
  Timer? _swapTimer;

  @override
  void initState() {
    super.initState();
    _currentTile = widget.initialTile;
    _swapTimer = Timer.periodic(_fadeDuration, (_) => _swapToRandomTile());
  }

  @override
  void dispose() {
    _swapTimer?.cancel();
    super.dispose();
  }

  void _swapToRandomTile() {
    if (!mounted || widget.allTiles.length < 2) {
      return;
    }

    final options =
        widget.allTiles.where((tile) => tile.imageUrl != _currentTile.imageUrl).toList();
    final nextTile = options[_random.nextInt(options.length)];

    setState(() {
      _currentTile = nextTile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 210,
        height: 210,
        child: AnimatedSwitcher(
          duration: _fadeDuration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Stack(
            key: ValueKey(_currentTile.imageUrl),
            fit: StackFit.expand,
            children: [
              Image.network(
                _currentTile.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF194C51).withOpacity(0.08),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.48),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _currentTile.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarPartTileData {
  const _CarPartTileData({
    required this.imageUrl,
    required this.label,
  });

  final String imageUrl;
  final String label;
}
