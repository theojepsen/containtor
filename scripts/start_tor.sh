#!/bin/bash
if [ -f /etc/torrc ]
then
    tor -f /etc/torrc &
else
    echo Will not start Tor: file does not exist: /etc/torrc
fi

exit 0
