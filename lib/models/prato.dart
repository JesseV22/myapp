import 'dart:convert';

class Prato {
  int? id;
  final String nome;
  final List<Map<String, dynamic>> ingredientes;

  Prato({
    this.id,
    required this.nome,
    required this.ingredientes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ingredientes': jsonEncode(ingredientes), // Serializa como JSON
    };
  }

  factory Prato.fromMap(Map<String, dynamic> map) {
    return Prato(
      id: map['id'],
      nome: map['nome'],
      ingredientes: List<Map<String, dynamic>>.from(jsonDecode(map['ingredientes'])),
    );
  }
}