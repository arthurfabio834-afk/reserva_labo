import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laboratorio.dart';
import '../models/reserva.dart';

class StorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _colLaboratorios = 'laboratorios';
  static const String _colReservas = 'reservas';
  static const String _colConfiguracoes = 'configuracoes';
  static const String _docHorarios = 'horarios_matriz';

  // Preferências locais por dispositivo (acessibilidade)
  static const String _keyModoEscuro = 'acessibilidade_modo_escuro';
  static const String _keyEscalaFonte = 'acessibilidade_escala_fonte';

  Future<void> salvarLaboratorios(List<Laboratorio> laboratorios) async {
    final collection = _db.collection(_colLaboratorios);
    final snapshot = await collection.get();
    final batch = _db.batch();

    final idsAtuais = laboratorios.map((l) => l.id).toSet();

    for (final doc in snapshot.docs) {
      if (!idsAtuais.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final lab in laboratorios) {
      batch.set(collection.doc(lab.id), lab.toJson());
    }

    await batch.commit();
  }

  Future<List<Laboratorio>> carregarLaboratorios() async {
    final snapshot = await _db.collection(_colLaboratorios).get();
    return snapshot.docs
        .map((doc) => Laboratorio.fromJson(doc.data()))
        .toList();
  }

  Future<void> salvarReservas(List<Reserva> reservas) async {
    final collection = _db.collection(_colReservas);
    final snapshot = await collection.get();
    final batch = _db.batch();

    final idsAtuais = reservas.map((r) => r.id).toSet();

    for (final doc in snapshot.docs) {
      if (!idsAtuais.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final res in reservas) {
      batch.set(collection.doc(res.id), res.toJson());
    }

    await batch.commit();
  }

  Future<List<Reserva>> carregarReservas() async {
    final snapshot = await _db.collection(_colReservas).get();
    return snapshot.docs
        .map((doc) => Reserva.fromJson(doc.data()))
        .toList();
  }

  Future<void> salvarHorarios(List<String> horarios) async {
    await _db
        .collection(_colConfiguracoes)
        .doc(_docHorarios)
        .set({'lista': horarios});
  }

  Future<List<String>> carregarHorarios() async {
    final doc = await _db
        .collection(_colConfiguracoes)
        .doc(_docHorarios)
        .get();
    if (!doc.exists || doc.data() == null) return [];
    final lista = doc.data()!['lista'];
    if (lista is List) {
      return lista.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<void> salvarAcessibilidade({
    required bool modoEscuro,
    required double escalaFonte,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyModoEscuro, modoEscuro);
    await prefs.setDouble(_keyEscalaFonte, escalaFonte);
  }

  Future<({bool modoEscuro, double escalaFonte})> carregarAcessibilidade() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      modoEscuro: prefs.getBool(_keyModoEscuro) ?? false,
      escalaFonte: prefs.getDouble(_keyEscalaFonte) ?? 1.0,
    );
  }
}