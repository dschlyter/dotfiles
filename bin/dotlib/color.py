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
GREY_BG = "\033[100m"
LIGHT_GREY_BG = "\033[107m"

RESET = "\033[0m"


def red(text):
    return f"{RED}{text}{RESET}"


def green(text):
    return f"{GREEN}{text}{RESET}"


def yellow(text):
    return f"{YELLOW}{text}{RESET}"


def blue(text):
    return f"{BLUE}{text}{RESET}"


def magenta(text):
    return f"{MAGENTA}{text}{RESET}"


def cyan(text):
    return f"{CYAN}{text}{RESET}"


def nothing(text):
    return text

def red_bg(text):
    return f"{RED_BG}{text}{RESET}"

def green_bg(text):
    return f"{GREEN_BG}{text}{RESET}"

def yellow_bg(text):
    return f"{YELLOW_BG}{text}{RESET}"

def blue_bg(text):
    return f"{BLUE_BG}{text}{RESET}"

def magenta_bg(text):
    return f"{MAGENTA_BG}{text}{RESET}"

def cyan_bg(text):
    return f"{CYAN_BG}{text}{RESET}"

def white_bg(text):
    return f"{WHITE_BG}{text}{RESET}"

def grey_bg(text):
    return f"{GREY_BG}{text}{RESET}"

def light_grey_bg(text):
    return f"{GREY_BG}{text}{RESET}"


# 256 colors

def color_fg_256(color_code, text):
    return f"\033[38;5;{color_code}m{text}\033[0m"

def color_bg_256(color_code, text):
    return f"\033[48;5;{color_code}m{text}\033[0m"

code_muted_blue = 24
code_muted_green = 22
code_muted_red = 88
code_muted_yellow = 136
code_muted_purple = 54

def muted_blue(text):
    return color_fg_256(code_muted_blue, text)

def muted_green(text):
    return color_fg_256(code_muted_green, text)

def muted_red(text):
    return color_fg_256(code_muted_red, text)

def muted_yellow(text):
    return color_fg_256(code_muted_yellow, text)

def muted_purple(text):
    return color_fg_256(code_muted_purple, text)

def muted_blue_bg(text):
    return color_bg_256(code_muted_blue, text)

def muted_green_bg(text):
    return color_bg_256(code_muted_green, text)

def muted_red_bg(text):
    return color_bg_256(code_muted_red, text)

def muted_yellow_bg(text):
    return color_bg_256(code_muted_yellow, text)

def muted_purple_bg(text):
    return color_bg_256(code_muted_purple, text)