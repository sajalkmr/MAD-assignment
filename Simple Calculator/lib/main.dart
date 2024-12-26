import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorApp(),
    );
  }
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _display = '0';
  String _firstNumber = '';
  String _operation = '';
  bool _isNewNumber = true;

  void _onNumberPress(String number) {
    setState(() {
      if (_isNewNumber) {
        _display = number;
        _isNewNumber = false;
      } else {
        _display += number;
      }
    });
  }

  void _onOperationPress(String operation) {
    setState(() {
      _firstNumber = _display;
      _operation = operation;
      _isNewNumber = true;
    });
  }

  void _onEqualPress() {
    setState(() {
      double result;
      double num1 = double.parse(_firstNumber);
      double num2 = double.parse(_display);

      switch (_operation) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '×':
          result = num1 * num2;
          break;
        case '÷':
          result = num1 / num2;
          break;
        default:
          return;
      }

      _display = result.toString();
      _isNewNumber = true;
      _operation = '';
    });
  }

  void _onClearPress() {
    setState(() {
      _display = '0';
      _firstNumber = '';
      _operation = '';
      _isNewNumber = true;
    });
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Text(
              _display,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildButton('7', () => _onNumberPress('7')),
              _buildButton('8', () => _onNumberPress('8')),
              _buildButton('9', () => _onNumberPress('9')),
              _buildButton('÷', () => _onOperationPress('÷')),
            ],
          ),
          Row(
            children: [
              _buildButton('4', () => _onNumberPress('4')),
              _buildButton('5', () => _onNumberPress('5')),
              _buildButton('6', () => _onNumberPress('6')),
              _buildButton('×', () => _onOperationPress('×')),
            ],
          ),
          Row(
            children: [
              _buildButton('1', () => _onNumberPress('1')),
              _buildButton('2', () => _onNumberPress('2')),
              _buildButton('3', () => _onNumberPress('3')),
              _buildButton('-', () => _onOperationPress('-')),
            ],
          ),
          Row(
            children: [
              _buildButton('C', _onClearPress),
              _buildButton('0', () => _onNumberPress('0')),
              _buildButton('=', _onEqualPress),
              _buildButton('+', () => _onOperationPress('+')),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
