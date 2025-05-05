import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/ingrediente.dart';
import '../utils/banco_dados.dart';
import 'cardapio_screen.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  List<Ingrediente> ingredientes = [];
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  String unidadeSelecionada = 'g';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool notificacaoPermitida = false;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _initializeNotifications();
    carregarIngredientes();
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      setState(() {
        notificacaoPermitida = status.isGranted;
      });
    } else {
      setState(() {
        notificacaoPermitida = true;
      });
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'estoque_baixo',
      'Estoque Baixo',
      description: 'Notificações para estoque baixo de ingredientes',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> carregarIngredientes() async {
    final lista = await BancoDados.instance.listarIngredientes();
    setState(() {
      ingredientes = lista;
      verificarAlertas();
    });
  }

  double converterParaGramas(double valor, String unidade) {
    if (unidade == 'kg') {
      return valor * 1000;
    } else if (unidade == 'unidade' || unidade == 'lata') {
      return valor;
    }
    return valor;
  }

  Future<void> verificarAlertas() async {
    if (!notificacaoPermitida) return;

    for (var ingrediente in ingredientes) {
      if (ingrediente.quantidade <= 1500 && ingrediente.nome.toLowerCase() == 'mussarela') {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'estoque_baixo', 'Estoque Baixo',
            channelDescription: 'Notificações para estoque baixo de ingredientes',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
        const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          'Estoque Baixo!',
          'Mussarela em nível crítico! (${ingrediente.quantidade} g restantes)',
          platformChannelSpecifics,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atenção: Estoque de mussarela baixo! (${ingrediente.quantidade} g restantes, limite: 1500 g)'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Repor',
              onPressed: () {
                // Lógica para reposição (opcional)
              },
              textColor: Colors.white,
            ),
          ),
        );
        break;
      }
    }
  }

  void adicionarIngrediente() async {
    final nome = nomeController.text.trim();
    final quantidade = double.tryParse(quantidadeController.text) ?? 0;
    if (nome.isNotEmpty && quantidade >= 0) {
      final quantidadeEmGramas = converterParaGramas(quantidade, unidadeSelecionada).round();
      await BancoDados.instance.inserirIngrediente(
        Ingrediente(nome: nome, quantidade: quantidadeEmGramas, unidade: 'g'),
      );
      nomeController.clear();
      quantidadeController.clear();
      await carregarIngredientes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nome adicionado ao estoque! ($quantidadeEmGramas g)'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome e quantidade válida!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void excluirIngrediente(int id) async {
    await BancoDados.instance.excluirIngrediente(id);
    await carregarIngredientes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingrediente excluído!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estoque de Ingredientes',
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
                            'Adicionar Ingrediente',
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
                          labelText: 'Nome do Ingrediente',
                          labelStyle: TextStyle(color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.orange[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.local_dining, color: Colors.orange),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: quantidadeController,
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
                      const SizedBox(height: 15),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton.icon(
                          onPressed: adicionarIngrediente,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Adicionar ao Estoque'),
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.inventory, color: Colors.orange, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Lista de Ingredientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ingredientes.isEmpty
                    ? const Center(
                  child: Text(
                    'Nenhum ingrediente no estoque. Adicione um!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredientes.length,
                  itemBuilder: (context, index) {
                    final ingrediente = ingredientes[index];
                    String quantidadeExibida;
                    if (ingrediente.quantidade >= 1000 && ingrediente.unidade == 'g') {
                      quantidadeExibida = '${(ingrediente.quantidade / 1000).toStringAsFixed(2)} kg';
                    } else {
                      quantidadeExibida = '${ingrediente.quantidade} ${ingrediente.unidade}';
                    }
                    bool isAviso = ingrediente.quantidade <= 1500 && ingrediente.nome.toLowerCase() == 'mussarela';
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: isAviso ? Colors.orange[50] : Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: const Icon(
                              Icons.local_dining,
                              color: Colors.orange,
                            ),
                          ),
                          title: Text(
                            ingrediente.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            quantidadeExibida,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => excluirIngrediente(ingrediente.id!),
                            tooltip: 'Excluir Ingrediente',
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