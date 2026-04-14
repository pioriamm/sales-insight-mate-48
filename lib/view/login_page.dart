import 'package:flutter/material.dart';

import 'sales_dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _validUser = 'lem';
  static const _validPassword = 'jomimar';
  static const _heroImages = <String>[
    'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1472162072942-cd5147eb3902?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1520698857293-5d763dde010f?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1485546246426-74dc88dec4d9?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1526634332515-d56c5fd16991?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=700&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          const Positioned.fill(child: _HeroImageMosaic(images: _heroImages)),
          Column(
            children: [
              Container(
                height: 88,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      'L&M Peças e Acessórios',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Color(0xFF194C51),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _openLoginPopup(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF194C51),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Gerencie suas vendas\ncom praticidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1B2D),
                    height: 1.1,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF1F1F1).withOpacity(0.2),
                      const Color(0xFFF1F1F1).withOpacity(0.92),
                    ],
                    radius: 1.15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLoginPopup(BuildContext context) async {
    final userController = TextEditingController();
    final passwordController = TextEditingController();
    var hidePassword = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 920),
                padding: const EdgeInsets.all(28),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bem-vindo(a)',
                            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 24),
                          const Text('Usuário', style: TextStyle(fontSize: 28)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: userController,
                            decoration: const InputDecoration(
                              hintText: 'Usuario',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(22)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text('Senha', style: TextStyle(fontSize: 28)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: InputDecoration(
                              hintText: 'senha',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(22)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => hidePassword = !hidePassword),
                                icon: Icon(
                                  hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF194C51),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              onPressed: () {
                                final userOk = userController.text.trim() == _validUser;
                                final passOk = passwordController.text.trim() == _validPassword;
                                if (!userOk || !passOk) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Usuário ou senha inválidos.'),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const SalesDashboardPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Container(
                        height: 560,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(34),
                        ),
                        alignment: Alignment.center,
                        child: const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Acesso restrito',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeroImageMosaic extends StatelessWidget {
  const _HeroImageMosaic({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        children: [
          const SizedBox(width: 8),
          _MosaicColumn(
            tiles: [
              _MosaicTileConfig(imageUrl: images[0], height: 340),
              _MosaicTileConfig(imageUrl: images[1], height: 220),
              _MosaicTileConfig(imageUrl: images[2], height: 190),
            ],
          ),
          const SizedBox(width: 16),
          _MosaicColumn(
            topPadding: 130,
            tiles: [
              _MosaicTileConfig(imageUrl: images[3], height: 250),
              _MosaicTileConfig(imageUrl: images[4], height: 270),
            ],
          ),
          const Spacer(),
          _MosaicColumn(
            topPadding: 240,
            tiles: [
              _MosaicTileConfig(imageUrl: images[5], height: 220),
              _MosaicTileConfig(imageUrl: images[6], height: 270),
            ],
          ),
          const SizedBox(width: 16),
          _MosaicColumn(
            tiles: [
              _MosaicTileConfig(imageUrl: images[7], height: 280),
              _MosaicTileConfig(imageUrl: images[0], height: 240),
              _MosaicTileConfig(imageUrl: images[1], height: 210),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _MosaicColumn extends StatelessWidget {
  const _MosaicColumn({required this.tiles, this.topPadding = 0});

  final List<_MosaicTileConfig> tiles;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          for (final tile in tiles) ...[
            _MosaicImageTile(tile: tile),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _MosaicImageTile extends StatelessWidget {
  const _MosaicImageTile({required this.tile});

  final _MosaicTileConfig tile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 220,
        height: tile.height,
        child: Image.network(
          tile.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE6E7EB),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined, size: 34),
          ),
        ),
      ),
    );
  }
}

class _MosaicTileConfig {
  const _MosaicTileConfig({required this.imageUrl, required this.height});

  final String imageUrl;
  final double height;
}
