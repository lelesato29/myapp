import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Velha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JogoDaVelha(),
    );
  }
}

class JogoDaVelha extends StatefulWidget {
  @override
  _JogoDaVelhaState createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> board = List.filled(9, ''); // Tabuleiro de 9 células
  String currentPlayer = 'X'; // Jogador inicial
  String winner = '';
  bool isGameOver = false;
  bool isComputerPlaying = false; // Se o computador está jogando
  bool isHumanVsHuman = false; // Se o jogo é contra outro humano

  // Função para verificar se alguém ganhou
  void checkWinner() {
    List<List<int>> winningCombination = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombination) {
      if (board[combination[0]] != '' &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        setState(() {
          winner = board[combination[0]];
          isGameOver = true;
        });
        return;
      }
    }

    if (!board.contains('') && winner == '') {
      setState(() {
        winner = 'Empate';
        isGameOver = true;
      });
    }
  }

  // Função para fazer a jogada
  void makeMove(int index) {
    if (board[index] == '' && !isGameOver) {
      setState(() {
        board[index] = currentPlayer;
        currentPlayer = (currentPlayer == 'X') ? 'O' : 'X'; // Alterna jogador
        checkWinner();
      });

      if (isComputerPlaying && currentPlayer == 'O' && !isGameOver) {
        Future.delayed(Duration(milliseconds: 500), () => computerMove());
      }
    }
  }

  // Função do computador para fazer uma jogada inteligente
  void computerMove() {
    int bestMove = minimax(board, 'O');
    if (board[bestMove] == '') {
      setState(() {
        board[bestMove] = 'O';
        currentPlayer = 'X';
        checkWinner();
      });
    }
  }

  // Função Minimax para o computador jogar
  int minimax(List<String> board, String player) {
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') availableMoves.add(i);
    }

    if (availableMoves.isEmpty) return -1;

    int bestMove = -1;
    int bestValue = player == 'O' ? -1000 : 1000;

    for (var move in availableMoves) {
      board[move] = player;
      int moveValue = minimaxScore(board, player == 'O' ? 'X' : 'O');
      board[move] = '';
      
      if (player == 'O' && moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      } else if (player == 'X' && moveValue < bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
    }
    return bestMove;
  }

  // Função de avaliação para minimax
  int minimaxScore(List<String> board, String player) {
    List<List<int>> winningCombination = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombination) {
      if (board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        if (board[combination[0]] == 'O') return 1;
        if (board[combination[0]] == 'X') return -1;
      }
    }

    return 0; // Empate
  }

  // Reiniciar o jogo
  void restartGame() {
    setState(() {
      board = List.filled(9, '');
      winner = '';
      isGameOver = false;
      currentPlayer = 'X';
      isComputerPlaying = false;
      isHumanVsHuman = false;
    });
  }

  // Alterar para jogar contra o computador
  void startGameAgainstComputer() {
    setState(() {
      isComputerPlaying = true;
      winner = '';
      isGameOver = false;
      currentPlayer = 'X'; // O jogador humano começa
      isHumanVsHuman = false;
    });
  }

  // Alterar para jogar contra outro humano
  void startGameVsHuman() {
    setState(() {
      isHumanVsHuman = true;
      winner = '';
      isGameOver = false;
      currentPlayer = 'X'; // O jogador humano começa
      isComputerPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo da Velha'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menu de opções
            if (!isGameOver)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: startGameAgainstComputer,
                    child: Text('Jogar contra o Computador'),
                  ),
                  ElevatedButton(
                    onPressed: startGameVsHuman,
                    child: Text('Jogar contra Humano'),
                  ),
                ],
              ),
            // Tabuleiro de Jogo
            if (isHumanVsHuman || isComputerPlaying)
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => makeMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.blue[50],
                      ),
                      height: 100,
                      width: 100,
                      child: Center(
                        child: Text(
                          board[index],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 20),
            Text(
              winner != '' ? 'Vencedor: $winner' : 'Jogador: $currentPlayer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: restartGame,
              child: Text('Reiniciar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}
