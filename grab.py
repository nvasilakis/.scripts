#!/usr/bin/env python

import sys
import shutil
import os.path
import re
import urllib

DEST="/home/nikos/Music"

def get(fname):
  """get a specific filename"""

def loadPlaylist(fname):
  """get a playlist and return list of files"""

  if os.path.isfile(fname):
    with open(fname, 'r') as f:
      lns = f.readlines()
      for line in lns:
        line = line.replace("\n","");
        if ((line.startswith("File")) ): #and os.path.isfile(line)):
          line = re.sub(r"^File.*=file://", "", line)
          line = urllib.unquote(line)
          if (os.path.isfile(line)):
            print  line
            shutil.copy(line,DEST)

def grab(args):
  """main functionality"""
  if len(args) > 1 and len(args) < 3:
    loadPlaylist(args[1])

if  __name__ == "__main__":
# Give as arg the m3u playlist file
  grab(sys.argv)
