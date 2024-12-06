import 'dart:async';
import 'package:flappy_bird/barrier.dart';
import 'package:flappy_bird/bird.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gameHasStarted = false;

  static const double spacing = 1.5; // Space between barriers
  List<double> barriers = [1.5, 1.5 + spacing, 1.5 + spacing * 2, 1.5 + spacing * 3];
  List<double> barrierHeights = [220.0, 170.0, 120.0, 270.0];
  int score = 0;
  int highScore = 0;

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      time += 0.05;

      // Gravity and jump physics
      height = -4.9 * time * time + 2.0 * time; // Reduced upward velocity
      setState(() {
        birdYaxis = initialHeight - height;

        // Move barriers and loop them
        for (int i = 0; i < barriers.length; i++) {
          barriers[i] -= 0.05;
          if (barriers[i] < -1.5) {
            barriers[i] += spacing * barriers.length; // Reposition with consistent spacing
            if (i == 0) score++; // Increment score only for the first barrier
          }
        }
      });

      // Check for collisions
      if (birdYaxis > 1 || birdYaxis < -1 || checkCollision()) {
        timer.cancel();
        gameOver();
      }
    });
  }

  bool checkCollision() {
    // Check if the bird is within any barrier's x range
    for (int i = 0; i < barriers.length; i++) {
      if (barriers[i] > -0.2 && barriers[i] < 0.2) {
        double barrierHeight = barrierHeights[i];
        if (i % 2 == 0) {
          // Bottom barrier
          if (birdYaxis > 1 - barrierHeight / 300) return true;
        } else {
          // Top barrier
          if (birdYaxis < -1 + barrierHeight / 300) return true;
        }
      }
    }
    return false;
  }

  void gameOver() {
    setState(() {
      gameHasStarted = false;
      if (score > highScore) {
        highScore = score; // Update high score
      }
      score = 0; // Reset score
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("Your Score: $score\nHigh Score: $highScore"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text("Restart"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      birdYaxis = 0;
      time = 0;
      initialHeight = birdYaxis;
      barriers = [1.5, 1.5 + spacing, 1.5 + spacing * 2, 1.5 + spacing * 3]; // Reset spacing
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  AnimatedContainer(
                    alignment: Alignment(0, birdYaxis),
                    duration: const Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: const MyBird(),
                  ),
                  if (!gameHasStarted)
                    Container(
                      alignment: const Alignment(0, -0.3),
                      child: const Text(
                        "T A P   TO   P L A Y",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  // Barriers
                  for (int i = 0; i < barriers.length; i++)
                    AnimatedContainer(
                      alignment: Alignment(barriers[i], i % 2 == 0 ? 1.1 : -1.1),
                      duration: const Duration(milliseconds: 0),
                      child: MyBarrier(size: barrierHeights[i]),
                    ),
                ],
              ),
            ),
            Container(
              height: 15,
              color: Colors.green,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "SCORE",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "$score",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 40),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "BEST",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "$highScore",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
