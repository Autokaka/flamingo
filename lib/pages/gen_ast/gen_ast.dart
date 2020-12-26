import 'package:flamingo_demo/flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenASTPage extends StatefulWidget {
  @override
  _GenASTPageState createState() => _GenASTPageState();
}

class _GenASTPageState extends State<GenASTPage> {
  String dartCode = "";
  Map codeAST;
  dynamic codeResult;

  Future<void> loadDartAST() async {
    dartCode = await rootBundle.loadString('assets/code/demo.dart');
    codeAST = DartCompiler.compile(dartCode);
    // codeResult = await DartInterpreter.run(dartCode);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDartAST();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generate AST from Dart code"),
      ),
      body: ListView(
        children: [
          Text(dartCode.trim()),
          Divider(color: Colors.blue),
          Text(debugEncode(codeAST)),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(10),
        child: Text(
          // '执行结果: $codeResult',
          '执行结果: ',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
