import 'package:app_ajedrez/components/piece.dart';
import 'package:app_ajedrez/components/square.dart';
import 'package:app_ajedrez/helper/helper_methods.dart';
import 'package:flutter/material.dart';

class Gameboard extends StatefulWidget {
  const Gameboard({super.key});

  @override
  State<Gameboard> createState() => _GameBoardState();
}

 //creacion de piezas
 ChessPiece myPawn = ChessPiece(
  type: ChessPieceType.pawn,
   isWhite: true, 
   imagePath: 'lib/images_dress/pawn.png',
  );

class _GameBoardState extends State<Gameboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
      itemBuilder: (context, index) {
        return Square(
          isWhite: isWhite(index),
          piece: myPawn, 
        );
      }
      ),
    );
  }
}