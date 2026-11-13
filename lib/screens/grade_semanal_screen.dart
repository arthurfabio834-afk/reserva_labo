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
  Laboratorio? _labAtual;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _service = widget.serviceExistente ?? ReservaService();
    _iniciar();
  }

  Future<void> _iniciar() async {
    if (widget.serviceExistente == null) {
      await _service.inicializar();
    }
    setState(() {
      _labAtual = widget.laboratorioInicial ??
          (_service.laboratorios.isNotEmpty
              ? _service.laboratorios.first
              : null);
      _carregando = false;
    });
  }

  Future<void> _abrirNovaReserva(DiaSemana dia, String horario) async {
    if (_labAtual == null) return;
    final atualizou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaReservaScreen(
          service: _service,
          laboratorioInicial: _labAtual,
          diaInicial: dia,
          horarioInicial: horario,
        ),
      ),
    );
    if (atualizou == true) setState(() {});
  }

  Future<void> _gerenciarHorarios() async {
    final inicioCtrl = TextEditingController();
    final fimCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Personalizar Horários da Matriz'),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inicioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Início',
                          hintText: '08:00',
                          border: OutlineInputBorder(),
                          isDense: true,
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
                        decoration: const InputDecoration(
                          labelText: 'Fim',
                          hintText: '09:00',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      tooltip: 'Adicionar horário',
                      onPressed: () async {
                        final ini = inicioCtrl.text.trim();
                        final fim = fimCtrl.text.trim();
                        if (ini.isEmpty || fim.isEmpty) return;
                        final faixa = '$ini - $fim';
                        final ok = await _service.adicionarHorario(faixa);
                        if (ok) {
                          inicioCtrl.clear();
                          fimCtrl.clear();
                          setDialogState(() {});
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
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
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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

  Future<void> _aoTocarCelula(
      DiaSemana dia, String horario, Reserva? reserva) async {
    if (reserva == null) {
      if (widget.isProfessor) {
        await _abrirNovaReserva(dia, horario);
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
            Text('Laboratório: ${_labAtual?.nome ?? ''}'),
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
                setState(() {});
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
          : _labAtual == null
              ? const Center(
                  child: Text('Nenhum laboratório cadastrado ainda.'))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: colorScheme.surfaceContainerLowest,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<Laboratorio>(
                            initialValue: _labAtual,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Laboratório selecionado',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _service.laboratorios
                                .map((lab) => DropdownMenuItem(
                                      value: lab,
                                      child: Text(
                                        '${lab.nome} (${lab.bloco})',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _labAtual = val);
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_labAtual!.capacidade} alunos • ${_labAtual!.quantidadePcs} PCs • Status: ${_labAtual!.status}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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
                                              _labAtual!.id,
                                              dia,
                                              horario,
                                            );
                                            final ocupado = reserva != null;

                                            return InkWell(
                                              onTap: () => _aoTocarCelula(
                                                  dia, horario, reserva),
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
                                                    : (widget.isProfessor
                                                        ? Icon(
                                                            Icons.add,
                                                            size: 18,
                                                            color: colorScheme
                                                                .outline,
                                                          )
                                                        : const Text(
                                                            '-',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
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
                ),
    );
  }
}