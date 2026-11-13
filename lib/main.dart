import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';

class AcessibilidadeController extends ChangeNotifier {
  final StorageService _storage = StorageService();
  bool _modoEscuro = false;
  double _escalaFonte = 1.0;

  bool get modoEscuro => _modoEscuro;
  double get escalaFonte => _escalaFonte;

  Future<void> carregar() async {
    final dados = await _storage.carregarAcessibilidade();
    _modoEscuro = dados.modoEscuro;
    _escalaFonte = dados.escalaFonte;
    notifyListeners();
  }

  Future<void> alternarTema(bool escuro) async {
    _modoEscuro = escuro;
    notifyListeners();
    await _storage.salvarAcessibilidade(
      modoEscuro: _modoEscuro,
      escalaFonte: _escalaFonte,
    );
  }

  Future<void> alterarEscalaFonte(double escala) async {
    _escalaFonte = escala;
    notifyListeners();
    await _storage.salvarAcessibilidade(
      modoEscuro: _modoEscuro,
      escalaFonte: _escalaFonte,
    );
  }
}

final acessibilidadeCtrl = AcessibilidadeController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await acessibilidadeCtrl.carregar();
  runApp(const ReservaLaboApp());
}

class ReservaLaboApp extends StatelessWidget {
  const ReservaLaboApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color.fromARGB(255, 29, 114, 74);

    return ListenableBuilder(
      listenable: acessibilidadeCtrl,
      builder: (context, _) {
        return MaterialApp(
          title: 'Reserva de Laboratórios IFPA',
          debugShowCheckedModeBanner: false,
          themeMode: acessibilidadeCtrl.modoEscuro
              ? ThemeMode.dark
              : ThemeMode.light,
          themeAnimationDuration: const Duration(milliseconds: 450),
          themeAnimationCurve: Curves.easeInOutCubic,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(acessibilidadeCtrl.escalaFonte),
              ),
              child: child!,
            );
          },
          home: const LoginScreen(),
        );
      },
    );
  }
}

void abrirMenuAcessibilidade(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => ListenableBuilder(
      listenable: acessibilidadeCtrl,
      builder: (context, _) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.accessibility_new),
            SizedBox(width: 8),
            Text('Acessibilidade'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Modo Escuro'),
              subtitle: const Text('Reduz o brilho da tela'),
              secondary: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  acessibilidadeCtrl.modoEscuro
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  key: ValueKey(acessibilidadeCtrl.modoEscuro),
                ),
              ),
              value: acessibilidadeCtrl.modoEscuro,
              onChanged: (val) => acessibilidadeCtrl.alternarTema(val),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Tamanho do Texto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1.0, label: Text('Normal')),
                ButtonSegment(value: 1.15, label: Text('Grande')),
                ButtonSegment(value: 1.3, label: Text('Extra')),
              ],
              selected: {acessibilidadeCtrl.escalaFonte},
              onSelectionChanged: (sel) =>
                  acessibilidadeCtrl.alterarEscalaFonte(sel.first),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Concluir'),
          ),
        ],
      ),
    ),
  );
}