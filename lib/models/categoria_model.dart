class CategoriaModel {
  int? idCategoria;
  String? nombre;

  CategoriaModel({
    this.idCategoria, 
    this.nombre
  });

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      idCategoria: map['idCategoria'],
      nombre: map['nombre'],
    );
  }

  get id => null;
}