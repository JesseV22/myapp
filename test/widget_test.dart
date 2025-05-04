import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prato_certo/main.dart';
import 'package:prato_certo/screens/estoque_screen.dart';
import 'package:prato_certo/screens/cardapio_screen.dart';

void main() {
  testWidgets('Verifica se a tela inicial carrega corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PratoCertoApp());
    expect(find.text('Prato Certo'), findsOneWidget);
    expect(find.text('Bem-vindo ao Prato Certo!'), findsOneWidget);
  });

  testWidgets('Verifica se a tela de estoque carrega corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EstoqueScreen()));
    expect(find.text('Estoque'), findsOneWidget);
    expect(find.text('Adicionar Ingrediente'), findsOneWidget);
    expect(find.text('Lista de Ingredientes'), findsOneWidget);
  });

  testWidgets('Verifica se a tela de cardápio carrega corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CardapioScreen()));
    expect(find.text('Cardápio'), findsOneWidget);
    expect(find.text('Adicionar Prato'), findsOneWidget);
    expect(find.text('Lista de Pratos'), findsOneWidget);
  });

  testWidgets('Simula adicionar um prato na tela de cardápio', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CardapioScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'Bacon com Tomate');
    await tester.enterText(find.byType(TextField).at(1), 'Bacon:100, Tomate:200');
    await tester.tap(find.text('Adicionar Prato'));
    await tester.pump();

    expect(find.text('Bacon com Tomate'), findsOneWidget);
    expect(find.text('Ingredientes: Bacon: 100g, Tomate: 200g'), findsOneWidget);
  });
}