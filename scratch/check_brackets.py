
def check_brackets(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    stack = []
    lines = content.split('\n')
    for i, line in enumerate(lines):
        for char in line:
            if char in '([{':
                stack.append((char, i+1))
            elif char in ')]}':
                if not stack:
                    print(f"Extra closing bracket {char} at line {i+1}")
                    return
                opening, line_num = stack.pop()
                if (opening == '(' and char != ')') or \
                   (opening == '[' and char != ']') or \
                   (opening == '{' and char != '}'):
                    print(f"Mismatched bracket: {opening} from line {line_num} with {char} at line {i+1}")
                    return
    
    if stack:
        for char, line_num in stack:
            print(f"Unclosed bracket {char} from line {line_num}")
    else:
        print("Brackets are balanced")

check_brackets(r'd:\premium_engineering_app\premium_engneering_app\lib\features\home\screens\role2_screen.dart')
