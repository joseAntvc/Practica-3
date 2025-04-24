import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:venta/screens/categoria_screen.dart';
import 'package:venta/screens/detalle_pedido_screen.dart';
import 'package:venta/screens/home_screen.dart';
import 'package:venta/screens/login_screen.dart';
import 'package:venta/screens/pedido_cat_screen.dart';
import 'package:venta/screens/pedido_prod_screen.dart';
import 'package:venta/screens/pedido_screen.dart';
import 'package:venta/screens/producto_screen.dart';
import 'package:venta/services/noti_service.dart';
import 'package:venta/utils/custom_theme.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.themeBrown(),
      title: 'Ventas',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'), // Español
        Locale('en', 'US'), // Inglés
      ],
      routes: {
        '/home': (context) => const HomeScreen(),
        '/producto': (context) => const ProductoScreen(),
        '/categoria': (context) => const CategoriaScreen(),
        '/pedido': (context) => const PedidoScreen(),
        '/pedidoCat': (context) => const PedidoCatScreen(),
        '/pedidoProd': (context) => const PedidoProdScreen(),
        '/detallePedido': (context) => const DetallePedidoScreen(),
      },
      home: LoginScreen()
    );
  }
}
