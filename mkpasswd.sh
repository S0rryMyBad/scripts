#!/bin/sh
# betmen
# simple password generator

LEN=${1:-16}

</dev/urandom tr -cd ${CHAR:-'a-zA-Z0-9'} | fold -w ${LEN} | sed 1q