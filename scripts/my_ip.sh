#!/bin/sh

##
## SCRIPT TO RETURN WAN IP WITH TOR CHECK WEBSITE
##


curl --silent https://check.torproject.org/ |grep "Your IP address appears to be"|sed -e 's/<[^>]*>//g'|sed 's/^[^:]*://'|cut -c 3-
