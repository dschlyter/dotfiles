from typing import List


def print_table(table: List[List[str]], sep="\t"):
    for row in printable(table):
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


# the function missing from python
def get(list, i, default=None):
    if i < 0 or i >= len(list):
        return default
    return list[i]
