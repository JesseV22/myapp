class Prato {
  int? id;
  String nome;
  List<Map<String, dynamic>> ingredientes; // Ex.: [{'nome': 'Bacon', 'quantidade': 100}, {'nome': 'Tomate', 'quantidade': 200}]

  Prato({this.id, required this.nome, required this.ingredientes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ingredientes': ingredientes.map((i) => '${i['nome']}:${i['quantidade']}').join(','),
    };
  }

  factory Prato.fromMap(Map<String, dynamic> map) {
    final ingredientesStr = (map['ingredientes'] as String).split(',');
    final ingredientes = ingredientesStr.map((str) {
      final parts = str.split(':');
      if (parts.length != 2) return null;
      final quantidade = int.tryParse(parts[1]);
      if (quantidade == null || quantidade <= 0) return null;
      return {'nome': parts[0].trim(), 'quantidade': quantidade};
    }).whereType<Map<String, dynamic>>().toList();
    return Prato(
      id: map['id'],
      nome: map['nome'],
      ingredientes: ingredientes,
    );
  }
}