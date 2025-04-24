class ProductoModel {
  int? idProducto;
  String? nombre;
  String? descripcion;
  double? precio;
  String? imagen;
  int? cantidad;
  String? color;
  int? idCategoria;

  ProductoModel({
    this.idProducto,
    this.nombre,
    this.descripcion,
    this.precio,
    this.imagen,
    this.cantidad,
    this.color,
    this.idCategoria,
  });

  factory ProductoModel.fromMap(Map<String, dynamic> map) {
    return ProductoModel(
      idProducto: map['idProducto'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      precio: map['precio']?.toDouble(),
      imagen: map['imagen'],
      cantidad: map['cantidad'],
      color: map['color'],
      idCategoria: map['idCategoria'],
    );
  }
  @override
  bool operator ==(Object other) { //Es para comparar objetos
    if (identical(this, other)) return true; // Si son el mismo objeto
    if (other is! ProductoModel) return false; // Si no son del mismo tipo
    return idProducto == other.idProducto; // Compara el idProducto
  }

  @override
  int get hashCode => idProducto.hashCode; // Genera un hashcode para el idProducto
}