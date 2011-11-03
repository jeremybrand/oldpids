#!/bin/sh

# Prints a list of PIDs based on process name that are
# older than a required number of seconds.
#
# Written by: Jeremy Brand <jeremy@nirvani.net> 
#             http://www.nirvani.net/
# Requires: GNU ps,grep,sed,date
#
# Version: 0.8
# 
# Bugs or features?
# The list of PIDs is for the user $USER, which is
# typically set in the environment.
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
#     - public release

exit_error()
{
  echo "Usage: $0 PROCESS_NAME OLDER_THAN" 1>&2
  echo "Prints a list of pids, space separated, that are "
  echo "  older than OLDER_THAN seconds." 1>&2
  echo "Returns: 1 on missing args."
  echo "  0 on success, even if success has no pids in the list."
  echo "Example: $0 php 259200" 1>&2
  exit 1;
}

if [ -z "$2" ]; then
  exit_error
fi

if [ "$2" -lt 1 ]; then
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


