# inspiration https://github.com/prompt-toolkit/ptpython/blob/master/examples/ptpython_config/config.py

from prompt_toolkit.filters import ViInsertMode
from prompt_toolkit.key_binding.key_processor import KeyPress
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style

from ptpython.layout import CompletionVisualisation

__all__ = ["configure"]


def configure(repl):
    # mouse support seems to mess up scrolling
    repl.enable_mouse_support = False
    repl.confirm_exit = False

    corrections = {
        "lm": "lambda:",
        "lx": "lambda x:",
        "ly": "lambda x, y:",
    }

    @repl.add_key_binding(" ")
    def _(event):
        " When a space is pressed. Check & correct word before cursor. "
        b = event.cli.current_buffer
        w = b.document.get_word_before_cursor()

        if w is not None:
            if w in corrections:
                b.delete_before_cursor(count=len(w))
                b.insert_text(corrections[w])

        b.insert_text(" ")
