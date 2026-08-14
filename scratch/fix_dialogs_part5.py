import os
import re

def process_file(filepath):
    if not os.path.exists(filepath):
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # We want to change `if (isRemarkRequired) ...[` to `if (isRemarkRequired || remarksController.text.trim().isNotEmpty) ...[`
    # We will just do a string replace since this is very specific.
    
    content = content.replace(
        "if (isRemarkRequired) ...[",
        "if (isRemarkRequired || remarksController.text.trim().isNotEmpty) ...["
    )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")


process_file(r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart")
process_file(r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart")
process_file(r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart")
