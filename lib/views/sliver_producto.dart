import 'package:flutter/material.dart';
import 'package:venta/models/categoria_model.dart';
import 'package:venta/models/product_model.dart';
import 'package:venta/views/card_producto.dart';

class SliverProducto extends StatelessWidget {
  const SliverProducto({super.key, required this.productos, required this.categorias, required this.onEditar, required this.onEliminar});

  final List<ProductoModel> productos;
  final List<CategoriaModel> categorias;
  final void Function(ProductoModel) onEditar;
  final void Function(ProductoModel) onEliminar;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //Numero de colomunas
          childAspectRatio: 0.6, //Para que sean mas altos
          crossAxisSpacing: 10, //Espacio horizontal
          mainAxisSpacing: 10, //Espacio vertical
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final obj = productos[index]; 
            return CardProducto(
              producto: obj,
              categoria: categorias.firstWhere((cat) => cat.idCategoria == obj.idCategoria).nombre,
              onEditar: (producto) => onEditar(producto),
              onEliminar: (producto) => onEliminar(producto),
            );
          },
          childCount: productos.length,
        ),
      ),
    );
  }
}