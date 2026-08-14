import os
import re

files_to_process = [
    r"d:\premium_engneering_app\lib\features\home\screens\role1_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role1_edit_certificate_screen.dart",
    r"d:\premium_engneering_app\lib\features\home\screens\role2_screen.dart",
    r"d:\premium_engneering_app\lib\features\certificate\screens\role2_edit_certificate_screen.dart"
]

add_or_update_remark_func = """
  void _addOrUpdateRemark(String title, String message) {
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
  }
"""

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add _addOrUpdateRemark if not present
    if "_addOrUpdateRemark(" not in content:
        # Find a good place to insert it. Before _showExpiredWarningDialog or somewhere
        if "void _showExpiredWarningDialog()" in content:
            content = content.replace("  void _showExpiredWarningDialog() {", add_or_update_remark_func + "\n  void _showExpiredWarningDialog() {")
        elif "void _showEarlyTestingDialog()" in content:
            content = content.replace("  void _showEarlyTestingDialog() {", add_or_update_remark_func + "\n  void _showEarlyTestingDialog() {")

    # We will replace the entire method bodies for known dialogs.
    # We will find the start of the method, and the matching end brace.
    def replace_method(method_name, new_body):
        nonlocal content
        pattern = r"  void " + method_name + r"\s*\([^)]*\)\s*{"
        match = re.search(pattern, content)
        if not match:
            return
        start_idx = match.start()
        # Find closing brace
        brace_count = 0
        idx = match.end() - 1 # points to '{'
        end_idx = -1
        for i in range(idx, len(content)):
            if content[i] == '{':
                brace_count += 1
            elif content[i] == '}':
                brace_count -= 1
                if brace_count == 0:
                    end_idx = i + 1
                    break
        if end_idx != -1:
            content = content[:start_idx] + new_body + content[end_idx:]

    
    # 1. _showExpiredWarningDialog
    expired_body = """  void _showExpiredWarningDialog() {
    const String defaultMessage = "your cylinder expire you can not perform test";
    TextEditingController popupRemarkCtrl = TextEditingController(text: defaultMessage);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Cylinder Expired", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(defaultMessage, style: TextStyle(fontSize: 15)),
            const SizedBox(height: 15),
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Cylinder Expired", popupRemarkCtrl.text);
              });
            },
            child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
"""
    replace_method("_showExpiredWarningDialog", expired_body)

    # 2. _showEarlyTestingDialog
    early_testing_dialog_body = """  void _showEarlyTestingDialog() {
    const String defaultMessage = "You've come in for testing earlier than the scheduled interval. If you proceed, you must provide a reason in the Remarks field below.";
    TextEditingController popupRemarkCtrl = TextEditingController(text: defaultMessage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Testing Alert"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(defaultMessage, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Testing Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
"""
    replace_method("_showEarlyTestingDialog", early_testing_dialog_body)

    # 3. _showVehicleWarningDialog
    vehicle_warning_dialog_body = """  void _showVehicleWarningDialog(String message) {
    TextEditingController popupRemarkCtrl = TextEditingController(text: message);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Vehicle Alert"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 15),
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Vehicle Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
"""
    replace_method("_showVehicleWarningDialog", vehicle_warning_dialog_body)

    # 4. _showWeightWarningDialog
    weight_warning_dialog_body = """  void _showWeightWarningDialog(String message) {
    TextEditingController popupRemarkCtrl = TextEditingController(text: message);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Weight Alert"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 15),
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Weight Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
"""
    replace_method("_showWeightWarningDialog", weight_warning_dialog_body)

    # 5. _showLastTestingDateWarningDialog
    last_test_dialog_body = """  void _showLastTestingDateWarningDialog(String message) {
    TextEditingController popupRemarkCtrl = TextEditingController(text: message);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Alert"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
"""
    replace_method("_showLastTestingDateWarningDialog", last_test_dialog_body)

    # 6. _showEarlyTestingWorkflow
    early_testing_workflow_body = """  void _showEarlyTestingWorkflow(String message) {
    TextEditingController popupRemarkCtrl = TextEditingController(text: message);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Vehicle Alert"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 15),
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Is cylinder multi-cylinder?",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isMultiCylinder = true;
                isRemarkRequired = false;
                try {
                  earlyTestingReason = "Multi-cylinder";
                } catch(e) {}
                _addOrUpdateRemark("Vehicle Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("Yes", style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isMultiCylinder = false;
                isRemarkRequired = true;
                try {
                  earlyTestingReason = popupRemarkCtrl.text;
                } catch(e) {}
                _addOrUpdateRemark("Vehicle Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("No", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
"""
    replace_method("_showEarlyTestingWorkflow", early_testing_workflow_body)

    # Note: the python script just replaces the string in memory.
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for f in files_to_process:
    if os.path.exists(f):
        print("Processing", f)
        process_file(f)
    else:
        print("File not found:", f)

print("Done")
