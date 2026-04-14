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
