#!/usr/bin/env bash

MONGOD="$(which mongod)"
MONGODPID=`ps -ef | grep 'mongod' | grep -v grep | awk '{print $2}'`

#Check if mongod is running, if so, stop it.
if [ "$MONGODPID" != "" ]; then
	echo "STOPPING mongod @ pid: $MONGODPID."
 	kill -15 $MONGODPID
	exit 0;
else    
	echo "mongod is NOT running"
fi
