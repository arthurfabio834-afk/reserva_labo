import 'package:flutter/material.dart';
import '../main.dart';
import 'lista_laboratorios_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _senhaController = TextEditingController();
  bool _modoProfessor = false;
  bool _obscureText = true;

  static const String _senhaDocentePadrao = 'ifpa2026';

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  void _entrarComoAluno() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ListaLaboratoriosScreen(isProfessor: false),
      ),
    );
  }

  void _entrarComoProfessor() {
    if (_senhaController.text.trim() != _senhaDocentePadrao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha docente incorreta!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ListaLaboratoriosScreen(isProfessor: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.accessibility_new),
            tooltip: 'Acessibilidade (Tema e Fonte)',
            onPressed: () => abrirMenuAcessibilidade(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.computer_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ReservaLab IFPA',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecione seu perfil de acesso',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Aluno'),
                          icon: Icon(Icons.school_outlined),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Professor'),
                          icon: Icon(Icons.badge_outlined),
                        ),
                      ],
                      selected: {_modoProfessor},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _modoProfessor = selection.first;
                          _senhaController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    if (!_modoProfessor) ...[
                      const Text(
                        'Acesso livre para consulta dos laboratórios e do calendário semanal (Segunda a Domingo).',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _entrarComoAluno,
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Entrar como Aluno'),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _senhaController,
                        obscureText: _obscureText,
                        onSubmitted: (_) => _entrarComoProfessor(),
                        decoration: InputDecoration(
                          labelText: 'Senha Institucional',
                          hintText: 'Digite a senha de docente',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscureText = !_obscureText);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _entrarComoProfessor,
                          icon: const Icon(Icons.edit_calendar_outlined),
                          label: const Text('Entrar como Professor'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}