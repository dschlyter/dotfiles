# Startup file - stuff in here will be available in the REPL

#
# Default imports
#

import math
import random
import subprocess
import statistics

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

    # quickly define vectors
    def v(*args):
        return np.array([n for n in args])
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

def fplot(*fns, x=None, split=None):
    """
    Quick plot utility, give a list of functions lambda x: x ** 2 + x and plot them.
    Args can also be arrays.
    Optionally give the x range for plotting
    """
    if not x:
        x = [n for n in range(100)]

    data = []
    for f in fns:
        if type(f).__name__ == 'function':
            data.append((x, [f(x) for x in x]))
        else:
            data.append((x, f))

    subplots(data, split=split)


def subplots(plot_data, split=None):
    """
    Automatically split plots when ranges are significantly different
    """
    split = split if split is not None else 5
    with_index = [(i+1, x, y) for i, (x, y) in enumerate(plot_data)]

    plot_groups = []
    for d in with_index:
        added = False
        for i in range(len(plot_groups)):
            new_group = plot_groups[i] + [d]
            y_range_sizes = [max(max([abs(p) for p in y]), 0.001) for (s, x, y) in new_group]
            if split is False or max(y_range_sizes) / min(y_range_sizes) < split:
                plot_groups[i] = new_group
                added = True
                break
        if not added:
            plot_groups.append([d])

    fig, axs = plt.subplots(len(plot_groups), 1)
    if len(plot_groups) == 1:
        axs = [axs]

    for i, p in enumerate(plot_groups):
        ax = axs[i]
        for (s, x, y) in p:
            ax.plot(x, y, label=f"series {s}")

            # nicer ticks if x range is short
            if len(x) <= 20 and max(x) < 100:
                ax.set_xticks(x)

        ax.legend(loc='best')
        ax.grid(linestyle="--")

    # plt.legend(loc='best')
    plt.show()

def avg(x):
    return statistics.fmean(x)

def binomial_cdf(n, p, k):
    """
    Calculates the probability of n events with probability p occurring k or more times.

    Returns:
        float: The cumulative probability P(X ≤ k).
    """
    cdf = 0.0
    for i in range(k + 1):
        binomial_coeff = math.comb(n, i)
        prob = binomial_coeff * (p ** i) * ((1 - p) ** (n - i))
        cdf += prob

    return cdf