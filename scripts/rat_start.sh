#!/bin/bash

##
## SCRIPT TO ENABLE ADBD REMOTELY AND RUN SCRCPY
##

HOST=192.168.42.118

echo ... starting adbd on $HOST
ssh root@$HOST start adbd

echo ... connecting adb $HOST:5555
adb connect $HOST:5555

echo ... executing read-only scrcpy
scrcpy -n
