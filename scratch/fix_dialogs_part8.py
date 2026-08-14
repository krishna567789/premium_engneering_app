import os

files_to_process = [
    r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role1_edit_certificate_screen.dart",
    r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart"
]

old_add = """  void _addOrUpdateRemark(String title, String message) {
    if (message.trim().isEmpty) return;
    String newRemark = "$title: $message";"""

new_add = """  void _addOrUpdateRemark(String title, String message) {
    if (message.trim().isEmpty) return;
    String cleanMessage = message.replaceAll('\\n', ' ').trim();
    String newRemark = "$title: $cleanMessage";"""

for f in files_to_process:
    if not os.path.exists(f):
        continue
    
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
        
    if old_add in content:
        content = content.replace(old_add, new_add)
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Updated {f}")
    else:
        print(f"Could not find old _addOrUpdateRemark in {f}")

print("Done")
