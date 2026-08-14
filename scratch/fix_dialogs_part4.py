import os
import re

files_to_process = [
    r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role1_edit_certificate_screen.dart",
    r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart"
]

remove_remark_func = """
  void _removeRemark(String title) {
    if (remarksController.text.trim().isEmpty) return;
    final lines = remarksController.text.split('\\n');
    final newLines = lines.where((line) => !line.startsWith("$title:")).toList();
    remarksController.text = newLines.join('\\n');
    if (remarksController.text.trim().isEmpty) {
      isRemarkRequired = false;
    }
  }
"""

for f in files_to_process:
    if not os.path.exists(f):
        continue
    
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
        
    # 1. Add _removeRemark below _addOrUpdateRemark
    if "void _removeRemark(" not in content:
        # find end of _addOrUpdateRemark
        pattern = r"  void _addOrUpdateRemark\(String title, String message\) \{[\s\S]*?\n  \}"
        match = re.search(pattern, content)
        if match:
            content = content[:match.end()] + "\n" + remove_remark_func + content[match.end():]

    # 2. Modify _syncExpiryDate / _checkExpiryWarning
    # In role1_screen.dart and role2_screen.dart it's _syncExpiryDate:
    #   if (!expired && !isEarlyTestingDetected && !isVehicleWarning) { isRemarkRequired = false; remarksController.clear(); }
    # Or similar combinations. We will replace the block inside `setState`
    
    content = re.sub(
        r'if\s*\([^)]*expired[^)]*\)\s*\{\s*isRemarkRequired\s*=\s*false;\s*remarksController\.clear\(\);\s*\}',
        r'if (!expired) { _removeRemark("Cylinder Expired"); }',
        content
    )
    # role1_edit_certificate_screen.dart has:
    # if (!isEarlyTestingDetected && !isVehicleWarning) { isRemarkRequired = false; remarksController.clear(); }
    # inside _checkExpiryWarning's else branch.
    # Let's just find _checkExpiryWarning and rewrite the else block if present.
    if "void _checkExpiryWarning()" in content:
        content = re.sub(
            r'else\s*\{\s*if\s*\(mounted\)\s*\{\s*setState\(\(\)\s*\{\s*if\s*\(!isEarlyTestingDetected[^}]*\}\s*\}\);\s*\}\s*\}',
            r'else { if (mounted) { setState(() { _removeRemark("Cylinder Expired"); }); } }',
            content
        )

    # 3. Modify _checkIntervalWarning
    # else { setState(() { isEarlyTestingDetected = false; if (!isCylinderExpired && !isVehicleWarning) { isRemarkRequired = false; remarksController.clear(); } }); }
    content = re.sub(
        r'else\s*\{\s*setState\(\(\)\s*\{\s*isEarlyTestingDetected\s*=\s*false;\s*if\s*\([^)]*\)\s*\{\s*isRemarkRequired\s*=\s*false;\s*remarksController\.clear\(\);\s*\}\s*\}\);\s*\}',
        r'else { setState(() { isEarlyTestingDetected = false; _removeRemark("Testing Alert"); }); }',
        content
    )

    # 4. Modify _checkVehicleNumber
    # else { if (mounted) { setState(() { isVehicleWarning = false; vehicleWarningMessage = null; isRemarkRequired = false; isMultiCylinder = null; earlyTestingReason = null; }); } }
    # Note: we need to remove "Vehicle Alert" here.
    content = re.sub(
        r'isVehicleWarning\s*=\s*false;\s*vehicleWarningMessage\s*=\s*null;\s*isRemarkRequired\s*=\s*false;\s*isMultiCylinder\s*=\s*null;\s*earlyTestingReason\s*=\s*null;',
        r'isVehicleWarning = false; vehicleWarningMessage = null; _removeRemark("Vehicle Alert"); isMultiCylinder = null; earlyTestingReason = null;',
        content
    )
    # in role1_edit_certificate:
    # isVehicleWarning = false; vehicleWarningMessage = null; final provider = ...
    # if (!isEarlyTestingDetected && !(info["isExpired"] as bool)) { isRemarkRequired = false; remarksController.clear(); }
    # Let's replace the if statement inside _checkVehicleNumber
    content = re.sub(
        r'if\s*\(!isEarlyTestingDetected\s*&&\s*!\(info\["isExpired"\]\s*as\s*bool\)\)\s*\{\s*isRemarkRequired\s*=\s*false;\s*remarksController\.clear\(\);\s*\}',
        r'_removeRemark("Vehicle Alert");',
        content
    )

    # 5. Modify _calculateWeightLoss (in role2)
    # weightErrorMessage = percentage > 5.0 ? ... : null;
    # (no existing logic to clear remark, we should add it)
    content = re.sub(
        r'(weightErrorMessage\s*=\s*percentage\s*>\s*5\.0[^;]+;)',
        r'\1\n          if (weightErrorMessage == null) { _removeRemark("Weight Alert"); }',
        content
    )
    
    # 6. Modify _checkLastTestingDateValidation (in role2)
    # There is no else branch for when the response is fine.
    # We will find `if (response != null && (response['status'] == false ...))` and add an `else { setState((){ _removeRemark("Alert"); }); }`
    content = re.sub(
        r'(if\s*\(response\s*!=\s*null\s*&&\s*\(\s*response\[\'status\'\]\s*==\s*false\s*\|\|[\s\S]*?_showLastTestingDateWarningDialog\(msg\);\s*\})',
        r'\1 else { if (mounted) { setState(() { _removeRemark("Alert"); }); } }',
        content
    )
    
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
    print(f"Updated {f}")

print("Done")
