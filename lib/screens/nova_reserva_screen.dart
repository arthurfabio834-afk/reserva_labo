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
    _labSelecionado = widget.laboratorioInicial ??
        widget.service.laboratorios
            .where((l) => l.status == 'Disponível')
            .firstOrNull ??
        widget.service.laboratorios.first;
    _diaSelecionado = widget.diaInicial ?? DiaSemana.segunda;
    _horarioSelecionado =
        widget.horarioInicial ?? widget.service.horarios.first;
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

    final erro = await widget.service.adicionarReserva(nova);

    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aula agendada na matriz!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final indisponivel = _labSelecionado.status != 'Disponível';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Horário'),
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
                  final labelStatus =
                      lab.status == 'Disponível' ? '' : ' [${lab.status}]';
                  return DropdownMenuItem(
                    value: lab,
                    child: Text('${lab.nome}$labelStatus'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _labSelecionado = val);
                },
              ),
              if (indisponivel) ...[
                const SizedBox(height: 8),
                Text(
                  'Atenção: Este laboratório está "${_labSelecionado.status}" e não permite novas reservas.',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              DropdownButtonFormField<DiaSemana>(
                initialValue: _diaSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Dia da Semana',
                  border: OutlineInputBorder(),
                ),
                items: DiaSemana.values.map((dia) {
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
                  labelText: 'Faixa de Horário',
                  border: OutlineInputBorder(),
                ),
                items: widget.service.horarios.map((h) {
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
                  labelText: 'Atividade / Observação',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a atividade' : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: indisponivel ? null : _salvar,
                icon: const Icon(Icons.check),
                label: const Text('Salvar na Matriz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}