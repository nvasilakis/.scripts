#!/usr/bin/env python

import sys
import shutil
import os.path
import re
import urllib
from os.path import basename

# TODO: 
#   parse m3u and pls
#   now works on 154/168 test cases
#   percent does not fully clear line

class clr:
    HDR = '\033[95m'
    BLU = '\033[94m'
    GRN = '\033[92m'
    RNG = '\033[93m'
    RED = '\033[91m'
    EOF = '\033[0m'

DEST="/home/nikos/Music"

def percent(str, spaces):
  sys.stdout.write('%s\r' % spaces)
  sys.stdout.write(str)
  sys.stdout.flush()

def loadPlaylist(fname):
  """get a playlist and return list of files"""
  lineNo = 0
  cur = ""
  pre = ""

  if os.path.isfile(fname):
    with open(fname, 'r') as f:
      lns = f.readlines()
      for line in lns:
        line = line.replace("\n","");
        if ((line.startswith("File")) ): #and os.path.isfile(line)):
          line = re.sub(r"^File.*=file://", "", line)
          line = urllib.unquote(line)
          if (os.path.isfile(line)):
            #sys.stdout.write('.')
            cur = str(lineNo * 100/len(lns)) + "%\t(" + basename(line) + ")";
            percent(cur,pre)
            shutil.copy(line,DEST)
            pre = re.sub('.', '  ', cur)
            lineNo+=2
          else:
            print "============"
            print clr.RED + "Error in " + lineNo, ': '+ line + clr.EOF
            print "============"
            sys.exit
            
def grab(args):
  """main functionality"""
  if len(args) > 1 and len(args) < 3:
    loadPlaylist(args[1])

if  __name__ == "__main__":
# Give as arg the m3u playlist file
  grab(sys.argv)
