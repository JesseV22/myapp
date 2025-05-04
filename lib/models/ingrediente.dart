class Ingrediente {
  int? id;
  String nome;
  int quantidade;

  Ingrediente({this.id, required this.nome, required this.quantidade});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
    );
  }
}