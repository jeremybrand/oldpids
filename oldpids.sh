#!/bin/bash --
PATH=/bin:/usr/bin

set +e

# Prints a list of your own PIDs based on process name that are
# older than a required number of seconds.
#
# Written by: Jeremy Brand <jeremy@nirvani.net> 
#             http://www.nirvani.net/software/oldpids
# Requires: GNU ps,grep,sed,date
#
# Version: 1.0
# 
# Bugs or features?
# The list of PIDs is for the user $USER, which is
# typically set in the environment.
#
# Example:
#
#  Find and print out all process ids of 'blastall' that are 300 seconds or older.
#  $ oldpids blastall 300
#
#
# License:
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License, Version 2 as 
#   published by the Free Software Foundation.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#   
# ChangeLog
# 0.8 Jeremy Brand 2003/11/14
#     - public release.
# 1.0 Jeremy Brand 2011/10/31
#     - improved compatibility, reliability and error checking.
#

die() 
{

	message=$1
	echo $message 1>&2
	exit 1
}


requires() 
{
	# Requires: GNU ps,grep,sed,date
	grep --version 2>&1 |grep -q "GNU" || die "grep is not GNU"
	ps --version 2>&1 | grep -q "procps" || die "ps is not procps"
	sed --version 2>&1 | grep -q "GNU" || die "sed is not GNU"
	date --version 2>&1 | grep -q "GNU" || die "date is not GNU"
}

exit_error()
{
  echo "Usage: $0 PROCESS_NAME OLDER_THAN" 1>&2
  echo "" 1>&2
  echo "Prints a list of pids, space separated, that are " 1>&2
  echo "  older than OLDER_THAN integer seconds." 1>&2
  echo "" 1>&2
  echo "Returns: 1 on missing args." 1>&2
  echo "  0 on success, even if success has no pids in the list." 1>&2
  echo "" 1>&2
  echo "Example: $0 blastall 259200" 1>&2
  echo "" 1>&2
  exit 1;
}

is_num() 
{
  echo $1 | egrep -q '^[0-9]+$'
  if [ "$?" = "0" ]; then
    true
  else
    echo "-----------------------------------" 1>&2
    echo "ERROR: Argument 2 is not an integer" 1>&2
    echo "-----------------------------------" 1>&2
    echo 1>&2
    exit_error
  fi
}

is_num $2

if [ "$2" -lt 1 ]; then
  echo "----------------------------------------" 1>&2
  echo "ERROR: Argument 2 must be greater than 0" 1>&2
  echo "----------------------------------------" 1>&2
  echo 1>&2
  exit_error
fi

CMDNAME=$1
CMDMAXAGE=$2

# Init return value
RETURN_PID_LIST=""

CMD=sleep
PIDS=`ps --no-headers -opid,user -C $CMDNAME | grep -e "$USER$" | grep -v grep | sed -re "s/^ +//g" | sed -re "s/ +//g" | sed -re "s/$USER$//g" `

STARTS=`ps --no-headers -ostart_time $PIDS | sed -re "s/^ +//g" | sed -re "s/ +//g" `

for i in $PIDS
do

THIS_PID=$i

# Get start
THIS_START=`ps --no-headers -ostart_time $THIS_PID | sed -re "s/^ +//g" | sed -re "s/ +//g" `

# Get the age of the processess (AGE)
THIS_TS=`date --date="${THIS_START}" "+%s"`
NOW=`date "+%s"`
let "THIS_AGE = $NOW-$THIS_TS"

# see if it's older than we want
if [ "$THIS_AGE" -gt "$CMDMAXAGE" ]; then
RETURN_PID_LIST="$RETURN_PID_LIST $THIS_PID"
fi

done

if [ -n "$RETURN_PID_LIST" ]; then
echo $RETURN_PID_LIST
fi

exit 0


