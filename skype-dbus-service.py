#!/usr/bin/env python
#
#Copyright 2009, 2010, Ned Hoy
#
#Authors:
#    Ned Hoy <nedhoy@gmail.com>
#    Modified heavily by not_insane so it works like it should!
#
#   much code taken from Highly Ubuntu 9.04 Intergrated GMail Notifier https://launchpad.net/gm-notify
#   and the interwebs
#

# Most notifications are handled in skype-notify.py
# However, the dbus service handles these notifications:
# ChatIncomingInitial   :   skype-name, skype-message
# ChatIncoming          :   skype-name, skype-message
# ContactOnline         :   skype-name, no code for indicator yet

import dbus, dbus.glib, dbus.service
import gobject
import gtk

import indicate
import pynotify

import wnck

from time import time
import time

import os
import re
import sys
from threading import Thread

class Service (dbus.service.Object):
    '''D-Bus server for receiving notifications'''
    # see http://dbus.freedesktop.org/doc/dbus-python/doc/tutorial.html#data-types
    # def __init__(self):
    @dbus.service.method(dbus_interface='org.skypenotify.Interface',
                         in_signature='sss', out_signature='')
    def notify (self, event, skypename, skypemessage):
        
        print("{contact} says '{message}'".format(contact=skypename, message=skypemessage))
        remote_bus = dbus.SessionBus()
        out_connection = remote_bus.get_object('com.Skype.API', '/com/Skype')
        out_connection.Invoke('NAME mySkypeController')
        out_connection.Invoke('PROTOCOL 5')
        fullname = ' '.join(out_connection.Invoke('GET USER ' + skypename + ' FULLNAME').split()[3:])
        if 'ChatIncoming' in event:
            if not isConversationActive(fullname):
                #if not isIndicated(skypename):
                #    addIndicator(event, skypename)
                n = pynotify.Notification(skypename, skypemessage, "skype")
                n.set_hint_string('append', 'allowed')
                n.show()
                if not isIndicated(skypename):
                    mm_source = indicate.Indicator()
                    mm_source.set_property("subtype", "im")
                    mm_source.set_property("sender", skypename)
                    mm_source.set_property("draw-attention", "true")
                    mm_source.set_property_time("time", time.time())
                    mm_source.connect("user-display", display_cb)
                    mm_source.show()
                    indicators.append(mm_source)
                    contactsIndicated.append(skypename)
                    contactNames.append(fullname)
        elif event == 'ContactOnline':
            if not findChatWindow(skypename).is_active():
                showNotification(skypename, "is online", "skype",  False)


indicators = []
contactsIndicated = []
contactNames = []

#def timeout_cb(indicator):
#    '''timeout example'''
#    print "Modifying properties"
#    global lastpath
#    indicator.set_property_time("time", time())
#    if lastpath == PATHA:
#        lastpath = PATHB
#    else:
#        lastpath = PATHA
#
#    pixbuf = gtk.gdk.pixbuf_new_from_file(lastpath)
#
#    indicator.set_property_icon("icon", pixbuf)
#
#    return True

def isIndicated(contact):
    if contact in contactsIndicated: return True

def isConversationActive(contact):
    '''Check if conversation with contact is active (has focus)'''
    for window in scr.get_windows():
        if isConversationWithContact(window, contact) and window.is_active():
            return True
    return False

def isConversationWithContact(window, contact):
    '''Checks if given window is a conversation with a particular contact'''
    #FOR LOLS: '''Checks if a window is a skype window instance of a chat with a contact'''
    return 'Skype' in window.get_application().get_name() and \
        'Chat' in window.get_name() and contact in window.get_name()

def findChatWindow(contact):
    '''Finds the chat window waiting for attention since the notification'''
    for window in scr.get_windows():
        #print ("-------")
        #if window.get_name():
        #    print(window.get_name())
        #    print(window.get_application().get_name())
        if isConversationWithContact(window, contact):
            return window

def display_cb(indicator, tempfixme):
    ''' The indicator has been clicked: Focus skype chat window '''
    #FIXME TypeError: display_cb() takes exactly 1 argument (2 given)
    # probably a change in libindicate
    #TODO match with the contact's skype username instead of alias (incase you rename them or something)
    contact = indicator.get_property("sender")

    remote_bus = dbus.SessionBus()
    out_connection = remote_bus.get_object('com.Skype.API', '/com/Skype')
    out_connection.Invoke('NAME mySkypeController')
    out_connection.Invoke('PROTOCOL 5')
    chatsRecent = out_connection.Invoke('SEARCH MISSEDCHATS')[6:].split(", ")
    chatsRecentMembers = []

    for x in chatsRecent:
        i = len(chatsRecentMembers)
        chatsRecentMembers.append([])
        memobjs = out_connection.Invoke('GET CHAT ' + x + ' MEMBEROBJECTS')
        chatsRecentMembers[i] = ' '.join(memobjs.split()[3:]).split(", ")
        for j in range(0, len(chatsRecentMembers[i])):
            print out_connection.Invoke('GET CHATMEMBER ' + chatsRecentMembers[i][j] + ' IDENTITY').split()
            chatsRecentMembers[i][j] = out_connection.Invoke('GET CHATMEMBER ' + chatsRecentMembers[i][j] + ' IDENTITY').split()[3]
        if x.find(contact) is not -1 and memobjs.strip() == '':
            out_connection.Invoke('OPEN CHAT ' + x)
            break
    print chatsRecent
    print chatsRecentMembers
    print contact

    for x in range(0, len(chatsRecentMembers)):
        for y in chatsRecentMembers[x]:
            if y.find(contact) is not -1:
                out_connection.Invoke('OPEN CHAT ' + chatsRecent[x])

    try:
        window = findChatWindow(contact)
        window.activate(int(time.time()))
    except:
        print ""

    for i in range(0, len(contactsIndicated)):
        try:
            if contactsIndicated[i] == contact:
                indicators[i].hide()
                indicators.remove(indicators[i])
                contactsIndicated.remove(contactsIndicated[i])
                contactNames.remove(contactNames[i])
                break
        except:
            print ""

def server_display_cb(server, tempfixme):
    '''The server indicator has been clicked: focus Skype main window'''
    #FIXME TypeError: server_display_cb() takes exactly 1 argument (2 given)
    # probably a change in libindicate
    print server
    #Check each window to see if it is the Skype contact list and give it focus
    map(focus_if_contact_list, scr.get_windows())
    try:
        # Try and set skype window to normal
        remote_bus = dbus.SessionBus()
        out_connection = remote_bus.get_object('com.Skype.API', '/com/Skype')
        out_connection.Invoke('NAME mySkypeController')
        out_connection.Invoke('PROTOCOL 5')
        out_connection.Invoke('SET WINDOWSTATE NORMAL')
        out_connection.Invoke('FOCUS')
    except:
        os.system("skype&")

def on_state_change(window, changed_mask, new_state):
    '''handle the chat becoming focused or closing by removing the indicator'''
    #FIXME remove only the relevant indicator.

    print("***state-changed***")
    print("window still needs attention? ", window.needs_attention ())

    if not window.needs_attention ():
        removeIndicator()

def focus_if_contact_list(window):
    '''Check if particular window is the Skype contact list and give focus'''
    #print ("--------")
    #if window.get_name():
    #    print(window.get_name())
    #    app = window.get_application()
    #    print(app.get_name())

    #FIXME there are some windows that are neither the contact list nor chats,
    #such as voice calls, that we also need to filter out. Would be best to use
    #the skype login name because it appears on the contact list
    if ("Skype" in window.get_application().get_name()
         and "Chat" not in window.get_name()):
        if not window.is_active():
            window.activate(int(time.time()))

def showNotification(summary, message, icon, append):
    '''Display a notification with a title summary, message body and icon'''
    global n
    n = pynotify.Notification(summary, message, icon)
    if append:
        print "append"
        n.set_hint_string('append', 'allowed')
    n.show()

def addIndicator(event, contact):
    '''adds a indicator to the indicator-applet which results in the "unread counter"
    increased by one. The indicator is stored in a class-list to keep the reference.
    If you delete this the indicator will be removed from the applet, too'''
    pixbuf = gtk.gdk.pixbuf_new_from_file("/usr/share/icons/skype.png")

    #setup indicator
    indicator = indicate.Indicator() # changed as suggested by mirko_3 http://ubuntuforums.org/showpost.php?p=8094319&postcount=42
    indicator.set_property("subtype", "im")
    indicator.set_property("sender", contact)
    #indicator.set_property_time("time", time())
    indicator.set_property_icon("icon", pixbuf)

    indicator.connect("user-display", display_cb)

    indicator.show()

    indicators.append(indicator) #not sure about this - if it isn't done: no indicator O.o
    contactsIndicated.append(contact)

    window = findChatWindow(contact)
    window.connect("state-changed", on_state_change)

def removeIndicator():
    '''remove an indicator - atm it removes all indicators FIXME'''
    global indicators
    global contactsIndicated
    global contactNames
    indicators = []
    contactsIndicated = []
    contactNames = []

def dummy():
    ''' Create one indicator and instantly delete it to make the server show up in the applet (HACK?)'''
    indicator = indicate.Indicator()
    indicator.set_property("subtype", "im")
    indicator.set_property("sender", "dummy")
    indicator.show()

class cleanupthread(Thread):
    def run(self):
        while 1:
            for i in range(0, len(contactNames)):
                try:
                    if findChatWindow(contactNames[i]).is_active():
                        indicators[i].hide()
                        indicators.remove(indicators[i])
                        contactsIndicated.remove(contactsIndicated[i])
                        contactNames.remove(contactNames[i])
                        break
                except:
                    print ""
            time.sleep(0.1)
cleanthread = cleanupthread()
cleanthread.daemon = True
cleanthread.start()

if __name__ == "__main__":
    # Initiate pynotify
    if not pynotify.init("Skype Hack"):
        sys.exit(-1)
    # Setup indicate server
    server = indicate.indicate_server_ref_default()
    server.set_type("message.im")
    server.set_desktop_file("/usr/share/skype-notify-improved/skype.desktop")
    server.connect("server-display", server_display_cb)

    server.show()

    # Get list of windows with wink
    scr = wnck.screen_get_default()
    server_display_cb("startup", 1)
    while gtk.events_pending():
	    gtk.main_iteration()

    # Export notify method over dbus
    bus = dbus.SessionBus()
    name = dbus.service.BusName('org.skypenotify.Service', bus=bus)
    obj = Service(name, '/')
    loop = gobject.MainLoop()
    print('Listening')
    gobject.threads_init()
    context = loop.get_context()
    
    while 1:
        time.sleep(0)
        context.iteration(True)
