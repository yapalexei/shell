#!/usr/bin/env bash

MONGOD="$(which mongod)"
MONGODPID=`ps -ef | grep 'mongod' | grep -v grep | awk '{print $2}'`
LDIR="$(pwd)"

# Check if mongod is installed
if [ "$MONGOD" == "" ]; then
	echo "mongod is NOT installed"
    exit 0;
fi

# Check if mongod is already running, if so, don't start a new instance.
if [ "$MONGODPID" != "" ]; then
	echo "mongod is ALREADY RUNNING. PID: $MONGODPID."
	exit 0;
fi

# Start mongod via the config file
if [ -f "$LDIR/mongod.conf" ]; then
	echo "Loading config file"
	$MONGOD -f $LDIR/mongod.conf
	echo "STARTED mongod"
else
  	echo "You must have a mongod.conf file defining the db settings."
fi
