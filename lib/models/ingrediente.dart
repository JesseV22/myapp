class Ingrediente {
  int? id;
  final String nome;
  int quantidade;
  final String unidade;

  Ingrediente({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.unidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
      unidade: map['unidade'] ?? 'unidade', // Valor padrão caso esteja ausente
    );
  }
}