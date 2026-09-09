#!/usr/bin/env python3
import gzip
import json
import sys
import urllib.request
from datetime import datetime

# Fetch monthly CPI (KPI) index from SCB (Statistics Sweden), base 2020=100
# Usage: scb_kpi.py [start-month]    e.g. scb_kpi.py 2020-10
# API docs: https://www.scb.se/vara-tjanster/oppna-data/api-for-statistikdatabasen/
# v1 API, v2 migration planned: https://www.scb.se/vara-tjanster/oppna-data/pxwebapi/pxwebapi-v2/
BASE = "https://api.scb.se/OV0104/v1/doris/sv/ssd/START/PR/PR0101/PR0101A"


def fetch(url, data=None):
    headers = {"User-Agent": "scb_kpi.py"}
    if data:
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers)
    resp = urllib.request.urlopen(req)
    raw = resp.read()
    if resp.headers.get("Content-Encoding") == "gzip":
        raw = gzip.decompress(raw)
    return json.loads(raw)


def query_scb(table, content_code, top):
    query = {
        "query": [
            {"code": "ContentsCode", "selection": {"filter": "item", "values": [content_code]}},
            {"code": "Tid", "selection": {"filter": "top", "values": [str(top)]}},
        ],
        "response": {"format": "json"},
    }
    result = fetch(f"{BASE}/{table}", json.dumps(query).encode())
    return {e["key"][0]: e["values"][0] for e in result["data"] if e["values"][0] != ".."}


now = datetime.now()
if len(sys.argv) > 1:
    start_year, start_month = map(int, sys.argv[1].split("-"))
else:
    start_year, start_month = now.year - 3, now.month

months_needed = (now.year - start_year) * 12 + (now.month - start_month) + 1

# Historical data (1980=100 rebased to 2020=100) + current year from new table
data = query_scb("KPI2020M1980", "000007T9", months_needed)
data.update(query_scb("KPI2020M", "00000808", min(months_needed, 12)))

start_key = f"{start_year:04d}M{start_month:02d}"
print("Month\t\tKPI (2020=100)")
for period in sorted(data):
    if period >= start_key:
        year, month = period.split("M")
        print(f"{year}-{month}\t\t{data[period]}")
