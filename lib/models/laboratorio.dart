class Laboratorio {
  final String id;
  final String nome;
  final String bloco;
  final int capacidade;
  final int quantidadePcs;
  final String status;
  final String softwares;
  final String observacoes;
  final List<String> recursos;

  Laboratorio({
    required this.id,
    required this.nome,
    required this.bloco,
    required this.capacidade,
    required this.quantidadePcs,
    this.status = 'Disponível',
    this.softwares = '',
    this.observacoes = '',
    required this.recursos,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'bloco': bloco,
      'capacidade': capacidade,
      'quantidadePcs': quantidadePcs,
      'status': status,
      'softwares': softwares,
      'observacoes': observacoes,
      'recursos': recursos,
    };
  }

  factory Laboratorio.fromJson(Map<String, dynamic> json) {
    return Laboratorio(
      id: json['id'] as String,
      nome: json['nome'] as String,
      bloco: (json['bloco'] as String?) ?? 'Bloco A',
      capacidade: json['capacidade'] as int,
      quantidadePcs: (json['quantidadePcs'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'Disponível',
      softwares: (json['softwares'] as String?) ?? '',
      observacoes: (json['observacoes'] as String?) ?? '',
      recursos: List<String>.from(json['recursos'] ?? []),
    );
  }
}