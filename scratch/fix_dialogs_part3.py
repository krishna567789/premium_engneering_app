import os

files_to_process = [
    r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role1_edit_certificate_screen.dart",
    r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart"
]

old_func = """  void _addOrUpdateRemark(String title, String message) {
    if (message.trim().isEmpty) return;
    String newRemark = "$title: $message";
    if (remarksController.text.trim().isEmpty) {
      remarksController.text = newRemark;
    } else {
      if (!remarksController.text.contains("$title:")) {
        remarksController.text = "${remarksController.text}\\n$newRemark";
      } else {
        final lines = remarksController.text.split('\\n');
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith("$title:")) {
            lines[i] = newRemark;
            break;
          }
        }
        remarksController.text = lines.join('\\n');
      }
    }
  }"""

new_func = """  void _addOrUpdateRemark(String title, String message) {
    if (message.trim().isEmpty) return;
    String newRemark = "$title: $message";
    if (remarksController.text.trim().isEmpty) {
      remarksController.text = newRemark;
    } else {
      final lines = remarksController.text.split('\\n');
      bool found = false;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith("$title:")) {
          lines[i] = newRemark;
          found = true;
          break;
        }
      }
      if (!found) {
        lines.add(newRemark);
      }
      remarksController.text = lines.join('\\n');
    }
  }"""

for f in files_to_process:
    if os.path.exists(f):
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
            
        content = content.replace(old_func, new_func)
        
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Updated {f}")
