import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:venta/database/venta_database.dart';
import 'package:venta/utils/global_values.dart';

class PedidoCatScreen extends StatefulWidget {
  const PedidoCatScreen({super.key});

  @override
  State<PedidoCatScreen> createState() => _PedidoCatScreenState();
}

class _PedidoCatScreenState extends State<PedidoCatScreen> {
  @override
  Widget build(BuildContext context) {
    final database = VentaDatabase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
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
        future: database.obtenerCategoriasConProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            var categorias = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  sliver: SliverList.separated(
                    itemCount: categorias.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.brown[200]!, width: 1.5),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          title: Center(
                            child: Text(
                              categoria.nombre!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[700],
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, "/pedidoProd", arguments: categoria);
                          },
                          splashColor: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}