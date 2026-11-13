import 'package:flutter/material.dart';
import '../models/dia_semana.dart';
import '../models/laboratorio.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';
import 'nova_reserva_screen.dart';

class GradeSemanalScreen extends StatefulWidget {
  final Laboratorio laboratorio;
  final ReservaService service;
  final bool isProfessor;

  const GradeSemanalScreen({
    super.key,
    required this.laboratorio,
    required this.service,
    required this.isProfessor,
  });

  @override
  State<GradeSemanalScreen> createState() => _GradeSemanalScreenState();
}

class _GradeSemanalScreenState extends State<GradeSemanalScreen> {
  DiaSemana _diaSelecionado = DiaSemana.segunda;

  static const List<DiaSemana> _diasUteis = [
    DiaSemana.segunda,
    DiaSemana.terca,
    DiaSemana.quarta,
    DiaSemana.quinta,
    DiaSemana.sexta,
  ];

  Future<void> _abrirNovaReserva(String horario) async {
    final atualizou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaReservaScreen(
          service: widget.service,
          laboratorioInicial: widget.laboratorio,
          diaInicial: _diaSelecionado,
          horarioInicial: horario,
        ),
      ),
    );
    if (atualizou == true) setState(() {});
  }

  Future<void> _confirmarCancelamento(Reserva reserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          'Deseja cancelar a reserva de ${reserva.docente} (${reserva.turma}) no horário ${reserva.horario}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await widget.service.cancelarReserva(reserva.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasDoDia = widget.service.reservasPorLaboratorioEDia(
      widget.laboratorio.id,
      _diaSelecionado,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.laboratorio.nome),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _diasUteis.map((dia) {
                final selecionado = dia == _diaSelecionado;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(dia.label.split('-').first),
                    selected: selecionado,
                    onSelected: (_) => setState(() => _diaSelecionado = dia),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: NovaReservaScreen.horariosDisponiveis.length,
              itemBuilder: (context, index) {
                final horario = NovaReservaScreen.horariosDisponiveis[index];
                final reserva = reservasDoDia
                    .where((r) => r.horario == horario)
                    .firstOrNull;

                final ocupado = reserva != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: ocupado
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: Icon(
                      ocupado ? Icons.lock : Icons.check_circle_outline,
                      color: ocupado ? Colors.red : Colors.green,
                    ),
                    title: Text(
                      horario,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: ocupado
                        ? Text(
                            '${reserva.turma} • Prof. ${reserva.docente}\nMotivo: ${reserva.motivo}',
                          )
                        : Text(
                            widget.isProfessor
                                ? 'Horário livre — toque para reservar'
                                : 'Horário livre',
                          ),
                    trailing: ocupado
                        ? (widget.isProfessor
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Cancelar reserva',
                                onPressed: () =>
                                    _confirmarCancelamento(reserva),
                              )
                            : null)
                        : (widget.isProfessor ? const Icon(Icons.add) : null),
                    onTap: (!ocupado && widget.isProfessor)
                        ? () => _abrirNovaReserva(horario)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}