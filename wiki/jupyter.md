## Installing

Don't use conda, do it the hard way :)

    pip3 install jupyterlab

If you get markupsafe errors - https://stackoverflow.com/questions/74411148/getting-importerror-cannot-import-name-soft-unicode-from-markupsafe-for-a-c/75987111#75987111

Also get vim

    pip3 install --upgrade jupyterlab-vim

## Using in an existing venv

    pip3 install ipython ipykernel
    ipython kernel install --user --name=$(basename $(pwd))
    
You MAY install jupytherlab, but you can also use the global one.

    pip3 install jupyterlab

Then run jupyter-lab

    jupyter-lab

Make sure to select the venv kernel in jupyter-lab.

To remove the kernel, do:

    jupyter kernelspec list
    jpyter kernelspec remove NAME

## Keys

With the vim plugin

    Ctrl-Shift-C - command palette

    Shift-Enter - execute and step to next
    Alt-Enter - execute and insert a new cell
    Ctrl-Enter - excute and stay

    Esc - vim mode (ctrl-c does not work)
    Ctrl-O - do cell level operations in vim (e.g. `d` for delete)
    Ctrl-j/k - up/down

    Shift-Esc - Jupyter mode where you can select cells
    Shift-j/k - select multiple cells

    Tab - autocomplete in insert mode