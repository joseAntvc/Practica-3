import 'dart:io';

import 'package:flutter/material.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/models/categoria_model.dart';
import 'package:badges/badges.dart' as badges;
import 'package:venta/utils/global_values.dart';

class PedidoProdScreen extends StatefulWidget {
  const PedidoProdScreen({super.key});

  @override
  State<PedidoProdScreen> createState() => _PedidoProdScreenState();
}

class _PedidoProdScreenState extends State<PedidoProdScreen> {

  @override
  Widget build(BuildContext context) {
    final categoria = ModalRoute.of(context)!.settings.arguments as CategoriaModel;
    final database = VentaDatabase();
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Productos:"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ValueListenableBuilder(
              valueListenable: PedidoGlobal.totalProductos,
              builder: (context, value, widget) {
                return badges.Badge(
                  badgeAnimation: badges.BadgeAnimation.fade(),
                  position: badges.BadgePosition.topEnd(top: 0, end: 0),
                  badgeContent: Text("$value", style: TextStyle(color: Colors.white, fontSize: 10)),
                  badgeStyle: badges.BadgeStyle(badgeColor: Colors.brown[300]!),
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/detallePedido');
                    },
                  ),
                );
              }
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: database.obtenerProductosPorCategoria(categoria.idCategoria!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Text(categoria.nombre!, style: TextStyle(fontSize: 25, color: Colors.brown[700])),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(right: 20, left: 20, bottom: 30, top: 10),
                  sliver: SliverList.separated(
                    separatorBuilder: (context, index) => Divider(color: Colors.brown[200]),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                    final producto = snapshot.data![index];
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
                                    style: TextStyle(fontSize: 15, color: Colors.brown[600]),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => PedidoGlobal.quitarProducto(producto),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: PedidoGlobal.totalProductos,
                                  builder: (context, value, widget) {
                                    return Text('${PedidoGlobal.productos[producto] ?? 0}');
                                  }
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => PedidoGlobal.agregarProducto(producto)
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}