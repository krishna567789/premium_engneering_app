
import 'dart:io';

void main() {
  final file = File('lib/features/home/screens/role2_screen.dart');
  final content = file.readAsStringSync();
  
  final stack = <Map<String, dynamic>>[];
  final lines = content.split('\n');
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    for (int j = 0; j < line.length; j++) {
      final char = line[j];
      if (char == '(' || char == '[' || char == '{') {
        stack.add({'char': char, 'line': i + 1, 'col': j + 1});
      } else if (char == ')' || char == ']' || char == '}') {
        if (stack.isEmpty) {
          print('Extra closing bracket $char at ${i + 1}:${j + 1}');
          return;
        }
        final opening = stack.removeLast();
        if ((opening['char'] == '(' && char != ')') ||
            (opening['char'] == '[' && char != ']') ||
            (opening['char'] == '{' && char != '}')) {
          print('Mismatched bracket: ${opening['char']} from ${opening['line']}:${opening['col']} with $char at ${i + 1}:${j + 1}');
          return;
        }
      }
    }
  }
  
  if (stack.isNotEmpty) {
    for (final open in stack) {
      print('Unclosed bracket ${open['char']} from ${open['line']}:${open['col']}');
    }
  } else {
    print('Brackets are balanced');
  }
}
