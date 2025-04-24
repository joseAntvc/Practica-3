class DetallePedidoModel {
  int? idDetalle;
  int? idPedido;
  int? idProducto;
  int? cantidad;
  double? precioUnitario;

  DetallePedidoModel({
    this.idDetalle,
    this.idPedido,
    this.idProducto,
    this.cantidad,
    this.precioUnitario,
  });

  factory DetallePedidoModel.fromMap(Map<String, dynamic> map) {
    return DetallePedidoModel(
      idDetalle: map['idDetalle'],
      idPedido: map['idPedido'],
      idProducto: map['idProducto'],
      cantidad: map['cantidad'],
      precioUnitario: map['precioUnitario']?.toDouble(),
    );
  }
}
