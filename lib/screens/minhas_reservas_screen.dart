import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';

class MinhasReservasScreen extends StatefulWidget {
  final ReservaService service;
  final bool isProfessor;

  const MinhasReservasScreen({
    super.key,
    required this.service,
    required this.isProfessor,
  });

  @override
  State<MinhasReservasScreen> createState() => _MinhasReservasScreenState();
}

class _MinhasReservasScreenState extends State<MinhasReservasScreen> {
  final _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _confirmarCancelamento(Reserva reserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          'Cancelar a aula de ${reserva.turma} (${reserva.dia.label}, ${reserva.horario})?',
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
    final lista = widget.service.reservasPorDocente(_buscaController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Filtrar por nome do docente',
                hintText: 'Digite o nome do professor...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text('Nenhuma reserva encontrada.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final r = lista[index];
                      final nomeLab =
                          widget.service.nomeLaboratorioPorId(r.laboratorioId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.event_available),
                          title: Text(
                            '$nomeLab • ${r.dia.sigla}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Horário: ${r.horario}\nTurma: ${r.turma} • Prof. ${r.docente}\nMotivo: ${r.motivo}',
                          ),
                          isThreeLine: true,
                          trailing: widget.isProfessor
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  tooltip: 'Cancelar reserva',
                                  onPressed: () => _confirmarCancelamento(r),
                                )
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