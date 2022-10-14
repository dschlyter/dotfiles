import math
import shutil
from typing import List


def print_table(table: List[List[str]], sep="\t", fit=False):
    p = printable(table)
    if fit:
        trim_to_terminal(p, sep)

    for row in p:
        print(*row, sep=sep)

# Pad strings to be equal width by column and thus nicely printable
def printable(table: List[List[str]]):
    str_table = [[str(col) for col in row] for row in table]

    col_width = {}
    for row in str_table:
        for i, col in enumerate(row):
            col_width[i] = max(len(col), col_width.get(i, 0))

    for row in str_table:
        for i,_ in enumerate(row):
            row[i] = row[i].ljust(col_width[i])

    return str_table


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


# the function missing from python
def get(list, i, default=None):
    if i < 0 or i >= len(list):
        return default
    return list[i]


def get_in(nested_dict, *keys, default=None):
    if not keys or not nested_dict:
        return default
    return get_in(nested_dict[keys[0]], keys[1:])