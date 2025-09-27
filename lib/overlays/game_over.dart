import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;
  const GameOverOverlay({Key? key, required this.score, required this.onRestart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Game Over', style: TextStyle(fontSize: 48, color: Colors.white)),
          SizedBox(height: 12),
          ElevatedButton(onPressed: onRestart, child: Text('Restart')),
        ],
      ),
    );
  }
}