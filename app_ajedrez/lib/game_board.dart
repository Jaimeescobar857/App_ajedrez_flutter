import 'package:app_ajedrez/components/piece.dart';
import 'package:app_ajedrez/components/square.dart';
import 'package:app_ajedrez/helper/helper_methods.dart';
import 'package:app_ajedrez/values/colors.dart';
import 'package:flutter/material.dart';

class Gameboard extends StatefulWidget {
  const Gameboard({super.key});

  @override
  State<Gameboard> createState() => _GameBoardState();
}

 

class _GameBoardState extends State<Gameboard> {

//una lista en 2d para representar el tablero
//con cada posicion posible que contiene un pieza de ajedrez
late List<List<ChessPiece?>>board; 

@override
  void initState() {
    super.initState();
    initializedBoard();
    

  }

//Iniciamos el tablero 
void initializedBoard() {
  //iniciamos el tablero con las piezas en sus posiciones
  List<List<ChessPiece?>> newBoard =
    List.generate(8, (index) => List.generate(8, (index) => null));
  
  //place pawns 
  for (int i = 0; i < 8; i++) {
    newBoard[1][i] = ChessPiece(
      type: ChessPieceType.pawn,
       isWhite: false,
        imagePath: 'lib/images_dress/pawn.png',
    );
    newBoard[6][i] = ChessPiece(
      type: ChessPieceType.pawn,
       isWhite: true,
        imagePath: 'lib/images_dress/pawn.png',
    );
  }
  //place rooks 
  newBoard[0][0] = ChessPiece(
    type: ChessPieceType.rook,
     isWhite: false,
      imagePath: 'lib/images_dress/rook.png',
  );
  newBoard[0][7] = ChessPiece(
    type: ChessPieceType.rook,
     isWhite: false,
      imagePath: 'lib/images_dress/rook.png',
  );
  newBoard[7][0] = ChessPiece(
    type: ChessPieceType.rook,
     isWhite: true,
      imagePath: 'lib/images_dress/rook.png',
  );
  newBoard[7][7] = ChessPiece(
    type: ChessPieceType.rook,
     isWhite: true,
      imagePath: 'lib/images_dress/rook.png',
  );
  //place knights
  newBoard[0][1] = ChessPiece(
    type: ChessPieceType.knight,
     isWhite: false,
      imagePath: 'lib/images_dress/knight.png',
  );
  newBoard[0][6] = ChessPiece(
    type: ChessPieceType.knight,
     isWhite: false,
      imagePath: 'lib/images_dress/knight.png',
  );
  newBoard[7][1] = ChessPiece(
    type: ChessPieceType.knight,
     isWhite: true,
      imagePath: 'lib/images_dress/knight.png',
  );
  newBoard[7][6] = ChessPiece(
    type: ChessPieceType.knight,
     isWhite: true,
      imagePath: 'lib/images_dress/knight.png',
  );
  
  //place bishops
  newBoard[0][2] = ChessPiece(
    type: ChessPieceType.bishop,
     isWhite: false,
      imagePath: 'lib/images_dress/bishop.png',
  );
  newBoard[0][5] = ChessPiece(
    type: ChessPieceType.bishop,
     isWhite: false,
      imagePath: 'lib/images_dress/bishop.png',
  );
  newBoard[7][2] = ChessPiece(
    type: ChessPieceType.bishop,
     isWhite: true,
      imagePath: 'lib/images_dress/bishop.png',
  );
  newBoard[7][5] = ChessPiece(
    type: ChessPieceType.bishop,
     isWhite: true,
      imagePath: 'lib/images_dress/bishop.png',
  );
  //place queens
  newBoard[0][3] = ChessPiece(
    type: ChessPieceType.queen,
     isWhite: false,
      imagePath: 'lib/images_dress/queen.png',
  );
  newBoard[7][3] = ChessPiece(
    type: ChessPieceType.queen,
     isWhite: true,
      imagePath: 'lib/images_dress/queen.png',
  );
  //place kings
  newBoard[0][4] = ChessPiece(
    type: ChessPieceType.king,
     isWhite: false,
      imagePath: 'lib/images_dress/king.png',
  );
  newBoard[7][4] = ChessPiece(
    type: ChessPieceType.king,
     isWhite: true,
      imagePath: 'lib/images_dress/king.png',
  );
  board = newBoard;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
      itemBuilder: (context, index) {
        

        // toma la columna y fila de la posicion de la pieza
        int row = index ~/ 8;
        int col = index % 8;

        return Square(
          isWhite: isWhite(index),
          piece: board[row][col], 
        );
      }
      ),
    );
  }
}