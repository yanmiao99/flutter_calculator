import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';

void main() {
  runApp(MyApp());
}

// 无状态组件
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 适配底部小白条
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      // SystemUiOverlay.bottom,
      // SystemUiOverlay.top,
    ]);

    return MaterialApp(
      title: '计算器',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            '计算器',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        // body: CalculatorWidget(),
        body: SafeArea(
          child: CalculatorWidget(),
        ),
      ),
    );
  }
}

// 计算组件/有状态组件
class CalculatorWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CalculatorWidgetState();
  }
}

// 计算组件状态类
class CalculatorWidgetState extends State {
  String _outPUT = "0"; // 输出
  dynamic _num1 = 0; // 第一个保存的数字
  dynamic _num2 = 0; // 第二个保存的数字
  bool _isCalculate = false; // 是否点击了运算符
  String _operand = ""; //保存当前运算符

  final d = (String s) => Decimal.parse(s);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          // 计算器显示结果的部分
          Container(
            color: Colors.black,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(20),
            child: Text(
              _outPUT,
              style: const TextStyle(
                fontSize: 62,
                color: Colors.white,
              ),
            ),
          ),

          // 计算器按钮部分
          Container(
            color: Colors.black,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('AC'),
                    buildButton('+/-'),
                    buildButton('%'),
                    buildButton('÷', curColor: Colors.orange),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('×', curColor: Colors.orange),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('-', curColor: Colors.orange),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('+', curColor: Colors.orange),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('0', isDouble: true),
                    buildButton('.'),
                    buildButton('=', curColor: Colors.orange),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // + - * / 的逻辑函数
  void calculateFn(String operand) {
    _operand = operand;
    _isCalculate = true;

    String currentOperand = operand;
    if (operand == '×') currentOperand = '*';
    if (operand == '÷') currentOperand = '/';

    // 映射
    Map<String, Function> operations = {
      '+': (a, b) => a + b,
      '-': (a, b) => a - b,
      '*': (a, b) => a * b,
      '/': (a, b) => a / b,
    };

    if (_num1 != 0) {
      if (_outPUT.contains(".") || _num1 is double) {
        _num2 = double.parse(_outPUT);
        _outPUT = operations[currentOperand]!(
                d(_num1.toString()), d(_num2.toString()))
            .toDouble()
            .toString();
        _num1 = double.parse(_outPUT);
      } else {
        _num2 = int.parse(_outPUT);
        _outPUT = operations[currentOperand]!(
                d(_num1.toString()), d(_num2.toString()))
            .toBigInt()
            .toString();
        _num1 = int.parse(_outPUT);
      }
    }
  }

  void onBtnClick(String btnText) {
    HapticFeedback.vibrate(); // 按钮震动反馈
    // 判断按钮点击的内容, 实现计算器逻辑
    switch (btnText) {
      case 'AC':
        _outPUT = '0';
        _num1 = 0;
        _num2 = 0;
        _isCalculate = false;
        break;
      case '+/-':
        if (_outPUT.contains('.')) {
          _outPUT = (-double.parse(_outPUT)).toString();
        } else {
          _outPUT = (-int.parse(_outPUT)).toString();
        }
        break;
      case '%':
        _outPUT = (d(_outPUT) / d('100.0')).toDouble().toString();
        break;
      case '÷':
      case '×':
      case '-':
      case '+':
        calculateFn(btnText);
        break;
      case '=':
        if (_outPUT == '0') return;
        onBtnClick(_operand);
        _isCalculate = false;
        _operand = "";
        _num1 = "0";
        _num2 = "0";
        break;
      default:
        // 判断是都点击了运算符 , 如果点击了则存储起来
        if (_isCalculate) {
          _num1 = _outPUT.contains(".")
              ? double.parse(_outPUT)
              : int.parse(_outPUT);
          _outPUT = '0';
          _isCalculate = false;
        }

        // 判断是否是小数点
        if (btnText == '.' && _outPUT.contains('.')) return;

        // 判断是否大于 9 位数
        if (_outPUT.length >= 9) return;

        // 第一次输入
        if (btnText != '.' && _outPUT == '0') {
          _outPUT = btnText;
        } else {
          // 非第一次输入
          _outPUT += btnText;
        }
        break;
    }

    // 刷新界面
    setState(() {
      _outPUT = _outPUT;
    });

    // 打印输出
    print(_outPUT);
  }

  // 自定义计算器按钮
  Widget buildButton(String btnText,
      {dynamic curColor = Colors.grey, bool isDouble = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextButton(
        onPressed: () => onBtnClick(btnText),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(curColor),
          minimumSize: MaterialStateProperty.all(
              // 根据是否是双倍按钮，设置按钮的宽度
              isDouble ? const Size(180, 80) : const Size(80, 80)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        child: Text(
          btnText,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
