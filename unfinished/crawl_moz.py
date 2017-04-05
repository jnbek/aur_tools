#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys
import urllib2
from BeautifulSoup import BeautifulSoup

def main():

    url = "https://hg.mozilla.org/releases/mozilla-beta";

    page = urllib2.urlopen(url)
    soup = BeautifulSoup(page)

    version = soup.find('span', {'class': 'logtags'}).find('span', {'class': 'tagtag'})
    print version # Put a mail command here

# main

if __name__ == '__main__':
    main()
