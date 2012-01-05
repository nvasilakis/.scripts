#!/usr/bin/env python
#    Python script to make Skype use notify-osd

# Copyright (c) 2009, 2010, Lightbreeze
# heavily modified by nvasilakis

# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# to use this script: Open Skype -> Open the menu and press 'Options' or press Ctrl-O
# -> hit the 'Advanced' button and check 'Execute the following script on _any_ event'
# -> paste: python /path/to/skype-notify.py -e"%type" -n"%sname" -f"%fname" -p"%fpath" -m"%smessage" -s%fsize -u%sskype
# -> disable or enable the notifications you want to receive.

import sys
from optparse import OptionParser

import pynotify
import dbus, dbus.glib

class NotifyForSkype:
    def __init__(self):
        # Initiate pynotify
        if not pynotify.init("Skype Notifier"):
            sys.exit(-1)

        # Add argument parser options
        parser = OptionParser()
        parser.add_option("-e", "--event", dest="type", help="type of SKYPE_EVENT")
        parser.add_option("-n", "--sname", dest="sname", help="display-name of contact")
        parser.add_option("-u", "--skype", dest="sskype", help="skype-username of contact")
        parser.add_option("-m", "--smessage", dest="smessage", help="message body", metavar="FILE")
        parser.add_option("-p", "--path", dest="fpath", help="path to file")
        parser.add_option("-s", "--size", dest="fsize", help="incoming file size")
        parser.add_option("-f", "--filename", dest="fname", help="file name", metavar="FILE")
        (self.o, args) = parser.parse_args()

        #print(args)
        #print(sys.argv)
        #print(self.o.type)

        self.handleNotification()

    def handleNotification(self):
        notification = self.o.type
        #FIXME this should run method based on the string
        # and not have to use all these else-ifs

        if notification == 'SkypeLogin': self._SkypeLogin()
        elif notification == 'SkypeLogout': self._SkypeLogout()
        elif notification == 'SkypeLoginFailed': self._SkypeLoginFailed()
        #elif notification == 'CallConnecting': self._CallConnecting()
        #elif notification == 'CallRingingIn': self._CallRingingIn()
        #elif notification == 'CallRingingOut': self._CallRingingOut()
        elif notification == 'CallAnswered': self._CallAnswered()
        elif notification == 'VoicemailReceived': self._VoicemailRecieved()
        elif notification == 'VoicemailSent': self._VoicemailSent()
        elif notification == 'ContactOnline': self._ContactOnline()
        #elif notification == 'ContactOffline': self._ContactOffline()
        elif notification== 'ContactDeleted': self._ContactDeleted()
        elif notification == 'ChatIncomingInitial': self._ChatIncomingInitial()
        elif notification == 'ChatIncoming': self._ChatIncoming()
        #elif notification == 'ChatOutgoing': self._ChatOutgoing()
        elif notification == 'ChatJoined': self._ChatJoined()
        elif notification == 'ChatParted': self._ChatParted()
        elif notification == 'TransferComplete': self._TransferComplete()
        elif notification == 'TransferFailed': self._TransferFailed()
        elif notification == 'Birthday': self._Birthday()
        # event handling for SMS notifications
        elif notification == 'SMSSent': self._SMSSent()
        elif notification == 'SMSFailed': self._SMSFailed()

    def _SkypeLogin(self):
        self.showNotification("Skype","You have logged into Skype with {contact}".format(contact=self.o.sname),"skype")

    def _SkypeLogout(self):
        pass

    def _SkypeLoginFailed(self):
        self.showNotification("Skype login failed",None,"user-offline")

    def _CallConnecting(self):
        self.showNotification("Dialing... {contact}".format(contact=self.o.sname),None,"skype")
        #some of these should be merged and update to the same bubble: Call Connecting -> CallRingingOut -> Call Answered

    def _CallRingingOut(self):
        self.showNotification("Calling {contact}".format(contact=self.o.sname),"skype")

    def _CallAnswered(self):
        self.showNotification("Call Answered",None,"skype")

    def _CallRingingIn(self):
        self.showNotification(self.o.sname,"is calling you","skype")

    def _VoicemailRecieved(self):
        self.showNotification(self.o.sname,"Voicemail Received","skype")

    def _VoicemailSent(self):
        self.showNotification("Voicemail Sent",None,"skype")

    def _ContactOnline(self):
        self.showNotification(self.o.sname,"is online","skype")
        #self.addIndicator(self.o.type, self.o.sname, self.o.smessage)

    def _ContactOffline(self):
        self.showNotification(self.o.sname,"is offline","skype")

    def _ContactDeleted(self):
        self.showNotification("Contact Deleted", "{contact} has been deleted from your contact list".format(contact=self.o.sname),"skype")

    def _ChatIncomingInitial(self):
        if not (self.addIndicator(self.o.type, self.o.sname, self.o.smessage)):
            #FIXME this notification should be shown if the dbus-service is not running
            self.showNotification(self.o.sname, self.o.smessage, "notification-message-IM")

    def _ChatIncoming(self):
        self._ChatIncomingInitial()

    def _ChatOutgoing(self):
        self.showNotification(self.o.sname,self.o.smessage,"notification-message-IM")

    def _ChatJoined(self):
        self.showNotification("{contact} joined chat".format(contact=self.o.sname),self.o.smessage,"emblem-people")

    def _ChatParted(self):
        self.showNotification("{contact} left chat".format(contact=self.o.sname),self.o.smessage,"emblem-people")

    def _TransferComplete(self):
        self.showNotification("Transfer Complete","{path}/{filename}".format(filename=self.o.fname,path=self.o.fpath),"gtk-save")
        #TODO show dialog [ok] [open file] [reveal in folder]
        # or preview in gloobus :D if suitable format

    def _TransferFailed(self):
        self.showNotification("Transfer Failed","{filename}".format(filename=self.o.fname),"error")

    def _Birthday(self):
        self.showNotification(self.o.sname,"has a birthday Tomorrow","appointment-soon")

    def _SMSSent(self):
        self.showNotification(self.o.sname,"SMS sent","skype")

    def _SMSFailed(self):
        self.showNotification(self.o.sname,"SMS failed","error")

    def showNotification(self, summary, message, ikon):
        '''takes a title summary a message, and an icon to display the notification. Returns the created notification object'''
        if summary == None: summary = " "
        n = pynotify.Notification(summary, message, ikon)
        n.set_hint_string('append', 'allowed')
        n.show()
        return n

    def addIndicator(self, event, sname, smessage):
        '''send event type, contact's display name, and message text over D-Bus'''
        bus = dbus.SessionBus()
        try:
           #self.showNotification("1","2","skype")
           server = dbus.Interface(bus.get_object('org.skypenotify.Service', '/'), 'org.skypenotify.Interface')
           server.notify(event, sname, smessage)
        except dbus.exceptions.DBusException:
            print >> sys.stderr, "You should be running skype-dbus-service.py for messaging menu support and to append new text in notification bubbles"
            return False
        print("connected to D-Bus org.skypenotify.Service server")
        return True

cm = NotifyForSkype()
sys.exit(-1) #hack TODO make sure this program quits properly
