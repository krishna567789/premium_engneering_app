import sys

def swap_in_edit_screen():
    file_path = 'lib/features/certificate/screens/role2_edit_certificate_screen.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    lines[1409] = '                      l2: "Manufacturing Date",\n'
    lines[1449] = '                      l2: "Last Testing Date",\n'

    last_testing = lines[1423:1445]
    manufacturing = lines[1496:1673]

    del lines[1496:1673]
    for i, line in enumerate(last_testing):
        lines.insert(1496 + i, line)

    del lines[1423:1445]
    for i, line in enumerate(manufacturing):
        lines.insert(1423 + i, line)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Edit screen swapped.")

swap_in_edit_screen()
