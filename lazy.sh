#!/bin/bash

sudo -u root mkdir -p /opt/netdata/etc/netdata
sudo -u root cp -n netdata.conf /opt/netdata/etc/netdata/netdata.conf
sudo -u root chmod -R a+rw /opt/netdata
