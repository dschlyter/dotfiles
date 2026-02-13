#!/usr/bin/env python3
import json
import urllib.request
from datetime import datetime, timedelta

# Calculate date range
end_date = datetime.now().date()
start_date = end_date - timedelta(days=395)

# Fetch data from Riksbank API
url = f"https://api.riksbank.se/swea/v1/Observations/SEKUSDPMI/{start_date}/{end_date}"
response = urllib.request.urlopen(url)
data = {entry['date']: entry['value'] for entry in json.loads(response.read())}

# Get rates for 1st of each month (or next available date)
print("Target Date\tRate\tActual Date")

today = datetime.now()
for i in range(12, -1, -1):
    # Calculate 1st of month going back i months
    year = today.year
    month = today.month - i
    while month < 1:
        month += 12
        year -= 1
    target = f"{year:04d}-{month:02d}-01"

    actual = min([d for d in data.keys() if d >= target], default=None)
    if actual:
        print(f"{target}\t{data[actual]}\t{actual}")
