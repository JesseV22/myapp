import 'package:flutter/material.dart';
import '../models/prato.dart';
import '../models/ingrediente.dart';
import '../utils/banco_dados.dart';
import 'estoque_screen.dart';

class CardapioScreen extends StatefulWidget {
  const CardapioScreen({super.key});

  @override
  State<CardapioScreen> createState() => _CardapioScreenState();
}

class _CardapioScreenState extends State<CardapioScreen> {
  List<Prato> pratos = [];
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController ingredientesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarPratos();
  }

  Future<void> carregarPratos() async {
    final lista = await BancoDados.listarPratos();
    setState(() {
      pratos = lista;
    });
  }

  void adicionarPrato() async {
    final nome = nomeController.text.trim();
    final ingredientesInput = ingredientesController.text.trim().split(',').map((e) => e.trim()).toList();
    final ingredientes = ingredientesInput.map((ing) {
      final parts = ing.split(':');
      if (parts.length != 2) return null;
      final quantidade = int.tryParse(parts[1]);
      if (quantidade == null || quantidade <= 0) return null;
      return {'nome': parts[0].trim(), 'quantidade': quantidade};
    }).whereType<Map<String, dynamic>>().toList();

    if (nome.isNotEmpty && ingredientes.isNotEmpty) {
      await BancoDados.inserirPrato(Prato(nome: nome, ingredientes: ingredientes));
      nomeController.clear();
      ingredientesController.clear();
      carregarPratos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e ingredientes com formato válido (ex.: Bacon:100, Tomate:200)!')),
      );
    }
  }

  Future<String?> verificarEstoque(Prato prato) async {
    final ingredientes = await BancoDados.listarIngredientes();
    String? falta;
    for (var ing in prato.ingredientes) {
      final estoqueIng = ingredientes.firstWhere(
        (i) => i.nome.toLowerCase() == ing['nome'].toLowerCase(),
        orElse: () => Ingrediente(nome: ing['nome'], quantidade: 0),
      );
      if (estoqueIng.quantidade < (ing['quantidade'] as int)) {
        final deficit = (ing['quantidade'] as int) - estoqueIng.quantidade;
        falta = falta == null
            ? 'Falta ${deficit}g de ${ing['nome']}'
            : '$falta, ${deficit}g de ${ing['nome']}';
      }
    }
    return falta;
  }

  void prepararPrato(Prato prato) async {
    final falta = await verificarEstoque(prato);
    if (falta == null) {
      final ingredientes = await BancoDados.listarIngredientes();
      for (var ing in prato.ingredientes) {
        final estoqueIng = ingredientes.firstWhere((i) => i.nome.toLowerCase() == ing['nome'].toLowerCase());
        final quantidadeUsada = ing['quantidade'] as int;
        estoqueIng.quantidade -= quantidadeUsada;
        if (estoqueIng.quantidade < 0) estoqueIng.quantidade = 0;
        await BancoDados.atualizarIngrediente(estoqueIng);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${prato.nome} preparado com sucesso! Estoque atualizado.'),
          action: SnackBarAction(
            label: 'Ver Estoque',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueScreen()));
            },
          ),
        ),
      );
      carregarPratos(); // Recarrega a lista de pratos para manter a interface atualizada
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingredientes insuficientes: $falta!')),
      );
    }
  }

  void excluirPrato(int id) async {
    await BancoDados.excluirPrato(id);
    carregarPratos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar Prato',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Prato',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ingredientesController,
              decoration: const InputDecoration(
                labelText: 'Ingredientes (ex.: Bacon:100, Tomate:200)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarPrato,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Adicionar Prato'),
            ),
            const Divider(height: 30),
            const Text(
              'Lista de Pratos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: pratos.isEmpty
                  ? const Center(child: Text('Nenhum prato encontrado.'))
                  : ListView.builder(
                      itemCount: pratos.length,
                      itemBuilder: (context, index) {
                        final prato = pratos[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.restaurant_menu, color: Colors.teal),
                            title: Text(prato.nome),
                            subtitle: Text(
                              'Ingredientes: ${prato.ingredientes.map((i) => '${i['nome']}: ${i['quantidade']}g').join(', ')}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                                  onPressed: () => prepararPrato(prato),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () => excluirPrato(prato.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}