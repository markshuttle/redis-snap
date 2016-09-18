#!/bin/sh

# This looks in $SNAP_COMMON/conf/ for redis_*.conf and launches
# or stops those instances of Redis accordingly

# Portions (c) RethinkDB, this script was based on the RethinkDB init script
# by Mark Shuttleworth, Canonical, 2016.

set -e -u
umask 022

cmd="${1:-}"

redis=$SNAP/bin/redis-server ;
confdir=$SNAP_COMMON ;
rundir="$SNAP_COMMON/run" ;
datadir="$SNAP_COMMON/data" ;
logdir="$SNAP_COMMON/log" ;

# is_running <pid>
# test if a process exists
is_running () {
    ps -p "$1" > /dev/null
}

usage_fail () {
    echo "Usage: redis.launch [start|stop|restart|force-restart|status|init]"
    exit 1
}

case "$cmd" in
    start|stop|restart|force-restart|status|init)
        true
        ;;
    "")
        usage_fail
        ;;
    *)
        echo "$0: error: unknown action $1"
        usage_fail
        ;;
esac

# Make our top-level writable directories
if [ ! -e "$confdir" ]; then
  if mkdir -p "$confdir"; then
    echo "redis: Created $confdir"
  fi
fi
if [ ! -e "$datadir" ]; then
  if mkdir -p "$datadir"; then
    echo "redis: Created $datadir"
  fi
fi
if [ ! -e "$logdir" ]; then
  if mkdir -p "$logdir"; then
    echo "redis: Created $logdir"
  fi
fi
if [ ! -e "$rundir" ]; then
  if mkdir -p "$rundir"; then
    echo "redis: Created $rundir"
  fi
fi

if [ "$cmd" = "init" ] ; then
    # Install default configuration
    if [ -e "$confdir/redis.conf" ]; then
        echo "redis: error: redis.conf already installed"
    else
        cp -r --preserve=mode "$SNAP/doc/redis.conf" "$confdir/"
    fi
fi

# Check for active configurations .
if ! ls "$confdir"/*.conf >/dev/null 2>/dev/null ; then
    echo "redis: No instances defined in $confdir/<name>.conf"
    echo "redis: Create default instance with 'sudo redis.launch init'"
    echo "and then start with 'sudo redis.launch start'"
    echo "redis: See http://redis.io/topics/config/ for configuration details" ;
    exit
fi

for conffile in "$confdir"/*.conf ;
do

    instance_name=`basename "$conffile" .conf`

    # $@ will contain the options we pass to redis
    set --
    set -- "$conffile"

    # The redis snap places pid files in $SNAP_COMMON/run/ and
    # trumps any pid file location in the daemonized config.
    redispidfile="$SNAP_COMMON/run/$instance_name.pid"
    set -- "$@" --pidfile "$redispidfile"

    # The redis snap places the database files in $SNAP_COMMON/data/ and
    # overrides any setting in the config file.
    set -- "$@" --dir "$datadir"
    set -- "$@" --dbfilename "$instance_name".rbd
    set -- "$@" --appendfilename "$instance_name".aof

    if [ "$cmd" = "stop" -o "$cmd" = "restart" -o "$cmd" = "force-restart" ] ; then
        # stop redis

        if [ ! -e "$redispidfile" ] ; then
            echo "redis: $instance_name: not running (there is no pid file)"
        elif is_running "`cat "$redispidfile"`" ; then
            echo -n "redis: $instance_name: stopping (pid `cat "$redispidfile"`) ..."
            instance_pid=`cat "$redispidfile"`
            # TODO switch to using redis CLI and shutdown command
            kill -TERM "$instance_pid"
            while is_running "$instance_pid"; do
                echo -n "."
                sleep 2
            done
            echo " Stopped."
        else
            rm -f "$redispidfile"
        fi
    fi

    if [ "$cmd"="start" -o "$cmd"="restart" -o "$cmd"="force-restart" -o "$cmd"="init" ] ; then
        # start redis

        if [ -e "$redispidfile" ] && is_running "$(cat "$redispidfile")"; then
            echo "redis: $instance_name: already started!"
        else
            if [ -e "$redispidfile" ] ; then
                rm "$redispidfile"
            fi
            "$redis" "$@" --daemonize yes
        fi
    fi

    if [ "$cmd" = "status" ] ; then
        # show the redis status

        if [ -e "$redispidfile" ] ; then
            if ! is_running "$(cat "$redispidfile")"; then
                echo "redis: $instance_name: stop/crashed"
            else
                echo "redis: $instance_name: running, pid `cat "$redispidfile"`"
            fi
        else
            echo "redis: $instance_name: dead"
        fi
    fi

done
