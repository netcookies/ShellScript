#!/bin/bash
#
# Example of how to parse short/long options with 'getopt'
#

OPTS=`getopt -o vhns: --long verbose,dry-run,help,stack-size: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"

VERBOSE=false
HELP=false
DRY_RUN=false
STACK_SIZE=0

usage(){
    echo "version "$VERSION" author by andrew :)"
    echo " "
    echo "Please give the group_name/project name without whitespace."
    echo "e.g. " $0 "lithium/boeing"
    echo " "
    echo "This script will do three things:"
    echo "   1. Create a folder contain base scss. "
    echo "   2. Create a repo use given project name."
    echo "   3. Copy necessary files to the new repo folder. e.g. 'run.sh'."
    exit 1
}

while true; do
  case "$1" in
    -v | --verbose ) VERBOSE=true; shift ;;
    -h | --help )    HELP=true; shift ;;
    -n | --dry-run ) DRY_RUN=true; shift ;;
    -s | --stack-size ) STACK_SIZE="$2"; shift; shift ;;
    -- )  PARAMETER="$2"; shift; break ;;
    * ) break ;;
  esac
done

[ -z "${PARAMETER}" ] && usage

echo VERBOSE=$VERBOSE
echo HELP=$HELP
echo DRY_RUN=$DRY_RUN
echo STACK_SIZE=$STACK_SIZE
