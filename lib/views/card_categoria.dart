import 'package:flutter/material.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/utils/custom_toast.dart';
import 'package:venta/utils/global_values.dart';
import 'package:venta/models/categoria_model.dart'; // Asegúrate de tener este modelo

class CardCategoria extends StatelessWidget {
  const CardCategoria({
    super.key,
    required this.categoria,
    required this.conNombre,
    required this.database,
    required this.onEdit,
  });

  final CategoriaModel categoria;
  final TextEditingController conNombre;
  final VentaDatabase database;
  final void Function(BuildContext context, {int idCategoria}) onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(categoria.nombre!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                conNombre.text = categoria.nombre!;
                onEdit(context, idCategoria: categoria.idCategoria!);
              },
              tooltip: 'Editar',
              icon: Icon(Icons.edit, color: Colors.brown[700]),
            ),
            IconButton(
              onPressed: () async {
                bool tieneProductos = await database.tieneProductosRelacionados(categoria.idCategoria!);
                if (tieneProductos) {
                  CustomToast.show(context, "Hay productos relacionados a esta categoría, no se puede eliminar.", isError: true);
                } else {
                  database.eliminar('categoria', categoria.idCategoria!, 'idCategoria').then((value) {
                    if (value > 0) {
                      GlobalValues.listCategoria.value = !GlobalValues.listCategoria.value;
                    }
                  });
                }
              },
              tooltip: 'Eliminar',
              icon: Icon(Icons.delete, color: Colors.brown[700]),
            ),
          ],
        ),
      ),
    );
  }
}
