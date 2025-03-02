# Define ANSI escape codes for colors
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"
RESET = "\033[0m"


def red(str):
    return f"{RED}{str}{RESET}"


def green(str):
    return f"{GREEN}{str}{RESET}"


def yellow(str):
    return f"{YELLOW}{str}{RESET}"


def blue(str):
    return f"{BLUE}{str}{RESET}"


def magenta(str):
    return f"{MAGENTA}{str}{RESET}"


def cyan(str):
    return f"{CYAN}{str}{RESET}"


def nothing(str):
    return str