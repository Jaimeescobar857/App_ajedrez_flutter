import 'package:app_ajedrez/components/piece.dart';
import 'package:app_ajedrez/values/colors.dart';
import 'package:flutter/material.dart';

//Clase square que representa una casilla del ajedrez
class Square extends StatelessWidget {
  final bool isWhite; // para checar si es un cuadrado blanco o no
  final ChessPiece? piece; //pieza de ajedrez en la casiila (null si es vacia)
  final bool isSelected;//si la casilla está seleccionada
  final bool isValidMove;//si es un mov valido
  final void Function()? onTap;  //cuando se toca la pantalla

  //constructor de la clase
  const Square({
    super.key, 
    required this.isWhite, 
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
    });

  @override
  Widget build(BuildContext context) {
    //almacenar el color de casilla
    Color? squareColor;

    //si la casilla está seleccionada es verde
    if (isSelected) {
      squareColor = Colors.green; 
      //si la casilla es un mov valido se pinta tambien de verde pero mas claro
    } else if (isValidMove){
      squareColor = Colors.green[300];
    }
    
    //si no se selecciona, se pinta de negro o blanco(fondo)
    else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    //detectar toques en la casilla
    return GestureDetector(
      onTap: onTap, //llamar cuando se toca la casilla
      child: Container(
          color: squareColor,
          margin: EdgeInsets.all(isValidMove ? 8 : 0),
          //si hay una pieza en la casilla muestra imagen
          child: piece != null 
            ? Image.asset(
                piece!.imagePath, //ruta de la imagen
                color: piece!.isWhite ? Colors.white : Colors.black, //define el color si la pieza es blanco o negra
              ) 
            : null,
      ),
    );
  }
}