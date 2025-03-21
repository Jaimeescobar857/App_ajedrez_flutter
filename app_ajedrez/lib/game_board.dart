import 'package:app_ajedrez/components/piece.dart';
import 'package:app_ajedrez/components/square.dart';
import 'package:app_ajedrez/helper/helper_methods.dart';
import 'package:app_ajedrez/values/colors.dart';
import 'package:flutter/material.dart';

import 'components/dead_piece.dart';

class Gameboard extends StatefulWidget {
  const Gameboard({super.key});

  @override
  State<Gameboard> createState() => _GameBoardState();
}

 

  class _GameBoardState extends State<Gameboard> {

  //una lista en 2d para representar el tablero
  //con cada posicion posible que contiene un pieza de ajedrez
  late List<List<ChessPiece?>>board; 

  //La pieza seleccionada en el tablero de ajedrez, Si no esta seleccionada es nulo
  ChessPiece? selectedPiece;

  //La fila de la pieza seleccionada, valor default es -1 y indica que ninguna pieza esta seleccionada
  int selectedRow = -1;

  //La columna de la pieza seleccionada, valor default es -1 y indica que ninguna pieza esta seleccionada
  int selectedColumn = -1;

  //una lista de movimientos validos para la pieza actualmente seleccionada, cada movimiento esta represetnado con una lista de elementos: column y fila.
  List<List<int>> validMoves = [];

  //una lista de piezas blancas que fueron tomadas por el jugador negro
  List<ChessPiece> whitePiecesTaken = [];
  //una lissta de piezas negras que fuero tomadas por el jugador blanco
  List<ChessPiece>blackPiecesTaken = [];
  //Un booleano para indicar de quien es el turno.
  bool isWhiteTurn = true;

  //posicion inicial de reyes
  List<int> whiteKingPosition = [7,4];
  List<int> blackKingPosition = [0,4];
  bool checkStatus = false; 


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

//Usuario selecciona una pieza
void pieceSelected(int row, int column) {
  setState(() {

    //no hay piezas seleccionada, es la primera selecciona
    if (selectedPiece == null && board [row][column] != null) {
      selectedPiece = board[row][column]; {
      selectedRow = row;
      selectedColumn = column; 
    }
  }  
    //esta es una pieza ya seleccionada, pero el usuario puede seleccionar cualquier otra de las piezas
    else if (board [row][column] != null && board[row][column]!.isWhite == selectedPiece!.isWhite){
      selectedPiece = board[row][column];
      selectedRow = row;
      selectedColumn = column;
    }
    //si el usuario toma una pieza y la da click en algun cuadrado del tablero pero el movimiento es invalido.
    else if (selectedPiece != null &&
     validMoves.any((element) => element[0] == row && element[1] == column)) {
    movePiece(row, column);
    }

    //si una pieza es seleccionada, calcula sus movimientos validos.
    validMoves = 
        calculateRawValidMoves(selectedRow, selectedColumn, selectedPiece!);
  });
}
    //Calcula datos de movimientos validos
    List<List<int>> calculateRawValidMoves(
      int row, int col, ChessPiece? Piece) {
      List<List<int>> candidateMoves = [];

      if (Piece == null) {
        return [];
      }

    //movimiento de piezas 
    void movePiece(int newRow, int newCol) {

      //si el enemigo tiene un nuevo spot.
      if (board[newRow][newCol] != null) {
      //añade la pieza a la Lista de captura del enemigo
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else{
        blackPiecesTaken.add(capturedPiece);
      }
    }
      
      //mueve la pieza y deja vacio el lugar anterior
      board[newRow][newCol] = selectedPiece;
      board[selectedRow][selectedColumn] = null;

      //see if any kings are under attack
      if (isKingInCheck()) {
        checkStatus = true;
      }else {
        checkStatus = false;
      }

      //clear selection 
      setState(() {
        selectedPiece = null;
        selectedRow = -1;
        selectedColumn = -1;
        validMoves = [];
      });
      //cabiar turnos
      isWhiteTurn = !isWhiteTurn; 

      //IS KING IN CHECK?
      bool isKingInCheck(bool isWhiteKing) {
        //el rey esta en jaque?
      List<int> KingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

      //
      }

    }
    //Diferente direcciones basado en el color de la pieza
    int direction = Piece.isWhite ? -1 : 1;

    switch (Piece.type) {
      case ChessPieceType.pawn:
        //El peon se puede mover hacia delante si el cuadro delantero no esta ocupado
        if (isInBoard(row + direction, col)&&
            board[row + direction][col] == null) {
              candidateMoves.add([row + direction, col]);
            }
          
        
        //El peon puede moverse dos cuadros si esta en su posicion inicial
        if ((row == 1 && !Piece.isWhite) || (row == 6 && Piece.isWhite)) {
          if (isInBoard(row +2 * direction, col) &&
            ((board[row + 2 * direction][col] == null &&
            board[row + direction][col] == null))) {
              candidateMoves.add([row + 2 * direction, col]);
            }
        }
        //El peon solo puede comer en digonal
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row+direction][col - 1]!.isWhite) {
              candidateMoves.add([row + direction, col - 1]);
            }
         if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row+direction][col + 1]!.isWhite) {
              candidateMoves.add([row + direction, col + 1]);
            }

        break;
      case ChessPieceType.rook:
      //se mueve en direccional horizonra
      var directions = [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1]  
      ];

      for (var direction in directions) {
        var i = 1;
        while (true) {
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if (!isInBoard(newRow, newCol)) {
            break;
          }
          if (board[newRow][newCol] == null) {
            if (board[newRow][newCol] != Piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            break; //blocked
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
        break;
      case ChessPieceType.knight:
      //El caballo se mueve en L en cualquier direccion posible
      var knightMoves = [
        [-2, -1],
        [-2, 1],
        [-1, -2],
        [-1, 2],
        [1, -2],
        [1, 2],
        [2, -1],
        [2, 1],
      ];

      for (var move in knightMoves) {
        var newRow = row + move[0];
        var newCol = col + move[1];
        if (isInBoard(newRow, newCol) &&
            board[newRow][newCol] == null) {
            continue;
        }
        if (board[newRow][newCol]!= null) {
          if (board[newRow][newCol]!.isWhite != Piece.isWhite) {
            candidateMoves.add([newRow, newCol]); //capture
        }
        continue; //block
        }
        candidateMoves.add([newRow, newCol]);
      }
        break;
      case ChessPieceType.bishop:
       //El alfil se mueve en diagonal
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if(board[newRow][newCol] !.isWhite != Piece.isWhite){
                candidateMoves.add([newRow, newCol]);
              }
              break; //block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
// todos los movimiento de la reina
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol] !.isWhite != Piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            break; //block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }


        break;
      case ChessPieceType.king:
//todas las direcciones del rey 
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol] !.isWhite != Piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue; //block
          }
          candidateMoves.add([newRow, newCol]);
        break;      
    }   
    return candidateMoves;
  }

    //piezas random en el medio para pruebas
    newBoard[3][3] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images_dress/rook.png');

  
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
      body: Column(
        children: [

          //PIEZAS BLANCAS TOMADAS 
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),
          //PIEZAS EN EL TABLERO
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
            itemBuilder: (context, index) {
              
            
              // toma la columna y fila de la posicion de la pieza
              int row = index ~/ 8;
              int col = index % 8;
            
              //checa si la pieza esta seleccionada
              bool isSelected = selectedRow == row && selectedColumn == col;
              //checar si el cuadrado que quieres usar esta en un movimiento valido
              bool isValidMove = false;
              for (var position in validMoves) {
                //compararfilas y columnas
                if (position[0] == row && position[1] == col) {
                  isValidMove = true;
                }
              }
            
              return Square(
                isWhite: isWhite(index),
                piece: board[row][col], 
                isSelected: isSelected,
                isValidMove: isValidMove,
                onTap: () => pieceSelected(row, col),
              );
            }
            ),
          ),

        //Black pieces taken
        Expanded(
          child: GridView.builder(
            itemCount: blackPiecesTaken.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
                ),
          )

        ),
        ],
    ));
  }
}
}