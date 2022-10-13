import json
import os
from pathlib import Path

# Simple local conf

class Conf:
    def __init__(self, app_name):
       self.path = os.path.join(Path.home(), ".config", f"{app_name}.json")

    def get(self, key, default=None):
        if os.path.exists(self.path):
            with open(self.path) as fp:
                j = json.load(fp)
            return j.get(key, default)
        return default

    def put(self, key, value):
        if os.path.exists(self.path):
            with open(self.path) as fp:
                j = json.load(fp)
        else:
            j = {}
        j[key] = value
        with open(self.path, 'w') as fp:
            json.dump(j, fp)

    def cursor(self, key):
        return ConfCursor(self, key)

class ConfCursor:
    def __init__(self, conf: Conf, key):
        self.conf = conf
        self.key = key

    def get(self, default=None):
        return self.conf.get(self.key, default=default)

    def put(self, data):
        return self.conf.put(self.key, data)