# Startup file - stuff in here will be available in the REPL

#
# Default imports
#

import math
import random
import subprocess

#
# Default libs
#

missing = []
try:
    import sympy
    from sympy.solvers import solve
    from sympy import Symbol

    # setting this up as a default symbol
    x = Symbol('x')
except:
    missing.append("sumpy")
    print("todo: pip install sumpy")

try:
    import numpy as np
except:
    missing.append("numpy")

try:
    import matplotlib.pyplot as plt
except:
    missing.append("matplotlib")

if missing:
    print("todo: pip install", " ".join(missing))

#
# Default functions
#

p = print

def fns():
    ignore = ['run', 'get_ptpython']
    names = [g for g in globals()]
    for n in names:
        c = globals()[n]
        if type(c).__name__ == 'function' and not n in ignore:
            print(n)

def where(fn):
    import inspect
    print(inspect.getsource(fn))

def sh(command):
    subprocess.check_call(['/bin/bash', '-o', 'pipefail', '-c', command])

def sh_read(command):
    return subprocess.check_output(['/bin/bash', '-o', 'pipefail', '-c', command]).decode("utf-8").strip()

def fplot(*fns, x=None):
    """
    Quick plot utility, give a list of functions lambda x: x ** 2 + x and plot them.
    Args can also be arrays.
    Optionally give the x range for plotting
    """
    if not x:
        x = [n for n in range(100)]

    fig, ax = plt.subplots()
    for f in fns:
        if type(f).__name__ == 'function':
            y = [f(x) for x in x]
        else:
            y = f
        ax.plot(x, y)
    
    if len(x) <= 20 and max(x) < 100:
        ax.set_xticks(x)
    plt.grid(linestyle="--")
    plt.show()
