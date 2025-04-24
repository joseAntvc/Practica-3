import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  //Muestra el mensaje de toast personalizado
  static void show(BuildContext context, String message, {bool isError = false, bool disa = true}) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(100),
      showProgressBar: true, 
      // ignore: deprecated_member_use
      closeButtonShowType: disa ? null : CloseButtonShowType.none,
      dragToClose: disa, // Puede lanzar a un lado el toast al soltarlo
      pauseOnHover: disa, // Pausa el toast cuando el usuario se encuentra encima
    );
  }
}