## Jupyter stuff

See jupyter.md

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

## Logging

Default conf is kinda bad :(

Gotcha 1: Default conf only logs WARN

How to set it up better

    import logging

    logging.basicConfig(format='%(asctime)s %(name)s %(levelname)s %(message)s', level=logging.DEBUG)

Gotcha 2: Any call to the logging.info before basicConfig will set a (bad) default config. In python 3.8+ you can add force=True to fix this.

## Data Sciencing

### Date string wrangling

    datetime.strptime("2021-05-30", "%Y-%m-%d").date()
    datetime.strptime("20210530", "%Y%m%d").date()
    datetime.strptime("2021-05-30 12:30:45", "%Y-%m-%d %H:%M:%S")

Printing

    datetime.now().strftime("%Y-%m-%d")

Or generic parsing with a lib.

This requires `pip install python-dateutil` !!

    from dateutil.parser import parse

    parse("2021-05-30").date()
    parse("20210530").date()

Combined

    from datetime import timedelta
    from dateutil.parser import parse

    (parse(datestring) - timedelta(days=30)).strftime("%Y-%m-%d")

### Unix

Convert to and from local timezone

    dt = datetime.fromtimestamp(unix_timestamp)

    dt.timestamp()

Converting to and from utc is a bit harder. For some reason utcfromtimestamp does not set tzinfo ???

    from datetime import timezone
    utc_datetime = datetime.utcfromtimestamp(unix_timestamp).replace(tzinfo=timezone.utc).timestamp()

    utc_datetime.timestamp()

