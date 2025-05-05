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
  String unidadeSelecionada = 'g';
  List<Map<String, dynamic>> ingredientesTemp = [];
  final TextEditingController ingredienteQuantidadeController = TextEditingController();
  List<Ingrediente> ingredientesEstoque = [];
  String? ingredienteSelecionado;

  @override
  void initState() {
    super.initState();
    carregarPratos();
    carregarIngredientesEstoque();
  }

  Future<void> carregarPratos() async {
    final lista = await BancoDados.instance.listarPratos();
    setState(() {
      pratos = lista;
    });
  }

  Future<void> carregarIngredientesEstoque() async {
    final lista = await BancoDados.instance.listarIngredientes();
    setState(() {
      ingredientesEstoque = lista;
      if (lista.isNotEmpty) {
        ingredienteSelecionado = lista[0].nome;
      }
    });
  }

  double converterParaGramas(double valor, String unidade) {
    if (unidade == 'kg') {
      return valor * 1000;
    } else if (unidade == 'unidade' || unidade == 'lata') {
      return valor; // Mantém como unidade, mas no banco será em g
    }
    return valor; // Já em gramas
  }

  void adicionarIngredienteTemp() {
    if (ingredienteSelecionado == null || ingredienteQuantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um ingrediente e informe a quantidade!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final quantidade = double.tryParse(ingredienteQuantidadeController.text) ?? 0;
    if (quantidade >= 0) {
      final quantidadeEmGramas = converterParaGramas(quantidade, unidadeSelecionada).round();
      final ingrediente = ingredientesEstoque.firstWhere(
            (i) => i.nome == ingredienteSelecionado,
        orElse: () => Ingrediente(nome: ingredienteSelecionado!, quantidade: 0, unidade: 'g'),
      );
      setState(() {
        ingredientesTemp.add({
          'nome': ingrediente.nome,
          'quantidade': quantidadeEmGramas,
          'unidade': 'g',
        });
      });
      ingredienteQuantidadeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade inválida!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void adicionarPrato() async {
    final nome = nomeController.text.trim();
    if (nome.isNotEmpty && ingredientesTemp.isNotEmpty) {
      await BancoDados.instance.inserirPrato(Prato(nome: nome, ingredientes: ingredientesTemp));
      nomeController.clear();
      setState(() {
        ingredientesTemp = [];
      });
      await carregarPratos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nome adicionado ao cardápio!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome e pelo menos um ingrediente!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<String?> verificarEstoque(Prato prato) async {
    final ingredientes = await BancoDados.instance.listarIngredientes();
    String? falta;
    for (var ingPrato in prato.ingredientes) {
      final estoqueIng = ingredientes.firstWhere(
            (i) => i.nome.toLowerCase() == ingPrato['nome'].toLowerCase(),
        orElse: () => Ingrediente(nome: ingPrato['nome'], quantidade: 0, unidade: 'g'),
      );
      final quantidadeEstoque = estoqueIng.quantidade;
      final quantidadeNecessaria = ingPrato['quantidade'] as int;
      if (quantidadeEstoque < quantidadeNecessaria) {
        final deficit = quantidadeNecessaria - quantidadeEstoque;
        falta = falta == null
            ? 'Falta $deficit g de ${ingPrato['nome']}'
            : '$falta, $deficit g de ${ingPrato['nome']}';
      }
    }
    return falta;
  }

  void prepararPrato(Prato prato) async {
    final falta = await verificarEstoque(prato);
    if (falta == null) {
      final ingredientes = await BancoDados.instance.listarIngredientes();
      for (var ingPrato in prato.ingredientes) {
        final estoqueIng = ingredientes.firstWhere(
              (i) => i.nome.toLowerCase() == ingPrato['nome'].toLowerCase(),
        );
        final quantidadeUsada = ingPrato['quantidade'] as int;
        estoqueIng.quantidade -= quantidadeUsada;
        if (estoqueIng.quantidade < 0) estoqueIng.quantidade = 0;
        await BancoDados.instance.atualizarIngrediente(estoqueIng);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${prato.nome} preparado com sucesso! Estoque atualizado.'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver Estoque',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueScreen()));
            },
            textColor: Colors.white,
          ),
        ),
      );
      await carregarPratos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingredientes insuficientes: $falta!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void excluirPrato(int id) async {
    await BancoDados.instance.excluirPrato(id);
    await carregarPratos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prato excluído!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cardápio Delicioso',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_circle, color: Colors.orange, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Adicionar Novo Prato',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Prato',
                          labelStyle: TextStyle(color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.orange[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.fastfood, color: Colors.orange),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(Icons.local_dining, color: Colors.orange, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Ingredientes do Prato',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Selecione um Ingrediente',
                          labelStyle: TextStyle(color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.orange[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        value: ingredienteSelecionado,
                        onChanged: (String? newValue) {
                          setState(() {
                            ingredienteSelecionado = newValue;
                          });
                        },
                        items: ingredientesEstoque.map<DropdownMenuItem<String>>((Ingrediente ing) {
                          return DropdownMenuItem<String>(
                            value: ing.nome,
                            child: Text('${ing.nome} (${ing.quantidade} g)'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ingredienteQuantidadeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Quantidade',
                                labelStyle: TextStyle(color: Colors.orange[700]),
                                filled: true,
                                fillColor: Colors.orange[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.scale, color: Colors.orange),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: unidadeSelecionada,
                              onChanged: (String? newValue) {
                                setState(() {
                                  unidadeSelecionada = newValue!;
                                });
                              },
                              items: <String>['g', 'kg', 'unidade', 'lata']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton.icon(
                          onPressed: adicionarIngredienteTemp,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Adicionar Ingrediente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ingredientes Temporários: ${ingredientesTemp.isEmpty ? "Nenhum" : ingredientesTemp.map((i) => '${i['nome']}: ${i['quantidade']} ${i['unidade']}').join(', ')}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton.icon(
                          onPressed: adicionarPrato,
                          icon: const Icon(Icons.restaurant_menu, size: 20),
                          label: const Text('Adicionar ao Cardápio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.orange, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Lista de Pratos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                pratos.isEmpty
                    ? const Center(
                  child: Text(
                    'Nenhum prato no cardápio. Adicione um!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pratos.length,
                  itemBuilder: (context, index) {
                    final prato = pratos[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.orange,
                            ),
                          ),
                          title: Text(
                            prato.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Ingredientes: ${prato.ingredientes.map((i) => '${i['nome']}: ${i['quantidade']} ${i['unidade']}').join(', ')}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow, color: Colors.green),
                                onPressed: () => prepararPrato(prato),
                                tooltip: 'Preparar Prato',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => excluirPrato(prato.id!),
                                tooltip: 'Excluir Prato',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}