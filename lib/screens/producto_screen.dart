import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/models/categoria_model.dart';
import 'package:venta/utils/custom_toast.dart';
import 'package:venta/utils/global_values.dart';
import 'package:venta/views/sliver_producto.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({super.key});

  @override
  State<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {

  VentaDatabase? database;
  File? photo;
  TextEditingController conNombre = TextEditingController();
  TextEditingController conDescripcion = TextEditingController();
  TextEditingController conPrecio = TextEditingController();
  TextEditingController conCantidad = TextEditingController();
  List<CategoriaModel> listaCategorias = [];
  CategoriaModel? categoriaSeleccionada;
  Map<String, String?> colores = {
    "Sin color": null,
    "Rojo": "FF0000",
    "Verde": "00FF00",
    "Azul": "0000FF",
    "Amarillo": "FFFF00",
    "Naranja": "FFA500",
    "Morado": "800080",
    "Negro": "000000",
    "Blanco": "FFFFFF",
  };
  String? colorSeleccionado = "Sin color"; 
  final _formKey = GlobalKey<FormState>(); 
  bool isLoading = true; //Como es un futuro lo de las categorias, lo que pasa es que se muestra el mensaje aunque haya categorias

  @override
  void initState() {
    super.initState();
    database = VentaDatabase();
    cargarCategorias();
  }

  void cargarCategorias() async {
    final categorias = await database!.obtenerCategoria();
    setState(() {
      listaCategorias = categorias;
      isLoading = false;
    });
  }

  SliverToBoxAdapter encabezado(String titulo){
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(titulo, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[700])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : listaCategorias.isEmpty ? 
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No hay categorías registradas. Por favor, registre una categoría primero.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ],
            ),
          ) :
        ValueListenableBuilder(
          valueListenable: GlobalValues.listProducto,
          builder: (context, value, widget) {
            return FutureBuilder(
              future: database?.obtenerProducto(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay productos disponibles.'));
                  } else {
                    final productos = snapshot.data!;
                    final productosDisponibles = productos.where((p) => p.cantidad! > 0).toList();
                    final productosAgotados = productos.where((p) => p.cantidad == 0).toList();
                    return CustomScrollView(
                      physics: BouncingScrollPhysics(), //Es una animacion como de rebote
                      slivers: [
                        encabezado("Disponibles"),
                        SliverProducto(
                          productos: productosDisponibles,
                          categorias: listaCategorias,
                          onEditar: (producto) => _editarProducto(producto),
                          onEliminar: (producto) => _eliminarProducto(producto),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 30), // Ajusta esta altura según el tamaño
                        ),
                        encabezado("Agotados"),
                        SliverProducto(
                          productos: productosAgotados,
                          categorias: listaCategorias,
                          onEditar: (producto) => _editarProducto(producto),
                          onEliminar: (producto) => _eliminarProducto(producto),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 90), // Ajusta esta altura según el tamaño
                        ),
                      ],
                    );
                  }
                }
              );
            }
          ),
      floatingActionButton: isLoading || listaCategorias.isEmpty ? null :
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: () => _dialogBuilder(context),
            icon: Icon(Icons.add, color: Colors.white,),
            label: Text('Agregar Producto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Montserrat-Medium")),
          ),
        ),
    );
  }
  void _editarProducto(producto) {
    photo = producto.imagen != null ? File(producto.imagen!) : null;
    conNombre.text = producto.nombre!;
    conDescripcion.text = producto.descripcion!;
    conPrecio.text = producto.precio!.toString();
    conCantidad.text = producto.cantidad!.toString();
    colorSeleccionado = colores.keys.firstWhere((key) => colores[key] == producto.color);
    categoriaSeleccionada = listaCategorias.firstWhere((cat) => cat.idCategoria == producto.idCategoria);
    _dialogBuilder(context, idProducto: producto.idProducto!);
  }

  void _eliminarProducto(producto) async {
    final estaEnPedido = await database!.productoEnPedido(producto.idProducto!);
    if (estaEnPedido) {
      CustomToast.show(context, "No se puede eliminar el producto porque está asociado a un pedido.", isError: true);
    } else {
      final resultado = await database!.eliminar('producto', producto.idProducto!, 'idProducto');
      if (resultado > 0) {
        GlobalValues.listProducto.value = !GlobalValues.listProducto.value;
      }
    }
  }


  void limpiarCampos() {
    conNombre.clear();
    conDescripcion.clear();
    conPrecio.clear();
    conCantidad.clear();
    colorSeleccionado = "Sin color";
    categoriaSeleccionada = null;
    photo = null;
  }

  InputDecoration customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.brown, width: 2),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, {int idProducto = 0}) {
    idProducto == 0 ? limpiarCampos() : null;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setModalState) {
            return AlertDialog(
              title: idProducto == 0 ? Text('Agregar producto') : Text('Editar producto'),
              content: SizedBox(
                height: 520,
                width: 280,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => showOptions(setModalState),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent, //Se ocupan ambos para que no se vea el color gris al momento de dar click
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.brown[400],
                                  backgroundImage: photo == null ? null : FileImage(photo!),
                                  child: photo == null ? Icon(Icons.add_a_photo, color: Colors.white, size: 50) : null,
                                ),
                              ),
                              TextFormField(
                                textCapitalization: TextCapitalization.sentences,
                                decoration: customInputDecoration('Nombre'),
                                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                                controller: conNombre,
                              ),
                              TextFormField(
                                textCapitalization: TextCapitalization.sentences,
                                decoration: customInputDecoration('Descripción'),
                                controller: conDescripcion,
                                maxLines: 3,
                              ),
                              TextFormField(
                                decoration: customInputDecoration('Precio'),
                                controller: conPrecio,
                                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                                keyboardType: TextInputType.numberWithOptions(decimal: true), //Acepta decimales
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), //Acepta solo numeros y hasta 2 decimales
                                ],
                              ),
                              TextFormField(
                                decoration: customInputDecoration('Cantidad'),
                                controller: conCantidad,
                                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, //Acepta solo numeros
                                ],
                              ),
                              DropdownButtonFormField(
                                menuMaxHeight: 200,
                                dropdownColor: Colors.white,
                                decoration: customInputDecoration('Color'),
                                value: colorSeleccionado,
                                items: colores.keys.map((color) {
                                  return DropdownMenuItem(
                                    value: color,
                                    child: Row(
                                      children: [
                                        colores[color] != null
                                            ? Container(
                                                width: 20, height: 20,
                                                decoration: BoxDecoration(
                                                  color: Color(int.parse('0xFF${colores[color]}')), 
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(color: Colors.grey, blurRadius: 0.5),
                                                  ],
                                                ),
                                              )
                                            : Icon(Icons.remove_circle_outline, color: Colors.grey), // "Sin color"
                                        SizedBox(width: 10),
                                        Text(color),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (color) {
                                  setModalState(() {
                                    colorSeleccionado = color;
                                  });
                                },
                              ),
                              DropdownButtonFormField(
                                menuMaxHeight: 200,
                                dropdownColor: Colors.white,
                                decoration: customInputDecoration('Categoría'),
                                value: categoriaSeleccionada,
                                validator: (value) => value == null ? 'Campo requerido' : null,
                                items: listaCategorias.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat.nombre!),
                                  );
                                }).toList(),
                                onChanged: (CategoriaModel? nuevaCategoria) {
                                  setModalState(() {
                                    categoriaSeleccionada = nuevaCategoria;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if(idProducto == 0){
                                database!.insertar('producto', {
                                  "nombre": conNombre.text.trim(),
                                  "descripcion": conDescripcion.text,
                                  "precio": conPrecio.text,
                                  "imagen": photo?.path,
                                  "cantidad": conCantidad.text,
                                  "color": colores[colorSeleccionado],
                                  "idCategoria": categoriaSeleccionada?.idCategoria
                                }).then((value) {
                                  GlobalValues.listProducto.value = !GlobalValues.listProducto.value;
                                  CustomToast.show(context, "Producto agregado correctamente");
                                });
                              } else { 
                                database!.actualizar('producto', {
                                  "idProducto": idProducto,
                                  "nombre": conNombre.text.trim(),
                                  "descripcion": conDescripcion.text,
                                  "precio": conPrecio.text,
                                  "imagen": photo?.path,
                                  "cantidad": conCantidad.text,
                                  "color": colores[colorSeleccionado],
                                  "idCategoria": categoriaSeleccionada?.idCategoria
                                }, 'idProducto').then((value){
                                  GlobalValues.listProducto.value = !GlobalValues.listProducto.value;
                                  CustomToast.show(context, "Producto actualizado correctamente");
                                });
                              }
                              Navigator.pop(context);
                            }
                          },
                          child: idProducto == 0 ? Text('Agregar', style: TextStyle(color: Colors.white,)) : Text('Actualizar', style: TextStyle(color: Colors.white,)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  //Sirve para obtener la imagen del usuario desde galaeria o camara
  Future<void> pickImage(ImageSource source, StateSetter setModalState) async {
    final pickedPhoto = await ImagePicker().pickImage(source: source);
    if (pickedPhoto != null) {
      setModalState(() {
        photo = File(pickedPhoto.path);
      });
    }
  }
  //Son las opciones para seleccionar la imagen del usuario
  void showOptions(StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(leading: Icon(Icons.camera), title: Text("Tomar foto"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera, setModalState);
                },
              ),
              ListTile(leading: Icon(Icons.photo_library),title: Text("Seleccionar de la galería"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery, setModalState);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}