import 'dart:isolate'; 

import 'package:app_ajedrez/components/piece.dart';
import 'package:app_ajedrez/components/square.dart';
import 'package:app_ajedrez/helper/helper_methods.dart';
import 'package:app_ajedrez/values/colors.dart';
import 'package:app_ajedrez/values/turn_indicator.dart';
import 'package:flutter/material.dart';

import 'package:app_ajedrez/components/dead_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // Una lista de 2 dimensiones que representa el tablero de ajedrez,
  // con cada posición que puede contener una pieza de ajedrez
  late List<List<ChessPiece?>> board;

  //La pieza actualmente seleccionada en el tablero de ajedrez
  //si no hay pieza seleccionada, esto es nulo
  ChessPiece? selectedPiece;

  //El índice de fila de la pieza seleccionada
  //El valor predeterminado -1 indica que no hay pieza seleccionada;
  int selectedRow = -1; //valor de -1 para indicar que no se ha seleccionado nada

  //El índice de columna de la pieza seleccionada
  //El valor predeterminado -1 indica que no hay pieza seleccionada;
  int selectedCol = -1;

  //Una lista de movimientos válidos para la pieza actualmente seleccionada
  //cada movimiento se representa como una lista con 2 elementos: fila y col
  List<List<int>> validMoves = [];

  //Lista de piezas blancas que han muerto por el negro
  List<ChessPiece> whitePiecesTaken = [];

  //Lista de piezas negras que han muerto por el blanco
  List<ChessPiece> blackPiecesTaken = [];

  // Un booleano para indicar de quién es el turno
  bool isWhiteTurn = true;

  //posición inicial de los reyes (mantener un seguimiento de esto para hacer más fácil ver si el rey está en jaque)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //INICIALIZAR TABLERO / POSICIONES INICIALES
  void _initializeBoard(){
    //Inicializar el tablero con los nulos, lo que significa que no hay piezas en esas posiciones
    List<List<ChessPiece?>> newBoard = 
      List.generate(8, (index) => List.generate(8, (index) => null));

    
    //Colocar peones  
    for (int i = 0; i < 8; i++){ //bucle para los 8 peones
      newBoard[1][i] = ChessPiece( //colocar en la segunda fila
        type: ChessPieceType.pawn, 
        isWhite: false, 
        imagePath: 'lib/images/pawn.png'
        );
      newBoard[6][i] = ChessPiece( // colocar en la fila de abajo
        type: ChessPieceType.pawn, 
        isWhite: true, 
        imagePath: 'lib/images/pawn.png'
        );
    }

    //Colocar torres
    newBoard[0][0] = ChessPiece( //posición arriba izquierda
      type: ChessPieceType.rook, 
      isWhite: false, 
      imagePath: 'lib/images/rook.png'
    );
    newBoard[0][7] = ChessPiece( //arriba derecha
      type: ChessPieceType.rook, 
      isWhite: false, 
      imagePath: 'lib/images/rook.png'
    );
    newBoard[7][0] = ChessPiece( //abajo izquierda
      type: ChessPieceType.rook, 
      isWhite: true, 
      imagePath: 'lib/images/rook.png'
    );
    newBoard[7][7] = ChessPiece( //abajo derecha
      type: ChessPieceType.rook, 
      isWhite: true, 
      imagePath: 'lib/images/rook.png'
    );
    //Colocar caballos
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: false, 
      imagePath: 'lib/images/knight.png'
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: false, 
      imagePath: 'lib/images/knight.png'
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: true, 
      imagePath: 'lib/images/knight.png'
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: true, 
      imagePath: 'lib/images/knight.png'
    );
    //Colocar alfiles
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: false, 
      imagePath: 'lib/images/bishop.png'
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: false, 
      imagePath: 'lib/images/bishop.png'
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: true, 
      imagePath: 'lib/images/bishop.png'
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: true, 
      imagePath: 'lib/images/bishop.png'
    );
    //Colocar reinas
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: false, 
      imagePath: 'lib/images/queen.png'
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: true, 
      imagePath: 'lib/images/queen.png'
    );
    //Colocar Reyes
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king, 
      isWhite: false, 
      imagePath: 'lib/images/king.png'
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king, 
      isWhite: true, 
      imagePath: 'lib/images/king.png'
    );

    board = newBoard; //actualizar el nuevo tablero
  }
 
  //USUARIO SELECCIONÓ UNA PIEZA / Queremos saber que se está seleccionando
  void pieceSelected(int row, int col) {
    setState(() {
      //No se ha seleccionado ninguna pieza aún, esta es la primera selección
      if (selectedPiece == null && board[row][col] != null){
        if (board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      //Hay una pieza ya seleccionada, pero el usuario puede seleccionar otra de sus piezas
      else if (board[row][col] != null && 
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //Si hay una pieza seleccionada y el usuario toca una casilla que es un movimiento válido, muévete allí
      else if (selectedPiece != null && 
          validMoves.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);
      }

      //Si hay una pieza seleccionada, calcula su movimiento
      validMoves = 
        calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  //Calcular movimientos válidos brutos
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = []; 

    if (piece == null){
      return[];
    }

    //diferentes direcciones según su color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        //los peones pueden moverse hacia adelante si la casilla no está ocupada
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
              candidateMoves.add([row + direction, col]);
            }

        //los peones pueden moverse 2 casillas hacia adelante si están en su posición inicial
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)){
          if (isInBoard(row + 2 * direction, col) && 
              board[row + 2 * direction][col] == null && 
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction,col]);
          }
        }

        //los peones pueden matar en diagonal
        if (isInBoard(row + direction, col - 1) && 
            board[row + direction][col - 1] != null && 
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && 
            board[row + direction][col + 1] != null && 
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:  
        //direcciones horizontales y verticales
        var directions = [
          [-1,0], //arriba
          [1,0], //abajo
          [0,-1], //izquierda
          [0,1], //derecha
        ];

        for (var direction in directions) {
          var i = 1;
          while (true){ //usar un while para obtener cada cuadrado hasta que le demos a algo
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow, newCol]); //matar
              }
              break; //bloqueado
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
      //todas las ocho posibles formas de L en las que el caballo puede moverse
        var knightMoves = [
          [-2, -1], // arriba 2 izquierda 1
          [-2, 1], // arriba 2 derecha 1
          [-1, -2], // arriba 1 izquierda 2
          [-1, 2], // arriba 1 derecha 2
          [1, -2], // abajo 1 izquierda 2
          [1, 2], //abajo 1 derecha 2
          [2, -1], //abajo 2 izquierda 1
          [2, 1], //abajo 2 derecha 1  
        ];

        for (var move in knightMoves){
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]); //matar
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        // direcciones diagonales
        var directions = [
          [-1, -1], // arriba izquierda
          [-1, 1],  // arriba derecha
          [1, -1],  // abajo izquierda
          [1, 1]    // abajo derecha
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
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // matar
              }
              break; // bloqueado
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        // las ocho direcciones: arriba, abajo, izquierda, derecha y 4 diagonales
        var directions = [
          [-1, 0],   // arriba
          [1, 0],  // abajo
          [0, -1],  // izquierda
          [0, 1],   // derecha
          [-1, -1], // arriba izquierda
          [-1, 1],  // arriba derecha
          [1, -1],  // abajo izquierda
          [1, 1]    // abajo derecha
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
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //matar
              }
              break; // bloqueado
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;     
      case ChessPieceType.king:
        //todas las ocho direcciones
        var directions = [
          [-1, 0],   // arriba
          [1, 0],  // abajo
          [0, -1],  // izquierda
          [0, 1],   // derecha
          [-1, -1], // arriba izquierda
          [-1, 1],  // arriba derecha
          [1, -1],  // abajo izquierda
          [1, 1]    // abajo derecha
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null){
            if (board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]); //matar
            }
            continue; //bloqueado
          }
          candidateMoves.add([newRow, newCol]);
        } 

        break;   
      
    }

    return candidateMoves;
  }

  
  //Calcular Movimientos Válidos Reales
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece); 

    //después de generar todos los movimientos candidatos, filtrar cualquier que resultaría en un jaque
    if (checkSimulation){
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        //esto simulará el futuro movimiento para ver si es seguro
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)){
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }
  
  //MOVER PIEZA
  void movePiece(int newRow, int newCol){

    //si el nuevo lugar tiene una pieza enemiga
    if (board[newRow][newCol] != null){
      //agregar la pieza capturada a la lista apropiada
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite){
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    //verificar si la pieza que se mueve es un rey
    if (selectedPiece!.type == ChessPieceType.king){
      //actualizar la posición del rey correspondiente
      if (selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    //mover la pieza y limpiar el antiguo lugar
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //verificar si algún rey está bajo ataque
    if (isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    //limpiar selección
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    //verificar si es jaque mate
    if (isCheckMate(!isWhiteTurn)){
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: const Text("¡JAQUE MATE!"),
          actions: [
            //botón para jugar de nuevo
            TextButton(
              onPressed: resetGame, 
              child: const Text("Jugar de Nuevo"),
            ),
          ],
        )
      );
    }

    //Cambiar turnos
    isWhiteTurn = !isWhiteTurn;
  }

  //¿ESTÁ EL REY EN JAQUE?
  bool isKingInCheck(bool isWhiteKing){
    //obtener la posición del rey
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    //verificar si alguna pieza enemiga puede atacar al rey
    for (int i = 0; i < 8; i++){
      for (int j = 0; j < 8; j++){
        //omitir casillas vacías y piezas del mismo color que el rey
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves = 
          calculateRealValidMoves(i, j, board[i][j], false);

        //verificar si la posición del rey está en los movimientos válidos de esta pieza
        if (pieceValidMoves.any((move) => 
            move[0] == kingPosition[0] && move[1] == kingPosition[1])){
          return true;
        }
      }
    }

    return false;
  }

  
  //Simular un movimiento futuro para ver si es seguro (¡No coloca a tu propio rey bajo ataque!)
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
    //guardar el estado actual del tablero
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //si la pieza es el rey, guardar su posición actual y actualizar a la nueva
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king){
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      //actualizar la posición del rey
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    //simular el movimiento
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //verificar si nuestro rey está bajo ataque
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restaurar el tablero al estado original
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //si la pieza era el rey, restaurar su posición original
    if (piece.type == ChessPieceType.king){
      if (piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      } else{
        blackKingPosition = originalKingPosition!;
      }
    }

    //si el rey está en jaque = verdadero, significa que no es un movimiento seguro. movimiento seguro = falso
    return !kingInCheck;
  }
  
  //¿ES JAQUE MATE?
  bool isCheckMate(bool isWhiteKing){
    //si el rey no está en jaque, entonces no es jaque mate
    if (!isKingInCheck(isWhiteKing)){
      return false;
    }

    //si hay al menos un movimiento legal para alguno de los otros jugadores, entonces no es jaque mate
    for (int i = 0; i < 8; i++){
      for (int j = 0; j < 8; j++){
        //omitir casillas vacías y piezas del otro color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true); 

        //si esta pieza tiene algún movimiento válido, entonces no es jaque mate
        if (pieceValidMoves.isNotEmpty){
          return false;
        }  
      }
    } 

    //si ninguna de las condiciones anteriores se cumple, entonces no quedan movimientos legales por hacer
    // ¡es jaque mate!
    return true;
  }

  //Restablecer a un nuevo juego
  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          
          //PIEZAS BLANCAS CAPTURADAS
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: 
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          //ESTADO DEL JUEGO
          Text(checkStatus ? "¡JAQUE!" : ""),

          //indicador de puntos.
          TurnIndicator(isWhiteTurn: isWhiteTurn),

          //TABLERO DE AJEDREZ
          Expanded(
            flex: 600,
            child: GridView.builder(
              //8 x 8 = 64 casillas
              itemCount: 8 * 8,
              //Desactiva el desplazamiento del grid
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              //Define la cuadrícula con 8 columnas
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index){
            
                //calcula la fila de la celda
                int row = index ~/ 8;
                //calcula la columna de la celda
                int col = index % 8;
            
                //verifica si esta casilla está seleccionada
                bool isSelected = selectedRow == row && selectedCol == col;
            
                //verifica si esta casilla es un movimiento válido
                bool isValidMove = false;
                for (var position in validMoves){
                  //compara fila y col
                  if (position[0] == row && position[1] == col){
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
              },
            ),
          ),

          //PIEZAS NEGRAS CAPTURADAS
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              gridDelegate: 
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),   
          ),
        ],
      ),
    );
  }
}