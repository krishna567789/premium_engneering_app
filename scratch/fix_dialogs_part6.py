import os

files_to_process = [
    r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role1_edit_certificate_screen.dart",
    r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart"
]

old_remove = """  void _removeRemark(String title) {
    if (remarksController.text.trim().isEmpty) return;
    final lines = remarksController.text.split('\\n');
    final newLines = lines.where((line) => !line.startsWith("$title:")).toList();
    remarksController.text = newLines.join('\\n');
    if (remarksController.text.trim().isEmpty) {
      isRemarkRequired = false;
    }
  }"""

new_remove = """  void _removeRemark(String title) {
    if (remarksController.text.trim().isNotEmpty) {
      final lines = remarksController.text.split('\\n');
      final newLines = lines.where((line) => !line.startsWith("$title:")).toList();
      remarksController.text = newLines.join('\\n');
    }
    if (remarksController.text.trim().isEmpty) {
      setState(() {
        isRemarkRequired = false;
      });
    }
  }"""

for f in files_to_process:
    if not os.path.exists(f):
        continue
    
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
        
    if old_remove in content:
        content = content.replace(old_remove, new_remove)
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Updated {f}")
    else:
        print(f"Could not find old _removeRemark in {f}")

print("Done")
