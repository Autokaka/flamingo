part of flamingo;

class DartCompiler extends SimpleAstVisitor<Map> {
  final astRef = <int, Map>{};

  DartCompiler._();

  static Map compile(String source) {
    try {
      var parseResult = parseString(content: source);
      var compilationUnit = parseResult.unit;
      return compilationUnit.accept<Map>(DartCompiler._());
    } catch (e) {
      return {
        'error': {
          'type': e.runtimeType.toString(),
          'message': e.message,
          'stackTrace': e.stackTrace,
        },
      };
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

  int _findScopeNodeId(int thisId) {
    var searchId = thisId;
    final astRefKeys = astRef.keys;
    while (astRefKeys.contains(searchId)) {
      final thisAST = astRef[searchId];
      if (thisAST['scope'] ?? false) return searchId;
      if (thisAST['thisId'] == thisAST['parentId']) return null;
      searchId = thisAST['parentId'];
    }
    return null;
  }

  AstNode _findParentNode(AstNode thisNode) {
    var searchNode = thisNode;
    final astRefKeys = astRef.keys;
    while (!astRefKeys.contains(searchNode.hashCode)) {
      if (searchNode.root.hashCode == searchNode.hashCode) return searchNode;
      searchNode = searchNode.parent;
    }
    return searchNode;
  }

  @override
  Map visitCompilationUnit(CompilationUnit node) {
    final nodeAST = {
      'scope': true,
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'CompilationUnit',
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'declarations': _safelyVisitNodeList(node.declarations),
      });
  }

  @override
  Map visitFunctionDeclaration(FunctionDeclaration node) {
    final nodeAST = {
      'scope': true,
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'FunctionDeclaration',
      'returnType': node.returnType.toSource(),
      'name': node.name.toString(),
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'functionExpression': _safelyVisitNode(node.functionExpression),
      });
  }

  @override
  Map visitFunctionExpression(FunctionExpression node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'FunctionExpression',
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'parameters': _safelyVisitNodeList(node.parameters.parameters),
        'body': _safelyVisitNode(node.body),
      });
  }

  @override
  Map visitSimpleFormalParameter(SimpleFormalParameter node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': node.type.toString(),
      'name': node.identifier.toString(),
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST;
  }

  @override
  Map visitBlockFunctionBody(BlockFunctionBody node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'BlockFunctionBody',
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'statements': _safelyVisitNodeList(node.block.statements),
      });
  }

  @override
  Map visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'VariableDeclarationStatement',
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'variables': _safelyVisitNodeList(node.variables.variables),
      });
  }

  @override
  Map visitVariableDeclaration(VariableDeclaration node) {
    final parentNode = _findParentNode(node);
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': parentNode.hashCode,
      'type': parentNode.beginToken.toString(),
      'name': node.name.toString(),
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'initializer': _safelyVisitNode(node.initializer),
      });
  }

  @override
  Map visitBinaryExpression(BinaryExpression node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'BinaryExpression',
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'leftOperand': _safelyVisitNode(node.leftOperand),
        'operator': node.operator.toString(),
        'rightOperand': _safelyVisitNode(node.rightOperand),
      });
  }

  @override
  Map visitReturnStatement(ReturnStatement node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'ReturnStatement',
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST
      ..addAll({
        'expression': _safelyVisitNode(node.expression),
      });
  }

  @override
  Map visitSimpleIdentifier(SimpleIdentifier node) {
    /// 查询作用域, 以找到作用域下是否有定义好的AstNode
    /// 如果有, 就优化这个Identifier为明确的AstNode
    final parentNode = _findParentNode(node).hashCode;
    final scopeId = _findScopeNodeId(parentNode.hashCode);
    String type = 'SimpleIdentifier';
    final foundVariableDeclarationInAST = (Map nodeAST) {
      final isSameScope = scopeId == _findScopeNodeId(nodeAST['thisId']);
      final isSameName = nodeAST['name'] == node.name;
      return isSameName && isSameScope;
    };
    if (scopeId != null) {
      for (var key in astRef.keys) {
        final nodeAST = astRef[key];
        if (foundVariableDeclarationInAST(nodeAST)) {
          type = nodeAST['type'];
        }
      }
    }

    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': parentNode.hashCode,
      'type': type,
      'name': node.name,
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST;
  }

  @override
  Map visitIntegerLiteral(IntegerLiteral node) {
    final nodeAST = {
      'thisId': node.hashCode,
      'parentId': _findParentNode(node).hashCode,
      'type': 'int',
      'value': node.value,
    };

    astRef[node.hashCode] = nodeAST;
    return nodeAST;
  }
}
