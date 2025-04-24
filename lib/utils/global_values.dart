import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venta/models/pedido_model.dart';
import 'package:venta/models/product_model.dart';

class GlobalValues{
  static ValueNotifier listCategoria = ValueNotifier(false);
  static ValueNotifier listProducto = ValueNotifier(false);
  static ValueNotifier listPedidos = ValueNotifier(false);
  static bool calendario = false;
}

class PedidoGlobal {
  static bool actulizar = false;
  static String? fecha;
  static String? cliente;
  static String? nota;
  static int? idPedido;
  static int? status = 1;
  static Map<ProductoModel, int> productos = {}; 
  static ValueNotifier<int> totalProductos = ValueNotifier(0);

  static void agregarProducto(ProductoModel producto) {
    final cantidadActual = productos[producto] ?? 0;
    if(cantidadActual < producto.cantidad!) {
      productos[producto] = cantidadActual + 1;
      actualizarTotalProductos();
    }
  }

  static void quitarProducto(ProductoModel producto) {
    final cantidadActual = productos[producto] ?? 0;
    if (cantidadActual > 0) {
      productos[producto] = cantidadActual - 1;
      if (productos[producto] == 0) {
        productos.remove(producto);
      }
      actualizarTotalProductos();
    }
  }

  static void actualizarTotalProductos() {
    totalProductos.value = productos.values.fold(0, (total, cantidad) => total + cantidad);
  }

  static double totalPrecio() {
    return productos.entries.fold(0.0, (total, entry) {
      final producto = entry.key;
      final cantidad = entry.value;
      return total + (cantidad * (producto.precio ?? 0.0));
    });
  }

  static void actualizarPedido(PedidoModel pedido){
    actulizar = true;
    fecha = DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(pedido.fecha!));
    cliente = pedido.cliente;
    nota = pedido.nota;
    status = pedido.estatus;
    idPedido = pedido.idPedido;
  }

  static void limpiarPedido() {
    fecha = null;
    cliente = null;
    nota = null;
    productos.clear();
    totalProductos.value = 0;
    actulizar = false;
    idPedido = null;
    status = 1;
  }
}