import 'package:flutter/material.dart';

class TurnIndicator extends StatelessWidget {
  final bool isWhiteTurn;
  
  const TurnIndicator({super.key, required this.isWhiteTurn});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isWhiteTurn ? Colors.white : Colors.black,
              border: Border.all(color: Colors.grey),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isWhiteTurn ? 'TURNO DE BLANCAS' : 'TURNO DE NEGRAS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isWhiteTurn ? Colors.white : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

