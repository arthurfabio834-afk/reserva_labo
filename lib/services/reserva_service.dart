import '../models/dia_semana.dart';
import '../models/laboratorio.dart';
import '../models/reserva.dart';
import 'storage_service.dart';

class ReservaService {
  final StorageService _storage = StorageService();

  List<Laboratorio> laboratorios = [];
  List<Reserva> reservas = [];

  Future<void> inicializar() async {
    laboratorios = await _storage.carregarLaboratorios();
    reservas = await _storage.carregarReservas();

    if (laboratorios.isEmpty) {
      laboratorios = [
        Laboratorio(
          id: 'lab_1',
          nome: 'Laboratório de Informática 01',
          bloco: 'Bloco B - Térreo',
          capacidade: 30,
          quantidadePcs: 30,
          status: 'Disponível',
          softwares: 'Windows 11, VS Code, Flutter SDK, Android Studio',
          observacoes: 'Chave disponível na portaria do Bloco B.',
          recursos: ['Projetor', 'Ar-condicionado', 'Wi-Fi'],
        ),
        Laboratorio(
          id: 'lab_2',
          nome: 'Laboratório de Redes e Hardware',
          bloco: 'Bloco C - Sala 04',
          capacidade: 20,
          quantidadePcs: 15,
          status: 'Disponível',
          softwares: 'Ubuntu Linux, Cisco Packet Tracer, Arduino IDE',
          observacoes: 'Bancadas com fontes de bancada e kits de microcontroladores.',
          recursos: ['Bancadas', 'Roteadores', 'Projetor'],
        ),
      ];
      await _storage.salvarLaboratorios(laboratorios);
    }
  }

  Future<void> salvarLaboratorio(Laboratorio lab) async {
    final index = laboratorios.indexWhere((item) => item.id == lab.id);
    if (index >= 0) {
      laboratorios[index] = lab;
    } else {
      laboratorios.add(lab);
    }
    await _storage.salvarLaboratorios(laboratorios);
  }

  Future<void> removerLaboratorio(String labId) async {
    laboratorios.removeWhere((l) => l.id == labId);
    reservas.removeWhere((r) => r.laboratorioId == labId);
    await _storage.salvarLaboratorios(laboratorios);
    await _storage.salvarReservas(reservas);
  }

  bool temConflito({
    required String laboratorioId,
    required DiaSemana dia,
    required String horario,
  }) {
    return reservas.any(
      (r) =>
          r.laboratorioId == laboratorioId &&
          r.dia == dia &&
          r.horario == horario,
    );
  }

  Future<bool> adicionarReserva(Reserva nova) async {
    if (temConflito(
      laboratorioId: nova.laboratorioId,
      dia: nova.dia,
      horario: nova.horario,
    )) {
      return false;
    }
    reservas.add(nova);
    await _storage.salvarReservas(reservas);
    return true;
  }

  Future<void> cancelarReserva(String reservaId) async {
    reservas.removeWhere((r) => r.id == reservaId);
    await _storage.salvarReservas(reservas);
  }

  List<Reserva> reservasPorLaboratorioEDia(String labId, DiaSemana dia) {
    return reservas
        .where((r) => r.laboratorioId == labId && r.dia == dia)
        .toList();
  }

  double taxaOcupacao(String labId, int totalSlotsSemanais) {
    if (totalSlotsSemanais == 0) return 0;
    final ocupados = reservas.where((r) => r.laboratorioId == labId).length;
    return (ocupados / totalSlotsSemanais) * 100;
  }
}