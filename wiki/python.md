## Shell scripting

Any bash script >10 LoC should be replaced with python.

### File handling

    os.path.basename("/a/b/c/myfile.yaml") # 'myfile.yaml'
    os.path.dirname("/a/b/c/myfile.yaml") # /a/b/c
    os.path.os.path.splitext("/a/b/c/myfile.yaml") # ('/a/b/c/myfile', '.yaml')
    os.path.abspath("myfile.yaml") # /a/b/c/myfile.yaml

### File existance

    os.path.exists("myfile.yaml")
    os.path.isfile("myfile.yaml")
    os.path.isdir("myfile.yaml")