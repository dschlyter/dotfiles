## Developing

In 2021 it is actually possible to have a half decent Windows dev environment

- VS Code is pretty nice
    - Python plugin is nice. Press F5 to run. Navigation, debugging, extract method works.
        - Nice support for ipynb with a plugin
        - TODO: How to venv ?
    - Git
        - The default per-file timeline, below the file-tree, is quite neat
        - GitLens adds a nice commit log. 
        - But git operations is more nice inside WSL terminal
    - WSL integration seems to work well. Python extract method is borked, but otherwise nice.
- Setup WSL
    - Use ubuntu, install your dotfiles
    - It is a bit laggy, WSL2 might be nice? - but later
    - Copy/Paste in terminal: Shift-Right click
    - Harpo: wget .../harpo_cli.zip; unzip harpo_cli.zip; src/cli/install_cli.sh
    - `code .` opens VS code in local dir (this will break in WSL 2?)