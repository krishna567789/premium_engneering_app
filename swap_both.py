import sys

def swap_in_edit_screen():
    file_path = 'lib/features/certificate/screens/role2_edit_certificate_screen.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    lines[1409] = '                      l2: "Manufacturing Date",\n'
    lines[1449] = '                      l2: "Last Testing Date",\n'

    last_testing = lines[1423:1444]
    manufacturing = lines[1496:1669]

    del lines[1496:1669]
    for i, line in enumerate(last_testing):
        lines.insert(1496 + i, line)

    del lines[1423:1444]
    for i, line in enumerate(manufacturing):
        lines.insert(1423 + i, line)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Edit screen swapped.")

def swap_in_create_screen():
    file_path = 'lib/features/home/screens/role2_screen.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    lines[1025] = '                            l2: "Manufacturing Date",\n'
    lines[1049] = '                            l2: "Last Testing Date",\n'
    
    last_testing = lines[1037:1044]
    manufacturing = lines[1063:1262]
    
    del lines[1063:1262]
    for i, line in enumerate(last_testing):
        lines.insert(1063 + i, line)
        
    del lines[1037:1044]
    for i, line in enumerate(manufacturing):
        lines.insert(1037 + i, line)
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Create screen swapped.")

swap_in_edit_screen()
swap_in_create_screen()
