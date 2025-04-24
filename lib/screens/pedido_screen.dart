import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/utils/global_values.dart';
import 'package:badges/badges.dart' as badges;

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {

  TextEditingController conFecha = TextEditingController();
  TextEditingController conCliente = TextEditingController();
  TextEditingController conNota = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    conFecha.text = PedidoGlobal.fecha ?? '';
    conCliente.text = PedidoGlobal.cliente ?? '';
    conNota.text = PedidoGlobal.nota ?? '';
  }

  InputDecoration customInputDecoration(String hint, String prefix) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixStyle: TextStyle(
        color: Colors.brown[700],
        fontWeight: FontWeight.bold,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.brown[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.brown, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[300]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (PedidoGlobal.fecha != null || PedidoGlobal.cliente != null || conFecha.text.isNotEmpty || conCliente.text.isNotEmpty || conNota.text.isNotEmpty) {
          final salir = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('¿Estás seguro?'),
                content: Text(PedidoGlobal.actulizar ? 'Si regresas, se pederan los datos actualizados ya que no se han registrado.' : 'Si regresas, se borrará el pedido actual ya que no se ha registrado.'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false), // No salir
                    child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if(PedidoGlobal.actulizar){
                        final database = VentaDatabase();
                        final detalles = await database.obtenerDetallesPedido(PedidoGlobal.idPedido!);
                        for (var detalle in detalles) {
                          final producto = await database.obtenerProductoPorId(detalle.idProducto!);
                          database.actualizarCantidadProducto(producto.idProducto!, producto.cantidad! - detalle.cantidad!);
                        }
                      }
                      PedidoGlobal.limpiarPedido();
                      Navigator.of(context).pop(true); // Salir
                    },
                    child: Text('Aceptar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
          return salir ?? false; // Si el usuario cancela, no salir
        }
        return true; // Si no hay datos, salir
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(PedidoGlobal.actulizar ? 'Actualizar Pedido' : 'Registrar Pedido'),
          actions: PedidoGlobal.actulizar ? [
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
          ] : null
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width * 0.7,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    readOnly: true,
                    controller: conFecha,
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    decoration: customInputDecoration('Fecha del pedido', 'Fecha: '),
                    onTap: () async {
                      DateTime? dateTodo = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(DateTime.now().year + 1,12,31),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(primary: Colors.brown[400]!),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (dateTodo != null) {
                        String formatDate = DateFormat('dd-MM-yyyy').format(dateTodo);
                        setState(() {
                          conFecha.text = formatDate;
                        });
                      }        
                    },
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: customInputDecoration('Nombre del cliente', 'Cliente: '),
                    controller: conCliente,
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: customInputDecoration('Nota del pedido', 'Notas: '),
                    controller: conNota,
                  ),      
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                PedidoGlobal.fecha = conFecha.text;
                PedidoGlobal.cliente = conCliente.text;
                PedidoGlobal.nota = conNota.text;
                Navigator.pushNamed(context, '/pedidoCat');
              }
            },
            label: Text('Seleccionar productos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Montserrat-Medium")),
          ),
        ),
      ),
    );
  }
}