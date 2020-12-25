part of flamingo;

class DartRuntimeDebugger extends SimpleAstVisitor<Map> {
  const DartRuntimeDebugger._();

  static Future<Map> getASTMap(String source) async {
    try {
      var parseResult = parseString(content: source);
      var compilationUnit = parseResult.unit;
      return compilationUnit.accept<Map>(DartRuntimeDebugger._());
    } catch (e) {
      print('Parse file error: ${e.toString()}');
      return null;
    }
  }

  /// 遍历节点
  Map _safelyVisitNode(AstNode node) {
    if (node == null) return null;
    return node.accept<Map>(this);
  }

  /// 遍历节点列表
  List<Map> _safelyVisitNodeList(NodeList<AstNode> nodeList) {
    if (nodeList == null) return [];
    var mapList = <Map>[];
    for (var node in nodeList) {
      var res = _safelyVisitNode(node);
      if (res != null) mapList.add(res);
    }
    return mapList;
  }

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
      'returnType': node.returnType.toSource(),
      'name': node.name.toString(),
      'functionExpression': _safelyVisitNode(node.functionExpression),
    };
  }

  @override
  Map visitFunctionExpression(FunctionExpression node) {
    return {
      'type': 'FunctionExpression',
      'parameters': _safelyVisitNodeList(node.parameters.parameters),
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

  @override
  Map visitBlockFunctionBody(BlockFunctionBody node) {
    return {
      'type': 'BlockFunctionBody',
      'statements': _safelyVisitNodeList(node.block.statements),
    };
  }

  @override
  Map visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    return {
      'type': 'VariableDeclarationStatement',
      'variables': _safelyVisitNodeList(node.variables.variables),
    };
  }

  @override
  Map visitVariableDeclaration(VariableDeclaration node) {
    return {
      'type': 'VariableDeclaration',
      'name': node.name.toString(),
      'initializer': _safelyVisitNode(node.initializer),
    };
  }

  @override
  Map visitBinaryExpression(BinaryExpression node) {
    return {
      'type': 'BinaryExpression',
      'leftOperand': _safelyVisitNode(node.leftOperand),
      'operator': node.operator.toString(),
      'rightOperand': _safelyVisitNode(node.rightOperand),
    };
  }

  @override
  Map visitReturnStatement(ReturnStatement node) {
    return {
      'type': 'ReturnStatement',
      'expression': _safelyVisitNode(node.expression),
    };
  }

  @override
  Map visitSimpleIdentifier(SimpleIdentifier node) {
    return {
      'type': 'SimpleIdentifier',
      'name': node.name,
    };
  }

  @override
  Map visitIntegerLiteral(IntegerLiteral node) {
    return {
      'type': 'IntegerLiteral',
      'value': node.value,
    };
  }
}
