#!/bin/bash

sudo -u root mkdir -p /opt/netdata/etc/netdata
sudo -u root cp -n netdata.conf /opt/netdata/etc/netdata/netdata.conf
sudo -u root touch /opt/netdata/etc/netdata/.opt-out-from-anonymous-statistics
sudo -u root chmod -R a+rw /opt/netdata
sudo hostname -I | awk '{print "destination="$1":2003"}' >.env
sudo hostname -I | awk '{print "registry=http://"$1":1999"}' >>.env
