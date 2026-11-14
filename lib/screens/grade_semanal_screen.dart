import 'package:flutter/material.dart';
import '../models/dia_semana.dart';
import '../models/laboratorio.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import 'nova_reserva_screen.dart';

class GradeSemanalScreen extends StatefulWidget {
  final Laboratorio? laboratorioInicial;
  final ReservaService? serviceExistente;
  final bool isProfessor;

  const GradeSemanalScreen({
    super.key,
    this.laboratorioInicial,
    this.serviceExistente,
    required this.isProfessor,
  });

  @override
  State<GradeSemanalScreen> createState() => _GradeSemanalScreenState();
}

class _GradeSemanalScreenState extends State<GradeSemanalScreen> {
  late final ReservaService _service;
  String? _labAtualId;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _service = widget.serviceExistente ?? ReservaService();
    _iniciar();
  }

  @override
  void dispose() {
    if (widget.serviceExistente == null) {
      _service.dispose();
    }
    super.dispose();
  }

  Future<void> _iniciar() async {
    if (widget.serviceExistente == null) {
      await _service.inicializar();
    }
    if (!mounted) return;
    setState(() {
      _labAtualId = widget.laboratorioInicial?.id ??
          (_service.laboratorios.isNotEmpty
              ? _service.laboratorios.first.id
              : null);
      _carregando = false;
    });
  }

  Future<void> _abrirNovaReserva(
      Laboratorio labAtual, DiaSemana dia, String horario) async {
    if (labAtual.status != 'Disponível') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não é possível reservar: "${labAtual.nome}" está "${labAtual.status}".',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaReservaScreen(
          service: _service,
          laboratorioInicial: labAtual,
          diaInicial: dia,
          horarioInicial: horario,
        ),
      ),
    );
  }

  Future<void> _gerenciarHorarios() async {
    final inicioCtrl = TextEditingController();
    final fimCtrl = TextEditingController();

    // Função auxiliar para formatar automaticamente "0800" para "08:00"
    String formatarHorarioDigitado(String texto) {
      final limpo = texto.replaceAll(RegExp(r'[^0-9]'), '');
      if (limpo.length == 4) {
        return '${limpo.substring(0, 2)}:${limpo.substring(2, 4)}';
      }
      return texto.trim();
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Personalizar Horários da Matriz'),
          // Envolvido em SingleChildScrollView para evitar estouro de tela com o teclado
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inicioCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          onChanged: (val) {
                            if (val.length == 4 && !val.contains(':')) {
                              inicioCtrl.text = formatarHorarioDigitado(val);
                              inicioCtrl.selection = TextSelection.fromPosition(
                                TextPosition(offset: inicioCtrl.text.length),
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Início',
                            hintText: '08:00',
                            border: OutlineInputBorder(),
                            isDense: true,
                            counterText: '',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('-'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: fimCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          onChanged: (val) {
                            if (val.length == 4 && !val.contains(':')) {
                              fimCtrl.text = formatarHorarioDigitado(val);
                              fimCtrl.selection = TextSelection.fromPosition(
                                TextPosition(offset: fimCtrl.text.length),
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Fim',
                            hintText: '09:00',
                            border: OutlineInputBorder(),
                            isDense: true,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        tooltip: 'Adicionar horário',
                        onPressed: () async {
                          final ini = formatarHorarioDigitado(inicioCtrl.text);
                          final fim = formatarHorarioDigitado(fimCtrl.text);
                          if (ini.isEmpty || fim.isEmpty) return;
                          final faixa = '$ini - $fim';
                          final ok = await _service.adicionarHorario(faixa);
                          if (ok) {
                            inicioCtrl.clear();
                            fimCtrl.clear();
                            setDialogState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _service.horarios.length,
                      itemBuilder: (_, idx) {
                        final h = _service.horarios[idx];
                        return ListTile(
                          dense: true,
                          title: Text(h),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () async {
                              await _service.removerHorario(h);
                              setDialogState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _aoTocarCelula(Laboratorio labAtual, DiaSemana dia,
      String horario, Reserva? reserva) async {
    if (reserva == null) {
      if (widget.isProfessor) {
        await _abrirNovaReserva(labAtual, dia, horario);
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${dia.label} • $horario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laboratório: ${labAtual.nome}'),
            const SizedBox(height: 6),
            Text('Turma: ${reserva.turma}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Professor(a): ${reserva.docente}'),
            const SizedBox(height: 6),
            Text('Atividade: ${reserva.motivo}'),
          ],
        ),
        actions: [
          if (widget.isProfessor)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Remover Aula',
                  style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _service.cancelarReserva(reserva.id);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isProfessor
            ? 'Matriz Semanal'
            : 'Grade de Horários • Aluno'),
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          if (widget.isProfessor)
            IconButton(
              icon: const Icon(Icons.edit_calendar_outlined),
              tooltip: 'Personalizar horários da matriz',
              onPressed: _gerenciarHorarios,
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: _service,
              builder: (context, _) {
                if (_service.laboratorios.isEmpty) {
                  return const Center(
                    child: Text('Nenhum laboratório cadastrado ainda.'),
                  );
                }

                final labAtual = _service.laboratorios
                        .where((l) => l.id == _labAtualId)
                        .firstOrNull ??
                    _service.laboratorios.first;
                final indisponivel = labAtual.status != 'Disponível';

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: colorScheme.surfaceContainerLowest,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: labAtual.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Laboratório selecionado',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _service.laboratorios
                                .map((lab) => DropdownMenuItem(
                                      value: lab.id,
                                      child: Text(
                                        '${lab.nome} (${lab.bloco})',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _labAtualId = val);
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${labAtual.capacidade} alunos • ${labAtual.quantidadePcs} PCs • Status: ${labAtual.status}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (indisponivel) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Aviso: Este laboratório está "${labAtual.status}" e não aceita novas reservas.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _service.horarios.isEmpty
                          ? const Center(
                              child: Text(
                                  'Nenhum horário na matriz. Toque no ícone de calendário acima para adicionar.'),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(12),
                                child: Table(
                                  defaultColumnWidth:
                                      const FixedColumnWidth(115),
                                  border: TableBorder.all(
                                    color: colorScheme.outlineVariant,
                                    width: 1,
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                      ),
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            'HORÁRIO',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ...DiaSemana.values.map(
                                          (dia) => Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              dia.sigla,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ..._service.horarios.map((horario) {
                                      return TableRow(
                                        children: [
                                          Container(
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 6),
                                            alignment: Alignment.center,
                                            child: Text(
                                              horario,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ...DiaSemana.values.map((dia) {
                                            final reserva =
                                                _service.buscarReserva(
                                              labAtual.id,
                                              dia,
                                              horario,
                                            );
                                            final ocupado = reserva != null;

                                            return InkWell(
                                              onTap: () => _aoTocarCelula(
                                                  labAtual,
                                                  dia,
                                                  horario,
                                                  reserva),
                                              child: Container(
                                                height: 68,
                                                padding:
                                                    const EdgeInsets.all(6),
                                                color: ocupado
                                                    ? colorScheme
                                                        .tertiaryContainer
                                                    : Colors.transparent,
                                                alignment: Alignment.center,
                                                child: ocupado
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            reserva.turma,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          Text(
                                                            reserva.docente,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : (widget.isProfessor &&
                                                            !indisponivel
                                                        ? Icon(
                                                            Icons.add,
                                                            size: 18,
                                                            color: colorScheme
                                                                .outline,
                                                          )
                                                        : Text(
                                                            indisponivel
                                                                ? 'Bloq.'
                                                                : '-',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .grey,
                                                                fontSize: 12),
                                                          )),
                                              ),
                                            );
                                          }),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}