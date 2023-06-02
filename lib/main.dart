import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Take the Quiz!'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuizPage()),
            );
          },
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  int questionIndex = 0;
  int score = 0;
  int lives = 3;
  bool isAnswered = false;
  Timer? timer;
  Stopwatch stopwatch = Stopwatch();
  Duration? totalTime;
  Duration timeLeft = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    generateQuestions();
    startTimer();
    stopwatch.start();
  }

  void generateQuestions() {
    const int numberOfQuestions = 5;
    const int minValue = 1;
    const int maxValue = 10;
    final Random random = Random();

    for (int i = 0; i < numberOfQuestions; i++) {
      int operand1 = random.nextInt(maxValue - minValue + 1) + minValue;
      int operand2 = random.nextInt(maxValue - minValue + 1) + minValue;
      int operator = random.nextInt(4);

      String questionText = "";
      late int correctAnswer;

      switch (operator) {
        case 0: // Addition
          questionText = '$operand1 + $operand2 = ?';
          correctAnswer = operand1 + operand2;
          break;
        case 1: // Subtraction
          questionText = '$operand1 - $operand2 = ?';
          correctAnswer = operand1 - operand2;
          break;
        case 2: // Multiplication
          questionText = '$operand1 * $operand2 = ?';
          correctAnswer = operand1 * operand2;
          break;
        case 3: // Division
          questionText = '$operand1 / $operand2 = ?';
          correctAnswer = (operand1 ~/ operand2).toInt(); // Integer division
          break;
      }

      List<int> options = generateOptions(correctAnswer);
      int correctAnswerIndex = -1;
      for(int i=0; i<4; ++i)
        {
          if(options[i] == correctAnswer)
            {
              correctAnswerIndex = i;
            }
        }
      questions.add(Question(questionText, correctAnswerIndex, options));
    }
  }

  List<int> generateOptions(int correctAnswer) {
    List<int> options = [];
    options.add(correctAnswer);

    final Random random = Random();
    while (options.length < 4) {
      int option = correctAnswer + random.nextInt(10) - 5;
      if (!options.contains(option)) {
        options.add(option);
      }
    }

    options.shuffle();
    return options;
  }

  void setCountDown()
  {
    setState(() {
      if (timeLeft.inSeconds <= 0) {
        timer!.cancel();
      }
      else {
        timeLeft = Duration(seconds :timeLeft.inSeconds - 1);
      }
    });
  }

  void startTimer() {
    const duration = Duration(seconds: 10);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
    timer = Timer(duration, () {
      setState(() {
        isAnswered = true;
        loseLife();
        showNextQuestion();
      });
    });
  }



  void resetTimer() {
    timeLeft = const Duration(seconds: 10);
    timer!.cancel();
    startTimer();
  }

  void showNextQuestion() {
    resetTimer();
    setState(() {
      if (questionIndex < questions.length - 1) {
        questionIndex++;
        isAnswered = false;
      } else {
        // Quiz completed
        stopwatch.stop();
        totalTime = stopwatch.elapsed;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Quiz Completed'),
              content: Column(
                children: [
                  Text('Your score: $score/${questions.length}'),
                  Text('Total time: ${totalTime!.inSeconds} seconds'),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    setState(() {
                      questionIndex = 0;
                      score = 0;
                      lives = 3;
                      stopwatch.reset();
                      questions.clear();
                      timeLeft = Duration(seconds: 10);
                      generateQuestions();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void answerQuestion(int selectedOption) {
    if (!isAnswered) {
      resetTimer();
      if (selectedOption == questions[questionIndex].correctAnswerIndex) {
        score++;
      } else {
        loseLife();
      }
      setState(() {
        isAnswered = true;
      });

      Future.delayed(const Duration(milliseconds: 100), ()
      {
        showNextQuestion();
      });
    }
  }

  void loseLife() {
    setState(() {
      lives--;
      if (lives <= 0) {
        // Quiz failed
        stopwatch.stop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Quiz Failed'),
              content: const Text('You lost all your lives.'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    setState(() {
                      questionIndex = 0;
                      score = 0;
                      lives = 3;
                      stopwatch.reset();
                      questions.clear();
                      timeLeft = Duration(seconds: 10);
                      generateQuestions();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final timeLeftDisp = timeLeft.inSeconds.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Question ${questionIndex + 1}',
              style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              questions[questionIndex].text,
              style: const TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: List.generate(questions[questionIndex].options.length, (index) {
                return ElevatedButton(
                  child: Text(questions[questionIndex].options[index].toString(),
                    style: const TextStyle(fontSize: 30.0),
                  ),

                  onPressed: () => answerQuestion(index),
                );
              }),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Time Left: $timeLeftDisp seconds',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Lives: $lives',
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final int correctAnswerIndex;
  final List<int> options;

  Question(this.text, this.correctAnswerIndex, this.options);
}
