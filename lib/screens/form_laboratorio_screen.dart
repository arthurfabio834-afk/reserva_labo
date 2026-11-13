import 'package:flutter/material.dart';
import '../models/laboratorio.dart';
import '../services/reserva_service.dart';

class FormLaboratorioScreen extends StatefulWidget {
  final ReservaService service;
  final Laboratorio? laboratorioEdicao;

  const FormLaboratorioScreen({
    super.key,
    required this.service,
    this.laboratorioEdicao,
  });

  @override
  State<FormLaboratorioScreen> createState() => _FormLaboratorioScreenState();
}

class _FormLaboratorioScreenState extends State<FormLaboratorioScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _blocoController;
  late final TextEditingController _capacidadeController;
  late final TextEditingController _pcsController;
  late final TextEditingController _softwaresController;
  late final TextEditingController _obsController;

  late String _statusSelecionado;
  late Set<String> _recursosSelecionados;

  static const List<String> _opcoesStatus = [
    'Disponível',
    'Em Manutenção',
    'Restrito',
  ];

  static const List<String> _opcoesRecursos = [
    'Projetor',
    'Lousa Digital',
    'Ar-condicionado',
    'Wi-Fi',
    'Bancadas',
    'Roteadores',
    'Kits Arduino',
  ];

  @override
  void initState() {
    super.initState();
    final lab = widget.laboratorioEdicao;
    _nomeController = TextEditingController(text: lab?.nome ?? '');
    _blocoController = TextEditingController(text: lab?.bloco ?? '');
    _capacidadeController =
        TextEditingController(text: lab != null ? '${lab.capacidade}' : '');
    _pcsController =
        TextEditingController(text: lab != null ? '${lab.quantidadePcs}' : '');
    _softwaresController = TextEditingController(text: lab?.softwares ?? '');
    _obsController = TextEditingController(text: lab?.observacoes ?? '');
    _statusSelecionado = lab?.status ?? 'Disponível';
    _recursosSelecionados =
        Set<String>.from(lab?.recursos ?? ['Ar-condicionado', 'Wi-Fi']);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _blocoController.dispose();
    _capacidadeController.dispose();
    _pcsController.dispose();
    _softwaresController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final lab = Laboratorio(
      id: widget.laboratorioEdicao?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nomeController.text.trim(),
      bloco: _blocoController.text.trim(),
      capacidade: int.parse(_capacidadeController.text.trim()),
      quantidadePcs: int.parse(_pcsController.text.trim()),
      status: _statusSelecionado,
      softwares: _softwaresController.text.trim(),
      observacoes: _obsController.text.trim(),
      recursos: _recursosSelecionados.toList(),
    );

    await widget.service.salvarLaboratorio(lab);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.laboratorioEdicao == null
              ? 'Laboratório cadastrado!'
              : 'Laboratório atualizado!',
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.laboratorioEdicao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Laboratório' : 'Novo Laboratório'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Laboratório',
                hintText: 'Ex.: Laboratório de Programação 02',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _blocoController,
              decoration: const InputDecoration(
                labelText: 'Bloco / Localização no Campus',
                hintText: 'Ex.: Bloco A - 1º Andar, Sala 12',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o bloco' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _capacidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacidade (alunos)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Número inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pcsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qtd. de PCs',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Número inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _statusSelecionado,
              decoration: const InputDecoration(
                labelText: 'Status de Funcionamento',
                border: OutlineInputBorder(),
              ),
              items: _opcoesStatus
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _statusSelecionado = val);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _softwaresController,
              decoration: const InputDecoration(
                labelText: 'Sistemas e Softwares Instalados',
                hintText: 'Ex.: Windows 11, Linux, VS Code, Flutter, MySQL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _obsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observações / Avisos (opcional)',
                hintText: 'Ex.: Pegar chave na coordenação',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Equipamentos e Infraestrutura',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _opcoesRecursos.map((recurso) {
                final ativo = _recursosSelecionados.contains(recurso);
                return FilterChip(
                  label: Text(recurso),
                  selected: ativo,
                  onSelected: (selecionado) {
                    setState(() {
                      if (selecionado) {
                        _recursosSelecionados.add(recurso);
                      } else {
                        _recursosSelecionados.remove(recurso);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label:
                  Text(editando ? 'Salvar Alterações' : 'Cadastrar Laboratório'),
            ),
          ],
        ),
      ),
    );
  }
}