import 'package:flutter/material.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/views/card_categoria.dart';
import 'package:venta/utils/custom_toast.dart';
import 'package:venta/utils/global_values.dart';

class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({super.key});

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {

  VentaDatabase? database;
  TextEditingController conNombre = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 

  @override
  void initState() {
    super.initState();
    database = VentaDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
      ),
      body: ValueListenableBuilder(
        valueListenable: GlobalValues.listCategoria,
        builder: (context, value, widget) {
          return FutureBuilder(
            future: database?.obtenerCategoria(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay categorías disponibles.'));
              } else {
                return ListView.separated(
                  physics: BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 100),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var obj = snapshot.data![index];
                    return CardCategoria(
                      categoria: obj, 
                      conNombre: conNombre, 
                      database: database!, 
                      onEdit: _dialogBuilder
                    );
                  }
                );
              }
            }
          );
        }
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FloatingActionButton.extended(
          onPressed: () => _dialogBuilder(context),
          icon: Icon(Icons.add, color: Colors.white,),
          label: Text('Agregar Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Montserrat-Medium")),
        ),
      ),
    );
  }


  Future<void> _dialogBuilder(BuildContext context, {int idCategoria = 0}) {
    idCategoria == 0 ? conNombre.clear() : null;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: idCategoria == 0 ? Text('Agregar categoria') : Text('Editar categoria'),
          content: SizedBox(
            height: 200,
            width: 280,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Center(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                        decoration: InputDecoration(
                          hintText: 'Nombre',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown, width: 2),
                          ),
                        ),
                        controller: conNombre,
                        textAlign: TextAlign.center, // Centrar el texto ingresado
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if(idCategoria == 0){
                            database!.insertar('categoria', {
                              "nombre": conNombre.text.trim(),
                            }).then((value) {
                              if(value > 0){
                                GlobalValues.listCategoria.value = !GlobalValues.listCategoria.value;
                                CustomToast.show(context, "Categoria Agregada correctamente");
                                }
                              });
                          } else { 
                            database!.actualizar('categoria', {
                              "idCategoria": idCategoria,
                              "nombre": conNombre.text.trim(),
                            }, 'idCategoria').then((value) {
                              if (value > 0) {
                                GlobalValues.listCategoria.value = !GlobalValues.listCategoria.value;
                                CustomToast.show(context, "Categoria Actualizada correctamente");
                                }
                              },
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: idCategoria == 0 ? Text('Agregar', style: TextStyle(color: Colors.white,)) : Text('Actualizar', style: TextStyle(color: Colors.white,))),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}