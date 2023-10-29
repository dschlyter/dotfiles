import subprocess
import shutil
import sys

def fzf_match(entries, multiple=False, hint_install_fzf=False, sort=True, or_exit=False):
    if not entries:
        if or_exit:
            print("Nothing to match on")
            sys.exit(1)
        elif multiple:
            return []
        else:
            return None

    if shutil.which("fzf"):
        cmd = ["fzf", "--tac", "--no-mouse"]
        if multiple:
            cmd += ["-m"]
        if not sort:
            cmd += ["--no-sort", "--exact"]
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

        for entry in entries:
            p.stdin.write((entry + "\n").encode("utf-8"))
        p.stdin.close()

        matches = []
        for line in p.stdout:
            matches.append(line.decode("utf-8").strip())

        if multiple:
            return matches
        elif len(matches) > 0:
            return matches[0]
        elif or_exit:
            print("Nothing was selected")
            sys.exit(1)
        else:
            return None
    else:
        if hint_install_fzf:
            print("pro tip: this selection dialog becomes more nice if you install 'fzf'")
        # Fallback behaviour without fzf installed
        i = 1
        for e in entries:
            print(i, e)
            i += 1

        if multiple:
            selection = input("select entries: ")
            return [entries[i-1] for i in map(int, selection.strip().split(" "))]
        else:
            selection = input("select entry: ")
            return entries[int(selection.strip())-1]