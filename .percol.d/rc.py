from percol.finder import FinderMultiQueryRegex

percol.view.prompt_replacees["F"] = lambda self, **args: self.model.finder.get_name()
percol.view.PROMPT = ur"<blue>Query:</blue> %q"
percol.view.RPROMPT = ur"(%F) [%i/%I]"

percol.view.CANDIDATES_LINE_BASIC    = ("on_default", "default")
percol.view.CANDIDATES_LINE_SELECTED = ("underline", "on_cyan", "black")
percol.view.CANDIDATES_LINE_MARKED   = ("bold", "on_blue", "white")
percol.view.CANDIDATES_LINE_QUERY    = ("yellow", "bold")

percol.import_keymap({
    # Vim like
    "C-j" : lambda percol: percol.command.select_next(),
    "C-k" : lambda percol: percol.command.select_previous(),
    "C-d" : lambda percol: percol.command.select_next_page(),
    "C-u" : lambda percol: percol.command.select_previous_page(),
    "C-v" : lambda percol: percol.command.toggle_mark_all(),

    "C-r" : lambda percol: percol.command.toggle_finder(FinderMultiQueryRegex),

    # Readline like
    "C-w" : lambda percol: percol.command.delete_backward_word(),

    # Emacs like
    "C-h" : lambda percol: percol.command.delete_backward_char(),
    "C-y" : lambda percol: percol.command.yank(),
    "C-t" : lambda percol: percol.command.transpose_chars(),
    "C-a" : lambda percol: percol.command.beginning_of_line(),
    "C-e" : lambda percol: percol.command.end_of_line(),
    "C-b" : lambda percol: percol.command.backward_char(),
    "C-f" : lambda percol: percol.command.forward_char(),
    "M-f" : lambda percol: percol.command.forward_word(),
    "M-b" : lambda percol: percol.command.backward_word(),
    "M-d" : lambda percol: percol.command.delete_forward_word(),
    "M-h" : lambda percol: percol.command.delete_backward_word(),
    "C-n" : lambda percol: percol.command.select_next(),
    "C-p" : lambda percol: percol.command.select_previous(),
    "M-v" : lambda percol: percol.command.select_previous_page(),
    "M-<" : lambda percol: percol.command.select_top(),
    "M->" : lambda percol: percol.command.select_bottom(),
    "C-g" : lambda percol: percol.cancel(),
})
