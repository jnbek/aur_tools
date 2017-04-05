# AsyncNotifier example from tutorial
#
# See: http://github.com/seb-m/pyinotify/wiki/Tutorial
#
import asyncore
import pyinotify

wm = pyinotify.WatchManager()  # Watch Manager
#mask = pyinotify.IN_DELETE | pyinotify.IN_CREATE | pyinotify.IN_MODIFY # watched events
mask = pyinotify.ALL_EVENTS

class EventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        print "Creating:", event.pathname

    def process_IN_DELETE(self, event):
        print "Removing:", event.pathname

	def process_IN_MODIFY(self, event):
		print "Modified:", event.pathname

notifier = pyinotify.AsyncNotifier(wm, EventHandler())
wdd = wm.add_watch('/home/jnbek/tmp', mask, rec=True)

asyncore.loop()
