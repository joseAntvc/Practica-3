class PedidoModel {
  int? idPedido;
  String? fecha;
  double? total;
  String? cliente;
  int? estatus;
  String? nota;
  String? fechaRecordatorio;

  PedidoModel({
    this.idPedido,
    this.fecha,
    this.total,
    this.cliente,
    this.estatus,
    this.nota,
    this.fechaRecordatorio
  });

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    return PedidoModel(
      idPedido: map['idPedido'],
      fecha: map['fecha'],
      total: map['total']?.toDouble(),
      cliente: map['cliente'],
      estatus: map['estatus'],
      nota: map['nota'],
      fechaRecordatorio: map['fechaRecordatorio']
    );
  }
}
