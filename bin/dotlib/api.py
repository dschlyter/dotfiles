import os
import urllib
import logging
import json
import sys
import time
from pathlib import Path
from urllib.request import Request, urlopen

log_level = logging.DEBUG if os.environ.get('API_DEBUG') == "1" else logging.INFO
logging.basicConfig(format='%(asctime)s %(name)s %(levelname)s %(message)s', level=log_level)

HOME = str(Path.home())
CREDS_PATH = HOME + "/.config/jstore-creds.json"
HOST_ENV_KEY = "API_HOST"


class RestApi:
    def get(self, url):
        return self._authed_request(url)

    def post(self, url, data):
        return self._authed_request(url, method="POST", data=data)

    def put(self, url, data):
        return self._authed_request(url, method="PUT", data=data)

    def delete(self, url):
        return self._authed_request(url, method="DELETE")

    def auth(self, host, user, password):
        ret = self._request(f"{host}/api/auth/login", method="POST", data={"userId": user, "password": password})
        creds = {"host": host, "sessionId": ret['sessionId']}

        with open(CREDS_PATH, 'w') as fp:
            json.dump(creds, fp)

        return True

    # TODO could be extracted to a pluggable auth module, sent into the constructor with a default
    def _get_auth(self):
        if not os.path.exists(CREDS_PATH):
            print("Please setup auth with 'jau auth'")
            sys.exit(1)
        with open(CREDS_PATH) as fp:
            return json.load(fp)

    def _authed_request(self, url, method="GET", data=None):
        return self._request(url, method=method, data=data, auth=self._get_auth())

    def _request(self, url, method="GET", data=None, auth=None):
        try:
            full_url = url
            if "https://" not in url:
                full_url = self._get_host(auth).rstrip("/") + "/" + url.lstrip("/")
            logging.debug(f"{method} {full_url}")
            req = Request(full_url)
            if auth is not None:
                req.add_header('X-Session-Id', auth['sessionId'])
            req.method = method
            if data is not None:
                req.add_header('Content-Type', 'application/json')
                req.data = json.dumps(data).encode('utf-8')
            start_time = time.time()
            content = urlopen(req).read().decode()
            duration = time.time() - start_time

            logging.debug(f"Completed in {duration}s: {content}")
            if content.startswith("{") or content.startswith("["):
                return json.loads(content)
            return content
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            logging.error(f"Request error: {body}")
            raise

    def _get_host(self, auth=None):
        return os.environ.get(HOST_ENV_KEY) or auth['host']