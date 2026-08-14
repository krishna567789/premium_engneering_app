import os
import re

files_to_process = [
    r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role1_edit_certificate_screen.dart",
    r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart"
]

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove the static Text widgets that display the message in the dialog.
    # These match the exact lines we inserted.
    
    # Text(defaultMessage, ...)
    content = re.sub(
        r'const Text\(defaultMessage,\s*style:\s*TextStyle\(fontSize:\s*1[456]\)\),\s*const SizedBox\(height:\s*15\),',
        r'',
        content
    )
    
    # Text(message, ...)
    content = re.sub(
        r'Text\(message,\s*style:\s*const TextStyle\(fontSize:\s*1[456]\)\),\s*const SizedBox\(height:\s*15\),',
        r'',
        content
    )
    
    # For _showEarlyTestingWorkflow
    content = re.sub(
        r'Text\(message,\s*style:\s*const TextStyle\(fontSize:\s*14\)\),\s*const SizedBox\(height:\s*15\),',
        r'',
        content
    )

    # 2. Remove remarksController.text = msg;
    # It is safe to remove `remarksController.text = msg;` and `remarksController.text = reasonCtrl.text;`
    content = content.replace("remarksController.text = msg;", "")
    content = content.replace("remarksController.text = reasonCtrl.text;", "")

    # Also clean up any extra newlines left by the removal
    content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for f in files_to_process:
    if os.path.exists(f):
        print("Processing", f)
        process_file(f)
    else:
        print("File not found:", f)

print("Done")
