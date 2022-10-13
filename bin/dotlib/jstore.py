#!/usr/bin/env python3
import os
import urllib
import logging
import json
from pathlib import Path
from urllib.parse import quote, unquote
from dotlib.api import RestApi

log_level = logging.INFO
logging.basicConfig(format='%(asctime)s %(name)s %(levelname)s %(message)s', level=log_level)

HOME = str(Path.home())
CREDS_PATH = HOME + "/.config/jstore-creds.json"

class JStore:
    def __init__(self, app, local=None) -> None:
        self.app = app
        self.local = local == True or os.environ.get('JSTORE_LOCAL')
        if not self.local:
            self.api = RestApi()
        else:
            self.api = LocalApi()

    def keys(self):
        return self.api.get(f"api/{self.app}?keys=1")['keys']

    def get(self, key, null_ok=False, fields=None):
        try:
            fields_query = f"?fields={','.join(fields)}" if fields else ""
            return self.api.get(f"api/{self.app}/{quote(key)}{fields_query}")
        except urllib.error.HTTPError as e:
            if null_ok and e.code == 404:
                return None
            raise 
        except FileNotFoundError:
            if null_ok:
                return None
            raise 

    def get_all(self, fields=None):
        fields_query = f"?fields={','.join(fields)}" if fields else ""
        return self.api.get(f"api/{self.app}{fields_query}")

    def put(self, key, data):
        if not isinstance(data, dict):
            raise Exception("You should store a dict")
        return self.api.put(f"api/{self.app}/{quote(key)}", data)

    def delete(self, key):
        return self.api.delete(f"api/{self.app}/{quote(key)}")

    def get_raw(self, path):
        return self.api.get(path)

    def auth(self, host, user, password):
        return self.api.auth(host, user, password)


class LocalApi:
    def __init__(self) -> None:
        self.STORE_PATH = HOME + "/.data/jstore-local/"

    def get(self, url):
        file = self._get_file(url)

        if url.endswith("?keys=1"):
            directory = file.replace("?keys=1", "")
            if os.path.isdir(directory):
                return {"keys": os.listdir(directory)}
            return {"keys": []}
        elif url.endswith("/api/kv-apps"):
            return {'apps': os.listdir(self.STORE_PATH + "/api")}
        elif os.path.isdir(file):
            ret = {}
            for subfile in os.listdir(file):
                with open(f"{file}/{subfile}") as fp:
                    ret[subfile] = json.load(fp)
            return ret
        else:
            with open(file) as fp:
                return json.load(fp)

    def post(self, url, data):
        raise NotImplemented("NYI")

    def put(self, url, data):
        file = self._get_file(url)
        os.makedirs(os.path.dirname(file), exist_ok=True)
        with open(file, 'w') as fp:
            json.dump(data, fp)
        return {"status": "success"}

    def delete(self, url):
        file = self._get_file(url)
        if os.path.isfile(file):
            os.remove(file)
        return {"status": "success"}

    def auth(self, host, user, password):
        # No need for auth
        return True

    def _get_file(self, url):
        return self.STORE_PATH + unquote(url.split("?")[0])