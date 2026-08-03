import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  final pattern1 = RegExp(
    r'\b_tr\s*\?\s*strings\.(\w+)Tr\s*:\s*strings\.\1En\b',
  );
  final pattern2 = RegExp(r'\bstrings\.(\w+)(Tr|En)\b');

  for (final file in files) {
    if (file.path.contains('app_strings.dart')) continue;

    final content = file.readAsStringSync();
    var newContent = content.replaceAllMapped(
      pattern1,
      (match) => 'strings.${match.group(1)}',
    );
    newContent = newContent.replaceAllMapped(
      pattern2,
      (match) => 'strings.${match.group(1)}',
    );

    if (newContent != content) {
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
    }
  }
}
