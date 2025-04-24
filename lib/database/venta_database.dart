import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:venta/models/categoria_model.dart';
import 'package:venta/models/detalle_pedido_model.dart';
import 'package:venta/models/pedido_model.dart';
import 'package:venta/models/product_model.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class VentaDatabase {
  static const NAMEDB = "VENTADB";
  static const VERSION = 1;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database!;
    return _database = await initDatabase();
  }

  Future<Database?> initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, NAMEDB);
    return openDatabase(
      path,
      version: VERSION,
      onCreate: (db, version) {
        // Crear tabla Pedidos
        db.execute('''
          CREATE TABLE pedido (
            idPedido integer primary key,
            fecha varchar(10),
            total numeric,
            cliente varchar(50),
            estatus integer,
            nota text,
            fechaRecordatorio varchar(10)
          )''');

        // Crear tabla Categorías
        db.execute('''
          CREATE TABLE categoria (
            idCategoria integer primary key,
            nombre varchar(25)
          )''');

        // Crear tabla Productos
        db.execute('''
          CREATE TABLE producto (
            idProducto integer primary key,
            nombre varchar(30),
            descripcion text,
            precio numeric,
            imagen text,
            cantidad integer,
            color varchar(15),
            idCategoria integer,
            foreign key(idCategoria) references categoria(idCategoria)
          )''');

        // Crear tabla Detalles del Pedido
        db.execute('''
          CREATE TABLE detalles_pedido (
            idDetalle integer primary key,
            idPedido integer,
            idProducto integer,
            cantidad integer,
            precioUnitario numeric,
            foreign key(idPedido) references pedido(idPedido),
            foreign key(idProducto) references producto(idProducto)
          )''');
      },
    );
  }

  Future<int> insertar(String table, Map<String, dynamic> map) async {
    final con = await database;
    return con!.insert(table, map);
  }

  Future<int> actualizar(String table, Map<String, dynamic> map, String idField) async {
    final con = await database;
    return con!.update(table, map, where: '$idField = ?', whereArgs: [map[idField]]);
  }

  Future<int> eliminar(String table, int id, String idField) async {
    final con = await database;
    return con!.delete(table, where: '$idField = ?', whereArgs: [id]);
  }

  Future<List<ProductoModel>> obtenerProducto() async {
    final con = await database;
    var result = await con!.query('producto');
    return result.map((p) => ProductoModel.fromMap(p)).toList();
  }

  Future<List<CategoriaModel>> obtenerCategoria() async {
    final con = await database;
    var result = await con!.query('categoria', orderBy: 'nombre');
    return result.map((p) => CategoriaModel.fromMap(p)).toList();
  }

  Future<List<PedidoModel>> obtenerPedido(int? estatus) async {
    final con = await database;
    var result = estatus == 0 
      ? await con!.query('pedido', orderBy: 'estatus asc, fecha asc')
      : await con!.query('pedido', where: 'estatus = ?', whereArgs: [estatus], orderBy:'fecha desc');
    return result.map((p) => PedidoModel.fromMap(p)).toList();
  }

  Future<List<DetallePedidoModel>> obtenerDetallesPedido(int idPedido) async {
    final con = await database;
    var result = await con!.query('detalles_pedido', where: 'idPedido = ?', whereArgs: [idPedido]);
    return result.map((p) => DetallePedidoModel.fromMap(p)).toList();
  }

  // Método para saber si una categoría tiene productos relacionados
  Future<bool> tieneProductosRelacionados(int idCategoria) async {
    final con = await database;
    var result = await con!.query('producto', where: 'idCategoria = ?', whereArgs: [idCategoria]);
    return result.isNotEmpty; // Retorna true si hay productos relacionados
  }

  // Método para obtener categorías que tienen productos relacionados
  Future<List<CategoriaModel>> obtenerCategoriasConProductos() async {
    final con = await database;
    var result = await con!.rawQuery('''
      select distinct c.*
        from categoria c join producto p on c.idCategoria = p.idCategoria
        where p.cantidad > 0
        order by c.nombre''');
    return result.map((p) => CategoriaModel.fromMap(p)).toList();
  }

  // Método para obtener productos por categoría
  Future<List<ProductoModel>> obtenerProductosPorCategoria(int idCategoria) async {
    final con = await database;
    var result = await con!.query('producto', where: 'idCategoria = ? and cantidad > 0', whereArgs: [idCategoria]);
    return result.map((p) => ProductoModel.fromMap(p)).toList();
  }

  // Método para obtener detalles de un pedido
  Future<int> actualizarCantidadProducto(int idProducto, int nuevaCantidad) async {
    final con = await database;
    return await con!.update('producto', {"cantidad": nuevaCantidad}, where: 'idProducto = ?', whereArgs: [idProducto]);
  }

  // Metodo para actualizar el estatus
  Future<int> actualizarEstatusPedido(int idPedido, int nuevoEstatus) async {
    final con = await database;
    return await con!.update('pedido',{'estatus': nuevoEstatus}, where: 'idPedido = ?', whereArgs: [idPedido]);
  }

  Future<ProductoModel> obtenerProductoPorId(int idProducto) async {
    final con = await database;
    var result = await con!.query('producto', where: 'idProducto = ?', whereArgs: [idProducto]);
    return ProductoModel.fromMap(result.first);
  }

  Future<List<Map<String, dynamic>>> obtenerDetallesConNombreProducto(int idPedido) async {
    final con = await database;
    var result = await con!.rawQuery('''
      select p.nombre as nombre, d.cantidad as cantidad
      from detalles_pedido d join producto p on d.idProducto = p.idProducto
      where d.idPedido = ?
    ''', [idPedido]);
    return result;
  }

  Future<bool> productoEnPedido(int idProducto) async {
    final con = await database;
    var result = await con!.query('detalles_pedido', where: 'idProducto = ?', whereArgs: [idProducto]);
    return result.isNotEmpty;
  }
}
