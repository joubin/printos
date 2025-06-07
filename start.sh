#!/bin/bash
cupsd &
echo "Waiting for cupsd to start..."
sleep 10`
cupsctl --remote-any
echo "Cupsd started"

brscan4 -d net -p 631 -b /dev/usb/lp0
echo "Brscan4 started"

sleep infinity
