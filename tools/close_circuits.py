#!/usr/bin/env python
import stem.control
import sys
con = stem.control.Controller.from_port()
con.authenticate()

# Disable automatic circuit creation:
# http://www.thesprawl.org/research/tor-control-protocol/
con.set_conf('__DisablePredictedCircuits', '1')
con.set_conf('MaxOnionsPending', '0')
con.set_conf('newcircuitperiod', '999999999')
con.set_conf('maxcircuitdirtiness', '999999999')

if len(sys.argv) > 1:
  con.close_circuit(sys.argv[1])
else:
  # Close all existing circuits:
  [con.close_circuit(c.id) for c in con.get_circuits()]
