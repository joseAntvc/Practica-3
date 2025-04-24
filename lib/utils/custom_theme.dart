
import 'package:flutter/material.dart';

class Themes{
  
  static ThemeData themeBrown(){
    return ThemeData(
      fontFamily: "Montserrat-Regular",
      scaffoldBackgroundColor: const Color(0xFFf7f2E9),
      drawerTheme: DrawerThemeData(
        backgroundColor: Color(0xFFf7f2E9),
      ),
      appBarTheme: AppBarTheme( // ! Son las barras de navegacion
        surfaceTintColor: Color(0xFFF7F2E9),
        backgroundColor: Color(0xFFF7F2E9),
        iconTheme: IconThemeData(color: Colors.brown[700]),
        titleTextStyle: TextStyle(
          color: Colors.brown[700],
          fontSize: 25,
        ),
      ),
      dialogTheme: DialogTheme( // ! Son los modales
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData( // ! Son los botones flotantes
        backgroundColor: Colors.brown[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData( // ! Son los botones elevados (Botones que estan en los modales)
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardTheme( // ! Son las tarjetas
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        color: Colors.white,
      ),
      iconTheme: IconThemeData( // ! Son los iconos
        color: Colors.brown[700],
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Colors.brown[400],
        headerForegroundColor: Colors.white,
        dividerColor: Colors.brown[400],
        locale: const Locale('es', 'MX'),
        cancelButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.brown[400]),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
        confirmButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.brown[400]),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.brown,
        selectionColor: Colors.brown[100],
        selectionHandleColor: Colors.brown, 
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Color(0xFFf7f2E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
      ),
    );
  }
}