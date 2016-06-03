#!/usr/bin/env python
import stem.control
import sys
import fileinput
con = stem.control.Controller.from_port()
con.authenticate()

# Disable automatic circuit creation:
# http://www.thesprawl.org/research/tor-control-protocol/
con.set_conf('__DisablePredictedCircuits', '1')
con.set_conf('MaxOnionsPending', '0')
con.set_conf('newcircuitperiod', '999999999')
con.set_conf('maxcircuitdirtiness', '999999999')

if len(sys.argv) < 2:
    print "Usage:", sys.argv[0], "CIRCUIT_FILE|-"
    sys.exit(1)

path = []
if sys.argv[1] != "-":
    f = open(sys.argv[1])
    lines = f.readlines()
else:
    lines = fileinput.input()
for line in lines:
    finger = line[:-1].split(" ")[0]
    path.append(finger)

circuit_id = con.new_circuit(path, await_build = True)
print circuit_id
