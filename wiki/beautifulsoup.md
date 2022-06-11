Tool for scraping and parsing stuff.

Installing:    

    pip install beautifulsoup4

Using:

    import urllib.request as url
    from bs4 import BeautifulSoup as Soup

    html = url.urlopen(some_url).read()
    soup = Soup(html)
    elements = soup.select('.some_class')
    for e in element:
        print(e.select_one('.sub_class').text.strip())
        print(e.get('href'))