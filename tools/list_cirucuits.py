#!/usr/bin/env python
import stem.control
con = stem.control.Controller.from_port()
con.authenticate()

for c in con.get_circuits():
  print 'Circuit', c.id
  print "\n".join(['  ' + r[0] + ' ' + r[1] for r in c.path])
  print ''
