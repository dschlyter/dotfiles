# Define ANSI escape codes for colors
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"

RED_BG = "\033[41m"
GREEN_BG = "\033[42m"
YELLOW_BG = "\033[43m"
BLUE_BG = "\033[44m"
MAGENTA_BG = "\033[45m"
CYAN_BG = "\033[46m"
WHITE_BG = "\033[47m"

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

def red_bg(str):
    return f"{RED_BG}{str}{RESET}"

def green_bg(str):
    return f"{GREEN_BG}{str}{RESET}"

def yellow_bg(str):
    return f"{YELLOW_BG}{str}{RESET}"

def blue_bg(str):
    return f"{BLUE_BG}{str}{RESET}"

def magenta_bg(str):
    return f"{MAGENTA_BG}{str}{RESET}"

def cyan_bg(str):
    return f"{CYAN_BG}{str}{RESET}"

def white_bg(str):
    return f"{WHITE_BG}{str}{RESET}"