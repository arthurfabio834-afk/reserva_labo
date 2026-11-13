import 'package:flutter/material.dart';
import '../main.dart';
import '../models/laboratorio.dart';
import '../services/reserva_service.dart';
import 'form_laboratorio_screen.dart';
import 'grade_semanal_screen.dart';
import 'login_screen.dart';
import 'minhas_reservas_screen.dart';
import 'nova_reserva_screen.dart';

class ListaLaboratoriosScreen extends StatefulWidget {
  final bool isProfessor;

  const ListaLaboratoriosScreen({
    super.key,
    required this.isProfessor,
  });

  @override
  State<ListaLaboratoriosScreen> createState() =>
      _ListaLaboratoriosScreenState();
}

class _ListaLaboratoriosScreenState extends State<ListaLaboratoriosScreen> {
  final ReservaService _service = ReservaService();
  bool _carregando = true;
  String? _recursoFiltro;

  static const List<String> _filtrosDisponiveis = [
    'Projetor',
    'Ar-condicionado',
    'Wi-Fi',
    'Bancadas',
    'Roteadores',
  ];

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await _service.inicializar();
    setState(() => _carregando = false);
  }

  void _sair() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _abrirFormLaboratorio([Laboratorio? lab]) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormLaboratorioScreen(
          service: _service,
          laboratorioEdicao: lab,
        ),
      ),
    );
    if (salvou == true) setState(() {});
  }

  Future<void> _confirmarExclusaoLab(Laboratorio lab) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Laboratório'),
        content: Text(
          'Deseja remover "${lab.nome}" e todas as reservas associadas a ele?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _service.removerLaboratorio(lab.id);
      setState(() {});
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'Em Manutenção':
        return Colors.orange;
      case 'Restrito':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labsFiltrados = _recursoFiltro == null
        ? _service.laboratorios
        : _service.laboratorios
            .where((l) => l.recursos.contains(_recursoFiltro))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isProfessor
              ? 'Laboratórios (Professor)'
              : 'Laboratórios (Aluno)',
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined),
            tooltip: 'Minhas Reservas',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MinhasReservasScreen(
                    service: _service,
                    isProfessor: widget.isProfessor,
                  ),
                ),
              );
              setState(() {});
            },
          ),
          if (widget.isProfessor)
            IconButton(
              icon: const Icon(Icons.add_business_outlined),
              tooltip: 'Novo Laboratório',
              onPressed: () => _abrirFormLaboratorio(),
            ),
          IconButton(
            icon: const Icon(Icons.accessibility_new),
            tooltip: 'Acessibilidade (Tema e Fonte)',
            onPressed: () => abrirMenuAcessibilidade(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Trocar perfil',
            onPressed: _sair,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Filtrar: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _recursoFiltro == null,
                        onSelected: (_) =>
                            setState(() => _recursoFiltro = null),
                      ),
                      const SizedBox(width: 6),
                      ..._filtrosDisponiveis.map((rec) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(rec),
                              selected: _recursoFiltro == rec,
                              onSelected: (sel) => setState(
                                  () => _recursoFiltro = sel ? rec : null),
                            ),
                          )),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: labsFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                              'Nenhum laboratório encontrado com esse recurso.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                          itemCount: labsFiltrados.length,
                          itemBuilder: (context, index) {
                            final lab = labsFiltrados[index];
                            final ocupacao = _service.taxaOcupacao(lab.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GradeSemanalScreen(
                                        laboratorioInicial: lab,
                                        serviceExistente: _service,
                                        isProfessor: widget.isProfessor,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lab.nome,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                          if (widget.isProfessor) ...[
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 20),
                                              tooltip: 'Editar laboratório',
                                              onPressed: () =>
                                                  _abrirFormLaboratorio(lab),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20),
                                              tooltip: 'Excluir laboratório',
                                              onPressed: () =>
                                                  _confirmarExclusaoLab(lab),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              lab.bloco,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _corStatus(lab.status)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              lab.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _corStatus(lab.status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Capacidade: ${lab.capacidade} alunos  •  ${lab.quantidadePcs} PCs  •  ${ocupacao.toStringAsFixed(0)}% ocupado',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      if (lab.softwares.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Softwares: ${lab.softwares}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                      if (lab.observacoes.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Obs.: ${lab.observacoes}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: lab.recursos
                                            .map((rec) => Chip(
                                                  label: Text(rec,
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: widget.isProfessor
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (_service.laboratorios.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Cadastre ao menos um laboratório antes de reservar.'),
                    ),
                  );
                  return;
                }
                final atualizou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NovaReservaScreen(service: _service),
                  ),
                );
                if (atualizou == true) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Reservar'),
            )
          : null,
    );
  }
}