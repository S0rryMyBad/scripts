#!/bin/sh
# betmen
# simple backup script

EXT=${EXT:-NOOSCBAK} # extension used for backup
LIM=${LIM:-9}   # maximum number of version to keep
PAD=${PAD:-0}   # number to start with

usage() {
    cat <<EOF
usage: `basename $0` [-hrv] <file>
        -h          : print this help
        -r <num>    : perform <num> rotations if \$LIM is reached
EOF
}

# report action performed in verbose mode
log() {
    # do not log anything if not in $VERBOSE mode
    test -z $VERBOSE && return

    # add a timestamp to the message 
    echo "[$(date +%Y-%m-%d\ %H:%M)] - $*"
}

rotate() {
    # do not rotate if the rotate flags wasn't provided
    test -z $ROTATE && return

    # delete the oldest backup
    rm ${FILE}.${PAD}.${EXT}

    # move every file down one place
    for N1 in `seq $PAD $LIM`; do
        N2=$(( N1 + ROTATE ))

        # don't go any further
        test -f ${FILE}.${N2}.${EXT} || return

        # move file down $ROTATE place
        log "${FILE}.${N2}.${EXT} -> ${FILE}.${N1}.${EXT}"
        mv ${FILE}.${N2}.${EXT} ${FILE}.${N1}.${EXT}
    done
}

# actually archive files
archive() {
    # test the presence of each version, and create one that doesn't exists
    for N in `seq $PAD $LIM`; do
        if test ! -f ${FILE}.${N}.${EXT}; then

            # cope the file under it's new name
            log "Created: ${FILE}.${N}.${EXT}"
            cp ${FILE} ${FILE}.${N}.${EXT}

            exit 0
        fi
    done
}

while getopts "hrv" opt; do
    case $opt in
        h) usage; exit 0 ;;
        r) ROTATE=1 ;;
        v) VERBOSE=1 ;;
        *) usage; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

test $# -lt 1 && usage && exit 1

FILE=$1

# in case limit is reach, remove the oldest backup
test -f ${FILE}.${LIM}.${EXT} && rotate

# if rotation wasn't performed, we'll not archive anything
test -f ${FILE}.${LIM}.${EXT} || archive

echo "Limit of $LIM .$EXT files reached run with -r to force rotation"
exit 1

