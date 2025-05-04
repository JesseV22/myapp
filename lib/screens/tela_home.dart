import 'package:flutter/material.dart';
import 'estoque_screen.dart';
import 'cardapio_screen.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prato Certo')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu', style: TextStyle(fontSize: 24))),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Estoque'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Cardápio'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CardapioScreen()));
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Bem-vindo ao Prato Certo!', style: TextStyle(fontSize: 20))),
    );
  }
}