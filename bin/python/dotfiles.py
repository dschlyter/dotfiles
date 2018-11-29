import subprocess
import re
import json
from tempfile import TemporaryFile

_AUTO = None


# high level fire and forget execution
def run(command, *args, shell=_AUTO, can_fail=False, print_stdout=False):
    if args:
        command = [command, *args]
    parsed = _parse_command(command, shell)
    if not print_stdout:
        try:
            return subprocess.check_output(parsed).strip().decode('utf-8')
        except subprocess.CalledProcessError:
            if can_fail:
                return None
            else:
                raise
    else:
        ret_val = subprocess.call(parsed)
        if not can_fail and ret_val != 0:
            raise Exception("command returned "+str(ret_val))
        return ret_val == 0


# more low level interface returning return value, stdout and stderr
# modified from https://stackoverflow.com/questions/30937829
def execute(command, *args, shell=_AUTO):
    if args:
        command = [command, *args]
    with TemporaryFile() as t:
        try:
            parsed = _parse_command(command, shell)
            out = subprocess.check_output(parsed, stderr=t).strip()
            t.seek(0)
            return 0, out, t.read().strip()
        except subprocess.CalledProcessError as e:
            t.seek(0)
            return e.returncode, None, t.read().strip()


def _parse_command(command, shell):
    command_list = _parse_into_arguments(command, shell)
    return list(map(lambda arg: arg.encode('utf-8', 'replace'), command_list))


def _parse_into_arguments(command, shell):
    if isinstance(command, str):
        if shell is _AUTO and re.search("['\"|><]", command):
            shell = True
        if shell:
            return ["bash", "-c", command]
        return command.split(" ")
    elif isinstance(command, list):
        return command
    else:
        raise Exception("Unsupported type issued to command")


def load_conf(path, default_value=None):
    try:
        with open(path, 'r') as data_file:
            return json.load(data_file)
    except (FileNotFoundError, json.JSONDecodeError):
        return default_value if default_value is not None else {}


def save_conf(path, data):
    with open(path, 'w') as data_file:
        json.dump(data, data_file)
