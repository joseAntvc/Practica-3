import 'dart:io';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:venta/models/product_model.dart';

class CardProducto extends StatelessWidget {
  const CardProducto({
    super.key,
    required this.producto,
    this.categoria,
    required this.onEditar,
    required this.onEliminar, 
  });
  
  final ProductoModel producto;
  final Function(ProductoModel) onEditar;
  final Function(ProductoModel) onEliminar;
  final String? categoria;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FlipCard(
                front: _front(),
                back: _back(),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(producto.nombre!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 10),
              title: Text(
                '\$${producto.precio!.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.brown[700], fontSize: 15, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 15, color: Colors.brown[700]),
                        SizedBox(width: 5),
                        Text("Editar", style: TextStyle(color: Colors.brown[700])),
                      ],
                    ),
                    onTap: () => onEditar(producto),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 15, color: Colors.brown[700]),
                        SizedBox(width: 5),
                        Text("Eliminar", style: TextStyle(color: Colors.brown[700])),
                      ],
                    ),
                    onTap: () => onEliminar(producto),
                  ),
                ],
                icon: Icon(Icons.more_vert, color: Colors.grey),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget _front(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: producto.imagen != null
          ? Image.file(File(producto.imagen!), fit: BoxFit.cover)
          : Image.asset('assets/default.png', fit: BoxFit.cover),
    );
  }

  Widget _back(){
    const space = SizedBox(height: 12);
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                producto.color != null
                  ? Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(color: Color(int.parse('0xFF${producto.color}')), shape: BoxShape.circle),
                    )
                  : Icon(Icons.remove_circle_outline, color: Colors.grey),
                Text(
                  producto.cantidad! > 0 ? 'Stock: ${producto.cantidad}' : 'Agotado',
                  style: TextStyle(
                    color: producto.cantidad! > 0 ? Colors.brown[700] : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          space,
          RichText( //Este widget es para mostrar texto con diferentes estilos
            text: TextSpan( //El widget TextSpan es un widget que permite mostrar texto con diferentes estilos
              children: [
                TextSpan(text: "Categoria: ", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
                TextSpan(text: categoria, style: TextStyle(color: Colors.grey[800])),
              ],
          )),
          space,
          RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            text: TextSpan(
              children: [
                TextSpan(text: "Descripción: \n", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
                TextSpan(text: producto.descripcion!.isNotEmpty ? producto.descripcion : "Sin descripción", style: TextStyle(color: Colors.grey[800])),
              ],
          )),
        ],
      ),
    );
  }
}
