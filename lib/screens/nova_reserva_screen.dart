import 'package:flutter/material.dart';
import '../models/dia_semana.dart';
import '../models/laboratorio.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';

class NovaReservaScreen extends StatefulWidget {
  final ReservaService service;
  final Laboratorio? laboratorioInicial;
  final DiaSemana? diaInicial;
  final String? horarioInicial;

  static const List<String> horariosDisponiveis = [
    '07:30 - 09:10',
    '09:30 - 11:10',
    '13:30 - 15:10',
    '15:30 - 17:10',
    '19:00 - 20:40',
    '20:50 - 22:30',
  ];

  const NovaReservaScreen({
    super.key,
    required this.service,
    this.laboratorioInicial,
    this.diaInicial,
    this.horarioInicial,
  });

  @override
  State<NovaReservaScreen> createState() => _NovaReservaScreenState();
}

class _NovaReservaScreenState extends State<NovaReservaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _docenteController = TextEditingController();
  final _turmaController = TextEditingController();
  final _motivoController = TextEditingController();

  late Laboratorio _labSelecionado;
  late DiaSemana _diaSelecionado;
  late String _horarioSelecionado;

  @override
  void initState() {
    super.initState();
    _labSelecionado =
        widget.laboratorioInicial ?? widget.service.laboratorios.first;
    _diaSelecionado = widget.diaInicial ?? DiaSemana.segunda;
    _horarioSelecionado =
        widget.horarioInicial ?? NovaReservaScreen.horariosDisponiveis.first;
  }

  @override
  void dispose() {
    _docenteController.dispose();
    _turmaController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final nova = Reserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      laboratorioId: _labSelecionado.id,
      docente: _docenteController.text.trim(),
      turma: _turmaController.text.trim(),
      dia: _diaSelecionado,
      horario: _horarioSelecionado,
      motivo: _motivoController.text.trim(),
    );

    final sucesso = await widget.service.adicionarReserva(nova);

    if (!mounted) return;

    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conflito: este laboratório já está reservado neste dia e horário!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reserva registrada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final diasUteis =
        DiaSemana.values.where((d) => d != DiaSemana.sabado).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Reserva'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Laboratorio>(
                initialValue: _labSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Laboratório',
                  border: OutlineInputBorder(),
                ),
                items: widget.service.laboratorios.map((lab) {
                  return DropdownMenuItem(
                    value: lab,
                    child: Text(lab.nome),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _labSelecionado = val);
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<DiaSemana>(
                initialValue: _diaSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Dia da Semana',
                  border: OutlineInputBorder(),
                ),
                items: diasUteis.map((dia) {
                  return DropdownMenuItem(
                    value: dia,
                    child: Text(dia.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _diaSelecionado = val);
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _horarioSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Horário',
                  border: OutlineInputBorder(),
                ),
                items: NovaReservaScreen.horariosDisponiveis.map((h) {
                  return DropdownMenuItem(
                    value: h,
                    child: Text(h),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _horarioSelecionado = val);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _docenteController,
                decoration: const InputDecoration(
                  labelText: 'Docente Responsável',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o docente' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _turmaController,
                decoration: const InputDecoration(
                  labelText: 'Turma / Disciplina',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a turma' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo / Atividade',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o motivo' : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}