import 'package:flutter/material.dart';

import 'sales_dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _validUser = 'lem';
  static const _validPassword = 'jomimar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          const Positioned.fill(child: _HeroImageMosaic()),
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
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SlideDot(active: false),
                  SizedBox(width: 10),
                  _SlideDot(active: true),
                  SizedBox(width: 10),
                  _SlideDot(active: false),
                ],
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
                      Colors.transparent,
                      const Color(0xFF194C51).withOpacity(0.07),
                    ],
                    radius: 1.2,
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
  const _HeroImageMosaic();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final opacity = screenWidth < 1100 ? 0.45 : 0.9;

          return Opacity(
            opacity: opacity,
            child: Stack(
              children: const [
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80',
                  top: 170,
                  left: -20,
                  width: 210,
                  height: 330,
                ),
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1516627315008-c1f67bb83249?auto=format&fit=crop&w=700&q=80',
                  top: 320,
                  left: 185,
                  width: 250,
                  height: 350,
                ),
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1478860409698-8707f313ee8b?auto=format&fit=crop&w=700&q=80',
                  top: 435,
                  left: 460,
                  width: 250,
                  height: 340,
                ),
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1542816417-098367b6eb42?auto=format&fit=crop&w=700&q=80',
                  top: 560,
                  left: 720,
                  width: 230,
                  height: 260,
                ),
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1516627436130-0b09740f14f6?auto=format&fit=crop&w=700&q=80',
                  top: 320,
                  right: 180,
                  width: 240,
                  height: 380,
                ),
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=700&q=80',
                  top: 170,
                  right: -30,
                  width: 210,
                  height: 330,
                ),
                _MosaicImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80',
                  top: 500,
                  right: -15,
                  width: 210,
                  height: 280,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MosaicImage extends StatelessWidget {
  const _MosaicImage({
    required this.imageUrl,
    required this.top,
    this.left,
    this.right,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double top;
  final double? left;
  final double? right;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => Container(
            width: width,
            height: height,
            color: const Color(0xFFE4E4E4),
          ),
        ),
      ),
    );
  }
}

class _SlideDot extends StatelessWidget {
  const _SlideDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF5B9D87) : const Color(0xFFD3D3D3),
        shape: BoxShape.circle,
      ),
    );
  }
}
