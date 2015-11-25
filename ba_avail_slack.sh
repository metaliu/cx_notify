#!/bin/bash
#finds Cathay Pacific availability using BA.com
#example: CX0846 12 22 2015 HKG JFK 2 F
set -e

. config.txt

function getColIndexForClass()
{
    case $1 in
        F) echo 4
            ;;
        J) echo 3
            ;;
        *) echo $1 is unknown class && exit
    esac
}

flight=$1
month=$2
day=$3
year=$4
origin=$5
originstr=$origin
dest=$6
deststr=$dest
seat_count=$7
class=$8
class_col_idx=`getColIndexForClass $class`
wait=true

while [ 1 ]
do
    echo -n "$(date) Searching on ${flight} ${origin}->${dest} ${month}/${day}/${year} for $seat_count $class class seats... "
    rm -f jar.txt
    rm -f tmp.html
    . curls.sh login $user $pass
    [ $wait = true ] && sleep $(( ( RANDOM % 15 )  + 5 ))
    . curls.sh search
    [ $wait = true ] && sleep $(( ( RANDOM % 15 )  + 5 ))
    . curls.sh flightsearch $month $day $year $originstr $deststr $seat_count
    [ $wait = true ] && sleep $(( ( RANDOM % 15 )  + 5 ))
    . curls.sh nonstop $month $day $year $originstr $deststr

    IFS=$'\n' 
    for flightline in `html2text -ascii -nobs tmp.html | egrep -o "CX[0-9]+.*$" | grep "Only"`
    do
        flightline=`echo $flightline | tr -s " " | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'`
        #     Flight Prem_Economy_Avail Business_Avail First_Avail
        #e.g. CX0846 Only_2 Not Not
        words=`echo $flightline | wc -w | sed -e 's/^[[:space:]]*//'`
        num_words_with_flight_available=4
        if [[ $words -ne $num_words_with_flight_available ]]; then
            continue
        fi
        current_flight=`echo $flightline | awk '{ print $1 }'`
        if [[ ( ${current_flight} = ${flight}) || $flight = '*' ]]; then
            echo -n "$current_flight found ... "
            availability=$(echo $flightline | cut -d ' ' -f ${class_col_idx} )
            #depending on class we want, gets the apropriate column, e.g. 'Not' or 'Only_2'

            seats=`echo ${availability: -1}`
            #gets the last char, e.g. 't' or '2'

            re='^[0-9]+$'
            if [[ $seats =~ $re ]] ; then
                if [[ $seats -ge $seat_count ]]; then
                    message="${current_flight} ${origin}->${dest} ${month}/${day}/${year} $class class available [${flightline}]"
                    echo -n "Available! Sending notification [${message}]"
                    message=`python -c "import sys, urllib as ul; print ul.quote_plus(\"${message}\")"`
                    curl -s -S -o /dev/null "https://slack.com/api/chat.postMessage?token=${slack_token}&channel=${slack_user_id}&text=${message}&username=Billy%20CX%20Notifier&pretty=1"
                    exit
                else
                    echo -n "only $seats found, need $seat_count"
                fi
            elif [[ "$seats" = "t" ]]; then
                echo -n "not available, "
            else
                echo -n "parse error on [$flightline]"
            fi
        fi
    done

    rnd_secs=$(( ( RANDOM % 300 )  + 1 ))
    sleep_secs=$((3600 + $rnd_secs))
    echo "waiting $sleep_secs secs to check again"
    sleep $sleep_secs
done
