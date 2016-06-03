#!/usr/bin/env python
import stem.control
import sys
import time
import fileinput
import signal

if len(sys.argv) < 2:
    print "Usage:", sys.argv[0], "auto|CIRC_ID|CIRC_FILE|-"
    sys.exit(1)

use_path = None
use_circ_id = None
prev_circ_id = None

if sys.argv[1] == "auto":
  pass
elif sys.argv[1].isdigit():
  use_circ_id = sys.argv[1]
else:
  if sys.argv[1] != "-":
      f = open(sys.argv[1])
      lines = f.readlines()
  else:
      lines = fileinput.input()

  use_path = []
  for line in lines:
      finger = line[:-1].split(" ")[0]
      use_path.append(finger)

con = stem.control.Controller.from_port()
con.authenticate()

def get_circ():
  global prev_circ_id
  circs = con.get_circuits()

  if use_circ_id != None:
    for c in circs:
      if c.id == use_circ_id: return c

  elif use_path != None:
    for c in circs:
      if prev_circ_id != None and c.id == prev_circ_id: return c
      if len([r for i, r in enumerate(c.path) if r[0] == use_path[i]]) == len(use_path):
          prev_circ_id = c.id
          return c
    prev_circ_id = con.new_circuit(use_path, await_build = False)
    print "Made new circuit:", prev_circ_id, use_path
    return con.get_circuit(prev_circ_id)

  else: # do auto circ selection:
    for c in circs:
      if len(c.path) > 1: return c

  raise Exception("Couldn't find any existing circuits. Use ./make_circuit.py to make a circuit first.")


def attach_stream(stream):
  if stream.status == 'NEW' and stream.purpose == stem.StreamPurpose.USER:
    circ = get_circ()
    print 'Attaching stream', stream.id, 'to circuit', circ.id
    #print stream
    #print "Using circuit", circ.id
    #print "\n".join(['  ' + r[0] + ' ' + r[1] for r in circ.path])
    try:
      con.attach_stream(stream.id, circ.id)
    except stem.InvalidRequest, e:
      print e

con.set_conf('MaxOnionsPending', '0')
con.set_conf('newcircuitperiod', '999999999')
con.set_conf('maxcircuitdirtiness', '999999999')
con.set_conf('__LeaveStreamsUnattached', '1')
con.add_event_listener(attach_stream, stem.control.EventType.STREAM)

def signal_handler(signal, frame):
  con.remove_event_listener(attach_stream)
  con.set_conf('__LeaveStreamsUnattached', '0')
  con.reset_conf('MaxOnionsPending')
  con.reset_conf('newcircuitperiod')
  con.reset_conf('maxcircuitdirtiness')
  print sys.argv[0], 'exiting'
  sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)
signal.pause()

