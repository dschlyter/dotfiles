#!/usr/bin/env python3

import os
import urllib
import logging
import json
import sys
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.parse import quote, unquote

log_level = logging.INFO
logging.basicConfig(format='%(asctime)s %(name)s %(levelname)s %(message)s', level=log_level)

HOME = str(Path.home())
CREDS_PATH = HOME + "/.config/jstore-creds.json"


class JStore:
    def __init__(self, app, local=None) -> None:
        self.app = app
        self.local = local == True or os.environ.get('JSTORE_LOCAL')
        if not self.local:
            self.api = Api()
        else:
            self.api = LocalApi()

    def keys(self):
        creds = self._get_auth()
        return self.api.get(creds, f"api/{self.app}?keys=1")['keys']

    def get(self, key, null_ok=False, fields=None):
        creds = self._get_auth()
        try:
            fields_query = f"?fields={','.join(fields)}" if fields else ""
            return self.api.get(creds, f"api/{self.app}/{quote(key)}{fields_query}")
        except urllib.error.HTTPError as e:
            if null_ok and e.code == 404:
                return None
            raise 
        except FileNotFoundError:
            if null_ok:
                return None
            raise 

    def put(self, key, data):
        if not isinstance(data, dict):
            raise Exception("You should store a dict")
        creds = self._get_auth()
        return self.api.put(creds, f"api/{self.app}/{quote(key)}", data)

    def delete(self, key):
        creds = self._get_auth()
        return self.api.delete(creds, f"api/{self.app}/{quote(key)}")

    def get_raw(self, path):
        creds = self._get_auth()
        return self.api.get(creds, path)

    def auth(self, host, user, password):
        if self.local:
            # No need for auth
            return True
        
        ret = self.api.post(None, f"{host}/api/auth/login", {"userId": user, "password": password})
        creds = {"host": host, "sessionId": ret['sessionId']}

        with open(CREDS_PATH, 'w') as fp:
            json.dump(creds, fp)

        return True

    def _get_auth(self):
        if self.local:
            # No need for auth
            return {}

        if not os.path.exists(CREDS_PATH):
            print("Please setup auth with 'jau auth'")
            sys.exit(1)
        with open(CREDS_PATH) as fp:
            return json.load(fp)


class Api:
    def get(self, creds, url):
        return self._request(creds, url)

    def post(self, creds, url, data):
        return self._request(creds, url, method="POST", data=data)

    def put(self, creds, url, data):
        return self._request(creds, url, method="PUT", data=data)

    def delete(self, creds, url):
        return self._request(creds, url, method="DELETE")

    def _request(self, creds, url, method="GET", data=None):
        try:
            full_url = url
            if "https://" not in url:
                full_url = creds['host'].rstrip("/") + "/" + url.lstrip("/")
            logging.debug(f"{method} {full_url}")
            req = Request(full_url)
            if creds is not None:
                req.add_header('X-Session-Id', creds['sessionId'])
            req.method = method
            if data is not None:
                req.add_header('Content-Type', 'application/json')
                req.data = json.dumps(data).encode('utf-8')
            content = urlopen(req).read().decode()

            logging.debug(f"Result {content}")
            if content.startswith("{") or content.startswith("["):
                return json.loads(content)
            return content
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            logging.error(f"Request error: {body}")
            raise


class LocalApi:
    def __init__(self) -> None:
        self.STORE_PATH = HOME + "/.data/jstore-local/"

    def get(self, creds, url):
        file = self._get_file(url)

        if url.endswith("?keys=1"):
            directory = file.replace("?keys=1", "")
            if os.path.isdir(directory):
                return {"keys": os.listdir(directory)}
            return {"keys": []}
        elif url.endswith("/api/kv-apps"):
            return {'apps': os.listdir(self.STORE_PATH + "/api")}

        with open(file) as fp:
            return json.load(fp)

    def post(self, creds, url, data):
        raise NotImplemented("NYI")

    def put(self, creds, url, data):
        file = self._get_file(url)
        os.makedirs(os.path.dirname(file), exist_ok=True)
        with open(file, 'w') as fp:
            json.dump(data, fp)
        return {"status": "success"}

    def delete(self, creds, url):
        file = self._get_file(url)
        if os.path.isfile(file):
            os.remove(file)
        return {"status": "success"}

    def _get_file(self, url):
        return self.STORE_PATH + unquote(url)