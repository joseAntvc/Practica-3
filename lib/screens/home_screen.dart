import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venta/database/venta_database.dart';
import 'package:venta/models/pedido_model.dart';
import 'package:venta/services/noti_service.dart';
import 'package:venta/utils/custom_toast.dart';
import 'package:venta/utils/global_values.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  VentaDatabase? database;
  TextEditingController conNombre = TextEditingController();
  late TabController tabController;
  final List<String> estados = ['Todos', 'En Proceso', 'Cumplidos', 'Cancelados'];
  final Map<int, Icon> estadosIconos = {
    1: Icon(Icons.schedule_rounded, color: Colors.brown[700]), //1: En Proceso
    2: Icon(Icons.check_circle_outline_rounded, color: Colors.green), //2: Cumplidos
    3: Icon(Icons.cancel_outlined, color: Colors.red),
  };
  Map<DateTime, List<Map<String, dynamic>>> eventos = {};

  @override
  void initState() {
    super.initState();
    database = VentaDatabase();
    tabController = TabController(length: estados.length, vsync: this);
    tabController.addListener(() {
      // * Solo si se completó el cambio de pestaña
      if (tabController.indexIsChanging == false && GlobalValues.calendario) {
        cargarEventos(tabController.index);
      }
    });
    if (GlobalValues.calendario) { cargarEventos(0);}
  }

  @override
  void dispose() {//todo: para liberar recursos
    super.dispose();
    tabController.dispose();
  } 

  Future<void> cargarEventos(int index) async {
    List<PedidoModel> pedidos = await database!.obtenerPedido(index); 
    Map<DateTime, List<Map<String, dynamic>>> eventosAgrupados = {};
    for (var pedido in pedidos) {
      DateTime fecha = DateFormat('yyyy-MM-dd').parse(pedido.fecha!);
      if (!eventosAgrupados.containsKey(fecha)) {
        eventosAgrupados[fecha] = [];
      }
      eventosAgrupados[fecha]!.add({
        "cliente": pedido.cliente,
        "total": pedido.total,
        "estatus": pedido.estatus,
        "idPedido": pedido.idPedido
      });
    }
    setState(() {
      eventos = eventosAgrupados;
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            icon: Icon(GlobalValues.calendario ? Icons.view_list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                GlobalValues.calendario = !GlobalValues.calendario; // Alternar entre vistas
                if(GlobalValues.calendario) { cargarEventos(tabController.index); }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          onTap: (index){
            if(GlobalValues.calendario) { cargarEventos(index); }
          },
          padding: const EdgeInsets.symmetric(horizontal: 10),
          labelPadding: EdgeInsets.zero, // Espacio entre las pestañas
          isScrollable: true, // Es para que se pueda desplazar la barra
          tabAlignment: TabAlignment.start,// !!! Algo importante, se me alineaba la barra como en centro, entonces dejaba mucho espacio, con esto ya no
          labelColor: Colors.white, //Color del texto de la pestaña seleccionada
          labelStyle: TextStyle(fontFamily: "Montserrat-Medium", fontSize: 14, fontWeight: FontWeight.bold), //Estilo del texto de la pestaña seleccionada
          unselectedLabelColor: Colors.brown[200], //Color del texto de la pestaña no seleccionada
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Montserrat-Medium", fontSize: 14),//Estilo del texto de la pestaña no seleccionada
          indicatorWeight: 0,
          indicator: BoxDecoration(),
          dividerColor: Colors.transparent,//todo: para quitar la linea fea que se pone abajo de los tabs
          physics: BouncingScrollPhysics(),//todo: para que haga el efecto de rebote
          overlayColor: WidgetStateProperty.all(Colors.transparent), // Para quitar el color gris que aparece al seleccionar la pestaña
          tabs: estados.asMap().entries.map((entry) {
            int index = entry.key; //Es el indice de la lista
            String estado = entry.value; //Es el valor de la lista
            return AnimatedBuilder( // todo: Con este widget, se puede animar el cambio de color de la pestaña al seleccionarla, no se utiliza el indicator
              animation: tabController.animation!, // Se le pasa la animacion del tabController
              builder: (context, child) {
                double selectedValue = tabController.animation!.value; //Es un valor decimal que tiene el tabcontroller, que va de 0 a 3, dependiendo de la pestaña seleccionada
                // !! Es un valor booleano que indica si la pestaña esta seleccionada o no, se le pasa el valor del tabcontroller y se le resta el indice de la pestaña, si es menor a 0.5, significa que esta seleccionada
                // * Es para poder controlar cuando se hace el swipe entre las pestañas, pero sin esto se hace lento el swipe del tabbar
                bool isSelected = (selectedValue - index).abs() < 0.5; 
                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.brown[400] : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: index == 0 ? Radius.circular(15) : Radius.zero,
                      right: index == estados.length - 1 ? Radius.circular(15) : Radius.zero,
                    ),
                    border: Border.all(color: Colors.brown[200]!, width: 2),
                  ),
                  child: Tab(text: estado),
                );
              },
            );
          }).toList(),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(color: Colors.brown[700]),
              child: Text('Operaciones disponibles', style: TextStyle(color: Colors.white, fontSize: 30), textAlign: TextAlign.center,),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/producto"),
              leading: Icon(Icons.checkroom_rounded),
              title: Text("Productos"),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/categoria"),
              leading: Icon(Icons.category_rounded),
              title: Text("Categorias"),
              trailing: Icon(Icons.chevron_right),
            ),
          ]
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List.generate(estados.length, (index) {
          if(GlobalValues.calendario){
            // Mostrar el calendario
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: TableCalendar(
                locale: 'es',
                availableCalendarFormats: {
                  CalendarFormat.month: 'Month', // Solo habilita la vista mensual
                },
                firstDay: DateTime.utc(2024),
                lastDay: DateTime.utc(DateTime.now().year + 1,12,31),
                focusedDay: DateTime.now(),
                onDaySelected: (selectedDay, focusedDay) {
                  DateTime fecha = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  List<Map<String, dynamic>> eventosDelDia = eventos[fecha] ?? [];
                  _eventosDia(context, fecha, eventosDelDia);
                },
                eventLoader: (day) {
                  DateTime fecha = DateTime(day.year, day.month, day.day);
                  return eventos[fecha]?.map((e) => e["descripcion"]).toList() ?? [];
                },
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.brown[700]),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.brown[700]),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.brown[400], shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.brown[700], shape: BoxShape.circle),
                  defaultTextStyle: TextStyle(color: Colors.brown[700]),
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                  outsideDaysVisible: false
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.brown[700]),
                  weekendStyle: TextStyle(color: Colors.redAccent),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    DateTime day = DateTime(date.year, date.month, date.day);
                    if (eventos[day] != null && eventos[day]!.isNotEmpty) {
                      // Crear una lista de colores basada en los estatus de los eventos
                      List<Color> colores = eventos[day]!.map((evento) {
                        int estatus = evento["estatus"];
                        switch (estatus) {
                          case 1: return Colors.brown[700]!; // En Proceso
                          case 2: return Colors.green; // Cumplidos
                          case 3: return Colors.red; // Cancelados
                          default: return Colors.transparent;
                        }
                      }).toList();
                      // Generar los círculos para cada color
                      return Positioned(
                        bottom: 4,
                        child: Wrap(
                          spacing: 2, // Espaciado entre los círculos
                          children: colores.map((color) {
                            return Container(width: 6, height: 6,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            );
          } else {
            return ValueListenableBuilder(
              valueListenable: GlobalValues.listPedidos,
              builder: (context, value, widget) {
                return FutureBuilder(
                  future: database!.obtenerPedido(index),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No hay pedidos"));
                    } else {
                      return ListView.separated(
                        separatorBuilder: (context, index) => SizedBox(height: 10),
                        padding: const EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 100),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var obj = snapshot.data![index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: estadosIconos[obj.estatus],
                              title: Text("Pedido de ${obj.cliente}", style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  RichText( //Este widget es para mostrar texto con diferentes estilos
                                    text: TextSpan( //El widget TextSpan es un widget que permite mostrar texto con diferentes estilos
                                      children: [
                                        TextSpan(text: "Fecha: ", style: TextStyle(fontSize: 14, color: Colors.brown[700], fontWeight: FontWeight.bold)),
                                        TextSpan(text: DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(obj.fecha!)), style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                                      ],
                                  )),
                                  SizedBox(height: 5),
                                  RichText( //Este widget es para mostrar texto con diferentes estilos
                                    text: TextSpan( //El widget TextSpan es un widget que permite mostrar texto con diferentes estilos
                                      children: [
                                        TextSpan(text: "Total: ", style: TextStyle(fontSize: 14, color: Colors.brown[700], fontWeight: FontWeight.bold)),
                                        TextSpan(text: obj.total!.toStringAsFixed(2), style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                                      ],
                                  )),
                                  SizedBox(height: 5),
                                if (obj.nota!.isNotEmpty)
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: "Nota: ", style: TextStyle(fontSize: 14, color: Colors.brown[700], fontWeight: FontWeight.bold)),
                                        TextSpan(text: obj.nota, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  obj.estatus != 1
                                  ? IconButton(onPressed: null, icon: Icon(Icons.update_rounded, color: Colors.grey[300]))
                                  : PopupMenuButton(
                                      tooltip: 'Actualizar Estatus',
                                      icon: Icon(Icons.update_rounded, color: Colors.brown[700]),
                                      offset: Offset(-40, -32),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 2,
                                          child: Row( spacing: 5,
                                            children: [
                                              estadosIconos[2]!,
                                              Text(estados[2], style: TextStyle(color: Colors.brown[700])),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 3,
                                          child: Row( spacing: 5,
                                            children: [
                                              estadosIconos[3]!,
                                              Text(estados[3], style: TextStyle(color: Colors.brown[700])),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (estatus) async {    
                                        final confirmado = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('¿Estás seguro?'),
                                            content: Column(
                                              spacing: 10,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Esta acción no se puede revertir. Has elegido...'),
                                                Row(
                                                  spacing: 5,
                                                  children: [
                                                    estadosIconos[estatus]!,
                                                    Text(estados[estatus])
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('Cancelar', style: TextStyle(color: Colors.brown)),
                                                onPressed: () => Navigator.of(context).pop(false),
                                              ),
                                              ElevatedButton(
                                                child: Text('Continuar', style: TextStyle(color: Colors.white)),
                                                onPressed: () => Navigator.of(context).pop(true),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmado != true) return; // Si no confirmó, no se hace nada
                                        database!.actualizarEstatusPedido(obj.idPedido!, estatus);
                                        NotiService().cancelNotification(obj.idPedido!);
                                        if (estatus == 3) {
                                          final detalles = await database!.obtenerDetallesPedido(obj.idPedido!);
                                          for (var detalle in detalles) {
                                            final producto = await database!.obtenerProductoPorId(detalle.idProducto!);
                                            database!.actualizarCantidadProducto(producto.idProducto!, (producto.cantidad ?? 0) + detalle.cantidad!);
                                          }
                                        }
                                        GlobalValues.listPedidos.value = !GlobalValues.listPedidos.value;
                                        CustomToast.show(context, "Estatus actualizado");
                                      },
                                    ),
                                  IconButton(
                                    onPressed: obj.estatus == 1 
                                    ? () async {
                                      final detalles = await database!.obtenerDetallesPedido(obj.idPedido!);
                                      PedidoGlobal.actualizarPedido(obj);
                                      for (var detalle in detalles) {
                                        final producto = await database!.obtenerProductoPorId(detalle.idProducto!);
                                        database!.actualizarCantidadProducto(producto.idProducto!, (producto.cantidad ?? 0) + detalle.cantidad!);
                                        PedidoGlobal.productos[producto] = detalle.cantidad!;
                                      }
                                      PedidoGlobal.actualizarTotalProductos();
                                      Navigator.pushNamed(context, '/pedido');
                                    } : null,
                                    tooltip: 'Editar',
                                    disabledColor: Colors.grey[300],
                                    color: Colors.brown[700],
                                    icon: Icon(Icons.edit),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }
            );
          }
        }),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, "/pedido"),
          icon: Icon(Icons.add, color: Colors.white,),
          label: Text('Agregar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Montserrat-Medium")),
        ),
      ),
    );
  }

  void _eventosDia(BuildContext context, DateTime fecha, List<Map<String, dynamic>> eventosDelDia) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permitir que el modal ocupe toda la pantalla
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7, // Tamaño inicial del modal (70% de la pantalla)
          maxChildSize: 1.0, // Tamaño máximo del modal (100% de la pantalla)
          minChildSize: 0.5, // Tamaño mínimo del modal (50% de la pantalla)
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Eventos del ${DateFormat('dd/MM/yyyy').format(fecha)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[700]),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: eventosDelDia.length,
                    itemBuilder: (context, index) {
                      final evento = eventosDelDia[index];
                      // Obtener los detalles del pedido
                      return FutureBuilder(
                        future: database!.obtenerDetallesConNombreProducto(evento["idPedido"]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text("Error al cargar los detalles"));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text("No hay productos para este pedido"));
                          } else {
                            final detalles = snapshot.data!;
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Padding( padding: const EdgeInsets.all(16.0),
                                child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row( spacing: 10,
                                      children: [
                                        estadosIconos[evento["estatus"]]!,
                                        Expanded(
                                          child: Text(
                                            evento["cliente"], // Asegúrate de que "cliente" esté presente en el mapa evento
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                                          ),
                                        ),
                                        Text(
                                          "Total: \$${evento["total"]}", // Asegúrate de que "total" esté presente en el evento
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Divider(color: Colors.brown[100]),
                                    ...detalles.map((detalle) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row( spacing: 12,
                                        children: [
                                          Icon(Icons.shopping_bag, size: 16, color: Colors.brown[200]),     
                                          Text("${detalle["cantidad"]}x", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[600])),
                                          Expanded(child: Text(detalle["nombre"], style: TextStyle(color: Colors.grey[800]), overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}