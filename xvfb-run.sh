#!/bin/sh

# $Id: xvfb-run 2027 2004-11-16 14:54:16Z branden $

# This script starts an instance of Xvfb, the "fake" X server, runs a command
# with that server available, and kills the X server when done.  The return
# value of the command becomes the return value of this script, except in cases
# where this script encounters an error.
#
# If anyone is using this to build a Debian package, make sure the package
# Build-Depends on xvfb, xbase-clients, and xfonts-base.

set -e

PROGNAME=xvfb-run
SERVERNUM=99
AUTHFILE=
ERRORFILE=/dev/null
STARTWAIT=3
SCREEN_WIDTH=${SCREEN_WIDTH:-'1280'}
SCREEN_HEIGHT=${SCREEN_HEIGHT:-'800'}
XVFBARGS="-screen 0, ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24"
LISTENTCP="-nolisten tcp"
XAUTHPROTO=.

echo "Using screen size ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
# Query the terminal to establish a default number of columns to use for
# displaying messages to the user.  This is used only as a fallback in the event
# the COLUMNS variable is not set.  ($COLUMNS can react to SIGWINCH while the
# script is running, and this cannot, only being calculated once.)
DEFCOLUMNS=$(stty size 2>/dev/null | awk '{print $2}') || true
if ! expr "$DEFCOLUMNS" : "[[:digit:]]\+$" >/dev/null 2>&1; then
    DEFCOLUMNS=80
fi

# Display a message, wrapping lines at the terminal width.
message () {
    echo "$PROGNAME: $*" | fmt -t -w ${COLUMNS:-$DEFCOLUMNS}
}

# Display an error message.
error () {
    message "error: $*" >&2
}

# Display a usage message.
usage () {
    if [ -n "$*" ]; then
        message "usage error: $*"
    fi
    cat <<EOF
Usage: $PROGNAME [OPTION ...] COMMAND
Run COMMAND (usually an X client) in a virtual X server environment.
Options:
-a        --auto-servernum          try to get a free server number, starting at
                                    --server-num
-e FILE   --error-file=FILE         file used to store xauth errors and Xvfb
                                    output (default: $ERRORFILE)
-f FILE   --auth-file=FILE          file used to store auth cookie
                                    (default: ./.Xauthority)
-h        --help                    display this usage message and exit
-n NUM    --server-num=NUM          server number to use (default: $SERVERNUM)
-l        --listen-tcp              enable TCP port listening in the X server
-p PROTO  --xauth-protocol=PROTO    X authority protocol name to use
                                    (default: xauth command's default)
-s ARGS   --server-args=ARGS        arguments (other than server number and
                                    "-nolisten tcp") to pass to the Xvfb server
                                    (default: "$XVFBARGS")
-w DELAY  --wait=DELAY              delay in seconds to wait for Xvfb to start
                                    before running COMMAND (default: $STARTWAIT)
EOF
}

# Find a free server number by looking at .X*-lock files in /tmp.
find_free_servernum() {
    # Sadly, the "local" keyword is not POSIX.  Leave the next line commented in
    # the hope Debian Policy eventually changes to allow it in /bin/sh scripts
    # anyway.
    #local i

    i=$SERVERNUM
    while [ -f /tmp/.X$i-lock ]; do
        i=$(($i 1))
    done
    echo $i
}

# Clean up files
clean_up() {
    if [ -e "$AUTHFILE" ]; then
        XAUTHORITY=$AUTHFILE xauth remove ":$SERVERNUM" >>"$ERRORFILE" 2>&1
    fi
    if [ -n "$XVFB_RUN_TMPDIR" ]; then
        if ! rm -r "$XVFB_RUN_TMPDIR"; then
            error "problem while cleaning up temporary directory"
            exit 5
        fi
    fi
}

# Parse the command line.
ARGS=$(getopt --optionsae:f:hn:lp:s:w: \
       --long auto-servernum,error-file:,auth-file:,help,server-num:,listen-tcp,xauth-protocol:,server-args:,wait: \
       --name "$PROGNAME" -- "$@")
GETOPT_STATUS=$?

if [ $GETOPT_STATUS -ne 0 ]; then
    error "internal error; getopt exited with status $GETOPT_STATUS"
    exit 6
fi

eval set -- "$ARGS"

while :; do
    case "$1" in
        -a|--auto-servernum) SERVERNUM=$(find_free_servernum); AUTONUM="yes" ;;
        -e|--error-file) ERRORFILE="$2"; shift ;;
        -f|--auth-file) AUTHFILE="$2"; shift ;;
        -h|--help) SHOWHELP="yes" ;;
        -n|--server-num) SERVERNUM="$2"; shift ;;
        -l|--listen-tcp) LISTENTCP="" ;;
        -p|--xauth-protocol) XAUTHPROTO="$2"; shift ;;
        -s|--server-args) XVFBARGS="$2"; shift ;;
        -w|--wait) STARTWAIT="$2"; shift ;;
        --) shift; break ;;
        *) error "internal error; getopt permitted \"$1\" unexpectedly"
           exit 6
           ;;
    esac
    shift
done

if [ "$SHOWHELP" ]; then
    usage
    exit 0
fi

if [ -z "$*" ]; then
    usage "need a command to run" >&2
    exit 2
fi

if ! which xauth >/dev/null; then
    error "xauth command not found"
    exit 3
fi

# tidy up after ourselves
trap clean_up EXIT

# If the user did not specify an X authorization file to use, set up a temporary
# directory to house one.
if [ -z "$AUTHFILE" ]; then
     XVFB_RUN_TMPDIR="$(mktemp -d -t $PROGNAME.XXXXXX)"
    # Create empty file to avoid xauth warning
    AUTHFILE=$(touch "$XVFB_RUN_TMPDIR/Xauthority")
fi

# Start Xvfb.
MCOOKIE=$(mcookie)
tries=10
while [ $tries -gt 0 ]; do
    tries=$(( $tries - 1 ))
    XAUTHORITY=$AUTHFILE xauth source - << EOF >>"$ERRORFILE" 2>&1
add :$SERVERNUM $XAUTHPROTO $MCOOKIE
EOF
    XAUTHORITY=$AUTHFILE Xvfb ":$SERVERNUM" $XVFBARGS $LISTENTCP >>"$ERRORFILE" 2>&1 &
    XVFBPID=$!

    sleep "$STARTWAIT"
    if kill -0 $XVFBPID 2>/dev/null; then
        break
    elif [ -n "$AUTONUM" ]; then
        # The display is in use so try another one (if '-a' was specified).
        SERVERNUM=$((SERVERNUM 1))
        SERVERNUM=$(find_free_servernum)
        continue
    fi
    error "Xvfb failed to start" >&2
    exit 1
done

# Start the command and save its exit status.
sete
DISPLAY=:$SERVERNUM XAUTHORITY=$AUTHFILE "$@" 2>&1
RETVAL=$?
set -e

# Kill Xvfb now that the command has exited.
kill $XVFBPID

# Return the executed command's exit status.
exit $RETVAL

# vim:set ai et sts=4 sw=4 tw=80:
