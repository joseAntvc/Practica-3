import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
             //todo: cubre toda la pantalla con la imagen
            alignment: Alignment.center, //todo: Alinea la imagen a la derecha
            image: AssetImage("assets/logo.png"),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width * .8,
              bottom: 48,
              child: Column(
                children: [
                  const SizedBox(height: 25),// * Es para meter una separacion entre el texto y el boton
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, "/home");
                    },  
                    child: Container(
                      height: 52,
                      width: MediaQuery.of(context).size.width * .79,
                      padding: EdgeInsets.symmetric(horizontal: 44, vertical: 16),//todo: para poder meter un pading de 44 y 16
                      alignment: Alignment.center,// * alinear el texto al centro, el boton
                      decoration: BoxDecoration(
                        color: Colors.brown[700],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text("Empecemos...", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "Montserrat-Medium")),
                    ),
                  ),
                ],
              ))
          ],
        ),
      ),
    );
  }
}
