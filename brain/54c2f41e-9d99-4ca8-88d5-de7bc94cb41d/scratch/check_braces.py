
def check_braces(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    stack = []
    lines = content.split('\n')
    for i, line in enumerate(lines):
        for j, char in enumerate(line):
            if char in '([{':
                stack.append((char, i + 1, j + 1))
            elif char in ')]}':
                if not stack:
                    print(f"Extra closing brace '{char}' at line {i+1}, col {j+1}")
                    return
                opening, oi, oj = stack.pop()
                if (opening == '(' and char != ')') or \
                   (opening == '[' and char != ']') or \
                   (opening == '{' and char != '}'):
                    print(f"Mismatched braces: '{opening}' at line {oi}, col {oj} and '{char}' at line {i+1}, col {j+1}")
                    return
    
    if stack:
        char, i, j = stack.pop()
        print(f"Unclosed brace '{char}' at line {i}, col {j}")
    else:
        print("All braces match!")

check_braces(r'd:\premium_engineering_app\premium_engneering_app\lib\features\home\screens\role2_screen.dart')
