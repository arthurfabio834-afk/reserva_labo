import 'dia_semana.dart';

class Reserva {
  final String id;
  final String laboratorioId;
  final String docente;
  final String turma;
  final DiaSemana dia;
  final String horario;
  final String motivo;

  Reserva({
    required this.id,
    required this.laboratorioId,
    required this.docente,
    required this.turma,
    required this.dia,
    required this.horario,
    required this.motivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laboratorioId': laboratorioId,
      'docente': docente,
      'turma': turma,
      'dia': dia.name,
      'horario': horario,
      'motivo': motivo,
    };
  }

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] as String,
      laboratorioId: json['laboratorioId'] as String,
      docente: json['docente'] as String,
      turma: json['turma'] as String,
      dia: DiaSemana.values.firstWhere((e) => e.name == json['dia']),
      horario: json['horario'] as String,
      motivo: json['motivo'] as String,
    );
  }
}