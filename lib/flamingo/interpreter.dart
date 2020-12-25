part of flamingo;

class DartInterpreter extends DartRuntimeDebugger {
  DartInterpreter._() : super._();

  static Future run(String sourceCode) async {
    var parseResult = parseString(content: sourceCode);
    var compilationUnit = parseResult.unit;
    return compilationUnit.accept(DartInterpreter._());
  }

  final variableStack = const [];

  @override
  Map visitCompilationUnit(CompilationUnit node) {
    return {
      'type': 'CompilationUnit',
      'declarations': _safelyVisitNodeList(node.declarations),
    };
  }

  @override
  Map visitFunctionDeclaration(FunctionDeclaration node) {
    return {
      'type': 'FunctionDeclaration',
      'returnType': node.returnType.toString(),
      'functionName': node.name.toString(),
      'functionExpression': _safelyVisitNode(node.functionExpression),
    };
  }

  @override
  Map visitFunctionExpression(FunctionExpression node) {
    return {
      'type': 'FunctionExpression',
      'params': _safelyVisitNodeList(node.parameters.parameters),
      'body': _safelyVisitNode(node.body),
    };
  }

  @override
  Map visitSimpleFormalParameter(SimpleFormalParameter node) {
    return {
      'type': node.type.toString(),
      'name': node.identifier.toString(),
    };
  }
}
