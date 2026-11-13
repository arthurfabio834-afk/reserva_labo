import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laboratorio.dart';
import '../models/reserva.dart';

class StorageService {
  static const String _keyLaboratorios = 'laboratorios_json';
  static const String _keyReservas = 'reservas_json';

  Future<void> salvarLaboratorios(List<Laboratorio> laboratorios) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = laboratorios.map((lab) => lab.toJson()).toList();
    await prefs.setString(_keyLaboratorios, jsonEncode(jsonList));
  }

  Future<List<Laboratorio>> carregarLaboratorios() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLaboratorios);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((item) => Laboratorio.fromJson(item)).toList();
  }

  Future<void> salvarReservas(List<Reserva> reservas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reservas.map((res) => res.toJson()).toList();
    await prefs.setString(_keyReservas, jsonEncode(jsonList));
  }

  Future<List<Reserva>> carregarReservas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyReservas);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((item) => Reserva.fromJson(item)).toList();
  }
}