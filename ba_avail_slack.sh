#!/bin/bash
#finds Cathay Pacific availability using BA.com
#example: CX0846 12 22 2015 HKG JFK 2 F
set -e

# go here to get a token: https://api.slack.com/web
slack_token=xoxp-9371305061-9961028053-14884067844-6719d616c1
#go here to find your slack user id https://api.slack.com/methods/users.list/test
slack_user_id=U09U90U1K

#BA user and password
user=97679935
pass=Ooth7ohn

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
    echo -n "$(date) Searching on ${flight} ${origin}->${dest} ${month}/${day}/${year} for $seat_count first class seats... "
    rm -f jar.txt
    rm -f tmp.html
    #login
    curl -o tmp.html -s -S -L -c jar.txt -b jar.txt "https://www.britishairways.com/travel/loginr/public/en_us?eId=109001" -H "Cookie: v1st=B073499F3A591A55; BA_COUNTRY_CHOICE_COOKIE=US; BIGipServerba.com-livesite.ba.com-port80=3413812899.20480.0000; BA_SITE_PREF=full; BIGipServerba.com-livesite.ba.com-port81=3413812899.20736.0000; RSR_RESULTS=empty; BIGipServersolr-live.baplc.com-80=595109539.20480.0000; BIGipServersolr-live.baplc.com-81=595109539.20736.0000; __gads=ID=61adff4ee5bb67fe:T=1415762400:S=ALNI_MY1CaKVC9MqFzM9nYlcWqdDeftFPw; BAAUTHKEY=BA1308C5482Z; ZSESSIONID=ylnwJHHJZhkyGGxSfM25TQTXCyszZDf3pmTPbLfggwrjm3TRTsv2!1261696417!-1062728933!9101!-1; ESLTM=2689640640.23296.0000; TS0117500e=01af6716624d3677a4e17416ebebc9c70962860e0d3512980c2d349dde7e091ada26a2026cd40aa6bf4656d7908bcdabae29b262b0c31792916e7410f7199f3fcebde504ff; BIGipServerba.com-port80=746104483.20480.0000; BIGipServerba.com-port81=746104483.20736.0000; AkamaiA=AkamaiA; AkamaiB=AkamaiB; ACCOUNT_TYPE_LIFT=0; __atssc=google"%"3B5; LGP=1/:&'()*+,-./01@EGCGDGINJJLSOVWQQUSHWfW]aaadecbRSTUekehnjrls; JSESSIONID=A3C55F083BC094001F1B66A030B97E7C.iwprd-lsds-live-right2; Allow_BA_Cookies=accepted; BASessionB=GMB0JDvTXpyMBSh0SwZ2yFRhR1P22VG7fJJ7Yydy5ncKcpP7S3GT!-1132030978!clx43al01-wl01.baplc.com!7003!-1!307179702!clx43an01-wl01.baplc.com!7003!-1; __utmt=1; HOME_AD_DISPLAY=1; previousCountryInfo=us; opHardCodedNameOld=functional/mytravelspace/yourprofile/cont_profile_welcome.jsp; opHardCodedNameNew=functional/home/home_us.jsp; op1668http___www_britishai_21gum=a0020020022b1og00i1fs72b1of00r1ec4c3e; op1668http___www_britishai_21liid=a0020020022b1og00i1fs72b1of00r1ec4c3e; opLoginType=public; depDate=12/22/15; FO_DESTINATION_COOKIE=JFK"%"7C1450760400"%"7C"%"7COWFLT"%"7CF"%"7CLOWEST; AKSB=s=1422075528738&r=https"%"3A//www.britishairways.com/travel/home/public/en_us; __ytrksn=GBXT7GU564J2LPL5EMRX; __ytrkid=ZLFJ9QFAA6DWXU6MUFH5; __ytrkHadUnloadEvent=true; __atuvc=9"%"7C51"%"2C8"%"7C0"%"2C76"%"7C1"%"2C26"%"7C2"%"2C13"%"7C3; __atuvs=54c318435707440e005; tmseen=1; __utma=28787695.1891873637.1395638170.1422068529.1422071867.75; __utmb=28787695.27.10.1422071867; __utmc=28787695; __utmz=28787695.1421640930.72.5.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not"%"20provided); fsr.s="%"7B"%"22v1"%"22"%"3A-2"%"2C"%"22v2"%"22"%"3A-2"%"2C"%"22rid"%"22"%"3A"%"22d445cf3-83496544-6c3a-91e0-e69ba"%"22"%"2C"%"22to"%"22"%"3A4.1"%"2C"%"22c"%"22"%"3A"%"22https"%"3A"%"2F"%"2Fwww.britishairways.com"%"2Ftravel"%"2Fredeem"%"2Fexecclub"%"2F_gf"%"2Fen_us"%"22"%"2C"%"22pv"%"22"%"3A1732"%"2C"%"22lc"%"22"%"3A"%"7B"%"22d0"%"22"%"3A"%"7B"%"22v"%"22"%"3A1732"%"2C"%"22s"%"22"%"3Atrue"%"7D"%"7D"%"2C"%"22cd"%"22"%"3A0"%"2C"%"22cp"%"22"%"3A"%"7B"%"22AdobeID"%"22"%"3A"%"22B073499F3A591A55"%"22"%"7D"%"2C"%"22f"%"22"%"3A1422075537234"%"2C"%"22sd"%"22"%"3A0"%"7D" -H "Origin: https://www.britishairways.com" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: https://www.britishairways.com/travel/redeem/execclub/_gf/en_us?eId=106019&tab_selected=redeem&redemption_type=STD_RED" -H "Connection: keep-alive" --data "Directional_Login="%"2Ftravel"%"2Fredeem"%"2Fexecclub"%"2F_gf"%"2Fen_us"%"3FeId"%"3D106019"%"26tab_selected"%"3Dredeem"%"26redemption_type"%"3DSTD_RED&membershipNumber=${user}&password=${pass}&loginButton=1" --compressed
    [ $wait = true ] && sleep $(( ( RANDOM % 15 )  + 5 ))
    #search award flight
    curl -o tmp.html -s -S -L -c jar.txt -b jar.txt "https://www.britishairways.com/travel/redeem/execclub/_gf/en_us?eId=106019&tab_selected=redeem&redemption_type=STD_RED" -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Referer: https://www.britishairways.com/travel/redeem/execclub/_gf/en_us?eId=106019&tab_selected=redeem&redemption_type=STD_RED" -H "Connection: keep-alive" -H "Cache-Control: max-age=0" --compressed
    #flight search
    [ $wait = true ] && sleep $(( ( RANDOM % 15 )  + 5 ))
    curl -o tmp.html -s -S -L -c jar.txt -b jar.txt "https://www.britishairways.com/travel/redeem/execclub/_gf/en_us" -H "Origin: https://www.britishairways.com" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: https://www.britishairways.com/travel/redeem/execclub/_gf/en_us?eId=106019&tab_selected=redeem&redemption_type=STD_RED" -H "Connection: keep-alive" --data "eId=100002&pageid=PLANREDEMPTIONJOURNEY&tab_selected=redeem&redemption_type=STD_RED&upgradeOutbound=true&WebApplicationID=BOD&Output=&hdnAgencyCode=&departurePoint=${originstr}&destinationPoint=${deststr}&departInputDate=${month}"%"2F${day}"%"2F${year}&oneWay=true&CabinCode=F&RestrictionType=Restricted&NumberOfAdults=${seat_count}&NumberOfChildren=0&NumberOfInfants=0&submit=Get+flights" --compressed
    curl -o tmp.html -s -S -L -c jar.txt -b jar.txt "https://www.britishairways.com/travel/redeem/execclub/_gf/en_us"  -H "Origin: https://www.britishairways.com" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: https://www.britishairways.com/travel/redeem/execclub/_gf/en_us" -H "Connection: keep-alive" --data "eId=111011" --compressed
    [ $wait = true ] && sleep $(( ( RANDOM % 15 )  + 5 ))
    #nonstop
    curl -o tmp.html -s -S -L -c jar.txt -b jar.txt "https://www.britishairways.com/travel/redeem/execclub/_gf/en_us?eId=100028" -H "Origin: https://www.britishairways.com" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: https://www.britishairways.com/travel/redeem/execclub/_gf/en_us" -H "Connection: keep-alive" --data "stopoverOptions=No&display=Continue&departurePoint=${origin}&destinationPoint=${dest}&tab_selected=redeem&upgradeType=null&departInputDate=${month}"%"2F${day}"%"2F${year}&departureStopoverPoint=&stopOverDepartInputDate=" --compressed
    curl -o tmp.html -s -S -L -c jar.txt -b jar.txt "https://www.britishairways.com/travel/redeem/execclub/_gf/en_us"  -H "Origin: https://www.britishairways.com" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: https://www.britishairways.com/travel/redeem/execclub/_gf/en_us?eId=100028" -H "Connection: keep-alive" --data "eId=111011" --compressed

    flightline=`html2text -ascii -nobs tmp.html | egrep -o " ${flight}.*$" | tr -s " " | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'`
    #     Flight Prem_Economy_Avail Business_Avail First_Avail
    #e.g. CX0846 Only_2 Not Not

    availability=$(echo $flightline | cut -d ' ' -f ${class_col_idx} )
    #depending on class we want, gets the apropriate column, e.g. 'Not' or 'Only_2'

    seats=`echo ${availability: -1}`
    #gets the last char, e.g. 't' or '2'

    re='^[0-9]+$'
    if [[ $seats =~ $re ]] ; then
        if [[ $seats -ge $seat_count ]]; then
            message="${flight} ${origin}->${dest} ${month}/${day}/${year} $class class available [${flightline}]"
            echo -n "Available! Sending notification [${message}]"
            message=`python -c "import sys, urllib as ul; print ul.quote_plus(\"${message}\")"`
            curl -s -S -o /dev/null "https://slack.com/api/chat.postMessage?token=${slack_token}&channel=${slack_user_id}&text=${message}&username=Billy%20CX%20Notifier&pretty=1"
            exit
        else
            echo -n "only $seats found, need $seat_count"
        fi
    fi

    if [[ "$seats" = "t" ]]; then
        echo -n "Not available, "
    elif [[ "$availability" = "" ]]; then
        echo -n "Flight not found, "
    else
        echo -n "Parse error on [$flightline]"
    fi

    rnd_secs=$(( ( RANDOM % 300 )  + 1 ))
    sleep_secs=$((3600 + $rnd_secs))
    echo "waiting $sleep_secs secs to check again"
    sleep $sleep_secs
done
