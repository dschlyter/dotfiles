import math
import os
import platform
import shutil
import subprocess
import re
from typing import List


def print_table(table: List[List[str]], sep="\t", fit=False, rjust=False):
    p = printable(table, rjust=rjust)
    if fit:
        trim_to_terminal(p, sep)

    for row in p:
        print(*row, sep=sep)

# Pad strings to be equal width by column and thus nicely printable
def printable(table: List[List[str]], rjust=False):
    str_table = [[str(col) for col in row] for row in table]

    col_width = {}
    for row in str_table:
        for i, col in enumerate(row):
            col_width[i] = max(length_without_color(col), col_width.get(i, 0))

    for row in str_table:
        for i,_ in enumerate(row):
            w = col_width[i]
            if rjust:
                row[i] = row[i].rjust(w)
            else:
                row[i] = row[i].ljust(w)

    return str_table


def length_without_color(text):
    # Regular expression to match ANSI escape sequences
    ansi_escape = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]')
    # Remove ANSI escape sequences
    clean_text = ansi_escape.sub('', text)
    # Return the length of the cleaned text
    return len(clean_text)


def trim_to_terminal(table, sep):
    if table:
        max_cols = 0
        term_width = int(shutil.get_terminal_size().columns)
        sum_width = 0
        for i in range(len(table[0])):
            l = len(table[0][i]) + 1
            if sep == "\t":
                l = math.ceil(l / 8.0) * 8
            if sum_width + l > term_width:
                break
            sum_width += l
            max_cols += 1
        for i in range(len(table)):
            table[i] = table[i][0:max_cols]


def get_clipboard():
    if platform.system() == 'Darwin':
        return subprocess.check_output(['pbpaste']).decode('utf-8').strip()
    elif platform.system() == 'Windows' or 'microsoft' in platform.uname().release.lower() or 'wsl' in platform.uname().release.lower():
        return subprocess.check_output(['powershell.exe', 'Get-Clipboard']).decode('utf-8').strip()
    else:
        return subprocess.check_output(['xclip', '-selection', 'clipboard', '-o']).decode('utf-8').strip()


def set_clipboard(text):
    if platform.system() == 'Darwin':
        subprocess.run(['pbcopy'], input=text.encode('utf-8'), check=True)
    elif platform.system() == 'Windows' or 'microsoft' in platform.uname().release.lower() or 'wsl' in platform.uname().release.lower():
        subprocess.run(['clip.exe'], input=text.encode('utf-8'), check=True)
        return
    else:
        subprocess.run(['xclip', '-selection', 'clipboard'], input=text.encode('utf-8'), check=True)


# the function missing from python
def get(list, i, default=None):
    if i < 0 or i >= len(list):
        return default
    return list[i]


def get_in(nested_dict, *keys, default=None):
    if not keys or not nested_dict:
        return default
    return get_in(nested_dict[keys[0]], keys[1:])