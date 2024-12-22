import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

enum MathOperation { addition, subtraction, multiply, divide }

enum Difficulty { veryEasy, easy, medium, hard, veryHard }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Quiz App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/level_selection': (context) => LevelSelectionPage(),
      },
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Math Quiz'),
      ),
      body: _buildPageBody(context, [
        SizedBox(height: 20),
        _buildText('Welcome to Math Quiz!', fontSize: 24),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/level_selection');
          },
          child: Text('Start Quiz'),
        ),
      ]),
    );
  }

  Widget _buildPageBody(BuildContext context, List<Widget> children) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildText(String text, {double fontSize = 20, Color color = Colors.white}) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, color: color),
      textAlign: TextAlign.center,
    );
  }
}

class LevelSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Difficulty Level'),
      ),
      body: _buildPageBody(context, [
        SizedBox(height: 20),
        _buildLevelButton(context, 'Very Easy Level', Difficulty.veryEasy),
        _buildLevelButton(context, 'Easy Level', Difficulty.easy),
        _buildLevelButton(context, 'Medium Level', Difficulty.medium),
        _buildLevelButton(context, 'Hard Level', Difficulty.hard),
          _buildLevelButton(context, 'Very Hard Level', Difficulty.veryHard), // Add this line
      ]),
    );
  }

  Widget _buildPageBody(BuildContext context, List<Widget> children) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String text, Difficulty difficulty) {
    return ElevatedButton(
      onPressed: () {
        startQuiz(context, difficulty);
      },
      child: Text(text),
    );
  }

  void startQuiz(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MathQuizGame(difficulty: difficulty),
      ),
    );
  }
}

class MathQuizGame extends StatefulWidget {
  final Difficulty difficulty;
  late String operationIndicator;

  MathQuizGame({Key? key, required this.difficulty}) : super(key: key);

  @override
  _MathQuizGameState createState() => _MathQuizGameState();
  
}

class _MathQuizGameState extends State<MathQuizGame> {
  Random random = Random();
  int operand1 = 1, operand2 = 1;
  int answer = 2;
  TextEditingController answerController = TextEditingController();
  int score = 0;
  int wrongAttempts = 0;
  int currentLevel = 1;
  MathOperation currentOperation = MathOperation.addition;
  late int correctAnswersToNextLevel;

  int maxTimeInSeconds = 30;
  late int remainingTime;
  late Timer timer;

  bool showVisualFeedback = false;

  @override
  void initState() {
    super.initState();
    setDifficultyParameters();
    generateQuestion();
    startTimer();
  }

  void setDifficultyParameters() {
    Difficulty newDifficulty;

    switch (widget.difficulty) {
      case Difficulty.veryEasy:
        correctAnswersToNextLevel = 3;
        currentOperation = MathOperation.addition;
        newDifficulty = Difficulty.veryEasy;
        break;
      case Difficulty.easy:
        correctAnswersToNextLevel = 5;
        currentOperation = MathOperation.subtraction;
        newDifficulty = Difficulty.easy;
        break;
      case Difficulty.medium:
        correctAnswersToNextLevel = 7;
        currentOperation = MathOperation.multiply;
        newDifficulty = Difficulty.medium;
        break;
      case Difficulty.hard:
        correctAnswersToNextLevel = 10;
        currentOperation = MathOperation.divide;
        newDifficulty = Difficulty.hard;
        break;
      default:
        correctAnswersToNextLevel = 10;
        currentOperation = MathOperation.addition;
        newDifficulty = Difficulty.veryHard;
        break;
    }
  }

  void generateQuestion() {
    setState(() {
      int maxOperandValue = 5;

      switch (widget.difficulty) {
        case Difficulty.veryEasy:
          maxOperandValue = 5;
          break;
        case Difficulty.easy:
          maxOperandValue = 10;
          break;
        case Difficulty.medium:
          maxOperandValue = 15;
          break;
        case Difficulty.hard:
          maxOperandValue = 20;
          break;
      }

      operand1 = random.nextInt(maxOperandValue) + 1;
      currentOperation = _getRandomOperation();
      operand2 = random.nextInt(maxOperandValue - 1) + 1;

      switch (currentOperation) {
        case MathOperation.addition:
          answer = operand1 + operand2;
          break;
        case MathOperation.subtraction:
          answer = operand1 - operand2;
          break;
        case MathOperation.multiply:
          answer = operand1 * operand2;
          break;
        case MathOperation.divide:
          answer = (operand1 / operand2).round();
          break;
      }

      answerController.clear();
    });
  }

  MathOperation _getRandomOperation() {
  switch (widget.difficulty) {
    case Difficulty.veryEasy:
      return MathOperation.addition;
    case Difficulty.easy:
      return MathOperation.subtraction;
    case Difficulty.medium:
      return MathOperation.multiply;
    case Difficulty.hard:
      return MathOperation.divide;
    case Difficulty.veryHard:
      // For very hard, include mix of addition, subtraction, multiplication, and division
      return MathOperation.values[Random().nextInt(MathOperation.values.length)];
    default:
      return MathOperation.addition; // Default to addition if difficulty is not recognized
  }
}

  void startTimer() {
    remainingTime = maxTimeInSeconds;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          wrongAttempts++;
          generateQuestion();
          resetTimer();
        }
      });
    });
  }

  void resetTimer() {
    timer.cancel();
    startTimer();
  }

  void checkAnswer() {
    setState(() {
      timer.cancel();

      if (answerController.text.isNotEmpty &&
          int.tryParse(answerController.text) == answer) {
        score++;
        showVisualFeedback = true;
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            showVisualFeedback = false;
          });
        });
      } else {
        wrongAttempts++;
        showVisualFeedback = false;
        Fluttertoast.showToast(
          msg: "Incorrect Answer!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (score % correctAnswersToNextLevel == 0) {
        currentLevel++;
        setDifficultyParameters();
        generateQuestion();

        if (currentLevel % 5 == 0) {
          showCongratulationsDialog();
        }
      } else {
        generateQuestion();
      }

      resetTimer();
    });
  }

  void showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have reached level $currentLevel! Keep it up!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      wrongAttempts = 0;
      currentLevel = 1;
      setDifficultyParameters();
      generateQuestion();
      resetTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Math Quiz - Level $currentLevel'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.orange,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildText('What is the result of the operation?', fontSize: 24),
                SizedBox(height: 16),
                _buildText('$operand1 ${_getOperationString()} $operand2 = ?', fontSize: 24),
                SizedBox(height: 16),
                _buildText('Time Remaining: $remainingTime seconds', fontSize: 18),
                SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) {
                    checkAnswer();
                    answerController.clear();
                  },
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                    focusedBorder:                    OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    checkAnswer();
                    answerController.clear();
                  },
                  child: Text('Submit', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showHintDialog();
                  },
                  child: Text('Get Hint', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    resetGame();
                  },
                  child: Text('Reset Game', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 16),
                _buildText('Score: $score', fontSize: 18),
                SizedBox(height: 16),
                _buildText('Wrong: $wrongAttempts', fontSize: 18),
                SizedBox(height: 16),
                if (showVisualFeedback) _buildVisualFeedback(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualFeedback() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      color: Colors.green,
      child: Text(
        'Correct Answer!',
        style: TextStyle(fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getOperationString() {
    switch (currentOperation) {
      case MathOperation.addition:
        return '+';
      case MathOperation.subtraction:
        return '-';
      case MathOperation.multiply:
        return '×';
      case MathOperation.divide:
        return '÷';
    }
  }

  Widget _buildText(String text, {double fontSize = 20, Color color = Colors.white}) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, color: color),
      textAlign: TextAlign.center,
    );
  }

  void showHintDialog() {
    String hintMessage = getHint();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hint'),
          content: Text(hintMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String getHint() {
    switch (currentOperation) {
      case MathOperation.addition:
        return 'Think about adding the values of the two operands.';
      case MathOperation.subtraction:
        return 'Subtract the value of the second operand from the first operand.';
      case MathOperation.multiply:
        return 'Multiply the values of the two operands.';
      case MathOperation.divide:
        return 'Divide the value of the first operand by the value of the second operand (rounded if necessary).';
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

