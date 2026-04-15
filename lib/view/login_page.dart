import 'dart:async';
import 'dart:math';

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
                        padding: const EdgeInsets.all(18),
                        child: const _RestrictedAccessPanel(),
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

class _RestrictedAccessPanel extends StatelessWidget {
  const _RestrictedAccessPanel();

  static const List<String> _restrictedImages = [
    'https://images.unsplash.com/photo-1577563908411-5077b6dc7624?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1533106418989-88406c7cc8ca?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1625047509168-a7026f36de04?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1471478331149-c72f17e33c73?auto=format&fit=crop&w=1200&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _RestrictedImageCarousel(imagePool: _restrictedImages),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.45),
                ],
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Acesso restrito',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestrictedImageCarousel extends StatefulWidget {
  const _RestrictedImageCarousel({required this.imagePool});

  final List<String> imagePool;

  @override
  State<_RestrictedImageCarousel> createState() => _RestrictedImageCarouselState();
}

class _RestrictedImageCarouselState extends State<_RestrictedImageCarousel> {
  static const Duration _transitionDuration = Duration(milliseconds: 950);
  static const Duration _changeInterval = Duration(seconds: 3);

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.imagePool.length > 1) {
      _timer = Timer.periodic(_changeInterval, (_) {
        if (!mounted) return;
        setState(() {
          _index = (_index + 1) % widget.imagePool.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _transitionDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Image.network(
        widget.imagePool[_index],
        key: ValueKey(widget.imagePool[_index]),
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Container(color: const Color(0xFFDDDDDD)),
      ),
    );
  }
}

class _HeroImageMosaic extends StatelessWidget {
  const _HeroImageMosaic();

  static const List<String> _animatedImages = [
    'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1615906655593-ad0386982a0f?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1613214149922-f1809c99b414?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1514316454349-750a7fd3da3a?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1616788494672-ec7ca25fdda9?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1526726538690-5cbf956ae2fd?auto=format&fit=crop&w=900&q=80',
  ];

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
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?auto=format&fit=crop&w=900&q=80',
                  top: 170,
                  left: -20,
                  width: 210,
                  height: 330,
                ),
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1615906655593-ad0386982a0f?auto=format&fit=crop&w=900&q=80',
                  top: 320,
                  left: 185,
                  width: 250,
                  height: 350,
                ),
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80',
                  top: 435,
                  left: 460,
                  width: 250,
                  height: 340,
                ),
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=900&q=80',
                  top: 560,
                  left: 720,
                  width: 230,
                  height: 260,
                ),
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1613214149922-f1809c99b414?auto=format&fit=crop&w=900&q=80',
                  top: 320,
                  right: 180,
                  width: 240,
                  height: 380,
                ),
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1514316454349-750a7fd3da3a?auto=format&fit=crop&w=900&q=80',
                  top: 170,
                  right: -30,
                  width: 210,
                  height: 330,
                ),
                _AnimatedMosaicImage(
                  imagePool: _animatedImages,
                  initialImageUrl:
                      'https://images.unsplash.com/photo-1616788494672-ec7ca25fdda9?auto=format&fit=crop&w=900&q=80',
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

class _AnimatedMosaicImage extends StatefulWidget {
  const _AnimatedMosaicImage({
    required this.imagePool,
    required this.initialImageUrl,
    required this.top,
    this.left,
    this.right,
    required this.width,
    required this.height,
  });

  final List<String> imagePool;
  final String initialImageUrl;
  final double top;
  final double? left;
  final double? right;
  final double width;
  final double height;

  @override
  State<_AnimatedMosaicImage> createState() => _AnimatedMosaicImageState();
}

class _AnimatedMosaicImageState extends State<_AnimatedMosaicImage> {
  static const Duration _transitionDuration = Duration(milliseconds: 900);
  static const int _minSwapSeconds = 2;
  static const int _maxSwapSeconds = 6;

  final Random _random = Random();
  Timer? _swapTimer;
  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
    _scheduleNextSwap();
  }

  @override
  void dispose() {
    _swapTimer?.cancel();
    super.dispose();
  }

  void _swapImage() {
    if (!mounted || widget.imagePool.length < 2) return;
    final options =
        widget.imagePool.where((image) => image != _currentImageUrl).toList();
    final nextImage = options[_random.nextInt(options.length)];
    setState(() => _currentImageUrl = nextImage);
    _scheduleNextSwap();
  }

  void _scheduleNextSwap() {
    final seconds = _minSwapSeconds + _random.nextInt(_maxSwapSeconds - _minSwapSeconds + 1);
    _swapTimer?.cancel();
    _swapTimer = Timer(Duration(seconds: seconds), _swapImage);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedSwitcher(
            duration: _transitionDuration,
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Image.network(
              _currentImageUrl,
              key: ValueKey(_currentImageUrl),
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => Container(
                width: widget.width,
                height: widget.height,
                color: const Color(0xFFE4E4E4),
              ),
            ),
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
