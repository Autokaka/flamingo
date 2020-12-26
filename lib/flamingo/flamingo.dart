library flamingo;

import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

part 'compiler.dart';

String debugEncode(dynamic json, {int indent = 4}) {
  var spaces = ' ' * indent;
  var encoder = JsonEncoder.withIndent(
    spaces,
    (value) => '[${value.runtimeType}] -> $value',
  );
  return encoder.convert(json);
}
