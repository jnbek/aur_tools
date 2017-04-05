#!/usr/bin/env python
# -*- coding: utf-8 -*-

import gamin
import sys
import time

def callback(path, event):
    print "Got callback: %s, %s" % (path, event)

def main():
    mon = gamin.WatchMonitor()
    mon.watch_directory("/home/jnbek/tmp", callback)
    time.sleep(1)
#    ret = mon.event_pending()
#    if ret > 0:
#        ret = mon.handle_one_event()
#        ret = mon.handle_events()
    while 1:
        mon.handle_events()
        time.sleep(1)

#    mon.stop_watch(".")
#    del mon

# main

if __name__ == '__main__':
    main()

