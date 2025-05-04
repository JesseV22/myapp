import 'package:flutter/material.dart';
import '../models/ingrediente.dart';
import '../utils/banco_dados.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  List<Ingrediente> ingredientes = [];
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarIngredientes();
  }

  Future<void> carregarIngredientes() async {
    final lista = await BancoDados.listarIngredientes();
    setState(() {
      ingredientes = lista;
    });
  }

  void adicionarIngrediente() async {
    final nome = nomeController.text.trim();
    final quantidade = int.tryParse(quantidadeController.text) ?? 0;

    if (nome.isNotEmpty && quantidade > 0) {
      await BancoDados.inserirIngrediente(Ingrediente(nome: nome, quantidade: quantidade));
      nomeController.clear();
      quantidadeController.clear();
      carregarIngredientes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e quantidade válida!')),
      );
    }
  }

  void alterarQuantidade(Ingrediente ingrediente, int delta) async {
    ingrediente.quantidade += delta;
    if (ingrediente.quantidade < 0) ingrediente.quantidade = 0;
    await BancoDados.atualizarIngrediente(ingrediente);
    carregarIngredientes();
  }

  void excluirIngrediente(int id) async {
    await BancoDados.excluirIngrediente(id);
    carregarIngredientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar Ingrediente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Ingrediente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarIngrediente,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Adicionar Ingrediente'),
            ),
            const Divider(height: 30),
            const Text(
              'Lista de Ingredientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ingredientes.isEmpty
                  ? const Center(child: Text('Nenhum ingrediente encontrado.'))
                  : ListView.builder(
                      itemCount: ingredientes.length,
                      itemBuilder: (context, index) {
                        final item = ingredientes[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.kitchen, color: Colors.teal),
                            title: Text(item.nome),
                            subtitle: Text('Quantidade: ${item.quantidade}g'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.red),
                                  onPressed: () => alterarQuantidade(item, -10),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  onPressed: () => alterarQuantidade(item, 10),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () => excluirIngrediente(item.id!),
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