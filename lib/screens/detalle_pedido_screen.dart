import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/services/noti_service.dart';
import 'package:venta/utils/custom_toast.dart';
import 'package:venta/utils/global_values.dart';

class DetallePedidoScreen extends StatefulWidget {
  const DetallePedidoScreen({super.key});

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  @override
  Widget build(BuildContext context) {
    final productos = PedidoGlobal.productos;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {}, // No hace nada
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      body: productos.isEmpty
        ? const Center(child: Text('No hay productos en el pedido.'))
        : Center(
          child: Container(
            margin: EdgeInsets.only(top: 20, bottom: 100),
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              separatorBuilder: (context, index) => Divider(color: Colors.brown[200]),
              itemCount: productos.length + 1,
              itemBuilder: (context, index) {
                if(index < productos.length) {
                  final producto = productos.keys.elementAt(index);
                  final cantidad = productos[producto]!;
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      spacing: 30,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: producto.imagen != null
                              ? Image.file(File(producto.imagen!), width: 70, height: 70, fit: BoxFit.cover)
                              : Image.asset('assets/default.png', width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre!,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                              ),
                              Text(
                                "\$${producto.precio!.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 12, color: Colors.brown[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${(producto.precio! * cantidad).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                            ),
                            Text('cant. $cantidad',
                              style: TextStyle(fontSize: 12, color: Colors.brown[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                        ),
                        Text(
                          '\$${PedidoGlobal.totalPrecio().toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      floatingActionButton: productos.isEmpty 
      ? null 
      : SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final database = VentaDatabase();
              final fechaFormateada = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(PedidoGlobal.fecha!));
              final notiService = NotiService();
              if(PedidoGlobal.actulizar){
                database.actualizar('pedido', {
                  "idPedido": PedidoGlobal.idPedido,
                  "fecha": fechaFormateada,
                  "total": PedidoGlobal.totalPrecio(),
                  "cliente": PedidoGlobal.cliente,
                  "estatus": PedidoGlobal.status,
                  "nota": PedidoGlobal.nota,
                  "fechaRecordatorio": DateFormat('dd-MM-yyyy').format(
                    DateFormat('dd-MM-yyyy').parse(PedidoGlobal.fecha!).subtract(Duration(days: 2)),
                  ),
                }, 'idPedido');
                // Eliminar todos los detalles del pedido
                database.eliminar('detalles_pedido', PedidoGlobal.idPedido!, 'idPedido');
                // Insertar los nuevos detalles del pedido
                for (var entry in PedidoGlobal.productos.entries) {
                  final producto = entry.key;
                  final cantidad = entry.value;
                  await database.insertar('detalles_pedido', {
                    "idPedido": PedidoGlobal.idPedido,
                    "idProducto": producto.idProducto,
                    "cantidad": cantidad,
                    "precioUnitario": producto.precio,
                  });
                }
                notiService.cancelNotification(PedidoGlobal.idPedido!);
                notiService.scheduleNotification(
                  id: PedidoGlobal.idPedido!, 
                  cliente: PedidoGlobal.cliente!,
                  fechaRecordatorio: DateFormat('dd-MM-yyyy').format(DateFormat('dd-MM-yyyy').parse(PedidoGlobal.fecha!).subtract(Duration(days: 2))),
                );
                CustomToast.show(context, "Pedido actualizado con éxito");
              } else {
                int idPedido = await database.insertar('pedido', {
                  "fecha": fechaFormateada,
                  "total": PedidoGlobal.totalPrecio(),
                  "cliente": PedidoGlobal.cliente,
                  "estatus": PedidoGlobal.status,
                  "nota": PedidoGlobal.nota,
                  "fechaRecordatorio": DateFormat('dd-MM-yyyy').format(
                    DateFormat('dd-MM-yyyy').parse(PedidoGlobal.fecha!).subtract(Duration(days: 2)),
                  ),
                });
                notiService.scheduleNotification(
                  id: idPedido, 
                  cliente: PedidoGlobal.cliente!,
                  fechaRecordatorio: DateFormat('dd-MM-yyyy').format(DateFormat('dd-MM-yyyy').parse(PedidoGlobal.fecha!).subtract(Duration(days: 2))),
                );
                for (var productos in PedidoGlobal.productos.entries) {
                  final producto = productos.key;
                  final cantidad = productos.value;
                  database.insertar('detalles_pedido', {
                    "idPedido": idPedido,
                    "idProducto": producto.idProducto,
                    "cantidad": cantidad,
                    "precioUnitario": producto.precio,
                  });
                  //Reducir la cantidad del producto en la tabla producto
                  database.actualizarCantidadProducto(producto.idProducto!, producto.cantidad! - cantidad);
                }
                CustomToast.show(context, "Pedido realizado con éxito");
              }
              PedidoGlobal.limpiarPedido();
              Navigator.pushNamedAndRemoveUntil(context, "/home", (Route route) => false);
            },
            label: Text(PedidoGlobal.actulizar ? 'Actualizar Pedido' : 'Finalizar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Montserrat-Medium")),
          ),
        ),
    );
  }
}

/*
Es para poder actualizar los datos sin borrar las tuplas
final detallesActuales = await database.obtenerDetallesPedido(PedidoGlobal.idPedido!);
final detallesMap = { //Genero un mapa con lo que son el id del producto y la cantidad registrada
  for (var detalle in detallesActuales) detalle.idProducto : detalle
};
// Comparar con los productos en el carrito
for (var entry in PedidoGlobal.productos.entries) {
  final producto = entry.key;
  final cantidadCarrito = entry.value;
  if (detallesMap.containsKey(producto.idProducto)) { // Si el producto ya existe en la base de datos, actualiza la cantidad
    final detalle = detallesMap[producto.idProducto]!;
    if (detalle.cantidad != cantidadCarrito) {
      database.actualizar('detalles_pedido', {
        "idDetalle": detalle.idDetalle,
        "cantidad": cantidadCarrito,
        "precioUnitario": producto.precio,
      }, 'idDetalle');
    }
    detallesMap.remove(producto.idProducto);
  } else { // Si el producto no existe en la base de datos, insértalo
    database.insertar('detalles_pedido', {
      "idPedido": PedidoGlobal.idPedido,
      "idProducto": producto.idProducto,
      "cantidad": cantidadCarrito,
      "precioUnitario": producto.precio,
    });
  }
}
for (var detalle in detallesMap.values) { // Eliminar los productos que ya no están en el carrito
  database.eliminar('detalles_pedido', detalle.idDetalle!, 'idDetalle = ?');
}
 */